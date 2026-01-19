from llm_module.schema import LEASE_CONTRACT_SCHEMA
import re
import copy


def analyze_contract_locally(contract_text):
    """
    Rule-based contract analysis (safe, non-hallucinating)
    """

    result = copy.deepcopy(LEASE_CONTRACT_SCHEMA)
    text = contract_text.lower()

    # ---------------- VEHICLE DETAILS ----------------

    vin_match = re.search(
        r'(vehicle identification number\s*\(vin\)|vin)\s*[:\-]?\s*([a-z0-9]{15,20})',
        text,
        re.IGNORECASE
    )
    if vin_match:
        result["vehicle_details"]["vin"]["value"] = vin_match.group(2).upper()

    brand_match = re.search(r'make\s*[:\-]\s*([a-zA-Z]+)', text)
    if brand_match:
        result["vehicle_details"]["brand"]["value"] = brand_match.group(1).title()

    model_match = re.search(r'model\s*[:\-]\s*([a-zA-Z0-9]+)', text)
    if model_match:
        result["vehicle_details"]["model"]["value"] = model_match.group(1).upper()

    year_match = re.search(r'\b(20\d{2})\b', text)
    if year_match:
        result["vehicle_details"]["year"]["value"] = year_match.group(1)

    # ---------------- LEASE TERMS ----------------

    duration_match = re.search(r'(\d+)\s+months', text)
    if duration_match:
        result["lease_terms"]["lease_duration_months"]["value"] = duration_match.group(1)

    payment_match = re.search(r'(₹|\$)\s?([\d,]+)', contract_text)
    if payment_match:
        result["lease_terms"]["monthly_payment"]["value"] = (
            payment_match.group(1) + payment_match.group(2)
        )

    deposit_match = re.search(r'security deposit\s*[:\-]?\s*(₹|\$)?([\d,]+)', text)
    if deposit_match:
        result["lease_terms"]["security_deposit"]["value"] = (
            (deposit_match.group(1) or "$") + deposit_match.group(2)
        )

   # ---------------- RISK FLAGS ----------------

    # Generic risk if contract has obligations
    if "agree" in text or "shall" in text:
        result["risk_flags"].append(
            "The contract contains binding obligations that may create legal responsibility."
        )

    # Termination risk
    if "terminate" in text or "termination" in text:
        result["risk_flags"].append(
            "Early termination clause detected. Ending the contract early may result in penalties."
        )

    # Payment risk
    if "penalty" in text or "fine" in text or "fee" in text:
        result["risk_flags"].append(
            "Financial penalties may apply under certain conditions."
        )


    # ---------------- MISSING CLAUSES ----------------

    if not result["lease_terms"]["monthly_payment"]["value"]:
        result["missing_or_unclear_clauses"].append(
            "Monthly payment amount is not explicitly mentioned."
        )

    if not result["lease_terms"]["lease_duration_months"]["value"]:
        result["missing_or_unclear_clauses"].append(
            "Lease duration is not clearly specified."
        )

    if not result["lease_terms"]["security_deposit"]["value"]:
        result["missing_or_unclear_clauses"].append(
            "Security deposit information is missing from the contract."
        )

    return result

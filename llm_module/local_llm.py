from llm_module.schema import LEASE_CONTRACT_SCHEMA
import re
import copy


def analyze_contract_locally(contract_text):
    """
    Simulates LLM-based contract analysis using rule-based extraction.
    Returns structured JSON following the predefined schema.
    """

    result = copy.deepcopy(LEASE_CONTRACT_SCHEMA)

    text = contract_text.lower()

    # --- Vehicle details ---
    vin_match = re.search(r'vin[:\s]+([a-z0-9]+)', text)
    if vin_match:
        result["vehicle_details"]["vin"]["value"] = vin_match.group(1)

    # --- Lease duration ---
    duration_match = re.search(r'(\d+)\s+months', text)
    if duration_match:
        result["lease_terms"]["lease_duration_months"]["value"] = duration_match.group(1)

    # --- Monthly payment ---
    payment_match = re.search(r'₹\s?([\d,]+)', contract_text)
    if payment_match:
        result["lease_terms"]["monthly_payment"]["value"] = "₹" + payment_match.group(1)

    # --- Risk flags ---
    if "early termination" in text:
        result["risk_flags"].append(
            "Early termination may involve additional charges."
        )

    if not result["lease_terms"]["monthly_payment"]["value"]:
        result["missing_or_unclear_clauses"].append(
            "Monthly payment amount not clearly specified."
        )

    return result

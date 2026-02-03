from llm_module.schema import LEASE_CONTRACT_SCHEMA
import re
import copy


def analyze_contract_locally(contract_text):
    """
    Rule-based contract analysis (NO hallucination).
    Extracts values only if found in document.
    """
    text = contract_text.lower()
    text = re.sub(r'\s+', ' ', text)  # removes line breaks and extra spaces
    result = copy.deepcopy(LEASE_CONTRACT_SCHEMA)
    text = contract_text.lower()

    # ---------------- VEHICLE DETAILS ----------------

    # VIN
    vin_match = re.search(
    r'(vehicle identification number.*?vin)?\s*[:\-]?\s*([A-HJ-NPR-Z0-9]{17})',
    contract_text,
    re.IGNORECASE | re.DOTALL
    )

    if vin_match:
        result["vehicle_details"]["vin"]["value"] = vin_match.group(2)

    # ---------------- BRAND ----------------
    brand_match = re.search(
        r'(car\s*make|make)\s*[:\-]?\s*([a-zA-Z]+)',
        text
    )

    if brand_match:
        result["vehicle_details"]["brand"]["value"] = brand_match.group(2).title()


    # ---------------- MODEL ----------------
    model_match = re.search(
        r'(car\s*model|model)\s*[:\-]?\s*([a-zA-Z0-9 ]+)',
        text
    )

    if model_match:
        result["vehicle_details"]["model"]["value"] = model_match.group(2).strip()


    # Year
    year_match = re.search(r'year\s*[:\-]?\s*(20\d{2})', text)

    if year_match:
        result["vehicle_details"]["year"]["value"] = year_match.group(1)


    # ---------------- LEASE TERMS ----------------

    # Monthly payment
    payment = re.search(r'(₹|\$)\s?([\d,]+)', contract_text)
    if payment:
        result["lease_terms"]["monthly_payment"]["value"] = payment.group(1) + payment.group(2)

    # Lease duration
    duration = re.search(r'(\d+)\s+months', text)
    if duration:
        result["lease_terms"]["lease_duration_months"]["value"] = duration.group(1)

    # Security deposit
    deposit = re.search(r'security deposit\s*[:\-]?\s*(₹|\$)?([\d,]+)', text)
    if deposit:
        result["lease_terms"]["security_deposit"]["value"] = deposit.group(1) + deposit.group(2)

    # ---------------- MILEAGE ----------------

    mileage = re.search(r'(\d{1,3},?\d{3})\s*(km|miles)\s*per\s*year', text)
    if mileage:
        result["mileage_terms"]["annual_mileage_limit"]["value"] = mileage.group(1) + " " + mileage.group(2)

    excess = re.search(r'excess mileage.*?(₹|\$)\s?([\d.]+)', text)
    if excess:
        result["mileage_terms"]["excess_mileage_fee"]["value"] = excess.group(1) + excess.group(2)

    # ---------------- PENALTIES ----------------

    late_fee = re.search(r'late payment.*?(₹|\$)\s?([\d,]+)', text)
    if late_fee:
        result["penalties_and_fees"]["late_payment_fee"]["value"] = late_fee.group(1) + late_fee.group(2)

    termination = re.search(r'early termination.*?(₹|\$)\s?([\d,]+)', text)
    if termination:
        result["penalties_and_fees"]["early_termination_fee"]["value"] = termination.group(1) + termination.group(2)

    # ---------------- BUYOUT ----------------

    buyout = re.search(r'buyout.*?(₹|\$)\s?([\d,]+)', text)
    if buyout:
        result["purchase_option"]["buyout_available"]["value"] = "Yes"
        result["purchase_option"]["buyout_price"]["value"] = buyout.group(1) + buyout.group(2)

    # ---------------- RISK FLAGS ----------------

    if "early termination" in text:
        result["risk_flags"].append(
            "Early termination may involve financial penalties."
        )

    if "late fee" in text or "penalty" in text:
        result["risk_flags"].append(
            "Late payment penalties apply if dues are delayed."
        )

    if "insurance" not in text:
        result["risk_flags"].append(
            "Insurance responsibility not clearly mentioned."
        )

    # ---------------- MISSING FIELDS ----------------

    for section in ["lease_terms", "mileage_terms", "penalties_and_fees"]:
        for key in result[section]:
            if result[section][key]["value"] == "":
                result["missing_or_unclear_clauses"].append(
                    f"{key.replace('_', ' ').title()} not specified in contract."
                )

    return result

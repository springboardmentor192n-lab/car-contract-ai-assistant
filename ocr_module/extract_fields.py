import re

def extract_fields(text):
    result = {
        "vehicle_details": {
            "vin": {"value": "", "explanation": "Unique vehicle identification number."},
            "brand": {"value": "", "explanation": "Manufacturer of the vehicle."},
            "model": {"value": "", "explanation": "Specific model name of the vehicle."},
            "year": {"value": "", "explanation": "Manufacturing year of the vehicle."}
        },
        "lease_terms": {
            "monthly_payment": {
                "value": "",
                "explanation": "Monthly amount paid for the lease."
            },
            "lease_duration": {
                "value": "",
                "explanation": "Total duration of the lease in months."
            },
            "security_deposit": {
                "value": "",
                "explanation": "Amount paid upfront as security."
            }
        }
    }

    # VIN
    vin_match = re.search(
        r'(vehicle identification number\s*\(vin\)|vin)\s*[:\-]?\s*([A-Z0-9]{15,20})',
        text,
        re.IGNORECASE
    )
    if vin_match:
        result["vehicle_details"]["vin"]["value"] = vin_match.group(2)

    # Brand
    brand = re.search(r'make\s*[:\-]\s*([a-zA-Z]+)', text, re.I)
    if brand:
        result["vehicle_details"]["brand"]["value"] = brand.group(1).title()

    # Model
    model = re.search(r'model\s*[:\-]\s*([a-zA-Z0-9]+)', text, re.I)
    if model:
        result["vehicle_details"]["model"]["value"] = model.group(1).upper()

    # Year
    year = re.search(r'\b(20\d{2})\b', text)
    if year:
        result["vehicle_details"]["year"]["value"] = year.group(1)

    # Monthly payment
    payment = re.search(r'monthly\s+payment\s*[:\-]?\s*\$?([\d,]+)', text, re.I)
    if payment:
        result["lease_terms"]["monthly_payment"]["value"] = "$" + payment.group(1)

    # Lease duration
    duration = re.search(r'(\d+)\s+months', text, re.I)
    if duration:
        result["lease_terms"]["lease_duration"]["value"] = duration.group(1) + " months"

    # Security deposit
    deposit = re.search(r'security deposit\s*[:\-]?\s*\$?([\d,]+)', text, re.I)
    if deposit:
        result["lease_terms"]["security_deposit"]["value"] = "$" + deposit.group(1)

    return result

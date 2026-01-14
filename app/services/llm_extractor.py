# app/services/llm_extractor.py
def build_extraction_prompt(contract_text: str) -> str:
    """
    Prompt to extract SLA fields from a car lease contract.
    """
    return f"""
You are an expert automotive contract analysis assistant.

Your task is to extract structured information from a car lease agreement.

INSTRUCTIONS:
- Extract ONLY the fields defined in the JSON schema below.
- If a field is not present, leave its value as an empty string.
- Do NOT guess or infer missing information.
- Return ONLY valid JSON.
- Do NOT include explanations or extra text.

JSON SCHEMA:
{SLA_SCHEMA}

CAR LEASE CONTRACT TEXT:
{contract_text}
"""

SLA_SCHEMA = {
    "interest_rate_apr": {"value": "", "notes": ""},
    "lease_term_duration": {"value": "", "unit": "months"},
    "monthly_payment": {"value": "", "currency": ""},
    "down_payment": {"value": "", "currency": ""},
    "residual_value": {"value": "", "currency": ""},
    "mileage_allowance": {
        "allowed_miles_per_year": "",
        "overage_charge_per_mile": ""
    },
    "early_termination_clause": {
        "summary": "",
        "penalty_details": ""
    },
    "purchase_option_buyout_price": {"value": "", "currency": ""},
    "maintenance_responsibilities": {"summary": ""},
    "warranty_and_insurance_coverage": {"summary": ""},
    "penalties_or_late_fees": {"summary": ""}
}

def call_llm(prompt: str) -> str:
    """
    Calls an LLM with the given prompt.
    """
    raise NotImplementedError("LLM integration not implemented yet")


def parse_llm_response(response_text: str) -> dict:
    try:
        return json.loads(response_text)
    except json.JSONDecodeError:
        raise ValueError("Invalid JSON returned by LLM")


def extract_contract_sla(cleaned_text: str) -> dict:
    prompt = build_extraction_prompt(cleaned_text)
    llm_response = call_llm(prompt)
    return parse_llm_response(llm_response)
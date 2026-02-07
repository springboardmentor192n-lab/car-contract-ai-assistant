# app/services/llm_extractor.py

print("✅ LOADED llm_extractor.py FROM:", __file__)

import json
import requests
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "llama3.2"

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


def build_extraction_prompt(contract_text: str) -> str:
    return f"""
You are an expert automotive contract analysis assistant.

Extract structured information from the car lease contract below.

STRICT RULES:
- Return ONLY valid JSON
- Follow the schema exactly
- Do NOT hallucinate
- Leave missing values as empty strings
- Do NOT add explanations

JSON SCHEMA:
{json.dumps(SLA_SCHEMA, indent=2)}

CAR LEASE CONTRACT TEXT:
{contract_text}
"""


def call_llm(prompt: str) -> str:
    payload = {
        "model": MODEL_NAME,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": 0,
            "num_predict": 1200
        }
    }

    response = requests.post(OLLAMA_URL, json=payload, timeout=180)
    response.raise_for_status()

    return response.json()["response"]


def parse_llm_response(response_text: str) -> dict:
    try:
        return json.loads(response_text)
    except json.JSONDecodeError:
        raise ValueError("Invalid JSON returned by LLM")


def extract_contract_sla(cleaned_text: str) -> dict:
    prompt = build_extraction_prompt(cleaned_text)
    llm_response = call_llm(prompt)
    return parse_llm_response(llm_response)


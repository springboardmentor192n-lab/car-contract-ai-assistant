"""
LLM Module - Uses Google Gemini API to analyze contract text.
Extracts key terms and assigns a simple risk level (Low / Medium / High).
"""

import json
import google.generativeai as genai
import os

# Gemini model name
# NOTE:
#   - Older models like "gemini-pro" are now deprecated / unavailable
#     for many new API keys, which caused the 404 error you saw.
#   - "gemini-2.5-flash" is a fast, up‑to‑date text model that works
#     well for this type of contract analysis.
MODEL_NAME = "gemini-2.5-flash"


def setup_gemini(api_key: str):
    """
    Configure the Gemini API with your API key.
    Call this once before using analyze_contract.
    """
    genai.configure(api_key=api_key)


def analyze_contract(ocr_text: str) -> dict:
    """
    Send the OCR text to Gemini and get structured contract details
    plus a simple, rule-based contract fairness score.

    Returns a dictionary with:
      - contract_details: agreement type, monthly payment, APR, duration, etc.
      - fairness_score: 0–100 (higher = more risk / less fair to customer)
      - risk_level: "Low", "Medium", or "High" (based on fairness_score)
      - risk_notes: short explanation for the risk level
    """
    if not ocr_text or not ocr_text.strip():
        return {
            "contract_details": {"error": "No text was extracted from the document."},
            "risk_level": "High",
            "risk_notes": "Cannot analyze empty text.",
        }

    # Prompt that tells Gemini what to extract and how to format the answer
    prompt = """You are a contract analyst. Analyze the following car lease or loan contract text and extract key information.

Contract text:
---
{text}
---

Provide your response in this exact JSON format (no extra text before or after the JSON):
{{
  "agreement_type": "Lease or Loan",
  "monthly_payment": "amount or N/A",
  "interest_rate_apr": "percentage or N/A",
  "lease_loan_duration": "e.g. 36 months",
  "mileage_limit": "e.g. 12000 miles/year or N/A",
  "penalties": "brief description or N/A",
  "early_termination_clause": "brief description or N/A"
}}

Reply with ONLY the JSON object, nothing else."""

    try:
        model = genai.GenerativeModel(MODEL_NAME)
        response = model.generate_content(prompt.format(text=ocr_text[:30000]))
        response_text = response.text.strip()

        # Remove markdown code blocks if Gemini wrapped the JSON
        if response_text.startswith("```"):
            lines = response_text.split("\n")
            if lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].strip() == "```":
                lines = lines[:-1]
            response_text = "\n".join(lines)

        # Parse the JSON response into a Python dict
        contract_details = json.loads(response_text)
    except Exception as e:
        contract_details = {
            "error": f"Gemini analysis failed: {str(e)}",
        }

    # Rule-based contract fairness score + risk label
    fairness_score, risk_level, risk_notes = get_fairness_score(contract_details)
    return {
        "contract_details": contract_details,
        "fairness_score": fairness_score,
        "risk_level": risk_level,
        "risk_notes": risk_notes,
    }


def get_fairness_score(details: dict) -> tuple:
    """
    Contract Fairness Score (0–100) with rule-based weights:

    - High APR           -> +20 risk
    - Early termination fee -> +20 risk
    - Mileage cap           -> +10 risk
    - Excess mileage fee    -> +10 risk
    - Customer-paid maintenance -> +10 risk

    Final score (0–100) is mapped to a label:
      0–30   -> Low risk
      31–60  -> Medium risk
      61–100 -> High risk
    """
    # If we don't have details, treat as high risk
    if not details or "error" in details:
        return 100, "High", "Analysis could not be completed."

    score = 0
    reasons = []

    # --- 1) High APR (interest_rate_apr) ---
    apr = details.get("interest_rate_apr", "")
    if apr and isinstance(apr, str):
        try:
            # Extract number from strings like "15.5%" or "15.5 APR"
            num = float("".join(c for c in apr if c.isdigit() or c == "."))
            # You can tune this threshold later if needed
            if num > 15:
                score += 20
                reasons.append(f"High APR detected (~{num}%).")
        except ValueError:
            # If we can't read the APR, skip this rule
            pass

    # --- 2) Early termination fee ---
    term = str(details.get("early_termination_clause", "")).lower()
    if term and "n/a" not in term:
        # Look for words that suggest a fee or charge
        if "fee" in term or "charge" in term or "penalty" in term:
            score += 20
            reasons.append("Early termination fee or penalty mentioned.")

    # --- 3) Mileage cap ---
    mileage = str(details.get("mileage_limit", "")).lower()
    if mileage and "n/a" not in mileage and "unlimited" not in mileage:
        score += 10
        reasons.append("Mileage cap / limit is present.")

    # --- 4) Excess mileage fee ---
    # We check both mileage_limit and penalties text for typical wording
    penalties = str(details.get("penalties", "")).lower()
    combined_mileage_text = mileage + " " + penalties
    if any(
        phrase in combined_mileage_text
        for phrase in ["excess mileage", "over mileage", "per mile", "per km", "per kilometer"]
    ):
        score += 10
        reasons.append("Excess mileage fee or per‑mile charge mentioned.")

    # --- 5) Customer-paid maintenance ---
    # Very simple rule: if penalties mention maintenance / service / repairs,
    # we treat it as customer responsibility.
    if any(word in penalties for word in ["maintenance", "servicing", "service", "repairs"]):
        score += 10
        reasons.append("Customer appears responsible for maintenance/repairs.")

    # Cap score at 100 just in case
    score = min(score, 100)

    # --- Convert score to risk label ---
    if score <= 30:
        level = "Low"
    elif score <= 60:
        level = "Medium"
    else:
        level = "High"

    # Build a friendly explanation
    if reasons:
        notes = " ".join(reasons)
    else:
        notes = "No strong risk indicators found in APR, mileage, or maintenance terms."

    return score, level, notes

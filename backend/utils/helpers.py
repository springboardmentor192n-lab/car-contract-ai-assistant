import re
from typing import Dict, Any, List
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

VIN_REGEX = re.compile(r"^[A-HJ-NPR-Z0-9]{17}$")

def extract_financial_terms(text: str) -> Dict[str, Any]:
    patterns = {
        "apr": r"(APR|Annual Percentage Rate)\s*[:\-]?\s*(\d{1,2}\.\d{1,4})",
        "monthly_payment": r"(Monthly Payment|Monthly Rent)\s*[:\-]?\s*\$?(\d+(\.\d{2})?)",
        "loan_term": r"(Term|Number of Payments)\s*[:\-]?\s*(\d{2,3})",
        "amount_financed": r"(Amount Financed)\s*[:\-]?\s*\$?([\d,]+\.\d{2})",
        "mileage_allowance": r"(Mileage Allowance|Annual Mileage)\s*[:\-]?\s*([\d,]+)",
        "penalties": r"(penalty|penalties|late fee|default fee)\s*(\$?[\d,]+\.?\d{0,2})?",
        "early_termination": r"(early termination fee|termination fee|buyout fee)\s*(\$?[\d,]+\.?\d{0,2})?",
        "hidden_fees": r"(administrative fee|processing fee|documentation fee|dealer prep)\s*(\$?[\d,]+\.?\d{0,2})?",
        "warranty_exclusions": r"(warranty exclusion|warranty limitations|no warranty|as-is)",
    }

    found = {}
    for key, pattern in patterns.items():
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            found[key] = match.group(0).strip() # Capture the whole matched phrase for specific clauses
            # For numerical terms, you might want to extract just the number
            if key in ["apr", "monthly_payment", "loan_term", "amount_financed", "mileage_allowance"]:
                 num_match = re.search(r"(\d+(\.\d{2})?|[\d,]+\.\d{2}|\d{1,2}\.\d{1,4})", match.group(0))
                 if num_match:
                     found[key] = num_match.group(0)
    return found


def analyze_text_for_risks(text: str, model) -> List[str]:
    sentences = [s.strip() for s in text.split('.') if len(s.strip()) > 20]
    risky = []

    if model: # Only run sentiment analysis if model is loaded
        try:
            results = model(sentences, truncation=True, max_length=512)
            for i, r in enumerate(results):
                if r["label"] == "NEGATIVE" and r["score"] > 0.8:
                    risky.append(sentences[i])
        except Exception as e:
            logger.error(f"Sentiment analysis error: {e}")
    else:
        # Placeholder for basic keyword-based risk detection if model is not loaded
        keywords = ["penalty", "termination fee", "late payment", "hidden fee", "exclude warranty", "arbitration clause"]
        for sentence in sentences:
            if any(keyword in sentence.lower() for keyword in keywords):
                risky.append(sentence)

    return risky

def calculate_risk_score_and_level(potential_risks: List[str]) -> Dict[str, Any]:
    score = min(len(potential_risks) * 20, 100) # Simple scoring: 20 points per risk, max 100

    if score >= 80:
        level = "High"
        explanation = ["Multiple significant risky clauses identified."]
    elif score >= 40:
        level = "Medium"
        explanation = ["Some potentially risky clauses detected."]
    else:
        level = "Low"
        explanation = ["Few or no significant risky clauses detected."]

    if potential_risks:
        explanation.append("Specific risky clauses include:")
        explanation.extend(potential_risks)
    
    return {
        "risk_score": score,
        "risk_level": level,
        "risk_explanation": explanation
    }

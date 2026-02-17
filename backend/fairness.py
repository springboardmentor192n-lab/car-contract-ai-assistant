def calculate_fairness_score(clauses: dict) -> dict:
    """
    Calculate a simple fairness score for a car lease contract
    based on presence of risky clauses.

    This function is SAFE:
    - Handles missing clause categories
    - Never raises KeyError
    - Always returns a score
    """

    score = 100
    reasons = []

    # -----------------------------
    # Safely get clauses
    # -----------------------------
    interest_clauses = clauses.get("INTEREST", [])
    penalty_clauses = clauses.get("PENALTY", [])
    mileage_clauses = clauses.get("MILEAGE", [])
    term_clauses = clauses.get("TERM", [])

    # -----------------------------
    # Interest analysis
    # -----------------------------
    if len(interest_clauses) > 0:
        score -= 15
        reasons.append("Interest rate clauses detected")

    # -----------------------------
    # Penalty analysis
    # -----------------------------
    if len(penalty_clauses) > 0:
        score -= 20
        reasons.append("Penalty clauses may increase cost")

    # -----------------------------
    # Mileage analysis
    # -----------------------------
    if len(mileage_clauses) > 0:
        score -= 10
        reasons.append("Mileage limits may restrict usage")

    # -----------------------------
    # Contract term analysis
    # -----------------------------
    if len(term_clauses) > 0:
        score -= 10
        reasons.append("Long-term commitment detected")

    # -----------------------------
    # Bound score between 0–100
    # -----------------------------
    score = max(0, min(score, 100))

    # -----------------------------
    # Rating
    # -----------------------------
    if score >= 80:
        rating = "Fair"
    elif score >= 60:
        rating = "Moderately Fair"
    else:
        rating = "Unfair"

    # -----------------------------
    # Final response
    # -----------------------------
    return {
        "score": score,
        "rating": rating,
        "reasons": reasons if reasons else ["No major risk factors detected"]
    }

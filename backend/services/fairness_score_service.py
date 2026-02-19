
from schemas import ExtractedSLACreate

class FairnessScoreService:
    def calculate_score(self, sla: ExtractedSLACreate, price_analysis: dict) -> dict:
        score = 100
        breakdown = {}
        explanation_points = []
        
        # 1. APR Check
        if sla.apr:
            if sla.apr > 15:
                penalty = 20
                score -= penalty
                breakdown["APR"] = -penalty
                explanation_points.append(f"High Interest Rate ({sla.apr}%).")
            elif sla.apr > 8:
                penalty = 10
                score -= penalty
                breakdown["APR"] = -penalty
                explanation_points.append(f"Moderate Interest Rate ({sla.apr}%).")
            else:
                 breakdown["APR"] = 0
        
        # 2. Hidden Fees
        if sla.hidden_charges:
            fees_count = len(sla.hidden_charges)
            penalty = fees_count * 5
            score -= penalty
            breakdown["Hidden Fees"] = -penalty
            explanation_points.append(f"Found {fees_count} potentially hidden or junk fees.")

        # 3. Market Price
        if price_analysis.get("verdict") == "Overpriced":
            penalty = 25
            score -= penalty
            breakdown["Price"] = -penalty
            explanation_points.append("Vehicle is significantly overpriced compared to market average.")

        # 4. Early Termination
        if sla.early_termination_fee and sla.early_termination_fee > 500:
             penalty = 10
             score -= penalty
             breakdown["Termination Fee"] = -penalty
             explanation_points.append("High early termination penalty.")

        # 5. Mileage Limits (Lease)
        if sla.mileage_limit_per_year and sla.mileage_limit_per_year < 10000:
             penalty = 10
             score -= penalty
             breakdown["Mileage"] = -penalty
             explanation_points.append("Low mileage limit (under 10k/year).")

        score = max(0, score)
        
        rating = "Excellent"
        if score < 60:
            rating = "High Risk / Predatory"
        elif score < 75:
            rating = "Fair / Needs Negotiation"
        elif score < 85:
            rating = "Good"

        return {
            "score": score,
            "rating": rating,
            "breakdown": breakdown,
            "explanation": " ".join(explanation_points) if explanation_points else "Contract looks standard with no major red flags."
        }

fairness_service = FairnessScoreService()

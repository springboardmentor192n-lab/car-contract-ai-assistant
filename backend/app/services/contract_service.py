# backend/app/services/contract_service.py
import time
from typing import Dict, List
from sqlalchemy.orm import Session

# Import other services
from .document_parser import DocumentParser
from .llm_extractor import SimpleLLMExtractor, MockLLMExtractor
from .database_service import DatabaseService


class ContractService:
    """Service for handling contract analysis and storage"""

    def __init__(self, db: Session):
        self.db = db
        self.parser = DocumentParser()

    async def analyze_and_save_contract(
            self,
            user_id: str,
            session_id: str,
            file_bytes: bytes,
            filename: str
    ) -> Dict:
        """
        Analyze a contract and save results to database

        Args:
            user_id: Unique user identifier
            session_id: Session identifier
            file_bytes: Contract file bytes
            filename: Original filename

        Returns:
            Dictionary with analysis results
        """

        start_time = time.time()

        # 1. Parse the document
        parsed_data = self.parser.parse_document(file_bytes, filename)

        # 2. Extract with LLM (use mock if API key not available)
        try:
            extractor = SimpleLLMExtractor()
        except:
            # Fallback to mock extractor if OpenAI not configured
            extractor = MockLLMExtractor()

        llm_result = extractor.extract_contract_details(parsed_data["text"])

        # 3. Calculate risk score
        risk_score = self._calculate_risk_score(llm_result.get("data", {}))

        # 4. Determine risk level
        risk_level = self._get_risk_level(risk_score)

        # 5. Identify red flags
        red_flags = self._identify_red_flags(llm_result.get("data", {}))

        # 6. Generate recommendations
        recommendations = self._generate_recommendations(llm_result.get("data", {}))

        # 7. Prepare analysis results
        analysis_results = {
            "llm_extraction": llm_result,
            "risk_score": risk_score,
            "risk_level": risk_level,
            "red_flags": red_flags,
            "recommendations": recommendations,
            "analysis_duration": time.time() - start_time
        }

        # 8. Save to database
        contract = DatabaseService.save_contract(
            db=self.db,
            user_id=user_id,
            session_id=session_id,
            filename=filename,
            file_bytes=file_bytes,
            extracted_data=parsed_data,
            analysis_results=analysis_results
        )

        return {
            "contract_id": contract.id,
            "analysis": analysis_results,
            "extraction": parsed_data,
            "contract_info": {
                "id": contract.id,
                "filename": contract.original_filename,
                "upload_date": contract.upload_date.isoformat() if contract.upload_date else None,
                "risk_score": contract.risk_score,
                "risk_level": contract.risk_level
            }
        }

    def _calculate_risk_score(self, data: Dict) -> float:
        """Calculate risk score from 0-100"""
        score = 50  # Start with neutral score

        # Check interest rate
        if "interest_rate" in data:
            rate_str = str(data["interest_rate"]).replace('%', '')
            try:
                rate = float(rate_str)
                if rate > 10:
                    score += 30  # Very high risk
                elif rate > 8:
                    score += 20  # High risk
                elif rate > 6:
                    score += 10  # Medium risk
            except ValueError:
                pass  # If conversion fails, skip

        # Check monthly payment (simple heuristic)
        if "monthly_payment" in data:
            payment = data["monthly_payment"]
            if isinstance(payment, (int, float)):
                if payment > 800:
                    score += 15  # High payment
                elif payment > 500:
                    score += 8  # Medium payment

        # Check mileage limit
        if "mileage_limit_per_year" in data:
            mileage = data["mileage_limit_per_year"]
            if isinstance(mileage, (int, float)):
                if mileage < 10000:
                    score += 10  # Low mileage limit

        # Ensure score stays between 0-100
        return max(0, min(100, score))

    def _get_risk_level(self, score: float) -> str:
        """Convert risk score to level"""
        if score >= 70:
            return "high"
        elif score >= 40:
            return "medium"
        else:
            return "low"

    def _identify_red_flags(self, data: Dict) -> List[str]:
        """Identify potential red flags in contract"""
        red_flags = []

        # High interest rate
        if "interest_rate" in data:
            rate_str = str(data["interest_rate"]).replace('%', '')
            try:
                if float(rate_str) > 10:
                    red_flags.append(f"Extremely high interest rate: {data['interest_rate']}")
                elif float(rate_str) > 8:
                    red_flags.append(f"High interest rate: {data['interest_rate']}")
            except:
                pass

        # High late payment fee
        if "late_payment_fee" in data:
            fee = data["late_payment_fee"]
            if isinstance(fee, (int, float)) and fee > 50:
                red_flags.append(f"High late payment fee: ${fee}")

        # Low mileage limit
        if "mileage_limit_per_year" in data:
            mileage = data["mileage_limit_per_year"]
            if isinstance(mileage, (int, float)) and mileage < 10000:
                red_flags.append(f"Low mileage limit: {mileage} miles/year")

        # High excess mileage charge
        if "excess_mileage_charge" in data:
            charge = data["excess_mileage_charge"]
            if isinstance(charge, (int, float)) and charge > 0.30:
                red_flags.append(f"High excess mileage charge: ${charge}/mile")

        return red_flags[:5]  # Return top 5 red flags

    def _generate_recommendations(self, data: Dict) -> List[str]:
        """Generate negotiation recommendations"""
        recommendations = []

        # Interest rate recommendation
        if "interest_rate" in data:
            rate_str = str(data["interest_rate"]).replace('%', '')
            try:
                rate = float(rate_str)
                if rate > 6:
                    recommendations.append(f"Negotiate interest rate down from {rate}% to around 4-5%")
                elif rate > 4.5:
                    recommendations.append(f"Try to lower interest rate from {rate}% by 0.5-1%")
            except:
                pass

        # Payment recommendation
        if "monthly_payment" in data:
            recommendations.append("Compare monthly payment with market averages")

        # Mileage recommendation
        if "mileage_limit_per_year" in data:
            mileage = data["mileage_limit_per_year"]
            if isinstance(mileage, (int, float)):
                if mileage < 12000:
                    recommendations.append(f"Request higher mileage allowance (currently {mileage}/year)")

        # Fee recommendations
        recommendations.append("Review all fees and ask for itemized breakdown")
        recommendations.append("Negotiate to waive or reduce processing/admin fees")

        return recommendations[:5]  # Return top 5 recommendations

    def get_contract_summary(self, contract_id: int, user_id: str = None) -> Dict:
        """Get summary of a contract"""
        contract = DatabaseService.get_contract_by_id(self.db, contract_id, user_id)

        if not contract:
            return {"error": "Contract not found"}

        return {
            "id": contract.id,
            "filename": contract.original_filename,
            "upload_date": contract.upload_date.isoformat() if contract.upload_date else None,
            "risk_score": contract.risk_score,
            "risk_level": contract.risk_level,
            "is_analyzed": contract.is_analyzed,
            "quick_extraction": contract.quick_extraction,
            "has_llm_analysis": bool(contract.llm_extraction and contract.llm_extraction.get("success"))
        }
# backend/app/services/database_service.py
import hashlib
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import func

# Import models (we'll create these too)
try:
    from ..models.contract import Contract, ChatHistory, VehicleInfo
except ImportError:
    # Create simple model classes for now
    class Contract:
        def __init__(self, **kwargs):
            self.id = kwargs.get('id')
            self.user_id = kwargs.get('user_id')
            self.original_filename = kwargs.get('original_filename')
            self.risk_score = kwargs.get('risk_score')
            self.risk_level = kwargs.get('risk_level')
            self.quick_extraction = kwargs.get('quick_extraction', {})
            self.llm_extraction = kwargs.get('llm_extraction', {})
            self.upload_date = kwargs.get('upload_date')

        def to_dict(self):
            return {
                "id": self.id,
                "user_id": self.user_id,
                "original_filename": self.original_filename,
                "risk_score": self.risk_score,
                "risk_level": self.risk_level,
                "quick_extraction": self.quick_extraction,
                "llm_extraction": self.llm_extraction,
                "upload_date": self.upload_date.isoformat() if hasattr(self.upload_date, 'isoformat') else str(
                    self.upload_date)
            }


class DatabaseService:
    """Service for database operations"""

    @staticmethod
    def save_contract(
            db: Session,
            user_id: str,
            session_id: str,
            filename: str,
            file_bytes: bytes,
            extracted_data: Dict,
            analysis_results: Dict
    ) -> Contract:
        """
        Save contract to database

        Note: This is a simplified version. In production, you'd use SQLAlchemy models.
        """

        # Generate a file hash
        file_hash = hashlib.md5(file_bytes).hexdigest()

        # Create a mock contract object
        contract = Contract(
            id=hash(file_hash) % 1000000,  # Simple ID generation
            user_id=user_id,
            session_id=session_id,
            original_filename=filename,
            file_type=filename.split('.')[-1].lower() if '.' in filename else 'unknown',
            file_size=len(file_bytes),
            file_hash=file_hash,
            raw_text=extracted_data.get("text", "")[:5000],  # Limit text
            processed_text=extracted_data.get("text", "")[:3000],
            quick_extraction=extracted_data.get("extracted_fields", {}),
            llm_extraction=analysis_results.get("llm_extraction", {}),
            risk_score=analysis_results.get("risk_score", 0),
            risk_level=analysis_results.get("risk_level", "unknown"),
            red_flags=analysis_results.get("red_flags", []),
            recommendations=analysis_results.get("recommendations", []),
            is_analyzed=True,
            analysis_duration=analysis_results.get("analysis_duration", 0)
        )

        # In a real implementation, you would:
        # db.add(contract)
        # db.commit()
        # db.refresh(contract)

        print(f"📁 Contract saved: {filename} (User: {user_id})")

        return contract

    @staticmethod
    def get_contract_by_id(
            db: Session,
            contract_id: int,
            user_id: Optional[str] = None
    ) -> Optional[Contract]:
        """Get contract by ID"""
        # Mock implementation
        return Contract(
            id=contract_id,
            user_id=user_id or "demo_user",
            original_filename="sample_contract.pdf",
            risk_score=65,
            risk_level="medium",
            quick_extraction={"interest_rate": "5.9%", "monthly_payment": "450"},
            llm_extraction={"success": True, "data": {"interest_rate": "5.9%"}},
            upload_date="2024-01-30T10:30:00"
        )

    @staticmethod
    def get_user_contracts(
            db: Session,
            user_id: str,
            limit: int = 50
    ) -> List[Contract]:
        """Get all contracts for a user"""
        # Mock implementation
        return [
            Contract(
                id=1,
                user_id=user_id,
                original_filename="lease_agreement.pdf",
                risk_score=65,
                risk_level="medium",
                quick_extraction={"interest_rate": "5.9%"},
                upload_date="2024-01-30T10:30:00"
            ),
            Contract(
                id=2,
                user_id=user_id,
                original_filename="loan_contract.docx",
                risk_score=42,
                risk_level="low",
                quick_extraction={"interest_rate": "4.5%"},
                upload_date="2024-01-29T14:20:00"
            )
        ][:limit]

    @staticmethod
    def save_chat_message(
            db: Session,
            session_id: str,
            role: str,
            message: str,
            contract_id: Optional[int] = None
    ):
        """Save chat message"""
        print(f"💬 Chat saved: {role} - {message[:50]}...")
        return True

    @staticmethod
    def get_chat_history(
            db: Session,
            session_id: str,
            limit: int = 100
    ) -> List[Dict]:
        """Get chat history"""
        return [
            {"role": "user", "message": "How do I negotiate interest rate?", "timestamp": "10:30"},
            {"role": "assistant", "message": "Compare rates from multiple lenders first.", "timestamp": "10:31"}
        ]

    @staticmethod
    def save_vehicle_info(db: Session, vin: str, vehicle_data: Dict):
        """Save vehicle info"""
        print(f"🚗 Vehicle info saved: {vin}")
        return True

    @staticmethod
    def get_vehicle_info(db: Session, vin: str):
        """Get vehicle info"""
        return {
            "vin": vin,
            "make": "Toyota",
            "model": "Camry",
            "year": 2023,
            "cached": False
        }

    @staticmethod
    def get_contract_stats(db: Session, user_id: Optional[str] = None) -> Dict:
        """Get contract statistics"""
        return {
            "total_contracts": 2,
            "analyzed_contracts": 2,
            "analysis_rate": 100,
            "risk_distribution": {
                "low": 1,
                "medium": 1,
                "high": 0
            },
            "average_risk_score": 53.5
        }
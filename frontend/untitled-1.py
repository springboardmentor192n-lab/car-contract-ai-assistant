# backend/app/services/database_service.py
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.contract import Contract, ChatHistory, VehicleInfo
from datetime import datetime
from typing import Dict, List, Optional
import hashlib


class DatabaseService:

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
        """Save contract to database"""

        # Calculate file hash for deduplication
        file_hash = hashlib.md5(file_bytes).hexdigest()

        # Check if contract already exists
        existing = db.query(Contract).filter(
            Contract.file_hash == file_hash,
            Contract.user_id == user_id
        ).first()

        if existing:
            return existing

        # Create new contract record
        contract = Contract(
            user_id=user_id,
            session_id=session_id,
            original_filename=filename,
            file_type=filename.split('.')[-1].lower(),
            file_size=len(file_bytes),
            file_hash=file_hash,
            raw_text=extracted_data.get("text", "")[:10000],  # Limit text length
            processed_text=extracted_data.get("text", "")[:5000],
            quick_extraction=extracted_data.get("extracted_fields", {}),
            llm_extraction=analysis_results.get("llm_extraction", {}),
            risk_score=analysis_results.get("risk_score", 0),
            risk_level=analysis_results.get("risk_level", "unknown"),
            red_flags=analysis_results.get("red_flags", []),
            recommendations=analysis_results.get("recommendations", []),
            is_analyzed=True,
            analysis_duration=analysis_results.get("analysis_duration", 0)
        )

        db.add(contract)
        db.commit()
        db.refresh(contract)

        return contract

    @staticmethod
    def get_user_contracts(db: Session, user_id: str, limit: int = 50) -> List[Contract]:
        """Get all contracts for a user"""
        return db.query(Contract).filter(
            Contract.user_id == user_id
        ).order_by(
            Contract.created_at.desc()
        ).limit(limit).all()

    @staticmethod
    def get_contract_by_id(db: Session, contract_id: int, user_id: str = None) -> Optional[Contract]:
        """Get contract by ID"""
        query = db.query(Contract).filter(Contract.id == contract_id)
        if user_id:
            query = query.filter(Contract.user_id == user_id)
        return query.first()

    @staticmethod
    def save_chat_message(
            db: Session,
            session_id: str,
            role: str,
            message: str,
            contract_id: Optional[int] = None
    ) -> ChatHistory:
        """Save chat message to database"""

        chat = ChatHistory(
            session_id=session_id,
            contract_id=contract_id,
            role=role,
            message=message
        )

        db.add(chat)
        db.commit()
        db.refresh(chat)

        return chat

    @staticmethod
    def get_chat_history(db: Session, session_id: str, limit: int = 100) -> List[ChatHistory]:
        """Get chat history for a session"""
        return db.query(ChatHistory).filter(
            ChatHistory.session_id == session_id
        ).order_by(
            ChatHistory.timestamp.asc()
        ).limit(limit).all()

    @staticmethod
    def save_vehicle_info(db: Session, vin: str, vehicle_data: Dict) -> VehicleInfo:
        """Save or update vehicle information"""

        # Check if vehicle info already exists
        vehicle = db.query(VehicleInfo).filter(VehicleInfo.vin == vin).first()

        if vehicle:
            # Update existing record
            vehicle.make = vehicle_data.get("make")
            vehicle.model = vehicle_data.get("model")
            vehicle.year = vehicle_data.get("year")
            vehicle.body_type = vehicle_data.get("body_type")
            vehicle.recall_count = vehicle_data.get("recall_count", 0)
        else:
            # Create new record
            vehicle = VehicleInfo(
                vin=vin,
                make=vehicle_data.get("make"),
                model=vehicle_data.get("model"),
                year=vehicle_data.get("year"),
                body_type=vehicle_data.get("body_type"),
                recall_count=vehicle_data.get("recall_count", 0)
            )
            db.add(vehicle)

        db.commit()
        db.refresh(vehicle)

        return vehicle

    @staticmethod
    def get_vehicle_info(db: Session, vin: str) -> Optional[VehicleInfo]:
        """Get vehicle information by VIN"""
        return db.query(VehicleInfo).filter(VehicleInfo.vin == vin).first()

    @staticmethod
    def get_contract_stats(db: Session, user_id: str = None) -> Dict:
        """Get contract statistics"""
        query = db.query(Contract)

        if user_id:
            query = query.filter(Contract.user_id == user_id)

        total = query.count()
        analyzed = query.filter(Contract.is_analyzed == True).count()

        # Risk distribution
        low_risk = query.filter(Contract.risk_level == "low").count()
        medium_risk = query.filter(Contract.risk_level == "medium").count()
        high_risk = query.filter(Contract.risk_level == "high").count()

        # Average risk score
        avg_score = db.query(func.avg(Contract.risk_score)).scalar() or 0

        return {
            "total_contracts": total,
            "analyzed_contracts": analyzed,
            "analysis_rate": (analyzed / total * 100) if total > 0 else 0,
            "risk_distribution": {
                "low": low_risk,
                "medium": medium_risk,
                "high": high_risk
            },
            "average_risk_score": round(avg_score, 2)
        }
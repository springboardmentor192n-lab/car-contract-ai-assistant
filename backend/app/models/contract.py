# backend/app/models/contract.py
from sqlalchemy import Column, Integer, String, Float, DateTime, JSON, Boolean, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from datetime import datetime

Base = declarative_base()


class Contract(Base):
    __tablename__ = "contracts"

    id = Column(Integer, primary_key=True, index=True)

    # User information
    user_id = Column(String, nullable=False, index=True)
    session_id = Column(String, nullable=False, index=True)

    # File information
    original_filename = Column(String, nullable=False)
    file_type = Column(String)  # pdf, docx, txt, etc.
    file_size = Column(Integer)  # in bytes
    file_hash = Column(String, unique=True, index=True)  # for deduplication

    # Extracted content
    raw_text = Column(Text)  # Full extracted text
    processed_text = Column(Text)  # Cleaned text

    # Extracted data
    quick_extraction = Column(JSON)  # Quick regex extraction
    llm_extraction = Column(JSON)  # LLM extraction results
    vin_data = Column(JSON)  # Vehicle information if VIN found

    # Analysis results
    risk_score = Column(Float)
    risk_level = Column(String)  # low, medium, high
    red_flags = Column(JSON)  # List of red flags
    recommendations = Column(JSON)  # List of recommendations

    # Metadata
    upload_date = Column(DateTime(timezone=True), server_default=func.now())
    analysis_date = Column(DateTime(timezone=True), onupdate=func.now())
    is_analyzed = Column(Boolean, default=False)
    analysis_duration = Column(Float)  # Seconds taken for analysis

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "session_id": self.session_id,
            "original_filename": self.original_filename,
            "file_type": self.file_type,
            "file_size": self.file_size,
            "risk_score": self.risk_score,
            "risk_level": self.risk_level,
            "upload_date": self.upload_date.isoformat() if self.upload_date else None,
            "is_analyzed": self.is_analyzed,
            "quick_extraction": self.quick_extraction,
            "llm_extraction": self.llm_extraction
        }


class ChatHistory(Base):
    __tablename__ = "chat_history"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String, nullable=False, index=True)
    contract_id = Column(Integer, nullable=True, index=True)

    # Message details
    role = Column(String, nullable=False)  # user or assistant
    message = Column(Text, nullable=False)

    # Metadata
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "session_id": self.session_id,
            "role": self.role,
            "message": self.message,
            "timestamp": self.timestamp.isoformat() if self.timestamp else None
        }


class VehicleInfo(Base):
    __tablename__ = "vehicle_info"

    id = Column(Integer, primary_key=True, index=True)
    vin = Column(String(17), unique=True, nullable=False, index=True)

    # Vehicle details
    make = Column(String)
    model = Column(String)
    year = Column(Integer)
    body_type = Column(String)
    engine = Column(String)
    transmission = Column(String)

    # Market data
    market_value_min = Column(Float)
    market_value_max = Column(Float)
    market_value_avg = Column(Float)

    # Recall/safety
    recall_count = Column(Integer, default=0)
    safety_rating = Column(Float)

    # Timestamps
    fetched_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    def to_dict(self):
        return {
            "vin": self.vin,
            "make": self.make,
            "model": self.model,
            "year": self.year,
            "market_value": {
                "min": self.market_value_min,
                "max": self.market_value_max,
                "avg": self.market_value_avg
            },
            "recall_count": self.recall_count,
            "fetched_at": self.fetched_at.isoformat() if self.fetched_at else None
        }
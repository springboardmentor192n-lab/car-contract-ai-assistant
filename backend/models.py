
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Text, JSON, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    full_name = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    contracts = relationship("Contract", back_populates="owner")

class Contract(Base):
    __tablename__ = "contracts"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    filename = Column(String)
    upload_date = Column(DateTime(timezone=True), server_default=func.now())
    status = Column(String) # uploading, processing, completed, failed
    file_path = Column(String)
    
    owner = relationship("User", back_populates="contracts")
    sla = relationship("ExtractedSLA", back_populates="contract", uselist=False)
    fairness_score = relationship("FairnessScore", back_populates="contract", uselist=False)
    vehicle_report = relationship("VehicleReport", back_populates="contract", uselist=False)
    price_analysis = relationship("PriceAnalysis", back_populates="contract", uselist=False)
    negotiation_threads = relationship("NegotiationThread", back_populates="contract")

class ExtractedSLA(Base):
    __tablename__ = "extracted_slas"
    id = Column(Integer, primary_key=True, index=True)
    contract_id = Column(Integer, ForeignKey("contracts.id"))
    
    # Financials
    apr = Column(Float)
    lease_term_months = Column(Integer)
    monthly_payment = Column(Float)
    down_payment = Column(Float)
    residual_value = Column(Float)
    mileage_limit_per_year = Column(Integer)
    overage_charge_per_mile = Column(Float)
    early_termination_fee = Column(Float)
    amount_due_at_signing = Column(Float)
    total_lease_cost = Column(Float)
    
    # Text Fields
    lender_name = Column(String)
    vehicle_vin = Column(String)
    vehicle_make = Column(String)
    vehicle_model = Column(String)
    vehicle_year = Column(Integer)
    
    # Clauses (stored as text or JSON)
    purchase_option_clause = Column(Text)
    warranty_clause = Column(Text)
    maintenance_clause = Column(Text)
    insurance_clause = Column(Text)
    late_fee_policy = Column(Text)
    
    # Analysis
    simple_language_summary = Column(Text)
    important_terms = Column(JSON) # List of important terms found
    red_flags = Column(JSON) # List of strings identifying risks
    hidden_charges = Column(JSON) # List of objects {name, amount, description}
    penalties = Column(JSON) # List of identified penalties
    negotiation_points = Column(JSON) # List of strings for negotiation
    final_advice = Column(Text) # Overall advice for the user
    risk_level = Column(String) # Low, Moderate, High
    
    contract = relationship("Contract", back_populates="sla")

class VehicleReport(Base):
    __tablename__ = "vehicle_reports"
    id = Column(Integer, primary_key=True, index=True)
    contract_id = Column(Integer, ForeignKey("contracts.id"))
    vin = Column(String)
    make = Column(String)
    model = Column(String)
    year = Column(Integer)
    manufacturer = Column(String)
    plant_city = Column(String)
    recalls = Column(JSON) # List of recall objects
    
    contract = relationship("Contract", back_populates="vehicle_report")

class PriceAnalysis(Base):
    __tablename__ = "price_analysis"
    id = Column(Integer, primary_key=True, index=True)
    contract_id = Column(Integer, ForeignKey("contracts.id"))
    
    estimated_fair_price_low = Column(Float)
    estimated_fair_price_high = Column(Float)
    market_average_price = Column(Float)
    contract_price = Column(Float)
    overpriced_amount = Column(Float)
    verdict = Column(String) # Good Deal, Fair, Overpriced
    explanation = Column(Text)
    
    contract = relationship("Contract", back_populates="price_analysis")

class FairnessScore(Base):
    __tablename__ = "fairness_scores"
    id = Column(Integer, primary_key=True, index=True)
    contract_id = Column(Integer, ForeignKey("contracts.id"))
    
    score = Column(Integer) # 0-100
    rating = Column(String) # Excellent, Good, Fair, Poor, Predatory
    breakdown = Column(JSON) # { "APR": 80, "Fees": 40, ... }
    explanation = Column(Text)
    
    contract = relationship("Contract", back_populates="fairness_score")

class NegotiationThread(Base):
    __tablename__ = "negotiation_threads"
    id = Column(Integer, primary_key=True, index=True)
    contract_id = Column(Integer, ForeignKey("contracts.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    messages = relationship("NegotiationMessage", back_populates="thread")
    contract = relationship("Contract", back_populates="negotiation_threads")

class NegotiationMessage(Base):
    __tablename__ = "negotiation_messages"
    id = Column(Integer, primary_key=True, index=True)
    thread_id = Column(Integer, ForeignKey("negotiation_threads.id"))
    sender = Column(String) # user, bot
    content = Column(Text)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    metadata_json = Column(JSON) # For suggested questions, drafts, etc.
    
    thread = relationship("NegotiationThread", back_populates="messages")

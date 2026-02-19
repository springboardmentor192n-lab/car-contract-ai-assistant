
from typing import List, Optional, Any, Dict
from pydantic import BaseModel
from datetime import datetime

# Token Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# User Schemas
class UserBase(BaseModel):
    email: str
    full_name: Optional[str] = None

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    created_at: datetime
    class Config:
        from_attributes = True

# SLA Schemas
class ExtractedSLABase(BaseModel):
    apr: Optional[float]
    lease_term_months: Optional[int]
    monthly_payment: Optional[float]
    down_payment: Optional[float]
    residual_value: Optional[float]
    mileage_limit_per_year: Optional[int]
    overage_charge_per_mile: Optional[float]
    early_termination_fee: Optional[float]
    amount_due_at_signing: Optional[float]
    total_lease_cost: Optional[float]
    lender_name: Optional[str]
    vehicle_vin: Optional[str]
    vehicle_make: Optional[str]
    vehicle_model: Optional[str]
    vehicle_year: Optional[int]
    
    simple_language_summary: Optional[str]
    important_terms: Optional[List[str]]
    red_flags: Optional[List[str]]
    hidden_charges: Optional[List[Dict[str, Any]]]
    penalties: Optional[List[str]]
    negotiation_points: Optional[List[str]]
    final_advice: Optional[str]
    risk_level: Optional[str]

class ExtractedSLACreate(ExtractedSLABase):
    pass

class ExtractedSLA(ExtractedSLABase):
    id: int
    contract_id: int
    class Config:
        from_attributes = True

# Vehicle Report Schemas
class VehicleReportBase(BaseModel):
    vin: str
    make: Optional[str]
    model: Optional[str]
    year: Optional[int]
    manufacturer: Optional[str]
    recalls: Optional[List[Dict[str, Any]]]

class VehicleReport(VehicleReportBase):
    id: int
    contract_id: int
    class Config:
        from_attributes = True

# Price Analysis Schemas
class PriceAnalysisBase(BaseModel):
    estimated_fair_price_low: Optional[float]
    estimated_fair_price_high: Optional[float]
    market_average_price: Optional[float]
    contract_price: Optional[float]
    overpriced_amount: Optional[float]
    verdict: Optional[str]
    explanation: Optional[str]

class PriceAnalysis(PriceAnalysisBase):
    id: int
    contract_id: int
    class Config:
        from_attributes = True

# Fairness Score Schemas
class FairnessScoreBase(BaseModel):
    score: int
    rating: str
    breakdown: Optional[Dict[str, Any]]
    explanation: Optional[str]

class FairnessScore(FairnessScoreBase):
    id: int
    contract_id: int
    class Config:
        from_attributes = True

# Negotiation Schemas
class NegotiationMessageBase(BaseModel):
    sender: str
    content: str
    metadata_json: Optional[Dict[str, Any]]

class NegotiationMessageCreate(NegotiationMessageBase):
    pass

class NegotiationMessage(NegotiationMessageBase):
    id: int
    thread_id: int
    timestamp: datetime
    class Config:
        from_attributes = True

class NegotiationChatRequest(BaseModel):
    contract_id: int
    user_message: str

class NegotiationChatResponse(BaseModel):
    response: str
    suggested_questions: List[str]
    dealer_email_draft: Optional[str]

# Contract Schemas
class ContractBase(BaseModel):
    filename: str
    status: str

class ContractCreate(ContractBase):
    pass

class Contract(ContractBase):
    id: int
    user_id: Optional[int]
    upload_date: datetime
    sla: Optional[ExtractedSLA]
    fairness_score: Optional[FairnessScore]
    vehicle_report: Optional[VehicleReport]
    price_analysis: Optional[PriceAnalysis]
    
    class Config:
        from_attributes = True

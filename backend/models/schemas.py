from __future__ import annotations
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import List, Optional, Any
from datetime import datetime
import uuid

# --- User Schemas ---
class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: uuid.UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# --- Token Schemas ---
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# --- Contract Schemas ---
class ContractBase(BaseModel):
    contract_type: Optional[str] = 'UNKNOWN'
    analysis_status: Optional[str] = 'PENDING'
    upload_status: Optional[str] = 'PENDING'
    file_name: Optional[str] = None
    file_path: Optional[str] = None
    user_id: uuid.UUID

class ContractCreate(ContractBase):
    pass

class ContractUpdate(BaseModel):
    contract_type: Optional[str] = None
    analysis_status: Optional[str] = None
    upload_status: Optional[str] = None

class Contract(ContractBase):
    id: uuid.UUID
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# --- AI Analysis Schemas ---
class AIAnalysisBase(BaseModel):
    risk_score: float = Field(..., ge=0, le=100, description="Overall risk score from 0-100.")
    risk_level: str = Field(..., description="Categorical risk level (e.g., Low, Medium, High).")
    summary: str = Field(..., description="A summary of the contract analysis.")

class AIAnalysisCreate(AIAnalysisBase):
    contract_id: uuid.UUID

class AIAnalysis(AIAnalysisBase):
    id: uuid.UUID
    contract_id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

# --- AI/Generative Schemas ---
class AskAIRequest(BaseModel):
    question: str = Field(..., description="The user's question about the contract.")
    context: str = Field(..., description="The contract text or relevant context.")

class AskAIResponse(BaseModel):
    answer: str

# --- Vehicle Schemas ---
class VehicleBase(BaseModel):
    vin: str = Field(..., max_length=17, min_length=17)
    make: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    body_type: Optional[str] = None
    engine: Optional[str] = None
    fuel_type: Optional[str] = None
    plant_country: Optional[str] = None

class VehicleCreate(VehicleBase):
    pass

class VehicleUpdate(VehicleBase):
    pass

class Vehicle(VehicleBase):
    id: uuid.UUID
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# --- VIN Report Schemas ---
class VINReportBase(BaseModel):
    source: str
    raw_response: Any

class VINReportCreate(VINReportBase):
    vehicle_id: uuid.UUID

class VINReport(VINReportBase):
    id: uuid.UUID
    vehicle_id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

# --- VIN Lookup Response Schema ---
class VINLookupResponse(BaseModel):
    vehicle: Vehicle
    report: VINReport

# --- Market Data Schemas ---
class MarketDataBase(BaseModel):
    region: Optional[str] = None
    make: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    average_price: Optional[float] = None
    data_source: Optional[str] = None

class MarketDataCreate(MarketDataBase):
    pass

class MarketDataUpdate(MarketDataBase):
    pass

class MarketData(MarketDataBase):
    id: uuid.UUID
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# --- Negotiation Schemas ---
class NegotiationThreadBase(BaseModel):
    user_id: uuid.UUID
    contract_id: Optional[uuid.UUID] = None
    status: Optional[str] = 'active'

class NegotiationThreadCreate(NegotiationThreadBase):
    pass

class NegotiationThreadUpdate(BaseModel):
    status: Optional[str] = None
    summary: Optional[str] = None

class NegotiationMessageBase(BaseModel):
    thread_id: uuid.UUID
    sender_type: str # 'user' or 'ai'
    message_content: str

class NegotiationMessageCreate(BaseModel):
    message_content: str

class NegotiationMessage(NegotiationMessageBase):
    id: uuid.UUID
    timestamp: datetime
    model_config = ConfigDict(from_attributes=True)

class NegotiationThread(NegotiationThreadBase):
    id: uuid.UUID
    created_at: datetime
    end_time: Optional[datetime] = None
    summary: Optional[str] = None
    messages: List[NegotiationMessage] = []
    model_config = ConfigDict(from_attributes=True)

# --- Vehicle Price Benchmark Schemas ---
class VehiclePriceBenchmarkBase(BaseModel):
    make: str
    model: str
    year: int
    trim: Optional[str] = None
    average_benchmark_price: float

class VehiclePriceBenchmarkCreate(VehiclePriceBenchmarkBase):
    pass

class VehiclePriceBenchmarkUpdate(BaseModel):
    average_benchmark_price: Optional[float] = None

class VehiclePriceBenchmark(VehiclePriceBenchmarkBase):
    id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class PriceBenchmarkResponse(BaseModel):
    min_price: float
    max_price: float
    avg_price: float
    make: str
    model: str
    year: int

class PriceBenchmarkCacheCreate(BaseModel):
    make: str
    model: str
    year: int
    min_price: float
    max_price: float
    avg_price: float


# --- Market Rates Specific Schemas ---
class HistoricalRate(BaseModel):
    date: str
    interest_rate: float


class MarketRatesResponse(BaseModel):
    latest_apr: float
    change_from_previous: float
    last_updated: str
    historical_data: List[HistoricalRate]


# --- Generic Response Schema ---
class ResponseModel(BaseModel):
    status: str
    message: str
    data: Optional[Any] = None

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    response: str


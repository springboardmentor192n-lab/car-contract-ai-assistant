import uuid
from datetime import datetime
from sqlalchemy import (
    create_engine,
    Column,
    String,
    Text,
    ForeignKey,
    Integer,
    Numeric,
    DateTime,
    JSON,
    Enum,
    Boolean,
    Index
)
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.mysql import CHAR

Base = declarative_base()

def generate_uuid():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    username = Column(String(255), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    contracts = relationship("Contract", back_populates="user")
    negotiation_threads = relationship("NegotiationThread", back_populates="user")
    audit_events = relationship("AuditEvent", back_populates="user")

class Provider(Base):
    __tablename__ = "providers"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    name = Column(String(255), nullable=False, unique=True)
    type = Column(String(50)) # e.g., 'vin_lookup', 'market_data'
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    credentials = relationship("ProviderCredential", back_populates="provider")

class ProviderCredential(Base):
    __tablename__ = "provider_credentials"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    provider_id = Column(CHAR(36), ForeignKey("providers.id"), nullable=False, index=True)
    user_id = Column(CHAR(36), ForeignKey("users.id"), nullable=False, index=True)
    credentials = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    provider = relationship("Provider", back_populates="credentials")


class MarketData(Base):
    __tablename__ = "market_data"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    region = Column(String(255))
    vehicle_type = Column(String(255))
    make = Column(String(255))
    model = Column(String(255))
    year = Column(Integer)
    average_price = Column(Numeric(10, 2))
    data_source = Column(String(255))
    recorded_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Vehicle(Base):
    __tablename__ = "vehicles"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    vin = Column(String(17), unique=True, nullable=False, index=True)
    make = Column(String(100))
    model = Column(String(100))
    year = Column(Integer)
    details = Column(JSON) # Other details from VIN lookup
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    contracts = relationship("Contract", back_populates="vehicle")
    vin_reports = relationship("VinReport", back_populates="vehicle")
    price_benchmarks = relationship("VehiclePriceBenchmark", back_populates="vehicle") # CORRECTED

class Dealer(Base):
    __tablename__ = "dealers"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    name = Column(String(255), nullable=False, index=True)
    address = Column(Text)
    contact_info = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    contracts = relationship("Contract", back_populates="dealer")

class Lender(Base):
    __tablename__ = "lenders"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    name = Column(String(255), nullable=False, index=True)
    contact_info = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    contracts = relationship("Contract", back_populates="lender")

class Contract(Base):
    __tablename__ = "contracts"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    user_id = Column(CHAR(36), ForeignKey("users.id"), nullable=False, index=True)
    vehicle_id = Column(CHAR(36), ForeignKey("vehicles.id"), index=True)
    dealer_id = Column(CHAR(36), ForeignKey("dealers.id"), index=True)
    lender_id = Column(CHAR(36), ForeignKey("lenders.id"), index=True)
    contract_type = Column(Enum('loan', 'lease', name='contract_type_enum'), nullable=False)
    status = Column(String(50), default='uploaded') # e.g., uploaded, processing, analyzed, archived
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="contracts")
    vehicle = relationship("Vehicle", back_populates="contracts")
    dealer = relationship("Dealer", back_populates="contracts")
    lender = relationship("Lender", back_populates="contracts")
    files = relationship("ContractFile", back_populates="contract")
    sla = relationship("ContractSla", uselist=False, back_populates="contract")
    llm_extractions = relationship("LlmExtraction", back_populates="contract")
    threads = relationship("NegotiationThread", back_populates="contract")
    offer_comparisons = relationship("OfferComparison", back_populates="contract")

class ContractFile(Base):
    __tablename__ = "contract_files"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    contract_id = Column(CHAR(36), ForeignKey("contracts.id"), nullable=False, index=True)
    file_path = Column(String(1024), nullable=False)
    original_filename = Column(String(255))
    file_type = Column(String(50)) # pdf, jpeg, png
    upload_timestamp = Column(DateTime, default=datetime.utcnow)
    
    contract = relationship("Contract", back_populates="files")
    pages = relationship("ContractPage", back_populates="contract_file") # Corrected back_populates

class ContractPage(Base):
    __tablename__ = "contract_pages"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    file_id = Column(CHAR(36), ForeignKey("contract_files.id"), nullable=False, index=True)
    page_number = Column(Integer, nullable=False)
    
    contract_file = relationship("ContractFile", back_populates="pages") # Corrected name
    ocr_texts = relationship("OcrText", back_populates="page")

class OcrText(Base):
    __tablename__ = "ocr_texts"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    page_id = Column(CHAR(36), ForeignKey("contract_pages.id"), nullable=False, index=True)
    text_content = Column(Text)
    ocr_provider = Column(String(100))
    created_at = Column(DateTime, default=datetime.utcnow)

    page = relationship("ContractPage", back_populates="ocr_texts")

class LlmExtraction(Base):
    __tablename__ = "llm_extractions"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    contract_id = Column(CHAR(36), ForeignKey("contracts.id"), nullable=False, index=True)
    model_used = Column(String(100))
    raw_output = Column(JSON)
    risk_analysis_results = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)

    contract = relationship("Contract", back_populates="llm_extractions")
    extracted_clauses = relationship("ExtractedClause", back_populates="extraction")

class ExtractedClause(Base):
    __tablename__ = "extracted_clauses"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    extraction_id = Column(CHAR(36), ForeignKey("llm_extractions.id"), nullable=False, index=True)
    clause_type = Column(String(255), index=True)
    normalized_value = Column(String(255))
    raw_text = Column(Text)
    red_flag_score = Column(Numeric(5, 2))
    explanation = Column(Text)
    
    extraction = relationship("LlmExtraction", back_populates="extracted_clauses")

class ContractSla(Base):
    __tablename__ = "contract_slas"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    contract_id = Column(CHAR(36), ForeignKey("contracts.id"), unique=True, nullable=False, index=True)
    apr = Column(Numeric(5, 2))
    loan_term = Column(Integer) # months
    mileage_allowance = Column(Integer) # miles per year for lease
    money_factor = Column(Numeric(10, 6))
    residual_value = Column(Numeric(10, 2))
    early_termination_penalty = Column(Text)
    wear_and_tear_policy = Column(Text)
    
    contract = relationship("Contract", back_populates="sla")

class VinReport(Base):
    __tablename__ = "vin_reports"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    vehicle_id = Column(CHAR(36), ForeignKey("vehicles.id"), nullable=False, index=True)
    report_provider = Column(String(100))
    report_data = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)

    vehicle = relationship("Vehicle", back_populates="vin_reports")
    recalls = relationship("VehicleRecall", back_populates="vin_report")

class VehicleRecall(Base):
    __tablename__ = "vehicle_recalls"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    vin_report_id = Column(CHAR(36), ForeignKey("vin_reports.id"), nullable=False, index=True)
    recall_id = Column(String(100), index=True)
    title = Column(String(255))
    description = Column(Text)
    date_issued = Column(DateTime)
    
    vin_report = relationship("VinReport", back_populates="recalls")

class VehiclePriceBenchmark(Base):
    __tablename__ = "vehicle_price_benchmarks"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    vehicle_id = Column(CHAR(36), ForeignKey("vehicles.id"), nullable=True, index=True)
    make = Column(String(255))
    model = Column(String(255))
    year = Column(Integer)
    trim = Column(String(255))
    mileage_range_start = Column(Integer)
    mileage_range_end = Column(Integer)
    condition_grade = Column(String(50))
    average_benchmark_price = Column(Numeric(10, 2), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    vehicle = relationship("Vehicle", back_populates="price_benchmarks")
    sources = relationship("PriceSource", back_populates="benchmark")

class PriceSource(Base):
    __tablename__ = "price_sources"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    benchmark_id = Column(CHAR(36), ForeignKey("vehicle_price_benchmarks.id"), nullable=False, index=True)
    source_name = Column(String(255)) # e.g., Edmunds, KBB
    source_url = Column(String(1024))
    
    benchmark = relationship("VehiclePriceBenchmark", back_populates="sources")

class NegotiationThread(Base):
    __tablename__ = "negotiation_threads"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    user_id = Column(CHAR(36), ForeignKey("users.id"), nullable=False, index=True)
    contract_id = Column(CHAR(36), ForeignKey("contracts.id"), nullable=False, index=True)
    vin_id = Column(CHAR(36), ForeignKey("vehicles.id"), nullable=True, index=True) # New
    session_topic = Column(String(255))
    status = Column(Enum('open', 'closed', 'pending', name='thread_status_enum'), default='open')
    created_at = Column(DateTime, default=datetime.utcnow)
    end_time = Column(DateTime, nullable=True) # New
    summary = Column(Text, nullable=True) # New
    
    user = relationship("User", back_populates="negotiation_threads")
    contract = relationship("Contract", back_populates="threads")
    vin = relationship("Vehicle") # New relationship
    messages = relationship("NegotiationMessage", back_populates="thread")

class NegotiationMessage(Base):
    __tablename__ = "negotiation_messages"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    thread_id = Column(CHAR(36), ForeignKey("negotiation_threads.id"), nullable=False, index=True)
    sender_type = Column(Enum('user', 'ai', 'dealer', name='sender_type_enum'), nullable=False)
    message_content = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    thread = relationship("NegotiationThread", back_populates="messages")

class OfferComparison(Base):
    __tablename__ = "offer_comparisons"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    contract_id = Column(CHAR(36), ForeignKey("contracts.id"), nullable=False, index=True)
    offer_details = Column(JSON) # Details of competing offer
    comparison_score = Column(Numeric(5, 2))
    
    contract = relationship("Contract", back_populates="offer_comparisons")

class AuditEvent(Base):
    __tablename__ = "audit_events"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    user_id = Column(CHAR(36), ForeignKey("users.id"), index=True)
    event_type = Column(String(100), nullable=False, index=True) # e.g., 'user_login', 'contract_upload'
    details = Column(JSON)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", back_populates="audit_events")
    tags = relationship("Tag", secondary="audit_event_tags")

class Tag(Base):
    __tablename__ = "tags"
    id = Column(CHAR(36), primary_key=True, default=generate_uuid)
    tag_name = Column(String(100), unique=True, nullable=False, index=True)

    audits = relationship("AuditEvent", secondary="audit_event_tags")

class AuditEventTag(Base):
    __tablename__ = 'audit_event_tags'
    audit_id = Column(CHAR(36), ForeignKey('audit_events.id'), primary_key=True)
    tag_id = Column(CHAR(36), ForeignKey('tags.id'), primary_key=True)

class PriceBenchmarkCache(Base):
    __tablename__ = "price_benchmark_cache"
    id = Column(Integer, primary_key=True, index=True)
    make = Column(String(100), nullable=False)
    model = Column(String(100), nullable=False)
    year = Column(Integer, nullable=False)
    min_price = Column(Numeric(10, 2), nullable=False)
    max_price = Column(Numeric(10, 2), nullable=False)
    avg_price = Column(Numeric(10, 2), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        Index('ix_make_model_year', 'make', 'model', 'year', unique=True),
    )
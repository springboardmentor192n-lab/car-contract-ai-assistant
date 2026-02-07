from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import asc, update, delete
from backend.models import orm_models, schemas
import uuid

# --- User CRUD ---
async def get_user_by_email(db: AsyncSession, email: str):
    result = await db.execute(select(orm_models.User).filter(orm_models.User.email == email))
    return result.scalars().first()

async def get_user_by_username(db: AsyncSession, username: str):
    result = await db.execute(select(orm_models.User).filter(orm_models.User.username == username))
    return result.scalars().first()

async def create_user(db: AsyncSession, user: schemas.UserCreate):
    """
    Creates a new user in the database.
    Assumes the password in the user schema is already hashed.
    """
    db_user = orm_models.User(
        username=user.username,
        email=user.email,
        hashed_password=user.password, # The route is responsible for hashing
        is_active=True
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

# --- Contract CRUD ---
async def create_contract(db: AsyncSession, contract: schemas.ContractCreate):
    db_contract = orm_models.Contract(**contract.model_dump())
    db.add(db_contract)
    await db.commit()
    await db.refresh(db_contract)
    return db_contract

async def get_contract(db: AsyncSession, contract_id: uuid.UUID):
    result = await db.execute(select(orm_models.Contract).filter(orm_models.Contract.id == contract_id))
    return result.scalars().first()

async def get_contracts(db: AsyncSession, user_id: uuid.UUID, skip: int = 0, limit: int = 100):
    result = await db.execute(
        select(orm_models.Contract)
        .filter(orm_models.Contract.user_id == user_id)
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()

async def update_contract(db: AsyncSession, contract_id: uuid.UUID, contract: schemas.ContractUpdate):
    db_contract = await get_contract(db, contract_id=contract_id)
    if db_contract:
        update_data = contract.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_contract, key, value)
        await db.commit()
        await db.refresh(db_contract)
    return db_contract

async def delete_contract(db: AsyncSession, contract_id: uuid.UUID):
    stmt = delete(orm_models.Contract).where(orm_models.Contract.id == contract_id)
    await db.execute(stmt)
    await db.commit()
    return True


# --- Negotiation Thread & Message CRUD ---
async def get_or_create_negotiation_thread(db: AsyncSession, user_id: uuid.UUID, contract_id: uuid.UUID):
    result = await db.execute(
        select(orm_models.NegotiationThread).filter_by(user_id=user_id, contract_id=contract_id)
    )
    thread = result.scalars().first()
    if not thread:
        thread = orm_models.NegotiationThread(
            user_id=user_id,
            contract_id=contract_id,
            session_topic=f"Negotiation for Contract {contract_id}"
        )
        db.add(thread)
        await db.commit()
        await db.refresh(thread)
    return thread

async def get_negotiation_thread(db: AsyncSession, thread_id: uuid.UUID):
    result = await db.execute(select(orm_models.NegotiationThread).filter(orm_models.NegotiationThread.id == thread_id))
    return result.scalars().first()

async def get_negotiation_threads(db: AsyncSession, user_id: uuid.UUID, skip: int = 0, limit: int = 100):
    result = await db.execute(
        select(orm_models.NegotiationThread)
        .filter(orm_models.NegotiationThread.user_id == user_id)
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()

async def update_negotiation_thread(db: AsyncSession, thread_id: uuid.UUID, thread: schemas.NegotiationThreadUpdate):
    db_thread = await get_negotiation_thread(db, thread_id=thread_id)
    if db_thread:
        update_data = thread.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_thread, key, value)
        await db.commit()
        await db.refresh(db_thread)
    return db_thread

async def delete_negotiation_thread(db: AsyncSession, thread_id: uuid.UUID):
    stmt = delete(orm_models.NegotiationThread).where(orm_models.NegotiationThread.id == thread_id)
    await db.execute(stmt)
    await db.commit()
    return True

async def create_negotiation_message(db: AsyncSession, message: schemas.NegotiationMessageBase):
    db_message = orm_models.NegotiationMessage(**message.model_dump())
    db.add(db_message)
    await db.commit()
    await db.refresh(db_message)
    return db_message

async def get_negotiation_message(db: AsyncSession, message_id: uuid.UUID):
    result = await db.execute(select(orm_models.NegotiationMessage).filter(orm_models.NegotiationMessage.id == message_id))
    return result.scalars().first()

async def get_messages_by_thread_id(db: AsyncSession, thread_id: uuid.UUID):
    result = await db.execute(
        select(orm_models.NegotiationMessage)
        .filter(orm_models.NegotiationMessage.thread_id == thread_id)
        .order_by(asc(orm_models.NegotiationMessage.timestamp))
    )
    return result.scalars().all()

async def update_negotiation_message(db: AsyncSession, message_id: uuid.UUID, message: schemas.NegotiationMessageCreate):
    db_message = await get_negotiation_message(db, message_id=message_id)
    if db_message:
        update_data = message.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_message, key, value)
        await db.commit()
        await db.refresh(db_message)
    return db_message

async def delete_negotiation_message(db: AsyncSession, message_id: uuid.UUID):
    stmt = delete(orm_models.NegotiationMessage).where(orm_models.NegotiationMessage.id == message_id)
    await db.execute(stmt)
    await db.commit()
    return True

# --- Vehicle CRUD ---
async def get_vehicle_by_vin(db: AsyncSession, vin: str):
    result = await db.execute(select(orm_models.Vehicle).filter(orm_models.Vehicle.vin == vin))
    return result.scalars().first()

async def create_vehicle(db: AsyncSession, vehicle: schemas.VehicleCreate):
    db_vehicle = orm_models.Vehicle(**vehicle.model_dump())
    db.add(db_vehicle)
    await db.commit()
    await db.refresh(db_vehicle)
    return db_vehicle

async def get_vehicle(db: AsyncSession, vehicle_id: uuid.UUID):
    result = await db.execute(select(orm_models.Vehicle).filter(orm_models.Vehicle.id == vehicle_id))
    return result.scalars().first()

async def get_vehicles(db: AsyncSession, skip: int = 0, limit: int = 100):
    result = await db.execute(select(orm_models.Vehicle).offset(skip).limit(limit))
    return result.scalars().all()

async def update_vehicle(db: AsyncSession, vehicle_id: uuid.UUID, vehicle: schemas.VehicleUpdate):
    db_vehicle = await get_vehicle(db, vehicle_id=vehicle_id)
    if db_vehicle:
        update_data = vehicle.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_vehicle, key, value)
        await db.commit()
        await db.refresh(db_vehicle)
    return db_vehicle

async def delete_vehicle(db: AsyncSession, vehicle_id: uuid.UUID):
    stmt = delete(orm_models.Vehicle).where(orm_models.Vehicle.id == vehicle_id)
    await db.execute(stmt)
    await db.commit()
    return True

# --- VIN Report CRUD ---
async def create_vin_report(db: AsyncSession, report: schemas.VINReportCreate):
    db_report = orm_models.VINReport(**report.model_dump())
    db.add(db_report)
    await db.commit()
    await db.refresh(db_report)
    return db_report

# --- Vehicle Price Benchmark CRUD ---
async def create_vehicle_price_benchmark(db: AsyncSession, benchmark: schemas.VehiclePriceBenchmarkCreate):
    db_benchmark = orm_models.VehiclePriceBenchmark(**benchmark.model_dump())
    db.add(db_benchmark)
    await db.commit()
    await db.refresh(db_benchmark)
    return db_benchmark

async def get_vehicle_price_benchmark(db: AsyncSession, benchmark_id: uuid.UUID):
    result = await db.execute(select(orm_models.VehiclePriceBenchmark).filter(orm_models.VehiclePriceBenchmark.id == benchmark_id))
    return result.scalars().first()

async def get_all_vehicle_price_benchmarks(db: AsyncSession, skip: int = 0, limit: int = 100):
    result = await db.execute(select(orm_models.VehiclePriceBenchmark).offset(skip).limit(limit))
    return result.scalars().all()

async def update_vehicle_price_benchmark(db: AsyncSession, benchmark_id: uuid.UUID, benchmark: schemas.VehiclePriceBenchmarkUpdate):
    db_benchmark = await get_vehicle_price_benchmark(db, benchmark_id=benchmark_id)
    if db_benchmark:
        update_data = benchmark.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_benchmark, key, value)
        await db.commit()
        await db.refresh(db_benchmark)
    return db_benchmark

async def delete_vehicle_price_benchmark(db: AsyncSession, benchmark_id: uuid.UUID):
    stmt = delete(orm_models.VehiclePriceBenchmark).where(orm_models.VehiclePriceBenchmark.id == benchmark_id)
    await db.execute(stmt)
    await db.commit()
    return True

# --- Price Benchmark Cache CRUD ---
async def get_benchmark_from_cache(db: AsyncSession, make: str, model: str, year: int):
    result = await db.execute(select(orm_models.PriceBenchmarkCache).filter_by(make=make, model=model, year=year))
    return result.scalars().first()

async def create_benchmark_in_cache(db: AsyncSession, benchmark_data: schemas.PriceBenchmarkCacheCreate):
    db_benchmark = orm_models.PriceBenchmarkCache(**benchmark_data.model_dump())
    db.add(db_benchmark)
    await db.commit()
    await db.refresh(db_benchmark)
    return db_benchmark
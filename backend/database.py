from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from backend.models.orm_models import Base
from backend.config import settings

db_engine = create_async_engine(
    settings.DATABASE_URL,
)

SessionLocal = async_sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=db_engine,
    expire_on_commit=False
)

# Dependency to get a DB session
async def get_db():
    async with SessionLocal() as session:
        yield session
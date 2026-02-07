import sys
import os

# Add the backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import pytest
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

# Configure pytest-asyncio to auto-detect async functions and fixtures
pytest_asyncio_mode = "auto" 

from database import Base, get_db # Import Base and get_db from your main database module

# Use an in-memory SQLite database for testing
DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture()
async def test_engine():
    engine = create_async_engine(DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all) # Create tables
    yield engine
    await engine.dispose() # Dispose engine after tests

@pytest.fixture()
async def test_session(test_engine):
    """
    Returns an async session for testing.
    Each test will get its own session and the database will be rolled back
    after each test.
    """
    async_session = async_sessionmaker(
        autocommit=False, autoflush=False, bind=test_engine, class_=AsyncSession
    )
    async with async_session() as session:
        yield session
        await session.rollback() # Rollback changes after each test

@pytest.fixture(autouse=True)
async def override_db_dependency(monkeypatch, test_session: AsyncSession):
    """
    This fixture ensures that all FastAPI dependencies requesting 'get_db'
    will receive the test_session.
    """
    async def get_test_db():
        yield test_session
    monkeypatch.setattr("database.get_db", get_test_db)
    yield
    # No need to clear app.dependency_overrides if we are patching the function directly

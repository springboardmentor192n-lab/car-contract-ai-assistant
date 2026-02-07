import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID

from crud import create_user, get_user_by_email
from models.schemas import UserCreate
from models.orm_models import UserRole

@pytest.mark.asyncio
async def test_create_user(test_session: AsyncSession):
    user_in = UserCreate(email="test@example.com", password="password", full_name="Test User")
    user = await create_user(test_session, user_in)

    assert user.email == "test@example.com"
    assert user.full_name == "Test User"
    assert hasattr(user, "id")
    assert isinstance(user.id, UUID)
    assert user.role == UserRole.USER
    assert user.is_active is True

@pytest.mark.asyncio
async def test_get_user_by_email(test_session: AsyncSession):
    # First create a user
    user_in = UserCreate(email="findme@example.com", password="password")
    await create_user(test_session, user_in)

    # Then try to get it
    found_user = await get_user_by_email(test_session, "findme@example.com")
    assert found_user is not None
    assert found_user.email == "findme@example.com"

    # Test for non-existent user
    not_found_user = await get_user_by_email(test_session, "nonexistent@example.com")
    assert not_found_user is None

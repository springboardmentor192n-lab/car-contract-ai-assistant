from app.db.session import engine
from app.models.base import Base

print("Creating database tables...")
Base.metadata.create_all(bind=engine)
print("Done.")

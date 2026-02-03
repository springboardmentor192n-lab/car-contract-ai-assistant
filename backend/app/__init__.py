# backend/init_db.py
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import init_db, test_connection

if __name__ == "__main__":
    print("Initializing database...")

    # Test connection
    if test_connection():
        print("✓ Database connection successful")
    else:
        print("✗ Database connection failed")
        sys.exit(1)

    # Create tables
    try:
        init_db()
        print("✓ Database tables created successfully")
    except Exception as e:
        print(f"✗ Error creating tables: {e}")
        sys.exit(1)

    print("Database initialization complete!")
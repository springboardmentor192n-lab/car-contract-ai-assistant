import sys
sys.path.insert(0, '.')

from passlib.context import CryptContext
import sqlite3

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Create test user
email = "nagaswetha903@gmail.com"
password = "test123"  # Simple test password
full_name = "Test User"

hashed_password = pwd_context.hash(password)

# Connect to database
conn = sqlite3.connect('sql_app.db')
cursor = conn.cursor()

# Insert user
cursor.execute("""
    INSERT INTO users (email, hashed_password, full_name)
    VALUES (?, ?, ?)
""", (email, hashed_password, full_name))

conn.commit()
conn.close()

print(f"✅ Test user created successfully!")
print(f"Email: {email}")
print(f"Password: {password}")

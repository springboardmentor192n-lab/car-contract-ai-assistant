
from database import SessionLocal
import models

db = SessionLocal()
contracts = db.query(models.Contract).all()

print(f"{'ID':<5} {'Filename':<30} {'Status':<15} {'Has SLA':<10}")
print("-" * 65)
for c in contracts:
    has_sla = "Yes" if c.sla else "No"
    print(f"{c.id:<5} {c.filename:<30} {c.status:<15} {has_sla:<10}")

db.close()

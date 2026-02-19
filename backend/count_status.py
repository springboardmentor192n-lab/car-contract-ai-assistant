
from database import SessionLocal
import models

db = SessionLocal()
print(f"Failed: {db.query(models.Contract).filter(models.Contract.status == 'failed').count()}")
print(f"Processing: {db.query(models.Contract).filter(models.Contract.status == 'processing').count()}")
print(f"Queued: {db.query(models.Contract).filter(models.Contract.status == 'queued').count()}")
print(f"Completed: {db.query(models.Contract).filter(models.Contract.status == 'completed').count()}")
db.close()

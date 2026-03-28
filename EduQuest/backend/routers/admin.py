from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
import models, database

router = APIRouter()

@router.get("/users")
def get_users(db: Session = Depends(database.get_db)):
    users = db.query(models.User).all()
    return [{"id": u.id, "email": u.email, "role": u.role} for u in users]

@router.get("/platform-status")
def get_platform_status(db: Session = Depends(database.get_db)):
    # Simple mock status for the MVP defense demo
    return {
        "tutor_api": "Online",
        "safety_filter": "Active",
        "database": "Connected"
    }

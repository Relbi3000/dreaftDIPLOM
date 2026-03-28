from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
import models, database

router = APIRouter()

@router.get("/students-progress")
def get_students_progress(db: Session = Depends(database.get_db)):
    students = db.query(models.User).filter(models.User.role == "student").all()
    
    result = []
    for s in students:
        profile = s.profile
        result.append({
            "id": s.id,
            "email": s.email,
            "level": profile.level if profile else 1,
            "xp": profile.xp if profile else 0,
            "streak": profile.streak if profile else 0
        })
    return result

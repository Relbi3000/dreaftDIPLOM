from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
import models, database

router = APIRouter()

@router.get("/users")
def get_users(db: Session = Depends(database.get_db)):
    users = db.query(models.User).all()
    return [{"id": u.id, "email": u.email, "name": u.full_name, "role": u.role} for u in users]

@router.get("/platform-status")
def get_platform_status(db: Session = Depends(database.get_db)):
    # Count resources
    user_count = db.query(models.User).count()
    course_count = db.query(models.Course).count()
    lesson_count = db.query(models.Lesson).count()
    quiz_count = db.query(models.Quiz).count()
    attempt_count = db.query(models.Attempt).count()
    
    return {
        "services": {
            "tutor_api": "Online Mock",
            "safety_filter": "Active",
            "database": "Connected"
        },
        "metrics": {
            "users": user_count,
            "courses": course_count,
            "lessons": lesson_count,
            "quizzes": quiz_count,
            "attempts": attempt_count
        }
    }

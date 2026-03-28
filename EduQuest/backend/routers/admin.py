from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
import models, database, dependencies

router = APIRouter()

@router.get("/users")
def get_users(db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_admin)):
    users = db.query(models.User).all()
    return [{"id": u.id, "email": u.email, "name": u.full_name, "role": u.role, "is_active": u.is_active} for u in users]

@router.put("/users/{user_id}/status")
def toggle_user_status(user_id: int, active: bool, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_admin)):
    usr = db.query(models.User).filter(models.User.id == user_id).first()
    if not usr:
        raise HTTPException(status_code=404, detail="User not found")
    usr.is_active = active
    db.commit()
    return {"status": "success", "is_active": usr.is_active}

@router.put("/users/{user_id}/role")
def change_user_role(user_id: int, role: str, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_admin)):
    usr = db.query(models.User).filter(models.User.id == user_id).first()
    if not usr:
        raise HTTPException(status_code=404, detail="User not found")
    if role not in ["student", "teacher", "admin"]:
        raise HTTPException(status_code=400, detail="Invalid role")
    usr.role = role
    db.commit()
    return {"status": "success", "role": usr.role}

class SystemConfigUpdate(BaseModel):
    ai_safety: bool
    retries_enabled: bool
    xp_per_quiz: int

@router.get("/config")
def get_system_config(db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_admin)):
    config = db.query(models.SystemConfig).first()
    if not config:
        return {"ai_safety": True, "retries_enabled": True, "xp_per_quiz": 100}
    return {
        "ai_safety": config.ai_safety,
        "retries_enabled": config.retries_enabled,
        "xp_per_quiz": config.xp_per_quiz
    }

@router.put("/config")
def update_system_config(cfg: SystemConfigUpdate, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_admin)):
    config = db.query(models.SystemConfig).first()
    if not config:
        config = models.SystemConfig()
        db.add(config)
    config.ai_safety = cfg.ai_safety
    config.retries_enabled = cfg.retries_enabled
    config.xp_per_quiz = cfg.xp_per_quiz
    db.commit()
    return {"status": "success"}

@router.get("/platform-status")
def get_platform_status(db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_admin)):
    # Count resources
    user_count = db.query(models.User).count()
    course_count = db.query(models.Course).count()
    lesson_count = db.query(models.Lesson).count()
    quiz_count = db.query(models.Quiz).count()
    attempt_count = db.query(models.Attempt).count()
    
    config = db.query(models.SystemConfig).first()
    ai_safe_status = "Active" if (config and config.ai_safety) else "Disabled"

    return {
        "services": {
            "tutor_api": "Online Mock",
            "safety_filter": ai_safe_status,
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


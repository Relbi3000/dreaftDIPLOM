from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
import models, database

router = APIRouter()

@router.get("/overview")
def get_analytics(db: Session = Depends(database.get_db)):
    total_users = db.query(models.User).count()
    total_attempts = db.query(models.Attempt).count()
    
    avg_score_query = db.query(func.avg(models.Attempt.score)).scalar()
    avg_score = float(avg_score_query) if avg_score_query is not None else 0.0
    
    top_user = db.query(models.GamificationProfile).order_by(models.GamificationProfile.xp.desc()).first()
    
    return {
        "total_users": total_users,
        "total_attempts": total_attempts,
        "average_score": avg_score,
        "top_xp": top_user.xp if top_user else 0
    }

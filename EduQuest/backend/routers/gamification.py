from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, database
from pydantic import BaseModel

router = APIRouter()

class ProfileSchema(BaseModel):
    xp: int
    level: int
    streak: int
    
    class Config:
        from_attributes = True

@router.get("/profile/{user_id}", response_model=ProfileSchema)
def get_gamification_profile(user_id: int, db: Session = Depends(database.get_db)):
    profile = db.query(models.GamificationProfile).filter(models.GamificationProfile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

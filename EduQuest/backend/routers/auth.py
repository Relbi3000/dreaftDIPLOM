from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, database
from pydantic import BaseModel

router = APIRouter()

class UserCreate(BaseModel):
    email: str
    password: str
    full_name: str

class UserLogin(BaseModel):
    email: str
    password: str

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Simple mock password "hashing" for MVP
    new_user = models.User(
        email=user.email,
        full_name=user.full_name,
        hashed_password=f"mock_hash_{user.password}"
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # create default gamification profile
    profile = models.GamificationProfile(user_id=new_user.id)
    db.add(profile)
    db.commit()
    
    return {"id": new_user.id, "email": new_user.email, "message": "Registered successfully"}

@router.post("/login")
def login(user: UserLogin, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if not db_user or db_user.hashed_password != f"mock_hash_{user.password}":
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {"token": f"mock_token_{db_user.id}", "user_id": db_user.id, "role": db_user.role}

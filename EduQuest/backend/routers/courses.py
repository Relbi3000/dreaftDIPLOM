from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, database
from typing import List
from pydantic import BaseModel

router = APIRouter()

class LessonSchema(BaseModel):
    id: int
    title: str
    content: str
    order: int

    class Config:
        from_attributes = True

class CourseSchema(BaseModel):
    id: int
    title: str
    description: str

    class Config:
        from_attributes = True

@router.get("/", response_model=List[CourseSchema])
def get_courses(db: Session = Depends(database.get_db)):
    return db.query(models.Course).all()

@router.get("/{course_id}/lessons", response_model=List[LessonSchema])
def get_lessons(course_id: int, db: Session = Depends(database.get_db)):
    lessons = db.query(models.Lesson).filter(models.Lesson.course_id == course_id).order_by(models.Lesson.order).all()
    if not lessons:
        return []
    return lessons

@router.get("/lessons/{lesson_id}", response_model=LessonSchema)
def get_lesson(lesson_id: int, db: Session = Depends(database.get_db)):
    lesson = db.query(models.Lesson).filter(models.Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return lesson

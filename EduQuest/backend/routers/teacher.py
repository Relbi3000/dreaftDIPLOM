from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from pydantic import BaseModel
from typing import Optional
import models, database, dependencies
import json

router = APIRouter()

@router.get("/dashboard")
def get_teacher_dashboard(db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_teacher)):
    # Total students
    total_students = db.query(models.User).filter(models.User.role == "student").count()
    
    # Average score & Total Attempts
    attempts_query = db.query(func.avg(models.Attempt.score), func.count(models.Attempt.id)).first()
    avg_score = float(attempts_query[0]) if attempts_query[0] is not None else 0.0
    total_attempts = int(attempts_query[1]) if attempts_query[1] is not None else 0

    return {
        "overview": {
            "total_students": total_students,
            "average_score": avg_score,
            "total_attempts": total_attempts
        }
    }

@router.get("/students-progress")
def get_students_progress(db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_teacher)):
    students = db.query(models.User).filter(models.User.role == "student").all()
    
    result = []
    for s in students:
        profile = s.profile
        completed = db.query(func.count(models.CompletedLesson.id)).filter(models.CompletedLesson.user_id == s.id).scalar()
        result.append({
            "id": s.id,
            "name": s.full_name,
            "email": s.email,
            "level": profile.level if profile else 1,
            "xp": profile.xp if profile else 0,
            "streak": profile.streak if profile else 0,
            "lessons_completed": completed
        })
    return result

@router.get("/recent-attempts")
def get_recent_attempts(limit: int = 10, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_teacher)):
    attempts = db.query(models.Attempt).order_by(models.Attempt.created_at.desc()).limit(limit).all()
    result = []
    for a in attempts:
        user = db.query(models.User).filter(models.User.id == a.user_id).first()
        quiz = db.query(models.Quiz).filter(models.Quiz.id == a.quiz_id).first()
        result.append({
            "id": a.id,
            "user_name": user.full_name if user else "Unknown",
            "quiz_title": quiz.title if quiz else "Quiz",
            "score": a.score,
            "earned_xp": a.earned_xp,
            "created_at": a.created_at.isoformat() if a.created_at else None
        })
    return result

class CourseCreate(BaseModel):
    title: str
    description: str

class LessonCreate(BaseModel):
    course_id: int
    title: str
    content: str
    order: int

class QuizCreate(BaseModel):
    lesson_id: int
    title: str
    questions: list

@router.post("/courses")
def create_course(course: CourseCreate, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_teacher)):
    new_course = models.Course(title=course.title, description=course.description)
    db.add(new_course)
    db.commit()
    db.refresh(new_course)
    return {"id": new_course.id, "title": new_course.title}

@router.post("/lessons")
def create_lesson(lesson: LessonCreate, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_teacher)):
    new_lesson = models.Lesson(course_id=lesson.course_id, title=lesson.title, content=lesson.content, order=lesson.order)
    db.add(new_lesson)
    db.commit()
    db.refresh(new_lesson)
    return {"id": new_lesson.id, "title": new_lesson.title}

@router.post("/quizzes")
def create_quiz(quiz: QuizCreate, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.require_teacher)):
    new_quiz = models.Quiz(lesson_id=quiz.lesson_id, title=quiz.title, questions=json.dumps(quiz.questions))
    db.add(new_quiz)
    db.commit()
    db.refresh(new_quiz)
    return {"id": new_quiz.id, "title": new_quiz.title}


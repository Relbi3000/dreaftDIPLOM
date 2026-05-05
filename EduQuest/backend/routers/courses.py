from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, database
from typing import List
from pydantic import BaseModel
import json

router = APIRouter()


def _quiz_count_for_lesson(db: Session, lesson_id: int) -> int:
    return db.query(models.Quiz).filter(models.Quiz.lesson_id == lesson_id).count()


def _course_metadata(db: Session, course: models.Course) -> dict:
    lessons = (
        db.query(models.Lesson)
        .filter(models.Lesson.course_id == course.id)
        .order_by(models.Lesson.order)
        .all()
    )
    lesson_count = len(lessons)
    quiz_count = sum(_quiz_count_for_lesson(db, lesson.id) for lesson in lessons)
    effort_hours = max(1, lesson_count * 2)
    difficulty = (
        "Beginner"
        if course.id % 3 == 1
        else "Intermediate"
        if course.id % 3 == 2
        else "Advanced"
    )
    return {
        "lesson_count": lesson_count,
        "quiz_count": quiz_count,
        "difficulty": difficulty,
        "estimated_effort": f"{effort_hours}-{effort_hours + 1} hrs",
    }


def _lesson_summary(db: Session, lesson: models.Lesson) -> dict:
    quiz_count = _quiz_count_for_lesson(db, lesson.id)
    content = lesson.content or ""
    summary = content[:140].strip()
    if len(content) > 140:
        summary = f"{summary}..."
    return {
        "id": lesson.id,
        "title": lesson.title,
        "content": lesson.content,
        "order": lesson.order,
        "quiz_count": quiz_count,
        "has_quiz": quiz_count > 0,
        "estimated_minutes": 15 + (quiz_count * 5),
        "summary": summary,
    }


def _question_count(quiz: models.Quiz) -> int:
    try:
        questions = json.loads(quiz.questions or "[]")
        return len(questions) if isinstance(questions, list) else 0
    except (TypeError, json.JSONDecodeError):
        return 0


class LessonSchema(BaseModel):
    id: int
    title: str
    content: str
    order: int
    quiz_count: int
    has_quiz: bool
    estimated_minutes: int
    summary: str


class CourseSchema(BaseModel):
    id: int
    title: str
    description: str
    lesson_count: int
    quiz_count: int
    difficulty: str
    estimated_effort: str


class CourseQuizSummarySchema(BaseModel):
    id: int
    title: str
    question_count: int


class CourseLessonContentSchema(LessonSchema):
    quizzes: list[CourseQuizSummarySchema]


class CourseContentMapSchema(BaseModel):
    course: CourseSchema
    lessons: list[CourseLessonContentSchema]


@router.get("/", response_model=List[CourseSchema])
def get_courses(db: Session = Depends(database.get_db)):
    courses = db.query(models.Course).order_by(models.Course.id).all()
    return [
        {
            "id": course.id,
            "title": course.title,
            "description": course.description,
            **_course_metadata(db, course),
        }
        for course in courses
    ]


@router.get("/{course_id}/lessons", response_model=List[LessonSchema])
def get_lessons(course_id: int, db: Session = Depends(database.get_db)):
    lessons = (
        db.query(models.Lesson)
        .filter(models.Lesson.course_id == course_id)
        .order_by(models.Lesson.order)
        .all()
    )
    if not lessons:
        return []
    return [_lesson_summary(db, lesson) for lesson in lessons]


@router.get("/{course_id}/content-map", response_model=CourseContentMapSchema)
def get_course_content_map(course_id: int, db: Session = Depends(database.get_db)):
    course = db.query(models.Course).filter(models.Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    lessons = (
        db.query(models.Lesson)
        .filter(models.Lesson.course_id == course_id)
        .order_by(models.Lesson.order)
        .all()
    )

    lesson_payloads = []
    for lesson in lessons:
        quizzes = (
            db.query(models.Quiz)
            .filter(models.Quiz.lesson_id == lesson.id)
            .order_by(models.Quiz.id)
            .all()
        )
        lesson_payloads.append(
            {
                **_lesson_summary(db, lesson),
                "quizzes": [
                    {
                        "id": quiz.id,
                        "title": quiz.title,
                        "question_count": _question_count(quiz),
                    }
                    for quiz in quizzes
                ],
            }
        )

    return {
        "course": {
            "id": course.id,
            "title": course.title,
            "description": course.description,
            **_course_metadata(db, course),
        },
        "lessons": lesson_payloads,
    }


@router.get("/lessons/{lesson_id}", response_model=LessonSchema)
def get_lesson(lesson_id: int, db: Session = Depends(database.get_db)):
    lesson = db.query(models.Lesson).filter(models.Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return _lesson_summary(db, lesson)

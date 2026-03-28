from database import SessionLocal, engine
import models
import json

def seed_db():
    print("Dropping all tables to reset state...")
    models.Base.metadata.drop_all(bind=engine)
    print("Recreating tables...")
    models.Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    
    print("Seeding users...")
    users_data = [
        {"email": "student@eduquest.com", "full_name": "Demo Student", "role": "student"},
        {"email": "teacher@eduquest.com", "full_name": "Demo Teacher", "role": "teacher"},
        {"email": "admin@eduquest.com", "full_name": "Demo Admin", "role": "admin"}
    ]
    
    users = []
    for ud in users_data:
        user = models.User(
            email=ud["email"],
            full_name=ud["full_name"],
            hashed_password="mock_hash_password123",
            role=ud["role"]
        )
        db.add(user)
        users.append(user)
        
    db.commit()
    for user in users:
        db.refresh(user)
        profile = models.GamificationProfile(user_id=user.id)
        if user.role == "student":
            profile.xp = 1250
            profile.level = 3
            profile.streak = 5
        db.add(profile)
        
    db.commit()

    print("Seeding courses...")
    course1 = models.Course(
        title="Introduction to Computer Science",
        description="Learn the basics of programming and computer systems."
    )
    course2 = models.Course(
        title="AI and Machine Learning 101",
        description="A foundational course on how AI learns and makes decisions."
    )
    db.add(course1)
    db.add(course2)
    db.commit()
    db.refresh(course1)
    db.refresh(course2)
    
    print("Seeding lessons...")
    lesson1 = models.Lesson(
        course_id=course1.id,
        title="Variables and Data Types",
        content="Variables are containers for storing data values. In programming, data types specify what kind of data can be stored and manipulated within a program.",
        order=1
    )
    lesson2 = models.Lesson(
        course_id=course1.id,
        title="Control Structures (Loops)",
        content="Control structures determine the flow of execution in a program. Loops (like 'for' and 'while') allow you to repeat a block of code.",
        order=2
    )
    db.add(lesson1)
    db.add(lesson2)
    db.commit()
    db.refresh(lesson1)
    db.refresh(lesson2)
    
    print("Seeding quizzes...")
    quiz1_data = [
        {"q": "What is a variable?", "options": ["A data container", "A loop", "A function", "An error"], "answer": 0},
        {"q": "Which is NOT a standard data type?", "options": ["Integer", "String", "Elephant", "Boolean"], "answer": 2}
    ]
    quiz1 = models.Quiz(
        lesson_id=lesson1.id,
        title="Variables Quiz",
        questions=json.dumps(quiz1_data)
    )
    
    quiz2_data = [
        {"q": "Which loop is best when you know the number of iterations?", "options": ["while loop", "do-while loop", "for loop", "infinite loop"], "answer": 2}
    ]
    quiz2 = models.Quiz(
        lesson_id=lesson2.id,
        title="Loops Quiz",
        questions=json.dumps(quiz2_data)
    )
    
    db.add(quiz1)
    db.add(quiz2)
    db.commit()
    db.refresh(quiz1)
    
    print("Seeding attempts...")
    student = users[0]
    attempt = models.Attempt(
        user_id=student.id,
        quiz_id=quiz1.id,
        score=1.0,
        earned_xp=100
    )
    db.add(attempt)
    db.commit()

    print("Database seeded successfully with demo content!")

if __name__ == "__main__":
    seed_db()

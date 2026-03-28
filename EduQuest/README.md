# EduQuest - AI-Enhanced Game-Based Learning (MVP)

This repository contains the MVP prototype developed for the bachelor thesis **"Development of an Application for AI-Enhanced Game-Based Learning"**.

It comprises a **Flutter frontend** and a **FastAPI backend (Python)** with a SQLite database. 

## Features

The MVP aligns perfectly with the thesis defense requirements and provides the following flows:

1. **Student Flow**: Gamified dashboard (XP/Levels), course browsing, lesson viewing, AI Tutor hint integration (mocked backend), and quiz submission.
2. **Teacher Flow**: Simple dashboard to view available courses and track student progress (Level, XP, Streak).
3. **Admin Flow**: Simple platform control dashboard showing mock platform safety status and viewing registered users.
4. **Analytics**: Overview of total platform usage (users, average scores, top students).

> **Note:** The AI Tutor responses and moderation filters are mocked on the backend to guarantee reliability during the live defense demonstration.

---

## 🔑 Demo Credentials

The database is seeded with 3 demo users so you can instantly log in and explore different roles:

| Role      | Email                  | Password      |
| --------- | ---------------------- | ------------- |
| **Student** | `student@eduquest.com` | `password123` |
| **Teacher** | `teacher@eduquest.com` | `password123` |
| **Admin**   | `admin@eduquest.com`   | `password123` |

---

## 🚀 Running the Project

### 1. Backend (FastAPI)

1. Navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Activate your virtual environment and install dependencies (if not already done):
   ```bash
   pip install -r requirements.txt
   ```
3. **Reset and Seed the Database:**
   To guarantee a clean slate for the defense demonstration, run this to drop tables, recreate them, and seed the demo data:
   ```bash
   python seed.py
   ```
4. Start the backend server:
   ```bash
   uvicorn main:app --reload
   ```
   *The server runs by default on `http://127.0.0.1:8000`.*

### 2. Frontend (Flutter)

1. Open a new terminal and navigate to the frontend folder:
   ```bash
   cd frontend
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app (ensure you have an emulator open or run it on desktop/web):
   ```bash
   flutter run
   ```

*(Note: The `api_service.dart` is configured to connect to `127.0.0.1`. If you run Android Emulator, you may need to map ports or change `baseUrl` to `10.0.2.2`).*

---

## 🏛️ Recommended Defense Demo Sequence

1. **Start clean:** Run `python seed.py` before presenting.
2. **Student Demo:** 
   - Open app and log in as `student@eduquest.com`. 
   - Show dashboard with 1250 XP and Level 3. 
   - Open "Introduction to Computer Science" course.
   - Open a Lesson, ask the AI Tutor for help (shows mock UI working).
   - Take the Quiz, answer questions.
   - Show the final screen with XP earned, and return to the dashboard to prove updated state.
3. **Teacher Demo:**
   - Log out, log in as `teacher@eduquest.com`.
   - Show Teacher Dashboard listing available demo courses.
   - Show that the student's XP / Level progress went up after the quiz.
4. **Admin Demo:**
   - Log out, log in as `admin@eduquest.com`.
   - Show Admin Dashboard with platform status and user accounts overview.

---

## Limitations (Defense Scope)

This is an **MVP (Minimum Viable Product)**. Some buttons might lead to simple mock states (e.g., AI Tutor). No actual Firebase, production auth, or microservice structure is intentionally used to maintain stability for the thesis defense.

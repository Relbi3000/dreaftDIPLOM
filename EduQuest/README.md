# EduQuest - AI-Enhanced Game-Based Learning (Final MVP)

This repository contains the upgraded MVP prototype developed for the bachelor thesis **"Development of an Application for AI-Enhanced Game-Based Learning"**.

It comprises a **Flutter frontend** and a **FastAPI backend (Python)** with a SQLite database. 

## Upgraded Features

The MVP now completely fulfills the thesis defense requirements with working logic:

1. **Student Flow**: Gamified dashboard (XP/Levels), course browsing, lesson viewing, logged AI Tutor with safety context, and adaptive quiz feedback based on Dynamic XP settings.
2. **Teacher Flow**: Full Content Management (Creation of Courses, Lessons, Quizzes via JSON) and tracking student progress.
3. **Admin Flow**: Real-time System Configuration (toggling AI safety, quiz retries, and XP values), editing user roles, and deactivating user accounts.
4. **Analytics**: Overview of total platform usage (users, average scores, top students).

> **Note:** The AI Tutor responses and moderation filters are mocked on the backend but correctly execute context enforcement, filtering rules, and store interaction logs into the database to demonstrate architecture viability during the defense.

---

## 🔑 Demo Credentials

The database is seeded with initial settings and demo users:

| Role      | Email                  | Password      |
| --------- | ---------------------- | ------------- |
| **Student** | `student@eduquest.com` | `password123` |
| **Teacher** | `teacher@eduquest.com` | `password123` |
| **Admin**   | `admin@eduquest.com`   | `password123` |

---

## 🚀 Running the Project

### 1. Configuration (Important)
API target addresses are completely unified. Open `frontend/lib/config.dart` and ensure `AppConfig.baseUrl` matches your machine's IP address (e.g., `http://192.168.1.68:8000/api`) or your emulator's loopback (`http://10.0.2.2:8000/api`).

### 2. Backend (FastAPI)

1. Navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Activate your virtual environment and install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. **Reset and Seed the Database:**
   To guarantee a clean slate with AI logs and System Configs for the defense demonstration, run:
   ```bash
   python seed.py
   ```
4. Start the backend server on all network interfaces:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

### 3. Frontend (Flutter)

1. Open a new terminal and navigate to the frontend folder:
   ```bash
   cd frontend
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on your chosen device:
   ```bash
   flutter run
   ```

---

## 🏛️ Recommended Defense Demo Sequence

1. **Start Clean:** Run `python seed.py` before presenting.
2. **Admin Phase:**
   - Log in as `admin@eduquest.com`.
   - Show the dynamic **System Configuration** toggles. 
   - Deactivate a test user or change a role.
3. **Teacher Phase:**
   - Log out, log in as `teacher@eduquest.com`.
   - Show Teacher Dashboard listing available demo courses.
   - Click **Create Content** and quickly scaffold a new "Live Demo Course".
4. **Student Phase:** 
   - Log out, log in as `student@eduquest.com`. 
   - View the newly created course from the Teacher.
   - Enter a Quiz, answer questions, and show the **Adaptive Feedback** and XP rewards calculated by the Admin's system settings!
   - Show the AI Tutor respecting (or blocking) queries based on the Admin Safety Configuration flag.

---

## Limitations (Defense Scope)

This is a targeted **MVP (Minimum Viable Product)** tightly scoping out thesis demands. Advanced cloud deployment, OAuth standards, and heavy production AI inference are sidestepped in favor of reliable, offline-capable database transaction mocks.

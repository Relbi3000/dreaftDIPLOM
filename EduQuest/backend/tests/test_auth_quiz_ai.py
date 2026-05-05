import routers.ai_tutor as ai_tutor_router


def test_auth_me_and_profile_update_for_all_roles(client, auth_headers):
    student = client.get("/api/auth/me", headers=auth_headers("student@eduquest.com"))
    teacher = client.get("/api/auth/me", headers=auth_headers("teacher@eduquest.com"))
    admin = client.get("/api/auth/me", headers=auth_headers("admin@eduquest.com"))

    assert student.status_code == 200
    assert teacher.status_code == 200
    assert admin.status_code == 200
    assert student.json()["role"] == "student"
    assert teacher.json()["role"] == "teacher"
    assert admin.json()["role"] == "admin"

    updated = client.put(
        "/api/auth/me",
        headers=auth_headers("teacher@eduquest.com"),
        json={"full_name": "  Teacher Renamed  "},
    )
    assert updated.status_code == 200
    assert updated.json()["full_name"] == "Teacher Renamed"


def test_change_password_validates_current_password(client, auth_headers):
    response = client.put(
        "/api/auth/change-password",
        headers=auth_headers("admin@eduquest.com"),
        json={
            "current_password": "wrong-password",
            "new_password": "new-password-123",
        },
    )
    assert response.status_code == 400
    assert response.json()["detail"] == "Current password is incorrect"


def test_quiz_submission_and_attempt_access_rules(client, auth_headers, seeded_ids):
    submit = client.post(
        "/api/quizzes/2/submit",
        headers=auth_headers("student@eduquest.com"),
        json={"user_id": seeded_ids["student@eduquest.com"], "score": 0.8},
    )
    assert submit.status_code == 200
    body = submit.json()
    assert body["score"] == 0.8
    assert "attempt_id" in body
    assert "new_streak" in body

    forbidden_submit = client.post(
        "/api/quizzes/2/submit",
        headers=auth_headers("student@eduquest.com"),
        json={"user_id": seeded_ids["alice@eduquest.com"], "score": 0.7},
    )
    assert forbidden_submit.status_code == 403

    own_attempts = client.get(
        f"/api/quizzes/user/{seeded_ids['student@eduquest.com']}/attempts",
        headers=auth_headers("student@eduquest.com"),
    )
    assert own_attempts.status_code == 200
    assert len(own_attempts.json()) >= 1

    forbidden_attempts = client.get(
        f"/api/quizzes/user/{seeded_ids['student@eduquest.com']}/attempts",
        headers=auth_headers("alice@eduquest.com"),
    )
    assert forbidden_attempts.status_code == 403

    teacher_attempts = client.get(
        f"/api/quizzes/user/{seeded_ids['student@eduquest.com']}/attempts",
        headers=auth_headers("teacher@eduquest.com"),
    )
    assert teacher_attempts.status_code == 200


def test_ai_review_shapes_and_user_validation(client, auth_headers, seeded_ids, monkeypatch):
    monkeypatch.setattr(ai_tutor_router.time, "sleep", lambda _: None)

    payload = {
        "user_id": seeded_ids["student@eduquest.com"],
        "lesson_title": "Variables and Data Types",
        "wrong_answers": [
            {
                "question": "Which is NOT a standard data type?",
                "options": ["Integer", "String", "Elephant", "Boolean"],
                "user_answer_index": 1,
                "correct_answer_index": 2,
            },
        ],
    }

    review = client.post(
        "/api/ai-tutor/review-mistakes",
        headers=auth_headers("student@eduquest.com"),
        json=payload,
    )
    assert review.status_code == 200
    review_body = review.json()
    assert "summary" in review_body
    assert isinstance(review_body["explanations"], list)

    chat = client.post(
        "/api/ai-tutor/review-chat",
        headers=auth_headers("student@eduquest.com"),
        json={**payload, "user_question": "Why is Elephant wrong?"},
    )
    assert chat.status_code == 200
    assert "answer" in chat.json()

    forbidden = client.post(
        "/api/ai-tutor/review-mistakes",
        headers=auth_headers("student@eduquest.com"),
        json={**payload, "user_id": seeded_ids["alice@eduquest.com"]},
    )
    assert forbidden.status_code == 403

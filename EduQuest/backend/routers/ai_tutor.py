from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import datetime
import time
import models, database, dependencies

router = APIRouter()

class HintRequest(BaseModel):
    user_id: int
    context: str # e.g. "Question 2 on arrays"
    user_question: str

@router.post("/hint")
def request_hint(request: HintRequest, db: Session = Depends(database.get_db), current_user: models.User = Depends(dependencies.get_active_student)):
    # Simulator delay to represent LLM latency
    time.sleep(1.5)

    config = db.query(models.SystemConfig).first()
    safety_enabled = config.ai_safety if config else True
    
    query = request.user_question.lower()
    hint_response = ""
    
    if safety_enabled and ("hack" in query or "bypass" in query or "answer" in query):
        hint_response = "[Blocked by AI Safety] I cannot provide direct answers or inappropriate content. Please try to solve the problem yourself!"
    elif "array" in query or "list" in query:
        hint_response = "An array is a data structure consisting of a collection of elements. Think of it like a row of mailboxes."
    elif "loop" in query or "for" in query or "while" in query:
        hint_response = "Loops let you run the same block of code multiple times. Use a 'for' loop when you know how many times to repeat."
    elif "function" in query or "method" in query:
        hint_response = "A function is a reusable block of code that performs a specific task."
    else:
        hint_response = "A good strategy here is to break down the problem. What are the inputs, and what is the expected output?"

    # Log to DB
    new_log = models.AILog(
        user_id=request.user_id,
        context=request.context,
        question=request.user_question,
        hint=hint_response,
        timestamp=datetime.utcnow()
    )
    db.add(new_log)
    db.commit()
    
    return {
        "hint": hint_response,
        "source": "mocked_safe_gateway" if safety_enabled else "mocked_llm_gateway"
    }

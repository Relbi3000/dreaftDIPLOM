from fastapi import APIRouter
from pydantic import BaseModel
import time

router = APIRouter()

class HintRequest(BaseModel):
    user_id: int
    context: str # e.g. "Question 2 on arrays"
    user_question: str

@router.post("/hint")
def request_hint(request: HintRequest):
    # This mocks the AI Tutor Gateway -> n8n -> LLM API flow
    # described in the thesis diagram (Figure 5.4)
    # Simulator delay to represent LLM latency
    time.sleep(1.5)
    
    # Simple algorithmic fallback/simulation for the MVP demo
    query = request.user_question.lower()
    hint_response = ""
    
    if "array" in query or "list" in query:
        hint_response = "An array is a data structure consisting of a collection of elements, each identified by at least one array index. Think of it like a row of mailboxes."
    elif "loop" in query or "for" in query or "while" in query:
        hint_response = "Loops let you run the same block of code multiple times. Use a 'for' loop when you know how many times to repeat, and a 'while' loop when repeating until a condition is met."
    elif "function" in query or "method" in query:
        hint_response = "A function is a reusable block of code that performs a specific task. You can pass parameters into it and get a result out."
    else:
        hint_response = "A good strategy here is to break down the problem. What are the inputs, and what is the expected output? Try to trace the code step-by-step."
        
    return {
        "hint": hint_response,
        "source": "mocked_llm_gateway"
    }

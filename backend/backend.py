from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
from gptprompt.prompter import correctExercice, init_firebase

app = FastAPI()
class Correction_Request(BaseModel):
    userID: str
    examID: str
    exerciseID: str

@app.post("/correction/")
async def correct_exam(request: Correction_Request, background_tasks: BackgroundTasks):
        background_tasks.add_task(correctExercice, request.userID, request.examID, request.exerciseID)    
        return {
        "message": f"Exam '{request.examID}' is being corrected for user '{request.userID}'.",
    }

# starten mit: "python -m uvicorn backend:app --reload"
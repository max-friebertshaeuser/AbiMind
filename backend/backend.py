from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel

app = FastAPI()

class Correction_Request(BaseModel):#
    userID: str
    examID: str

@app.post("/corretion/")
async def correct_exam(request: Correction_Request):
    return {
        "message": f"Exam '{request.examID}' is being corrected for user '{request.userID}'.",
    }
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from compass_backend.database import get_db
from compass_backend.models import Student
from compass_backend.schemas import LoginRequest, UserResponse
from compass_backend.security import verify_password

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=UserResponse)
def login(credentials: LoginRequest, db: Session = Depends(get_db)):
    # 1. Search for student by email in the DB
    student = db.query(Student).filter(Student.email == credentials.email).first()
    
    if not student:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials: email not found."
        )

    # 2. Verify if the entered password matches the stored hash
    if not verify_password(credentials.password, student.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials: incorrect password."
        )

    # 3. Return the authenticated user information
    return student

from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from compass_backend.database import get_db
from compass_backend.models import Student
from compass_backend.schemas import UserResponse

router = APIRouter(prefix="/students", tags=["Students"])

@router.get("/", response_model=List[UserResponse])
def get_all_students(db: Session = Depends(get_db)):
    """Retorna todos los estudiantes registrados en la base de datos PostgreSQL."""
    students = db.query(Student).all()
    return students

@router.get("/{student_id}", response_model=UserResponse)
def get_student_by_id(student_id: int, db: Session = Depends(get_db)):
    """Retorna la informacion de un estudiante especifico por su ID."""
    student = db.query(Student).filter(Student.student_id == student_id).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    return student
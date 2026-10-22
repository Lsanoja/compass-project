from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from compass_backend.database import get_db
from compass_backend.models import Student
from compass_backend.schemas import LoginRequest, UserResponse
from compass_backend.security import verify_password

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=UserResponse)
def login(credentials: LoginRequest, db: Session = Depends(get_db)):
    # 1. Buscar al estudiante por correo electrónico en la BD
    student = db.query(Student).filter(Student.email == credentials.email).first()
    
    if not student:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales invalidas: correo no encontrado."
        )

    # 2. Verificar si la contraseña ingresada coincide con el hash almacenado
    if not verify_password(credentials.password, student.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales invalidas: contrasena incorrecta."
        )

    # 3. Retornar la información del usuario autenticado
    return student
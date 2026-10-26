from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# =============================================================================
# 1. AUTHENTICATION AND STUDENT SCHEMAS
# =============================================================================

class StudentBase(BaseModel):
    student_id: int
    first_name: str
    last_name: str
    email: str
    major: str
    graduation_date: str
    gender: Optional[str] = None

class StudentCreate(StudentBase):
    password: str

class StudentResponse(StudentBase):
    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    student_id: int
    first_name: str
    last_name: str
    email: str
    major: str

    class Config:
        from_attributes = True


# =============================================================================
# 2. MATCHING ENGINE SCHEMAS
# =============================================================================

class MatchEvaluationRequest(BaseModel):
    student_id: int
    job_id: int

class MatchResultResponse(BaseModel):
    match_id: int
    student_id: int
    job_id: int
    match_score: float
    eligibility_status: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

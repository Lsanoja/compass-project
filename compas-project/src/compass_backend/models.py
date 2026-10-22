from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Boolean, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from compass_backend.database import Base

# -----------------------------------------------------------------------------
# 1. CATALOGS AND MAIN ENTITIES
# -----------------------------------------------------------------------------

class Student(Base):
    __tablename__ = "student"
    __table_args__ = {'extend_existing': True}

    student_id = Column(Integer, primary_key=True, index=True)  # 8-digit J-Number
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    major = Column(String(50), nullable=False)
    graduation_date = Column(String(20), nullable=False)
    password_hash = Column(String(255), nullable=False)
    gender = Column(String(10))

class Company(Base):
    __tablename__ = "company"

    company_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    industry = Column(String(50))
    phone_number = Column(String(20))
    email = Column(String(100))
    address = Column(String(200))

class Skill(Base):
    __tablename__ = "skill"

    skill_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    skill_name = Column(String(50), unique=True, nullable=False)
    category = Column(String(50))

class UniversityCourse(Base):
    __tablename__ = "universitycourse"

    course_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    course_code = Column(String(20), unique=True, nullable=False)
    course_name = Column(String(100), nullable=False)
    credits = Column(Integer, nullable=False)

class ExternalCourse(Base):
    __tablename__ = "externalcourse"

    external_course_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    provider = Column(String(50), nullable=False)
    title = Column(String(100), nullable=False)
    url = Column(String(255))
    cost = Column(Numeric(10, 2))

# -----------------------------------------------------------------------------
# 2. DEPENDENT ENTITIES & MATCHING RESULTS
# -----------------------------------------------------------------------------

class Job(Base):
    __tablename__ = "job"

    job_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    company_id = Column(Integer, ForeignKey("COMPANY.company_id", ondelete="CASCADE"), nullable=False)
    title = Column(String(100), nullable=False)
    description = Column(Text)
    location = Column(String(100))
    status = Column(String(20), default="OPEN")

class MatchResult(Base):
    __tablename__ = "matchresult"

    match_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    student_id = Column(Integer, ForeignKey("STUDENT.student_id", ondelete="CASCADE"), nullable=False)
    job_id = Column(Integer, ForeignKey("JOB.job_id", ondelete="CASCADE"), nullable=False)
    match_score = Column(Numeric(5, 2), nullable=False)
    eligibility_status = Column(String(20), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
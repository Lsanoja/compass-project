-- =============================================================================
-- PROJECT: COMPASS (Matching Engine & Recommendation System)
-- FILE: scripts/schema.sql
-- DESCRIPTION: DDL to create the 13 tables for the Entity Model Layer (EML)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CATALOGS AND MAIN ENTITIES (NO FOREIGN KEY DEPENDENCIES)
-- -----------------------------------------------------------------------------

-- Table: STUDENT
-- Stores student profile information
CREATE TABLE IF NOT EXISTS STUDENT (
    student_id INT PRIMARY KEY,                       -- Represents the 8-digit J-Number[cite: 1, 5]
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    major VARCHAR(50) NOT NULL,                       -- e.g., 'Computer Science', 'Computer Engineering'[cite: 1, 5]
    graduation_date DATE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,              -- Sufficient length for Bcrypt/Argon2 hashes[cite: 1, 5]
    gender VARCHAR(10)
);

-- Table: COMPANY
-- Stores registered employer companies
CREATE TABLE IF NOT EXISTS COMPANY (
    company_id SERIAL PRIMARY KEY,                    -- Auto-incrementing unique identifier[cite: 5]
    name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(200)
);

-- Table: SKILL
-- Global master catalog of technical and soft skills
CREATE TABLE IF NOT EXISTS SKILL (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(50)                              -- e.g., 'Programming Language', 'Database', 'Soft Skill'
);

-- Table: UNIVERSITYCOURSE
-- Catalog of official university courses
CREATE TABLE IF NOT EXISTS UNIVERSITYCOURSE (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,          -- e.g., 'CSC-450'
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL
);

-- Table: EXTERNALCOURSE
-- Catalog of external certifications and courses (Coursera, Udemy, AWS, etc.)
CREATE TABLE IF NOT EXISTS EXTERNALCOURSE (
    external_course_id SERIAL PRIMARY KEY,
    provider VARCHAR(50) NOT NULL,                     -- e.g., 'Coursera', 'AWS', 'Udacity'
    title VARCHAR(100) NOT NULL,
    url VARCHAR(255),
    cost DECIMAL(10, 2)
);


-- -----------------------------------------------------------------------------
-- 2. DEPENDENT ENTITIES
-- -----------------------------------------------------------------------------

-- Table: JOB
-- Job postings published by companies
CREATE TABLE IF NOT EXISTS JOB (
    job_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    location VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',       -- 'OPEN', 'CLOSED'
    CONSTRAINT fk_job_company 
        FOREIGN KEY (company_id) REFERENCES COMPANY(company_id) 
        ON DELETE CASCADE
);


-- -----------------------------------------------------------------------------
-- 3. BRIDGE TABLES / N:M RELATIONS
-- -----------------------------------------------------------------------------

-- Bridge Table: StudentCourse
-- Academic history of courses completed by each student
CREATE TABLE IF NOT EXISTS StudentCourse (
    student_course_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    term_taken VARCHAR(20) NOT NULL,                  -- e.g., 'Fall 2026'
    grade VARCHAR(5),                                 -- e.g., 'A', 'B+'
    completion_status VARCHAR(20) NOT NULL,           -- e.g., 'COMPLETED', 'IN_PROGRESS'
    CONSTRAINT fk_studentcourse_student 
        FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_studentcourse_course 
        FOREIGN KEY (course_id) REFERENCES UNIVERSITYCOURSE(course_id) 
        ON DELETE CASCADE
);

-- Bridge Table: StudentSkill
-- Skills declared by the student along with evidence
CREATE TABLE IF NOT EXISTS StudentSkill (
    student_skill_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    skill_id INT NOT NULL,
    level VARCHAR(20),                                -- e.g., 'Beginner', 'Intermediate', 'Advanced'
    evidence TEXT,                                    -- Portfolio or repository links
    CONSTRAINT fk_studentskill_student 
        FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_studentskill_skill 
        FOREIGN KEY (skill_id) REFERENCES SKILL(skill_id) 
        ON DELETE CASCADE
);

-- Bridge Table: CourseSkill
-- Skills covered or taught by a university course
CREATE TABLE IF NOT EXISTS CourseSkill (
    course_skill_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    skill_id INT NOT NULL,
    coverage_level VARCHAR(20),                       -- e.g., 'Introductory', 'Advanced'
    CONSTRAINT fk_courseskill_course 
        FOREIGN KEY (course_id) REFERENCES UNIVERSITYCOURSE(course_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_courseskill_skill 
        FOREIGN KEY (skill_id) REFERENCES SKILL(skill_id) 
        ON DELETE CASCADE
);

-- Bridge Table: ExternalCourseSkill
-- Skills certified by an external course
CREATE TABLE IF NOT EXISTS ExternalCourseSkill (
    external_course_skill_id SERIAL PRIMARY KEY,
    external_course_id INT NOT NULL,
    skill_id INT NOT NULL,
    coverage_level VARCHAR(20),
    CONSTRAINT fk_extcourseskill_extcourse 
        FOREIGN KEY (external_course_id) REFERENCES EXTERNALCOURSE(external_course_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_extcourseskill_skill 
        FOREIGN KEY (skill_id) REFERENCES SKILL(skill_id) 
        ON DELETE CASCADE
);

-- Bridge Table: JobRequirement
-- Skills required by a specific job opening
CREATE TABLE IF NOT EXISTS JobRequirement (
    requirement_id SERIAL PRIMARY KEY,
    job_id INT NOT NULL,
    skill_id INT NOT NULL,
    required_level VARCHAR(20),                       -- e.g., 'Intermediate', 'Advanced'
    mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    weight DECIMAL(3, 2) DEFAULT 1.00,                -- Requirement weight for scoring calculations
    CONSTRAINT fk_jobreq_job 
        FOREIGN KEY (job_id) REFERENCES JOB(job_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_jobreq_skill 
        FOREIGN KEY (skill_id) REFERENCES SKILL(skill_id) 
        ON DELETE CASCADE
);


-- -----------------------------------------------------------------------------
-- 4. MATCHING ENGINE AND RECOMMENDATIONS
-- -----------------------------------------------------------------------------

-- Table: MatchResult
-- Stores compatibility scores calculated between a student and a job
CREATE TABLE IF NOT EXISTS MatchResult (
    match_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    job_id INT NOT NULL,
    match_score DECIMAL(5, 2) NOT NULL,               -- Match percentage (e.g., 85.50)
    eligibility_status VARCHAR(20) NOT NULL,          -- e.g., 'ELIGIBLE', 'GAP_DETECTED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_student 
        FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_match_job 
        FOREIGN KEY (job_id) REFERENCES JOB(job_id) 
        ON DELETE CASCADE
);

-- Table: RECOMMENDATION
-- Generated recommendations to bridge skill gaps found in a MatchResult
CREATE TABLE IF NOT EXISTS RECOMMENDATION (
    recommendation_id SERIAL PRIMARY KEY,
    match_id INT NOT NULL,
    recommendation_type VARCHAR(50) NOT NULL,         -- e.g., 'UNIVERSITY_COURSE', 'EXTERNAL_COURSE'
    target_id INT NOT NULL,                           -- ID of the recommended course or resource
    priority VARCHAR(20) DEFAULT 'MEDIUM',            -- 'HIGH', 'MEDIUM', 'LOW'
    CONSTRAINT fk_rec_match 
        FOREIGN KEY (match_id) REFERENCES MatchResult(match_id) 
        ON DELETE CASCADE
);
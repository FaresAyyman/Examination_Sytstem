-- Create Database
CREATE DATABASE ITI_Examination_System;
GO
USE ITI_Examination_System;

-- Branch Table
CREATE TABLE Branch (
    branch_id INT PRIMARY KEY,
    branch_name NVARCHAR(100)
);

-- Intake Table
CREATE TABLE Intake (
    intake_id INT PRIMARY KEY,
    intake_name NVARCHAR(100)
);

-- Track Table
CREATE TABLE Track (
    track_id INT PRIMARY KEY,
    track_name NVARCHAR(100)
);

-- Instructor Table
CREATE TABLE Instructor (
    instructor_id INT PRIMARY KEY,
    Fname NVARCHAR(50),
    Lname NVARCHAR(50),
	Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    Address NVARCHAR(255),
    Major NVARCHAR(100),
    Email NVARCHAR(100),
	CONSTRAINT UQ_Instructor_Email UNIQUE (Email)
);

-- Instructor Phone Table
CREATE TABLE InstructorPhone (
    instructor_id INT,
    phone NVARCHAR(15),
    PRIMARY KEY (instructor_id, phone),
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
);

-- Ternary Relationship Table: Branch + Intake + Track (using surrogate key assignment_id)
CREATE TABLE Branch_Intake_Track_Assignment (
    assignment_id INT PRIMARY KEY idENTITY(1,1),
    branch_id INT,
    intake_id INT,
    track_id INT,
    instructor_id INT UNIQUE NOT NULL,  -- Ensures 1 instructor per assignment
    CONSTRAINT FK_BITA_Branch FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    CONSTRAINT FK_BITA_Intake FOREIGN KEY (intake_id) REFERENCES Intake(intake_id),
    CONSTRAINT FK_BITA_Track FOREIGN KEY (track_id) REFERENCES Track(track_id),
    CONSTRAINT FK_BITA_Instructor FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id),
    CONSTRAINT UQ_BranchIntakeTrack UNIQUE (branch_id, intake_id, track_id) -- prevent duplicates
);

-- Student Table (connected to ternary assignment)
CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    Fname NVARCHAR(50),
    Lname NVARCHAR(50),
    Address NVARCHAR(255),
    DoB DATE,
    Major NVARCHAR(50),
    Email NVARCHAR(100),
	Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    assignment_id INT NOT NULL,
    CONSTRAINT FK_Student_Assignment FOREIGN KEY (assignment_id) REFERENCES Branch_Intake_Track_Assignment(assignment_id),
	CONSTRAINT UQ_Student_Email UNIQUE (Email)
);

-- Student Phone Table
CREATE TABLE StudentPhone (
    student_id INT,
    phone NVARCHAR(15),
    PRIMARY KEY (student_id, phone),
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
);

-- Course Table
CREATE TABLE Course (
    course_id INT PRIMARY KEY,
    course_name NVARCHAR(100),
    course_hours INT,
);


-- Course_Track Table (Junction table)
CREATE TABLE TrackCourse (
    course_id INT,
    track_id INT,
    PRIMARY KEY (course_id, track_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- Course_Instructor Table (Junction table)
CREATE TABLE InstructorCourse (
    course_id INT,
    instructor_id INT,
    PRIMARY KEY (course_id, instructor_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
);

-- Question Table
CREATE TABLE Question (
    question_id INT PRIMARY KEY,
    course_id INT NOT NULL,
    question_text NVARCHAR(MAX) NOT NULL,
    correct_answer CHAR(1) NOT NULL,
    question_type CHAR(3) CHECK (question_type IN ('MCQ', 'TF')) NOT NULL,
    difficulty CHAR(6) CHECK (difficulty IN ('Easy', 'Medium', 'Hard')) NOT NULL,
    CONSTRAINT FK_Question_Course FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- MCQ Options Table
CREATE TABLE MCQ_Options (
    question_id INT PRIMARY KEY,
    option_A NVARCHAR(255) NOT NULL,
    option_B NVARCHAR(255) NOT NULL,
    option_C NVARCHAR(255) NOT NULL,
    option_D NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_MCQ_Option_Question FOREIGN KEY (question_id) REFERENCES Question(question_id) ON DELETE CASCADE
);

-- Exam Table
CREATE TABLE Exam (
    exam_id INT idENTITY(1,1) PRIMARY KEY,
    course_id INT,
    exam_date DATE,
    CONSTRAINT FK_Exam_Course FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- Exam Question Table
CREATE TABLE ExamQuestion (
    ExamQuestionid INT idENTITY(1,1) PRIMARY KEY,
    exam_id INT,
    question_id INT,
    points INT,
    CONSTRAINT FK_ExamQuestion_Exam FOREIGN KEY (exam_id) REFERENCES Exam(exam_id),
    CONSTRAINT FK_ExamQuestion_Question FOREIGN KEY (question_id) REFERENCES Question(question_id) ON DELETE CASCADE
);

-- Student Answer Table
CREATE TABLE StudentAnswer (
    answer_id INT idENTITY(1,1) PRIMARY KEY,
    student_id INT,
    exam_id INT,
    question_id INT,
    studentAnswer CHAR(1),
    answerDate DATETIME DEFAULT GETDATE(),
    isCorrect BIT,
    grade DECIMAL(5,2),
	CONSTRAINT UQ_StudentAnswer_PerQuestion UNIQUE (student_id, exam_id, question_id),
    CONSTRAINT FK_StudentAnswer_Student FOREIGN KEY (student_id) REFERENCES Student(student_id),
    CONSTRAINT FK_StudentAnswer_Exam FOREIGN KEY (exam_id) REFERENCES Exam(exam_id),
    CONSTRAINT FK_StudentAnswer_Question FOREIGN KEY (question_id) REFERENCES Question(question_id) ON DELETE CASCADE
);

USE ITI_Examination_System;
GO

-- 1. View: Average grade per track
-- This view calculates the average grade for students within each track.
CREATE OR ALTER VIEW TrackAverageGrades AS
SELECT
    T.track_name,
    AVG(SA.grade) AS average_grade_per_track
FROM Track T
INNER JOIN Branch_Intake_Track_Assignment BITA ON T.track_id = BITA.track_id
INNER JOIN Student S ON BITA.assignment_id = S.assignment_id             
LEFT JOIN StudentAnswer SA ON S.student_id = SA.student_ID                
WHERE SA.grade IS NOT NULL 
GROUP BY T.track_name;
GO

-- 2. View: Course Question Counts
-- Shows the total number of questions for each course, broken down by type and difficulty.
CREATE OR ALTER VIEW CourseQuestionCounts AS
SELECT
    C.course_name,
    Q.question_type,
    Q.difficulty,
    COUNT(Q.question_id) AS NumberOfQuestions
FROM Course C
INNER JOIN Question Q ON C.course_id = Q.course_id
GROUP BY C.course_name, Q.question_type, Q.difficulty;
GO

-- 3. View: ExamTotalPoints
-- Provides the maximum possible score for each exam.
CREATE OR ALTER VIEW ExamTotalPoints AS
SELECT
    E.exam_id,
    C.course_name,
    SUM(EQ.points) AS total_exam_points
FROM Exam E
INNER JOIN Course C ON E.course_id = C.course_id
INNER JOIN ExamQuestion EQ ON E.exam_id = EQ.exam_id
GROUP BY E.exam_id, C.course_name;
GO

-- 4. View: StudentOverallPercentages
-- Calculates each student's overall average percentage across ALL exams they have taken.
CREATE OR ALTER VIEW StudentOverallPercentages AS
SELECT
    S.student_id,
    S.Fname + ' ' + S.Lname AS StudentName,
    AVG(CAST(SA.grade AS DECIMAL(5,2)) * 100.0 / NULLIF(EQ.points, 0)) AS OverallAveragePercentage 
FROM Student S
INNER JOIN StudentAnswer SA ON S.student_id = SA.student_ID
INNER JOIN ExamQuestion EQ ON SA.exam_id = EQ.exam_id AND SA.question_id = EQ.question_id
GROUP BY S.student_id, S.Fname, S.Lname;
GO

-- 5. View: InstructorCourseAssignments
-- Lists instructors and the courses they are assigned to teach.
CREATE OR ALTER VIEW InstructorCourseAssignments AS
SELECT
    I.Fname + ' ' + I.Lname AS InstructorName,
    C.course_name
FROM Instructor I
INNER JOIN InstructorCourse IC ON I.instructor_id = IC.instructor_id 
INNER JOIN Course C ON IC.course_id = C.course_id; 
GO

-- 6. View: StudentsPerBITACombination
-- Counts the number of students assigned to each Branch, Intake, and Track combination.
CREATE OR ALTER VIEW StudentsPerBITACombination AS
SELECT
    B.branch_name,
    I.intake_name,
    T.track_name,
    COUNT(S.student_id) AS NumberOfStudents
FROM Branch B
INNER JOIN Branch_Intake_Track_Assignment BITA ON B.branch_id = BITA.branch_id
INNER JOIN Intake I ON BITA.intake_id = I.intake_id
INNER JOIN Track T ON BITA.track_id = T.track_id
LEFT JOIN Student S ON BITA.assignment_id = S.assignment_id 
GROUP BY B.branch_name, I.intake_name, T.track_name;
GO

-- 7. View: DetailedExamReport
-- Provides a detailed overview of each exam, including its course, date, total questions, and maximum possible score.
CREATE OR ALTER VIEW DetailedExamReport AS
SELECT
    E.exam_id,
    C.course_name,
    E.exam_date,
    COUNT(EQ.question_id) AS TotalQuestions,
    SUM(EQ.points) AS MaxPossibleScore
FROM Exam E
INNER JOIN Course C ON E.course_id = C.course_id
INNER JOIN ExamQuestion EQ ON E.exam_id = EQ.exam_id
GROUP BY E.exam_id, C.course_name, E.exam_date;
GO

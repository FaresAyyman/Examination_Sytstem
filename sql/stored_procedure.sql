USE ITI_Examination_System;
GO

-- 1. Generate Exam Questions
CREATE OR ALTER PROCEDURE GenerateExamQuestions
    @CourseIdentifier NVARCHAR(100), -- Can be CourseID (e.g., '201') or CourseName (e.g., 'Database Fundamentals')
    @NumTF INT,                      -- Number of True/False questions requested
    @NumMCQ INT                     -- Number of Multiple Choice Questions requested
--    @GeneratedExamID INT OUTPUT      -- Output parameter: Returns the ID of the newly created exam (Flask Extenstion)
AS
BEGIN
    SET NOCOUNT ON;   -- Remove the roww affected massage
    SET XACT_ABORT ON; -- Ensures that if any statement within the transaction encounters a runtime error, the entire transaction is rolled back.

    DECLARE @CourseID INT;
    DECLARE @CourseName NVARCHAR(100);
	DECLARE @GeneratedExamID INT;

    -- --- Determine the actual CourseID from the @CourseIdentifier ---
    -- Try to convert @CourseIdentifier to INT. If successful, assume it's a CourseID.
    IF ISNUMERIC(@CourseIdentifier) = 1
    BEGIN
        SET @CourseID = CAST(@CourseIdentifier AS INT);
        SELECT @CourseName = course_name FROM Course WHERE course_id = @CourseID;
        IF @CourseName IS NULL
        BEGIN
            RAISERROR('Course ID %s does not exist.', 16, 1, @CourseIdentifier);
            RETURN;
        END
    END
    ELSE
    BEGIN
        -- Assume it's a CourseName if not numeric
        SET @CourseName = @CourseIdentifier;
        SELECT @CourseID = course_id FROM Course WHERE course_name = @CourseName;
        IF @CourseID IS NULL
        BEGIN
            RAISERROR('Course name "%s" does not exist.', 16, 1, @CourseName);
            RETURN;
        END
    END

    -- --- Begin Transaction and Generate Exam ---
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert a new exam record (always using current date for exam_date)
        INSERT INTO Exam (course_id, exam_date)
        VALUES (@CourseID, GETDATE()); 

        SET @GeneratedExamID = SCOPE_IDENTITY(); -- Get the ID of the newly created exam

        -- Variables to track actual questions inserted
        DECLARE @ActualTFInserted INT = 0;
        DECLARE @ActualMCQInserted INT = 0;

        -- --- Insert TF Questions by difficulty with assigned points ---
        -- Distribute requested TF questions across difficulties as evenly as possible.
        DECLARE @TF_Easy_Count INT = @NumTF / 3;
        DECLARE @TF_Medium_Count INT = @NumTF / 3;
        DECLARE @TF_Hard_Count INT = @NumTF - (@TF_Easy_Count + @TF_Medium_Count);

        -- Easy TF (1 point)
        INSERT INTO ExamQuestion (exam_id, question_id, points)
        SELECT TOP (@TF_Easy_Count) @GeneratedExamID, Q.question_id, 1 -- 1 point for Easy
        FROM Question Q
        WHERE Q.course_id = @CourseID AND Q.question_type = 'TF' AND Q.difficulty = 'Easy'
        ORDER BY NEWID(); -- Random selection
        SET @ActualTFInserted = @ActualTFInserted + @@ROWCOUNT;

        -- Medium TF (2 points) - ensuring no duplicates within the same exam
        INSERT INTO ExamQuestion (exam_id, question_id, points)
        SELECT TOP (@TF_Medium_Count) @GeneratedExamID, Q.question_id, 2 -- 2 points for Medium
        FROM Question Q
        WHERE Q.course_id = @CourseID AND Q.question_type = 'TF' AND Q.difficulty = 'Medium'
            AND Q.question_id NOT IN (SELECT EQ.question_id FROM ExamQuestion EQ WHERE EQ.exam_id = @GeneratedExamID)
        ORDER BY NEWID();
        SET @ActualTFInserted = @ActualTFInserted + @@ROWCOUNT;

        -- Hard TF (3 points) - ensuring no duplicates within the same exam
        INSERT INTO ExamQuestion (exam_id, question_id, points)
        SELECT TOP (@TF_Hard_Count) @GeneratedExamID, Q.question_id, 3 -- 3 points for Hard
        FROM Question Q
        WHERE Q.course_id = @CourseID AND Q.question_type = 'TF' AND Q.difficulty = 'Hard'
            AND Q.question_id NOT IN (SELECT EQ.question_id FROM ExamQuestion EQ WHERE EQ.exam_id = @GeneratedExamID)
        ORDER BY NEWID();
        SET @ActualTFInserted = @ActualTFInserted + @@ROWCOUNT;


        -- --- Insert MCQ Questions by difficulty with assigned points ---
        -- Distribute requested MCQ questions across difficulties as evenly as possible.
        DECLARE @MCQ_Easy_Count INT = @NumMCQ / 3;
        DECLARE @MCQ_Medium_Count INT = @NumMCQ / 3;
        DECLARE @MCQ_Hard_Count INT = @NumMCQ - (@MCQ_Easy_Count + @MCQ_Medium_Count);

        -- Easy MCQ (1 point) - ensuring no duplicates within the same exam
        INSERT INTO ExamQuestion (exam_id, question_id, points)
        SELECT TOP (@MCQ_Easy_Count) @GeneratedExamID, Q.question_id, 1 -- 1 point for Easy
        FROM Question Q
        WHERE Q.course_id = @CourseID AND Q.question_type = 'MCQ' AND Q.difficulty = 'Easy'
            AND Q.question_id NOT IN (SELECT EQ.question_id FROM ExamQuestion EQ WHERE EQ.exam_id = @GeneratedExamID)
        ORDER BY NEWID();
        SET @ActualMCQInserted = @ActualMCQInserted + @@ROWCOUNT;

        -- Medium MCQ (2 points) - ensuring no duplicates within the same exam
        INSERT INTO ExamQuestion (exam_id, question_id, points)
        SELECT TOP (@MCQ_Medium_Count) @GeneratedExamID, Q.question_id, 2 -- 2 points for Medium
        FROM Question Q
        WHERE Q.course_id = @CourseID AND Q.question_type = 'MCQ' AND Q.difficulty = 'Medium'
            AND Q.question_id NOT IN (SELECT EQ.question_id FROM ExamQuestion EQ WHERE EQ.exam_id = @GeneratedExamID)
        ORDER BY NEWID();
        SET @ActualMCQInserted = @ActualMCQInserted + @@ROWCOUNT;

        -- Hard MCQ (3 points) - ensuring no duplicates within the same exam
        INSERT INTO ExamQuestion (exam_id, question_id, points)
        SELECT TOP (@MCQ_Hard_Count) @GeneratedExamID, Q.question_id, 3 -- 3 points for Hard
        FROM Question Q
        WHERE Q.course_id = @CourseID AND Q.question_type = 'MCQ' AND Q.difficulty = 'Hard'
            AND Q.question_id NOT IN (SELECT EQ.question_id FROM ExamQuestion EQ WHERE EQ.exam_id = @GeneratedExamID)
        ORDER BY NEWID();
        SET @ActualMCQInserted = @ActualMCQInserted + @@ROWCOUNT;


        -- Provide feedback messages
        PRINT 'Exam ID: ' + CAST(@GeneratedExamID AS NVARCHAR(10)) + ' created for Course: ' + @CourseName + ' (ID: ' + CAST(@CourseID AS NVARCHAR(10)) + ')';
        PRINT 'Requested TF questions: ' + CAST(@NumTF AS NVARCHAR(10)) + ', Actual TF inserted: ' + CAST(@ActualTFInserted AS NVARCHAR(10));
        PRINT 'Requested MCQ questions: ' + CAST(@NumMCQ AS NVARCHAR(10)) + ', Actual MCQ inserted: ' + CAST(@ActualMCQInserted AS NVARCHAR(10));

        IF @ActualTFInserted < @NumTF OR @ActualMCQInserted < @NumMCQ
        BEGIN
            PRINT 'Warning: Could not find enough questions for the requested counts across all difficulties. Inserted available questions.';
        END

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback transaction on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Re-raise error to the caller (Flask application)
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- 2. Percentage Calculation
CREATE OR ALTER PROCEDURE Percentage_Exam
    @exam_id INT,
    @student_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CAST(SUM(SA.grade) * 100.0 / NULLIF(MAXG.max_grade, 0) AS DECIMAL(5,2)) AS percentage
    FROM StudentAnswer SA
    INNER JOIN (
        SELECT
            EQ.exam_ID,
            SUM(EQ.points) AS max_grade
        FROM ExamQuestion EQ
        GROUP BY EQ.exam_ID
    ) MAXG ON SA.exam_ID = MAXG.exam_ID
    WHERE SA.student_ID = @student_id AND SA.exam_ID = @exam_id 
    GROUP BY SA.student_ID, SA.exam_ID, MAXG.max_grade;
END
GO

-- 3. Instructor details with phones
CREATE OR ALTER PROCEDURE getInstructor
    @instructor_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.*, iph.phone
    FROM Instructor i
    LEFT JOIN InstructorPhone iph ON iph.instructor_ID = i.instructor_ID
    WHERE i.instructor_ID = @instructor_id;
END
GO

-- 4. Courses in a track 
CREATE OR ALTER PROCEDURE getCourses
    @track_name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.course_name
    FROM Track t
    INNER JOIN TrackCourse tc ON t.track_id = tc.track_id 
    INNER JOIN Course c ON tc.course_id = c.course_id     
    WHERE t.track_name = @track_name;
END
GO

-- 5. Questions in exam
CREATE OR ALTER PROCEDURE exam_questions
    @exam_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT q.question_text, q.question_type, q.difficulty, eq.points 
    FROM ExamQuestion eq
    JOIN Question q ON q.question_id = eq.question_id
    WHERE eq.exam_id = @exam_id
    ORDER BY q.question_type, q.difficulty;
END
GO

-- 6. Students by track 
CREATE OR ALTER PROCEDURE Students_By_Track
    @track_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT S.*
    FROM Student S
    INNER JOIN Branch_Intake_Track_Assignment BITA ON S.assignment_id = BITA.assignment_id
    WHERE BITA.track_id = @track_id;
END
GO

-- 7. Student grades in all courses 
CREATE OR ALTER PROCEDURE Student_Grades
    @student_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.course_name, sa.grade
    FROM StudentAnswer sa
    JOIN Exam e ON e.exam_id = sa.exam_id
    JOIN Course c ON c.course_ID = e.course_ID
    WHERE sa.student_ID = @student_id
    ORDER BY c.course_name;
END
GO

-- 8. Instructor Courses and Student Counts 
CREATE OR ALTER PROCEDURE Instructor_Courses
    @instructor_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.course_name,
        COUNT(DISTINCT SA.student_ID) AS student_count
    FROM Instructor i
    INNER JOIN InstructorCourse ic ON i.instructor_id = ic.instructor_id 
    INNER JOIN Course c ON ic.course_id = c.course_id                  
    LEFT JOIN Exam E ON C.course_id = E.course_id                      
    LEFT JOIN StudentAnswer SA ON E.exam_id = SA.exam_id              
    WHERE i.instructor_ID = @instructor_id
    GROUP BY c.course_name
    ORDER BY c.course_name;
END
GO

-- 9. Course Names for each Track 
CREATE OR ALTER PROCEDURE Course_Names_Track
    @track_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.track_name,
        c.course_name
    FROM Track t
    INNER JOIN TrackCourse tc ON t.track_id = tc.track_id 
    INNER JOIN Course c ON tc.course_id = c.course_id      
    WHERE t.track_id = @track_id
    ORDER BY t.track_name, c.course_name;
END
GO

-- 10. Exam Questions + Student Answers
CREATE OR ALTER PROCEDURE Exam_Student_Answers
    @exam_id INT,
    @student_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        q.question_text,
        q.question_type,
        q.correct_answer, 
        sa.studentAnswer,
        sa.isCorrect,     -
        sa.grade          
    FROM ExamQuestion eq
    JOIN Question q ON q.question_id = eq.question_id
    LEFT JOIN StudentAnswer sa ON sa.question_id = q.question_id AND sa.exam_id = eq.exam_id AND sa.student_ID = @student_id
    WHERE eq.exam_id = @exam_id
    ORDER BY q.question_id;
END
GO

-- 11. General Report: Students grade per track
CREATE OR ALTER PROCEDURE Students_Per_Track_Grade
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        BITA.track_name, 
        S.Fname + ' ' + S.Lname AS StudentName,
        SUM(SA.grade) AS total_grade_for_all_exams,
        CAST(SUM(SA.grade) * 100.0 / NULLIF(SUM(EQ.points), 0) AS DECIMAL(5,2)) AS overall_percentage
    FROM StudentAnswer SA
    INNER JOIN Student S ON SA.student_ID = S.student_id
    INNER JOIN Branch_Intake_Track_Assignment BITA_Assign ON S.assignment_id = BITA_Assign.assignment_id
    INNER JOIN Track BITA ON BITA_Assign.track_id = BITA.track_id 
    INNER JOIN Exam E ON SA.exam_id = E.exam_id
    INNER JOIN ExamQuestion EQ ON SA.exam_id = EQ.exam_id AND SA.question_id = EQ.question_id
    GROUP BY BITA.track_name, S.student_ID, S.Fname, S.Lname
    ORDER BY BITA.track_name, overall_percentage DESC;
END
GO

-- 12. General Report: Number of students per exam
CREATE OR ALTER PROCEDURE Students_Per_Exam_Grade
AS
BEGIN
    SET NOCOUNT ON;

    WITH StudentExamGrades AS (
        SELECT
            SA.student_ID,
            E.exam_id,
            C.course_name,
            SUM(SA.grade) AS student_total_grade,
            MAXG.max_grade AS exam_max_grade,
            CAST(SUM(SA.grade) * 100.0 / NULLIF(MAXG.max_grade, 0) AS DECIMAL(5,2)) AS percentage_achieved
        FROM StudentAnswer SA
        INNER JOIN Exam E ON SA.exam_ID = E.exam_id
        INNER JOIN Course C ON E.course_id = C.course_id
        INNER JOIN (
            SELECT
                EQ.exam_ID,
                SUM(EQ.points) AS max_grade
            FROM ExamQuestion EQ
            GROUP BY EQ.exam_ID
        ) MAXG ON SA.exam_ID = MAXG.exam_ID
        GROUP BY SA.student_ID, E.exam_id, C.course_name, MAXG.max_grade
    )
    SELECT
        SEG.exam_id,
        SEG.course_name,
        Percentage_Category =
            CASE
                WHEN SEG.percentage_achieved >= 90 THEN '90-100%'
                WHEN SEG.percentage_achieved >= 80 THEN '80-89%'
                WHEN SEG.percentage_achieved >= 70 THEN '70-79%'
                WHEN SEG.percentage_achieved >= 60 THEN '60-69%'
                ELSE 'Below 60%'
            END,
        COUNT(DISTINCT SEG.student_ID) AS Number_Of_Students
    FROM StudentExamGrades SEG
    GROUP BY SEG.exam_id, SEG.course_name,
        CASE
            WHEN SEG.percentage_achieved >= 90 THEN '90-100%'
            WHEN SEG.percentage_achieved >= 80 THEN '80-89%'
            WHEN SEG.percentage_achieved >= 70 THEN '70-79%'
            WHEN SEG.percentage_achieved >= 60 THEN '60-69%'
            ELSE 'Below 60%'
        END
    ORDER BY SEG.exam_id, Percentage_Category;
END
GO

-- 13. Total number of students
CREATE OR ALTER PROCEDURE Total_Students
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS total_students FROM Student;
END
GO

-- 14. Student submit (all questions using JSON for python later with Flask)
-- (handles default for answerDate and trigger for isCorrect/grade)
CREATE OR ALTER PROCEDURE sp_ExamAnswers_JSON
    @student_id INT,
    @exam_id INT,
    @answers NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO StudentAnswer (student_ID, exam_ID, question_ID, studentAnswer)
    SELECT
        @student_id,
        @exam_id,
        question_id,
        studentAnswer
    FROM OPENJSON(@answers)
    WITH (
        question_id INT '$.question_id',
        studentAnswer CHAR(1) '$.answer'
    );
END
GO
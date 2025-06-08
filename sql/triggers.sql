CREATE TRIGGER trg_AutoCalculate_StudentAnswer
ON StudentAnswer
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO StudentAnswer (
        student_ID,
        exam_ID,
        question_ID,
        studentAnswer,
        answerDate,
        isCorrect,
        grade
    )
    SELECT 
        i.student_ID,
        i.exam_ID,
        i.question_ID,
        i.studentAnswer,
        GETDATE(),  -- Set current datetime
        CASE 
            WHEN i.studentAnswer = q.correct_answer THEN 1 ELSE 0 
        END,
        CASE 
            WHEN i.studentAnswer = q.correct_answer THEN eq.points 
            ELSE 0 
        END
    FROM inserted i
    JOIN Question q ON i.question_ID = q.question_ID
    JOIN ExamQuestion eq 
        ON eq.exam_id = i.exam_ID AND eq.question_id = i.question_ID;
END;

DROP TABLE IF EXISTS Student_Audit;
GO

CREATE TABLE Student_Audit (
    Audit_ID INT IDENTITY(1,1) PRIMARY KEY,
    Student_ID INT,
    Action_Type VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    Modified_By VARCHAR(50),
    Modified_Date DATETIME,
    
    -- Full Name and Major
    Old_Full_Name VARCHAR(100),
    New_Full_Name VARCHAR(100),
    Old_Major VARCHAR(50),
    New_Major VARCHAR(50)
);
GO


CREATE TRIGGER trg_Student_Insert
ON dbo.Student
AFTER INSERT
AS
BEGIN
    INSERT INTO Student_Audit (
        Student_ID, Action_Type, Modified_By, Modified_Date, 
        New_Full_Name, New_Major
    )
    SELECT 
        i.Student_ID,
        'INSERT',
        SUSER_NAME(),
        GETDATE(),
        CONCAT(i.Fname, ' ', i.Lname),
        i.Major
    FROM inserted i;
END;
GO


CREATE TRIGGER trg_Student_Update
ON dbo.Student
AFTER UPDATE
AS
BEGIN
    INSERT INTO Student_Audit (
        Student_ID, Action_Type, Modified_By, Modified_Date, 
        Old_Full_Name, New_Full_Name,
        Old_Major, New_Major
    )
    SELECT 
        i.Student_ID,
        'UPDATE',
        SUSER_NAME(),
        GETDATE(),
        CONCAT(d.Fname, ' ', d.Lname),
        CONCAT(i.Fname, ' ', i.Lname),
        d.Major,
        i.Major
    FROM inserted i
    JOIN deleted d ON i.Student_ID = d.Student_ID;
END;
GO

CREATE TRIGGER trg_Student_Delete
ON dbo.Student
AFTER DELETE
AS
BEGIN
    INSERT INTO Student_Audit (
        Student_ID, Action_Type, Modified_By, Modified_Date, 
        Old_Full_Name, Old_Major
    )
    SELECT 
        d.Student_ID,
        'DELETE',
        SUSER_NAME(),
        GETDATE(),
        CONCAT(d.Fname, ' ', d.Lname),
        d.Major
    FROM deleted d;
END;
GO
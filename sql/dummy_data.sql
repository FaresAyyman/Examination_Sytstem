USE ITI_Examination_System;
GO

-- 1. Branch Table
INSERT INTO Branch (branch_id, branch_name) VALUES
(1, 'Smart Village'),
(2, 'Nasr City'),
(3, 'Assiut'),
(4, 'Alexandria');

-- 2. Intake Table
INSERT INTO Intake (intake_id, intake_name) VALUES
(1, 'January 2024'),
(2, 'July 2024'),
(3, 'September 2024');

-- 3. Track Table
INSERT INTO Track (track_id, track_name) VALUES
(1, 'Software Engineering'),
(2, 'Data Science'),
(3, 'Cloud Computing'),
(4, 'Cybersecurity'),
(5, 'Game Development');

-- 4. Instructor Table
INSERT INTO Instructor (instructor_id, Fname, Lname, Gender, Address, Major, Email) VALUES
(101, 'Ahmed', 'Kamal', 'M', '123 Cairo St.', 'Database Systems', 'ahmed.kamal@example.com'),
(102, 'Fatma', 'Ali', 'F', '45 New Giza Blvd.', 'Web Development', 'fatma.ali@example.com'),
(103, 'Mostafa', 'Hassan', 'M', '78 Zamalek St.', 'Cloud Architecture', 'mostafa.hassan@example.com'),
(104, 'Nour', 'El-Din', 'F', '33 Mohandessin Sq.', 'Network Security', 'nour.eldin@example.com'),
(105, 'Khaled', 'Mansour', 'M', '99 Maadi Rd.', 'AI & ML', 'khaled.mansour@example.com'),
(106, 'Laila', 'Zaki', 'F', '22 Heliopolis St.', 'Game Design', 'laila.zaki@example.com');

-- 5. InstructorPhone Table
INSERT INTO InstructorPhone (instructor_id, phone) VALUES
(101, '01011112222'),
(101, '01155556666'),
(102, '01233334444'),
(103, '01099998888'),
(104, '01122223333'),
(105, '01007778888');

-- 6. Branch_Intake_Track_Assignment (Ternary Relationship)
INSERT INTO Branch_Intake_Track_Assignment (branch_id, intake_id, track_id, instructor_id) VALUES
(1, 1, 1, 101), -- Smart Village, Jan 2024, Software Eng -> Ahmed Kamal
(1, 2, 2, 102), -- Smart Village, July 2024, Data Science -> Fatma Ali
(2, 1, 3, 103), -- Nasr City, Jan 2024, Cloud Computing -> Mostafa Hassan
(3, 1, 4, 104), -- Assiut, Jan 2024, Cybersecurity -> Nour El-Din
(4, 3, 5, 105); -- Alexandria, Sep 2024, Game Development -> Khaled Mansour
-- Instructor 106 (Laila Zaki) is not supervising any assignment yet.


-- 7. Student Table
INSERT INTO Student (student_id, Fname, Lname, Address, DoB, Major, Email, Gender, assignment_id) VALUES
(1, 'Mona', 'Said', '10 October St.', '2000-05-15', 'Software Eng.', 'mona.said@example.com', 'F', 1), -- Assigned to SV, Jan 2024, SE
(2, 'Ali', 'Mostafa', '20 El Nasr St.', '1999-11-20', 'Software Eng.', 'ali.mostafa@example.com', 'M', 1), -- Assigned to SV, Jan 2024, SE
(3, 'Sara', 'Mahmoud', '30 Pyramids Rd.', '2001-02-28', 'Data Science', 'sara.mahmoud@example.com', 'F', 2), -- Assigned to SV, July 2024, DS
(4, 'Omar', 'Ahmed', '40 Freedom Ave.', '2000-08-01', 'Cloud Computing', 'omar.ahmed@example.com', 'M', 3), -- Assigned to NC, Jan 2024, CC
(5, 'Layla', 'Fawzy', '50 Sphinx St.', '2002-01-10', 'Data Science', 'layla.fawzy@example.com', 'F', 2), -- Assigned to SV, July 2024, DS
(6, 'Youssef', 'Tarek', '60 River Rd.', '2001-07-22', 'Cybersecurity', 'youssef.tarek@example.com', 'M', 4); -- Assigned to Assiut, Jan 2024, CS

-- 8. StudentPhone Table
INSERT INTO StudentPhone (student_id, phone) VALUES
(1, '01001234567'),
(1, '01112345678'),
(2, '01209876543'),
(3, '01501122334'),
(4, '01056789012'),
(5, '01144556677');

-- 9. Course Table
INSERT INTO Course (course_id, course_name, course_hours) VALUES
(201, 'Database Fundamentals', 40),
(202, 'Python Programming', 60),
(203, 'Web Design Basics', 45),
(204, 'Operating Systems', 50),
(205, 'Cloud Security', 35),
(206, 'Game Engine Basics', 55);

-- 10. TrackCourse (Junction table)
INSERT INTO TrackCourse (course_id, track_id) VALUES
(201, 1), -- DB for Software Eng
(202, 1), -- Python for Software Eng
(202, 2), -- Python for Data Science
(204, 1), -- OS for Software Eng
(205, 3), -- Cloud Security for Cloud Computing
(205, 4), -- Cloud Security for Cybersecurity
(206, 5); -- Game Engine Basics for Game Development

-- 11. InstructorCourse (Junction table)
INSERT INTO InstructorCourse (course_id, instructor_id) VALUES
(201, 101), -- Ahmed Kamal teaches DB
(202, 102), -- Fatma Ali teaches Python
(203, 102), -- Fatma Ali teaches Web Design
(204, 103), -- Mostafa Hassan teaches OS
(205, 104), -- Nour El-Din teaches Cloud Security
(206, 106); -- Laila Zaki teaches Game Engine Basics

-- 12. Question Table (Around 20 questions, mixed types and difficulties)
INSERT INTO Question (question_id, course_id, question_text, correct_answer, question_type, difficulty) VALUES
-- Course 201: Database Fundamentals (8 questions)
(301, 201, 'Which SQL keyword is used to retrieve data from a database?', 'A', 'MCQ', 'Easy'),
(302, 201, 'TRUE/FALSE: A primary key can contain NULL values.', 'F', 'TF', 'Easy'),
(303, 201, 'Which clause is used to filter records based on aggregate functions?', 'B', 'MCQ', 'Medium'),
(304, 201, 'TRUE/FALSE: A foreign key must reference a primary key in another table.', 'T', 'TF', 'Medium'),
(305, 201, 'What is the purpose of database normalization?', 'C', 'MCQ', 'Hard'),
(306, 201, 'TRUE/FALSE: OLAP is primarily used for transactional processing.', 'F', 'TF', 'Hard'),
(307, 201, 'Which type of join returns all rows from both tables, matching where possible?', 'D', 'MCQ', 'Medium'),
(308, 201, 'TRUE/FALSE: An index always speeds up data retrieval.', 'F', 'TF', 'Easy'),

-- Course 202: Python Programming (8 questions)
(309, 202, 'What is the output of `2 + 2 * 3` in Python?', 'B', 'MCQ', 'Easy'),
(310, 202, 'TRUE/FALSE: Python is a statically typed language.', 'F', 'TF', 'Easy'),
(311, 202, 'Which data structure is ordered, mutable, and allows duplicate members?', 'A', 'MCQ', 'Medium'),
(312, 202, 'TRUE/FALSE: Indentation is optional in Python.', 'F', 'TF', 'Medium'),
(313, 202, 'Explain the difference between `list` and `tuple`.', 'C', 'MCQ', 'Hard'), -- Answer will be a conceptual choice
(314, 202, 'TRUE/FALSE: `break` and `continue` keywords are used to alter loop flow.', 'T', 'TF', 'Hard'),
(315, 202, 'What is a decorator in Python?', 'D', 'MCQ', 'Medium'),
(316, 202, 'TRUE/FALSE: Python supports multiple inheritance.', 'T', 'TF', 'Easy'),

-- Course 205: Cloud Security (4 questions)
(317, 205, 'Which of the following is a common security concern in cloud computing?', 'A', 'MCQ', 'Easy'),
(318, 205, 'TRUE/FALSE: Shared responsibility model means the cloud provider is solely responsible for security.', 'F', 'TF', 'Easy'),
(319, 205, 'What is the principle of least privilege in cloud security?', 'B', 'MCQ', 'Medium'),
(320, 205, 'TRUE/FALSE: DDoS attacks are only a concern for on-premise infrastructure.', 'F', 'TF', 'Hard');

-- 13. MCQ_Options Table (Only for MCQ questions from above)
INSERT INTO MCQ_Options (question_id, option_A, option_B, option_C, option_D) VALUES
(301, 'SELECT', 'GET', 'OPEN', 'EXTRACT'),
(303, 'WHERE', 'HAVING', 'GROUP BY', 'ORDER BY'),
(305, 'To increase data redundancy', 'To speed up queries', 'To reduce data redundancy and improve data integrity', 'To create more tables'),
(307, 'INNER JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'FULL OUTER JOIN'),
(309, '8', '9', '10', '12'),
(311, 'List', 'Tuple', 'Set', 'Dictionary'),
(313, 'Lists are immutable, tuples are mutable', 'Lists are ordered, tuples are unordered', 'Lists are mutable, tuples are immutable', 'No difference'),
(315, 'A function that takes a function as an argument', 'A variable that stores a function', 'A class that inherits from another class', 'A built-in Python module'),
(317, 'Data Breaches', 'High Availability', 'Scalability', 'Cost Savings'),
(319, 'Granting users only the permissions they need to perform their job', 'Giving all users administrative access', 'Allowing users to access any resource by default', 'Restricting all network access');

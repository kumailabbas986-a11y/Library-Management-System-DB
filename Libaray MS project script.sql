-- LIBRARY MANAGEMENT SYSTEM | MySQL Script

CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- ─── TABLES ───────────────────────────────────────────────

CREATE TABLE Book (
    BookID          INT          PRIMARY KEY AUTO_INCREMENT,
    Title           VARCHAR(100) NOT NULL,
    Author          VARCHAR(100) NOT NULL,
    Category        VARCHAR(50)  NOT NULL,
    AvailableCopies INT          NOT NULL DEFAULT 0,
    CHECK (AvailableCopies >= 0)
);

CREATE TABLE Member (
    MemberID INT          PRIMARY KEY AUTO_INCREMENT,
    Name     VARCHAR(100) NOT NULL,
    CNIC     VARCHAR(15)  NOT NULL UNIQUE
);

CREATE TABLE Issue (
    IssueID    INT  PRIMARY KEY AUTO_INCREMENT,
    MemberID   INT  NOT NULL,
    BookID     INT  NOT NULL,
    IssueDate  DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (BookID)   REFERENCES Book(BookID)
);

-- ─── SAMPLE DATA ──────────────────────────────────────────

INSERT INTO Book (Title, Author, Category, AvailableCopies) VALUES
('Database System Concepts',  'Silberschatz', 'Computer Science', 3),
('Clean Code',                'Robert Martin','Programming',      2),
('Computer Networks',         'Tanenbaum',    'Networking',       4),
('Discrete Mathematics',      'Kenneth Rosen','Mathematics',      2),
('Operating System Concepts', 'Silberschatz', 'Computer Science', 1);

INSERT INTO Member (Name, CNIC) VALUES
('Ali Hassan',  '35201-1234567-1'),
('Sara Khan',   '35202-2345678-2'),
('Usman Tariq', '35203-3456789-3'),
('Ayesha Noor', '35204-4567890-4');

INSERT INTO Issue (MemberID, BookID, IssueDate, ReturnDate) VALUES
(1, 1, '2025-01-05', '2025-01-19'),
(1, 2, '2025-01-10', NULL),
(2, 3, '2025-02-01', '2025-02-15'),
(3, 1, '2025-02-10', NULL),
(4, 4, '2025-03-01', '2025-03-15'),
(2, 5, '2025-03-10', NULL);

-- ─── BASIC QUERIES ────────────────────────────────────────

SELECT * FROM Book;
SELECT * FROM Member;
SELECT * FROM Issue;

-- ─── AND / OR / NOT ───────────────────────────────────────

-- Books in Computer Science with copies available
SELECT Title, AvailableCopies FROM Book
WHERE Category = 'Computer Science' AND AvailableCopies > 1;

-- Books in Programming or Mathematics
SELECT Title, Category FROM Book
WHERE Category = 'Programming' OR Category = 'Mathematics';

-- Books NOT in Computer Science
SELECT Title, Category FROM Book
WHERE NOT Category = 'Computer Science';

-- ─── JOINS ────────────────────────────────────────────────

-- All issued books with member and book details (INNER JOIN)
SELECT M.Name, B.Title, I.IssueDate, I.ReturnDate
FROM Issue I
INNER JOIN Member M ON I.MemberID = M.MemberID
INNER JOIN Book   B ON I.BookID   = B.BookID;

-- Books not yet returned
SELECT M.Name, B.Title, I.IssueDate
FROM Issue I
INNER JOIN Member M ON I.MemberID = M.MemberID
INNER JOIN Book   B ON I.BookID   = B.BookID
WHERE I.ReturnDate IS NULL;

-- All members including those who never borrowed (LEFT JOIN)
SELECT M.Name, I.BookID, I.IssueDate
FROM Member M
LEFT JOIN Issue I ON M.MemberID = I.MemberID;

-- ─── AGGREGATE FUNCTIONS & GROUP BY ──────────────────────

SELECT COUNT(*) AS TotalBooks   FROM Book;
SELECT COUNT(*) AS TotalMembers FROM Member;
SELECT SUM(AvailableCopies) AS TotalCopies FROM Book;
SELECT AVG(AvailableCopies) AS AvgCopies   FROM Book;
SELECT MAX(AvailableCopies) AS Max, MIN(AvailableCopies) AS Min FROM Book;

-- Books issued per member
SELECT M.Name, COUNT(I.IssueID) AS TotalIssued
FROM Issue I
INNER JOIN Member M ON I.MemberID = M.MemberID
GROUP BY M.Name;

-- Members who borrowed more than 1 book (HAVING)
SELECT M.Name, COUNT(I.IssueID) AS Total
FROM Issue I
INNER JOIN Member M ON I.MemberID = M.MemberID
GROUP BY M.Name
HAVING COUNT(I.IssueID) > 1;

-- ─── SUBQUERIES ───────────────────────────────────────────

-- Books that have never been issued
SELECT Title FROM Book
WHERE BookID NOT IN (SELECT BookID FROM Issue);

-- Most borrowed book
SELECT Title FROM Book
WHERE BookID = (
    SELECT BookID FROM Issue
    GROUP BY BookID
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- ─── DATE FUNCTIONS ───────────────────────────────────────

-- Days each returned book was borrowed
SELECT M.Name, B.Title,
       DATEDIFF(I.ReturnDate, I.IssueDate) AS DaysBorrowed
FROM Issue I
INNER JOIN Member M ON I.MemberID = M.MemberID
INNER JOIN Book   B ON I.BookID   = B.BookID
WHERE I.ReturnDate IS NOT NULL;

-- Overdue books (not returned, issued over 14 days ago)
SELECT M.Name, B.Title,
       DATEDIFF(CURDATE(), I.IssueDate) AS DaysOverdue
FROM Issue I
INNER JOIN Member M ON I.MemberID = M.MemberID
INNER JOIN Book   B ON I.BookID   = B.BookID
WHERE I.ReturnDate IS NULL
  AND DATEDIFF(CURDATE(), I.IssueDate) > 14;

-- ─── REPORTS ──────────────────────────────────────────────

-- Full transaction report with return status
SELECT M.Name, B.Title, I.IssueDate, I.ReturnDate,
       CASE WHEN I.ReturnDate IS NOT NULL THEN 'Returned' ELSE 'Pending' END AS Status
FROM Issue I
INNER JOIN Member M ON I.MemberID = M.MemberID
INNER JOIN Book   B ON I.BookID   = B.BookID;

-- Book availability report
SELECT Title, Category, AvailableCopies,
       CASE WHEN AvailableCopies > 0 THEN 'Available' ELSE 'Unavailable' END AS Availability
FROM Book;
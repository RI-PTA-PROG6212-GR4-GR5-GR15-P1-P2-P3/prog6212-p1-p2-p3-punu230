---- ============================================================
-- RACEDAY DATABASE SCRIPT - FINAL FIXED VERSION
-- THIS WILL COMPLETELY REBUILD YOUR DATABASE
-- ============================================================

-- Step 1: Switch to master and DROP the database completely
USE master;
GO

-- Force close all connections and drop the database
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDayDB')
BEGIN
    PRINT 'Dropping existing RaceDayDB database...';
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
    PRINT 'Database dropped successfully.';
END
GO

-- Step 2: Create fresh database
PRINT 'Creating fresh RaceDayDB database...';
CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

PRINT 'Database created and selected. Now creating tables...';
GO

-- ============================================================
-- CREATE TABLES
-- ============================================================

CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);
PRINT 'Roles table created.';
GO

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    RoleID INT NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
PRINT 'Users table created.';
GO

CREATE TABLE Organisers (
    OrganiserID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    OrganisationName NVARCHAR(200) NOT NULL,
    ContactPhone NVARCHAR(20) NULL,
    Website NVARCHAR(200) NULL,
    CONSTRAINT FK_Organisers_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
PRINT 'Organisers table created.';
GO

CREATE TABLE Participants (
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    EmergencyContactName NVARCHAR(200) NULL,
    EmergencyContactPhone NVARCHAR(20) NULL,
    MedicalConditions NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Participants_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
PRINT 'Participants table created.';
GO

CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    EventDate DATE NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    RouteDistanceKM DECIMAL(5,2) NOT NULL,
    RegistrationDeadline DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Events_Organisers FOREIGN KEY (OrganiserID) REFERENCES Organisers(OrganiserID)
);
PRINT 'Events table created.';
GO

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    AgeGroupMin INT NULL,
    AgeGroupMax INT NULL,
    Gender NCHAR(1) NULL,
    EntryFee DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) REFERENCES Events(EventID) ON DELETE CASCADE,
    CONSTRAINT CHK_Categories_Gender CHECK (Gender IN ('M', 'F', NULL))
);
PRINT 'Categories table created.';
GO

CREATE TABLE EventEnrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME DEFAULT GETDATE(),
    IsPaid BIT DEFAULT 0,
    CONSTRAINT FK_EventEnrolments_Participants FOREIGN KEY (ParticipantID) REFERENCES Participants(ParticipantID),
    CONSTRAINT FK_EventEnrolments_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_EventEnrolments_ParticipantCategory UNIQUE (ParticipantID, CategoryID)
);
PRINT 'EventEnrolments table created.';
GO

CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NOT NULL,
    Position INT NOT NULL,
    CONSTRAINT FK_Results_EventEnrolments FOREIGN KEY (EnrolmentID) REFERENCES EventEnrolments(EnrolmentID)
);
PRINT 'Results table created.';
PRINT 'All tables created successfully!';
GO

-- ============================================================
-- INSERT SAMPLE DATA
-- ============================================================

PRINT 'Inserting sample data...';
GO

INSERT INTO Roles (RoleName) VALUES ('Organiser'), ('Participant');
GO

INSERT INTO Users (RoleID, Email, PasswordHash, FirstName, LastName, DateOfBirth) VALUES
(1, 'thabo.mokoena@capeevents.co.za', 'hashedpassword_1', 'Thabo', 'Mokoena', '1985-04-12'),
(1, 'annelie.vdm@durbanrunners.org', 'hashedpassword_2', 'Annelie', 'van der Merwe', '1990-08-25'),
(2, 'sipho.ndlovu@gmail.com', 'hashedpassword_3', 'Sipho', 'Ndlovu', '1995-01-15'),
(2, 'lindiwe.zulu@gmail.com', 'hashedpassword_4', 'Lindiwe', 'Zulu', '1988-11-30');
GO

INSERT INTO Organisers (UserID, OrganisationName, ContactPhone, Website) VALUES
(1, 'Cape Town Events Management', '021-555-1234', 'www.capetownevents.co.za'),
(2, 'Durban Road Runners Club', '031-555-5678', 'www.durbanroadrunners.org');
GO

INSERT INTO Participants (UserID, EmergencyContactName, EmergencyContactPhone, MedicalConditions) VALUES
(3, 'Nomsa Ndlovu', '082-123-4567', 'Mild asthma. Allergic to penicillin.'),
(4, 'Bongani Zulu', '083-987-6543', 'None reported.');
GO

INSERT INTO Events (OrganiserID, Name, Description, EventDate, Location, RouteDistanceKM, RegistrationDeadline, IsActive) VALUES
(1, 'Cape Town Cycle Tour 2026', 'The world''s largest timed cycle event. This 109km route takes participants through the breathtaking Cape Peninsula.', '2026-03-15', 'Cape Town, Western Cape', 109.00, '2026-03-01', 1),
(1, 'Two Oceans Marathon 2026', 'Known as the ''world''s most beautiful marathon'', this 56km ultra-marathon follows the stunning coastline of the Cape Peninsula.', '2026-04-18', 'Cape Town, Western Cape', 56.00, '2026-03-25', 1),
(2, 'Durban City Marathon 2026', 'A flat and fast marathon along the picturesque Durban coastline.', '2026-05-10', 'Durban, KwaZulu-Natal', 42.20, '2026-04-20', 1);
GO

INSERT INTO Categories (EventID, Name, AgeGroupMin, AgeGroupMax, Gender, EntryFee) VALUES
(1, 'Elite Men', 18, 39, 'M', 350.00),
(1, 'Elite Women', 18, 39, 'F', 350.00),
(1, 'Veteran Men', 40, NULL, 'M', 300.00),
(1, 'Veteran Women', 40, NULL, 'F', 300.00),
(2, 'Ultra Marathon Men', 20, 49, 'M', 450.00),
(2, 'Ultra Marathon Women', 20, 49, 'F', 450.00),
(3, 'Men Open', 18, NULL, 'M', 250.00),
(3, 'Women Open', 18, NULL, 'F', 250.00);
GO

INSERT INTO EventEnrolments (ParticipantID, CategoryID, EnrolmentDate, IsPaid) VALUES
(1, 1, GETDATE(), 1),  -- Sipho in Elite Men - CT Cycle Tour
(1, 5, GETDATE(), 0),  -- Sipho in Ultra Marathon Men - Two Oceans
(2, 2, GETDATE(), 1);  -- Lindiwe in Elite Women - CT Cycle Tour
GO

INSERT INTO Results (EnrolmentID, FinishTime, Position) VALUES
(1, '02:45:30', 5),   -- Sipho's result in CT Cycle Tour
(3, '03:10:22', 12);  -- Lindiwe's result in CT Cycle Tour
GO

PRINT 'Sample data inserted successfully!';
GO

-- ============================================================
-- VERIFY DATA - COMPLETELY FIXED
-- ============================================================

PRINT '========================================';
PRINT 'VERIFYING DATA INSERTION';
PRINT '========================================';
GO

-- Check row counts for each table (FIXED - no syntax errors)
SELECT 
    'Roles' AS TableName, 
    COUNT(*) AS [RowCount] 
FROM Roles
UNION ALL
SELECT 
    'Users', 
    COUNT(*) 
FROM Users
UNION ALL
SELECT 
    'Organisers', 
    COUNT(*) 
FROM Organisers
UNION ALL
SELECT 
    'Participants', 
    COUNT(*) 
FROM Participants
UNION ALL
SELECT 
    'Events', 
    COUNT(*) 
FROM Events
UNION ALL
SELECT 
    'Categories', 
    COUNT(*) 
FROM Categories
UNION ALL
SELECT 
    'EventEnrolments', 
    COUNT(*) 
FROM EventEnrolments
UNION ALL
SELECT 
    'Results', 
    COUNT(*) 
FROM Results;
GO

-- View all Users
PRINT '=== USERS ===';
SELECT * FROM Users;
GO

-- View all Events
PRINT '=== EVENTS ===';
SELECT * FROM Events;
GO

-- View all Enrolments with participant and event details (FIXED - corrected typos)
PRINT '=== ENROLMENTS WITH DETAILS ===';
SELECT 
    e.EnrolmentID,
    u.FirstName + ' ' + u.LastName AS ParticipantName,
    ev.Name AS EventName,
    c.Name AS CategoryName,
    e.EnrolmentDate,
    CASE 
        WHEN e.IsPaid = 1 THEN 'Paid' 
        ELSE 'Unpaid' 
    END AS PaymentStatus
FROM EventEnrolments e
INNER JOIN Participants p ON e.ParticipantID = p.ParticipantID
INNER JOIN Users u ON p.UserID = u.UserID
INNER JOIN Categories c ON e.CategoryID = c.CategoryID
INNER JOIN Events ev ON c.EventID = ev.EventID;
GO

-- View Results
PRINT '=== RESULTS ===';
SELECT * FROM Results;
GO

PRINT '========================================';
PRINT 'DATABASE SETUP COMPLETE!';
PRINT 'All tables created and data inserted successfully.';
PRINT '========================================';
GO

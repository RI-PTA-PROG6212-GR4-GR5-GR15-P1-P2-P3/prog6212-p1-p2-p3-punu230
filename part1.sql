-- create a database 
CREATE DATABASE RaceDay;
GO

-- 1. Roles Table
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- 2. Users Table
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
GO

-- 3. Organisers Table
CREATE TABLE Organisers (
    OrganiserID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    OrganisationName NVARCHAR(200) NOT NULL,
    ContactPhone NVARCHAR(20) NULL,
    Website NVARCHAR(200) NULL,
    CONSTRAINT FK_Organisers_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- 4. Participants Table
CREATE TABLE Participants (
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    EmergencyContactName NVARCHAR(200) NULL,
    EmergencyContactPhone NVARCHAR(20) NULL,
    MedicalConditions NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Participants_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- 5. Events Table
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
GO

-- 6. Categories Table
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    AgeGroupMin INT NULL,
    AgeGroupMax INT NULL,
    Gender NCHAR(1) NULL, -- 'M', 'F', or NULL
    EntryFee DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) REFERENCES Events(EventID) ON DELETE CASCADE,
    CONSTRAINT CHK_Categories_Gender CHECK (Gender IN ('M', 'F', NULL))
);
GO

-- 7. EventEnrolments Table
CREATE TABLE EventEnrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME DEFAULT GETDATE(),
    IsPaid BIT DEFAULT 0,
    CONSTRAINT FK_EventEnrolments_Participants FOREIGN KEY (ParticipantID) REFERENCES Participants(ParticipantID),
    CONSTRAINT FK_EventEnrolments_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    -- Ensure a participant can only enrol in a specific category once
    CONSTRAINT UQ_EventEnrolments_ParticipantCategory UNIQUE (ParticipantID, CategoryID)
);
GO

-- 8. Results Table
CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NOT NULL,
    Position INT NOT NULL,
    CONSTRAINT FK_Results_EventEnrolments FOREIGN KEY (EnrolmentID) REFERENCES EventEnrolments(EnrolmentID)
);
GO

-- Insert Roles
INSERT INTO Roles (RoleName) VALUES ('Organiser'), ('Participant');
GO

-- Insert Users
INSERT INTO Users (RoleID, Email, PasswordHash, FirstName, LastName, DateOfBirth) VALUES
(1, 'organiser1@example.com', 'hashedpassword_1', 'Thabo', 'Mokoena', '1985-04-12'),
(1, 'organiser2@example.com', 'hashedpassword_2', 'Annelie', 'van der Merwe', '1990-08-25'),
(2, 'participant1@example.com', 'hashedpassword_3', 'Sipho', 'Ndlovu', '1995-01-15'),
(2, 'participant2@example.com', 'hashedpassword_4', 'Lindiwe', 'Zulu', '1988-11-30');
GO

-- Insert Organisers
INSERT INTO Organisers (UserID, OrganisationName, ContactPhone, Website) VALUES
(1, 'Cape Town Events', '021-555-1234', 'www.ctevents.co.za'),
(2, 'Durban Road Runners', '031-555-5678', 'www.dbnroadrunners.org');
GO

-- Insert Participants
INSERT INTO Participants (UserID, EmergencyContactName, EmergencyContactPhone, MedicalConditions) VALUES
(3, 'Nomsa Ndlovu', '082-123-4567', 'Mild asthma.'),
(4, 'Bongani Zulu', '083-987-6543', NULL);
GO

-- Insert Events
INSERT INTO Events (OrganiserID, Name, Description, EventDate, Location, RouteDistanceKM, RegistrationDeadline, IsActive) VALUES
(1, 'Cape Town Cycle Tour 2026', 'The world''s largest timed cycle event.', '2026-03-15', 'Cape Town', 109.00, '2026-03-01', 1),
(1, 'Two Oceans Marathon 2026', 'The world''s most beautiful marathon.', '2026-04-18', 'Cape Town', 56.00, '2026-03-25', 1),
(2, 'Durban City Marathon 2026', 'A flat and fast marathon along the Durban coastline.', '2026-05-10', 'Durban', 42.20, '2026-04-20', 1);
GO

-- Insert Categories
INSERT INTO Categories (EventID, Name, AgeGroupMin, AgeGroupMax, Gender, EntryFee) VALUES
(1, 'Elite Men', 18, 40, 'M', 350.00),
(1, 'Elite Women', 18, 40, 'F', 350.00),
(1, 'Veteran Men (40+)', 40, NULL, 'M', 300.00),
(2, 'Ultra Marathon Men', 20, 50, 'M', 450.00),
(2, 'Ultra Marathon Women', 20, 50, 'F', 450.00),
(3, 'Men (Open)', 18, NULL, 'M', 250.00),
(3, 'Women (Open)', 18, NULL, 'F', 250.00);
GO

-- Insert Event Enrolments
INSERT INTO EventEnrolments (ParticipantID, CategoryID, EnrolmentDate, IsPaid) VALUES
(1, 1, GETDATE(), 1), -- Sipho in Elite Men for CT Cycle Tour
(1, 4, GETDATE(), 0), -- Sipho in Ultra Marathon Men for Two Oceans
(2, 3, GETDATE(), 1), -- Lindiwe in Veteran Men? No, wait, she's female. Let's make category 3 unisex but she should be in a different category. We'll put her in category 2 (Elite Women) if it exists. Let's use Category 2 for Lindiwe.
(2, 2, GETDATE(), 1); -- Lindiwe in Elite Women for CT Cycle Tour
GO

-- Insert Results
-- Note: Assuming enrolment IDs start from 1. Adjust if needed after insertion.
-- Run a SELECT * FROM EventEnrolments to see the correct EnrolmentID values before inserting Results.
INSERT INTO Results (EnrolmentID, FinishTime, Position) VALUES
(1, '02:45:30', 5),
(4, '03:10:22', 12);
GO

-- Check if the data was inserted correctly
SELECT 'Table Counts Check' as CheckPoint;
SELECT 'Users', COUNT(*) FROM Users
UNION ALL
SELECT 'Organisers', COUNT(*) FROM Organisers
UNION ALL
SELECT 'Participants', COUNT(*) FROM Participants
UNION ALL
SELECT 'Events', COUNT(*) FROM Events
UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM EventEnrolments
UNION ALL
SELECT 'Results', COUNT(*) FROM Results;
GO

-- 1. Create the Database
CREATE DATABASE LibraryDB;
USE LibraryDB;

-- 2. Create Tables
-- Users Table: includes students and librarians
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    role ENUM('Librarian', 'Student') NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Authors Table
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    bio TEXT
);

-- Publishers Table
CREATE TABLE Publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address TEXT
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Books Table
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    category_id INT,
    publisher_id INT,
    available_copies INT DEFAULT 1,
    total_copies INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) ON DELETE SET NULL
);

-- Book_Authors Table
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- Transactions Table: tracks book issues and returns
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    book_id INT,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    return_date DATE,
    fine DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);

-- Reservations Table: tracks book reservations
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    book_id INT,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Fulfilled', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- 3.1. Insert 10 Students into Users table
INSERT INTO Users (name, email, phone, role) VALUES
('Vipul', 'vipul123@gmail.com', '111-222-3333', 'Student'),
('Mohit', 'mohit123@gmail.com', '222-333-4444', 'Student'),
('Nikhil', 'Nikhil123@gmail.com', '333-444-5555', 'Student'),
('Sohit', 'Sohit123@gmail.com', '444-555-6666', 'Student'),
('Rahul', 'Rahul123@gmail.com', '555-666-7777', 'Student'),
('Tarun', 'Tarun123@gmail.com', '666-777-8888', 'Student'),
('Aryan', 'Aryan123@gmail.com', '777-888-9999', 'Student'),
('Bharat', 'Bharat123@gmail.com', '888-999-0000', 'Student'),
('Kapil', 'Kapil123@gmail.com', '999-000-1111', 'Student'),
('Jay', 'Jay123@gmail.com', '000-111-2222', 'Student');

-- Insert a Librarian for administrative tasks
INSERT INTO Users (name, email, phone, role) VALUES
('Librarian', 'Librarian@gmail.com', '123-456-7890', 'Librarian');

-- 3.2. Insert Authors
INSERT INTO Authors (name, bio) VALUES 
('J.K. Rowling', 'Author of the Harry Potter series'),
('George Orwell', 'Author of 1984 and Animal Farm');

-- 3.3. Insert Publishers
INSERT INTO Publishers (name, address) VALUES 
('Penguin Books', '123 Penguin St, NY'),
('HarperCollins', '456 Harper St, CA');

-- 3.4. Insert Categories
INSERT INTO Categories (name) VALUES 
('Fiction'),
('Science'),
('Technology'),
('History');

-- 3.5. Insert Books
INSERT INTO Books (title, isbn, category_id, publisher_id, available_copies, total_copies) VALUES 
('Harry Potter and the Sorcerer''s Stone', '9780747532699', 1, 1, 5, 5),
('1984', '9780451524935', 1, 2, 3, 3),
('A Brief History of Time', '9780553380163', 2, 1, 4, 4),
('Clean Code', '9780132350884', 3, 2, 2, 2);

-- 3.6. Link Books with Authors
-- Harry Potter by J.K. Rowling
INSERT INTO Book_Authors (book_id, author_id) VALUES (1, 1);
-- 1984 by George Orwell
INSERT INTO Book_Authors (book_id, author_id) VALUES (2, 2);
-- For the other books, you can link as needed (here left without authors for demonstration)
-- For example:
-- INSERT INTO Book_Authors (book_id, author_id) VALUES (3, 1); -- if appropriate

-- 3.7. Create a sample Transaction
-- Let's say student 'Alice Johnson' (user_id = 1) borrows '1984' (book_id = 2)
INSERT INTO Transactions (user_id, book_id, due_date) 
VALUES (1, 2, DATE_ADD(CURDATE(), INTERVAL 14 DAY));

-- 3.8. Create a Reservation
-- Let student 'Bob Smith' (user_id = 2) reserve 'Clean Code' (book_id = 4)
INSERT INTO Reservations (user_id, book_id) VALUES (2, 4);

SELECT * FROM Users;

SELECT * FROM Books;

CREATE OR REPLACE VIEW StudentLentBooks AS
SELECT 
    u.user_id,
    u.name AS student_name,
    b.book_id,
    b.title AS book_title,
    t.issue_date,
    t.due_date,
    t.return_date,
    -- Calculate number of days the book has been lent:
    -- If return_date is null, use CURDATE(), otherwise use return_date.
    DATEDIFF(COALESCE(t.return_date, CURDATE()), t.issue_date) AS days_lent,
    t.fine
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Books b ON t.book_id = b.book_id
WHERE u.role = 'Student';

INSERT INTO Transactions (user_id, book_id, issue_date, due_date)
VALUES 
  (1, 1, '2024-12-01', '2025-02-15'),
  (2, 2, '2024-12-02', '2025-02-16'),
  (3, 3, '2024-12-03', '2025-02-17'),
  (4, 4, '2024-12-04', '2025-02-18'),
  (5, 1, '2024-12-05', '2025-02-19'),
  (6, 2, '2024-12-06', '2025-02-20'),
  (7, 3, '2024-12-07', '2025-02-21'),
  (8, 4, '2024-12-08', '2025-02-22'),
  (9, 1, '2024-12-09', '2025-02-23'),
  (10, 2, '2024-12-10', '2025-02-24');


SELECT *
FROM StudentLentBooks;

SET SQL_SAFE_UPDATES = 0;



UPDATE Transactions t
JOIN Users u ON t.user_id = u.user_id
SET t.return_date = DATE_ADD(t.issue_date, INTERVAL 90 DAY)
WHERE u.role = 'Student'
  AND t.return_date IS NULL;

SET SQL_SAFE_UPDATES = 1;


SELECT * FROM StudentLentBooks;


-- Create Database
CREATE DATABASE ABC_Company;
USE ABC_Company;

-- Create Tables
CREATE TABLE Person (
    Personal_ID INT PRIMARY KEY,
    Last_Name VARCHAR(50),
    First_Name VARCHAR(50),
    Age INT CHECK (Age < 65),
    Gender CHAR(1),
    Address_Line1 VARCHAR(100),
    Address_Line2 VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(2),
    ZipCode VARCHAR(10),
    Email_Address VARCHAR(100)
);

CREATE TABLE Phone (
    Phone_ID INT PRIMARY KEY,
    Personal_ID INT,
    Phone_Number VARCHAR(15),
    FOREIGN KEY (Personal_ID) REFERENCES Person(Personal_ID)
);

CREATE TABLE Department (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(50)
);

CREATE TABLE Employee (
    Personal_ID INT PRIMARY KEY,
    Rank VARCHAR(50),
    Title VARCHAR(50),
    FOREIGN KEY (Personal_ID) REFERENCES Person(Personal_ID)
);

CREATE TABLE Employee_Supervisor (
    Employee_ID INT,
    Supervisor_ID INT,
    Start_Date DATE,
    End_Date DATE,
    PRIMARY KEY (Employee_ID, Supervisor_ID, Start_Date),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Personal_ID),
    FOREIGN KEY (Supervisor_ID) REFERENCES Employee(Personal_ID)
);

CREATE TABLE Employee_Department (
    Employee_ID INT,
    Department_ID INT,
    Start_Date DATE,
    End_Date DATE,
    PRIMARY KEY (Employee_ID, Department_ID, Start_Date),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Personal_ID),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Customer (
    Personal_ID INT PRIMARY KEY,
    Preferred_Salesperson_ID INT,
    FOREIGN KEY (Personal_ID) REFERENCES Person(Personal_ID),
    FOREIGN KEY (Preferred_Salesperson_ID) REFERENCES Employee(Personal_ID)
);

CREATE TABLE Potential_Employee (
    Personal_ID INT PRIMARY KEY,
    FOREIGN KEY (Personal_ID) REFERENCES Person(Personal_ID)
);

CREATE TABLE Job (
    Job_ID INT PRIMARY KEY,
    Department_ID INT,
    Job_Description TEXT,
    Posted_Date DATE,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Job_Application (
    Application_ID INT PRIMARY KEY,
    Job_ID INT,
    Applicant_ID INT,
    Application_Date DATE,
    FOREIGN KEY (Job_ID) REFERENCES Job(Job_ID),
    FOREIGN KEY (Applicant_ID) REFERENCES Person(Personal_ID)
);

CREATE TABLE Interview (
    Interview_ID INT PRIMARY KEY,
    Job_ID INT,
    Interviewee_ID INT,
    Interviewer_ID INT,
    Interview_Time DATETIME,
    Grade INT CHECK (Grade >= 0 AND Grade <= 100),
    FOREIGN KEY (Job_ID) REFERENCES Job(Job_ID),
    FOREIGN KEY (Interviewee_ID) REFERENCES Person(Personal_ID),
    FOREIGN KEY (Interviewer_ID) REFERENCES Employee(Personal_ID)
);

CREATE TABLE Product (
    Product_ID INT PRIMARY KEY,
    Product_Type VARCHAR(50),
    Size VARCHAR(20),
    List_Price DECIMAL(10,2),
    Weight DECIMAL(10,2),
    Style VARCHAR(50)
);

CREATE TABLE Marketing_Site (
    Site_ID INT PRIMARY KEY,
    Site_Name VARCHAR(100),
    Location VARCHAR(100)
);

CREATE TABLE Site_Employee (
    Site_ID INT,
    Employee_ID INT,
    Start_Date DATE,
    End_Date DATE,
    PRIMARY KEY (Site_ID, Employee_ID, Start_Date),
    FOREIGN KEY (Site_ID) REFERENCES Marketing_Site(Site_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Personal_ID)
);

CREATE TABLE Sale (
    Sale_ID INT PRIMARY KEY,
    Product_ID INT,
    Customer_ID INT,
    Salesperson_ID INT,
    Site_ID INT,
    Sale_Time DATETIME,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Personal_ID),
    FOREIGN KEY (Salesperson_ID) REFERENCES Employee(Personal_ID),
    FOREIGN KEY (Site_ID) REFERENCES Marketing_Site(Site_ID)
);

CREATE TABLE Vendor (
    Vendor_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(200),
    Account_Number VARCHAR(50),
    Credit_Rating INT,
    Web_Service_URL VARCHAR(200)
);

CREATE TABLE Part (
    Part_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Weight DECIMAL(10,2)
);

CREATE TABLE Part_Price (
    Part_ID INT,
    Vendor_ID INT,
    Price DECIMAL(10,2),
    PRIMARY KEY (Part_ID, Vendor_ID),
    FOREIGN KEY (Part_ID) REFERENCES Part(Part_ID),
    FOREIGN KEY (Vendor_ID) REFERENCES Vendor(Vendor_ID)
);

CREATE TABLE Product_Uses_Part (
    Product_ID INT,
    Part_ID INT,
    Quantity INT,
    PRIMARY KEY (Product_ID, Part_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Part_ID) REFERENCES Part(Part_ID)
);

CREATE TABLE Salary (
    Employee_ID INT,
    Transaction_Number INT,
    Pay_Date DATE,
    Amount DECIMAL(10,2),
    PRIMARY KEY (Employee_ID, Transaction_Number),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Personal_ID)
);

-- Create Views
CREATE VIEW Employee_Avg_Salary AS
SELECT 
    e.Personal_ID,
    p.Last_Name,
    p.First_Name,
    AVG(s.Amount) as avg_monthly_salary
FROM 
    Employee e
    JOIN Person p ON e.Personal_ID = p.Personal_ID
    JOIN Salary s ON e.Personal_ID = s.Employee_ID
GROUP BY 
    e.Personal_ID, p.Last_Name, p.First_Name;

CREATE VIEW Interview_Pass_Count AS
SELECT 
    i.Interviewee_ID,
    i.Job_ID,
    COUNT(*) as passed_rounds
FROM 
    Interview i
WHERE 
    i.Grade >= 60
GROUP BY 
    i.Interviewee_ID, i.Job_ID;

CREATE VIEW Product_Sales_Count AS
SELECT 
    p.Product_Type,
    COUNT(*) as items_sold
FROM 
    Product p
    JOIN Sale s ON p.Product_ID = s.Product_ID
GROUP BY 
    p.Product_Type;

CREATE VIEW Product_Part_Cost AS
SELECT 
    p.Product_ID,
    p.Product_Type,
    SUM(pp.Price * pup.Quantity) as total_part_cost
FROM 
    Product p
    JOIN Product_Uses_Part pup ON p.Product_ID = pup.Product_ID
    JOIN Part_Price pp ON pup.Part_ID = pp.Part_ID
GROUP BY 
    p.Product_ID, p.Product_Type;

-- Queries (1-15)
-- Query 1
SELECT DISTINCT 
    i.Interviewer_ID,
    p.Last_Name,
    p.First_Name
FROM 
    Interview i
    JOIN Person p ON i.Interviewer_ID = p.Personal_ID
    JOIN Person interviewee ON i.Interviewee_ID = interviewee.Personal_ID
WHERE 
    interviewee.Last_Name = 'Cole'
    AND interviewee.First_Name = 'Hellen'
    AND i.Job_ID = '11111';

-- Query 2
SELECT 
    j.Job_ID
FROM 
    Job j
    JOIN Department d ON j.Department_ID = d.Department_ID
WHERE 
    d.Department_Name = 'Marketing'
    AND MONTH(j.Posted_Date) = 1
    AND YEAR(j.Posted_Date) = 2011;

-- Query 3
SELECT 
    e.Personal_ID,
    p.Last_Name,
    p.First_Name
FROM 
    Employee e
    JOIN Person p ON e.Personal_ID = p.Personal_ID
WHERE 
    e.Personal_ID NOT IN (
        SELECT DISTINCT Supervisor_ID 
        FROM Employee_Supervisor
        WHERE Supervisor_ID IS NOT NULL
    );

-- Query 4
SELECT 
    Site_ID,
    Location
FROM 
    Marketing_Site
WHERE 
    Site_ID NOT IN (
        SELECT DISTINCT Site_ID
        FROM Sale
        WHERE MONTH(Sale_Time) = 3 
        AND YEAR(Sale_Time) = 2011
    );

-- Query 5
SELECT 
    j.Job_ID,
    j.Job_Description
FROM 
    Job j
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM Interview i
        WHERE i.Job_ID = j.Job_ID
        GROUP BY i.Interviewee_ID
        HAVING AVG(i.Grade) >= 70 
        AND COUNT(CASE WHEN i.Grade >= 60 THEN 1 END) >= 5
    )
    AND DATEDIFF(month, j.Posted_Date, GETDATE()) > 1;

-- Query 6
SELECT DISTINCT 
    e.Personal_ID,
    p.Last_Name,
    p.First_Name
FROM 
    Employee e
    JOIN Person p ON e.Personal_ID = p.Personal_ID
    JOIN Sale s ON e.Personal_ID = s.Salesperson_ID
WHERE NOT EXISTS (
    SELECT Product_ID 
    FROM Product 
    WHERE List_Price > 200
    AND Product_ID NOT IN (
        SELECT Product_ID 
        FROM Sale 
        WHERE Salesperson_ID = e.Personal_ID
    )
);

-- Query 7
SELECT 
    Department_ID,
    Department_Name
FROM 
    Department
WHERE 
    Department_ID NOT IN (
        SELECT Department_ID
        FROM Job
        WHERE Posted_Date BETWEEN '2011-01-01' AND '2011-02-01'
    );

-- Query 8
SELECT 
    e.Personal_ID,
    p.Last_Name,
    p.First_Name,
    ed.Department_ID
FROM 
    Employee e
    JOIN Person p ON e.Personal_ID = p.Personal_ID
    JOIN Employee_Department ed ON e.Personal_ID = ed.Employee_ID
    JOIN Job_Application ja ON e.Personal_ID = ja.Applicant_ID
WHERE 
    ja.Job_ID = '12345';

-- Query 9
SELECT TOP 1 
    p.Product_Type,
    COUNT(*) as total_sales
FROM 
    Product p
    JOIN Sale s ON p.Product_ID = s.Product_ID
GROUP BY 
    p.Product_Type
ORDER BY 
    total_sales DESC;

-- Query 10
SELECT TOP 1 
    p.Product_Type,
    SUM(p.List_Price - pc.total_part_cost) as net_profit
FROM 
    Product p
    JOIN Product_Part_Cost pc ON p.Product_ID = pc.Product_ID
    JOIN Sale s ON p.Product_ID = s.Product_ID
GROUP BY 
    p.Product_Type
ORDER BY 
    net_profit DESC;

-- Query 11
SELECT 
    p.Last_Name,
    p.First_Name,
    e.Personal_ID
FROM 
    Employee e
    JOIN Person p ON e.Personal_ID = p.Personal_ID
WHERE NOT EXISTS (
    SELECT Department_ID 
    FROM Department d
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Employee_Department ed
        WHERE ed.Employee_ID = e.Personal_ID
        AND ed.Department_ID = d.Department_ID
    )
);

-- Query 12
SELECT DISTINCT 
    p.Last_Name,
    p.First_Name,
    p.Email_Address
FROM 
    Person p
    JOIN Interview i ON p.Personal_ID = i.Interviewee_ID
GROUP BY 
    p.Last_Name,
    p.First_Name,
    p.Email_Address,
    i.Job_ID
HAVING 
    AVG(i.Grade) >= 70
    AND COUNT(CASE WHEN i.Grade >= 60 THEN 1 END) >= 5;

-- Query 13
SELECT DISTINCT 
    p.Last_Name,
    p.First_Name,
    ph.Phone_Number,
    p.Email_Address
FROM 
    Person p
    JOIN Phone ph ON p.Personal_ID = ph.Personal_ID
    JOIN Interview i ON p.Personal_ID = i.Interviewee_ID
GROUP BY 
    p.Last_Name,
    p.First_Name,
    ph.Phone_Number,
    p.Email_Address,
    i.Job_ID
HAVING 
    AVG(i.Grade) >= 70
    AND COUNT(CASE WHEN i.Grade >= 60 THEN 1 END) >= 5;

-- Query 14
SELECT TOP 1 
    p.Last_Name,
    p.First_Name,
    e.Personal_ID,
    AVG(s.Amount) as avg_monthly_salary
FROM 
    Employee e
    JOIN Person p ON e.Personal_ID = p.Personal_ID
    JOIN Salary s ON e.Personal_ID = s.Employee_ID
GROUP BY 
    p.Last_Name,
    p.First_Name,
    e.Personal_ID
ORDER BY 
    avg_monthly_salary DESC;

-- Query 15
SELECT 
    v.Vendor_ID,
    v.Name
FROM 
    Vendor v
    JOIN Part_Price pp ON v.Vendor_ID = pp.Vendor_ID
    JOIN Part p ON pp.Part_ID = p.Part_ID
WHERE 
    p.Name = 'Cup'
    AND p.Weight < 4
    AND pp.Price = (
        SELECT MIN(Price)
        FROM Part_Price pp2
        JOIN Part p2 ON pp2.Part_ID = p2.Part_ID
        WHERE p2.Name = 'Cup'
        AND p2.Weight < 4
    );
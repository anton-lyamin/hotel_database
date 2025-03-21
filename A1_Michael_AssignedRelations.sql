DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS paymentInvoice;
DROP TABLE IF EXISTS paymentInformation;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS cardDetails;
DROP TABLE IF EXISTS employeeRole;
DROP TABLE IF EXISTS guest;

CREATE TABLE guest (
	guestId INT PRIMARY KEY,
	name VARCHAR(100),
	street VARCHAR(255),
	buildingNo VARCHAR(50),
	postcode VARCHAR(20),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	contactNumber VARCHAR(20),
	email VARCHAR(100),
	dob DATE,
	gender CHAR(1)
);

CREATE TABLE customer (
	customerId INT PRIMARY KEY,
	name VARCHAR(100),
	street VARCHAR(255),
	buildingNo VARCHAR(50),
	postcode VARCHAR(20),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	contactNumber VARCHAR(20),
	email VARCHAR(100),
	dob DATE,
	gender CHAR(1)
	FOREIGN KEY (customerId) references guest(guestId)
);

CREATE TABLE cardDetails (
    cardNumber VARCHAR(20) PRIMARY KEY,
    expiryDate DATE,
    nameOnCard VARCHAR(100),
    securityPin VARCHAR(6)
);


CREATE TABLE paymentInformation (
    paymentInformationId INT PRIMARY KEY,
    customerId INT,
    cardNumber VARCHAR(20),
    FOREIGN KEY (customerId) REFERENCES customer(customerId),
    FOREIGN KEY (cardNumber) REFERENCES cardDetails(cardNumber)
);

CREATE TABLE paymentInvoice (
    invoiceNumber INT PRIMARY KEY,
    reservationNumber INT,
    paymentInformationId INT,
    amount DECIMAL(10,2),
    date DATE,
    status VARCHAR(50),
    FOREIGN KEY (paymentInformationId) REFERENCES paymentInformation(paymentInformationId),
    --FOREIGN KEY (reservationNumber) REFERENCES booking(reservationNumber)
);

CREATE TABLE employeeRole (
    roleId INT PRIMARY KEY,
    description VARCHAR(255),
    clearance VARCHAR(50),
    name VARCHAR(100)
);

CREATE TABLE employee (
    employeeId INT PRIMARY KEY,
    roleId INT,
    name VARCHAR(100),
    dob DATE,
    street VARCHAR(255),
    buildingNo VARCHAR(50),
    postCode VARCHAR(20),
    city VARCHAR(100),
	country VARCHAR(100),
    state VARCHAR(100),
    phoneNumber VARCHAR(20),
    FOREIGN KEY (roleId) REFERENCES employeeRole(roleId)
);

-- Insert sample data into guest table
INSERT INTO guest (guestId, name, street, buildingNo, postcode, city, state, country, contactNumber, email, dob, gender)
VALUES
(1, 'John Doe', '123 Queen St', 'A-5', '4000', 'Brisbane', 'Queensland', 'Australia', '123-456-7890', 'johndoe@email.com', '1985-04-12', 'M'),
(2, 'Jane Smith', '456 Duke St', 'B-7', '4870', 'Cairns', 'Queensland', 'Australia', '987-654-3210', 'janesmith@email.com', '1990-08-22', 'F'),
(3, 'Sam Brown', '789 King St', 'C-10', '2300', 'Newcastle', 'New South Wales', 'Australia', '555-123-4567', 'sambrown@email.com', '1982-11-30', 'M'),
(4, 'Emily White', '123 Robinson St', 'D-4', '6725', 'Broome', 'Western Australia', 'Australia', '444-555-6666', 'emilywhite@email.com', '1995-03-11', 'F'),
(5, 'Chris Black', '456 James St', 'E-12', '0800', 'Darwin', 'Northern Territory', 'Australia', '777-888-9999', 'chrisblack@email.com', '1980-07-05', 'M'),
(6, 'Tuan Nguyen', '123 Tran Hung Dao', 'F-1', '700000', 'Ho Chi Minh City', NULL, 'Vietnam', '098-123-4567', 'tuannguyen@email.vn', '1992-06-10', 'M'),
(7, 'Amina Tan', '456 Orchard Rd', 'G-2', '238859', 'Singapore', NULL, 'Singapore', '988-123-4567', 'aminatan@email.sg', '1988-12-25', 'F'),
(8, 'Somchai Srisai', '789 Sukhumvit Rd', 'H-8', '10110', 'Bangkok', NULL, 'Thailand', '087-456-7890', 'somchaisrisai@email.th', '1984-05-14', 'M'),
(9, 'Anjali Desai', '321 MG Road', 'I-3', '400001', 'Mumbai', NULL, 'India', '022-12345678', 'anjalidesai@email.in', '1990-01-22', 'F'),
(10, 'Sujeewa Perera', '654 Galle Rd', 'J-4', '80000', 'Colombo', NULL, 'Sri Lanka', '071-9876543', 'sujeewaperera@email.lk', '1986-09-30', 'M');

-- Insert sample data into customer table (only customers who are also guests)
INSERT INTO customer (customerId, name, street, buildingNo, postcode, city, state, country, contactNumber, email, dob, gender)
VALUES
(1, 'John Doe', '123 Queen St', 'A-5', '4000', 'Brisbane', 'Queensland', 'Australia', '123-456-7890', 'johndoe@email.com', '1985-04-12', 'M'),
(2, 'Jane Smith', '456 Duke St', 'B-7', '4870', 'Cairns', 'Queensland', 'Australia', '987-654-3210', 'janesmith@email.com', '1990-08-22', 'F'),
(6, 'Tuan Nguyen', '123 Tran Hung Dao', 'F-1', '700000', 'Ho Chi Minh City', NULL, 'Vietnam', '098-123-4567', 'tuannguyen@email.vn', '1992-06-10', 'M'),
(7, 'Amina Tan', '456 Orchard Rd', 'G-2', '238859', 'Singapore', NULL, 'Singapore', '988-123-4567', 'aminatan@email.sg', '1988-12-25', 'F');

-- Insert sample data into cardDetails table
INSERT INTO cardDetails (cardNumber, expiryDate, nameOnCard, securityPin)
VALUES
('1234-5678-9876-5432', '2026-12-31', 'John Doe', '1234'),
('9876-5432-1234-5678', '2025-05-20', 'Jane Smith', '5678'),
('1111-2222-3333-4444', '2027-03-15', 'Sam Brown', '0000'),
('4444-5555-6666-7777', '2028-07-12', 'Emily White', '4321'),
('8888-9999-0000-1111', '2025-11-25', 'Chris Black', '7890'),
('5555-6666-7777-8888', '2026-08-14', 'Tuan Nguyen', '2222'),
('3333-4444-5555-6666', '2027-09-30', 'Amina Tan', '1357'),
('2222-3333-4444-5555', '2025-01-01', 'Somchai Srisai', '2468'),
('7777-8888-9999-0000', '2025-06-30', 'Anjali Desai', '3690'),
('1111-3333-4444-5555', '2027-05-10', 'Sujeewa Perera', '1357');

-- Insert sample data into paymentInformation table
INSERT INTO paymentInformation (paymentInformationId, customerId, cardNumber)
VALUES
(1, 1, '1234-5678-9876-5432'),
(2, 2, '9876-5432-1234-5678'),
(6, 6, '5555-6666-7777-8888'),
(7, 7, '3333-4444-5555-6666');

-- Insert sample data into paymentInvoice table
INSERT INTO paymentInvoice (invoiceNumber, reservationNumber, paymentInformationId, amount, date, status)
VALUES
(1001, 501, 1, 200.00, '2025-03-21', 'Paid'),
(1002, 502, 2, 150.00, '2025-03-20', 'Pending'),
(1006, 506, 6, 200.00, '2025-03-25', 'Paid'),
(1007, 507, 7, 220.00, '2025-03-26', 'Paid');

-- Insert sample data into employeeRole table
INSERT INTO employeeRole (roleId, description, clearance, name)
VALUES
(1, 'Manager', 'High', 'Manager'),
(2, 'Developer', 'Medium', 'Developer'),
(3, 'Customer Service', 'Low', 'Customer Service'),
(4, 'Housekeeping', 'Low', 'Housekeeping'),
(5, 'Security', 'Medium', 'Security');

-- Insert sample data into employee table
INSERT INTO employee (employeeId, roleId, name, dob, street, buildingNo, postCode, city, country, state, phoneNumber)
VALUES
(1, 1, 'Alice Green', '1980-02-15', '101 Maple Ave', 'D-3', '12345', 'Brisbane', 'Australia', 'Queensland', '555-111-2222'),
(2, 2, 'Bob White', '1992-05-30', '202 Birch Rd', 'E-8', '54321', 'Cairns', 'Australia', 'Queensland', '555-333-4444'),
(3, 3, 'Carol Black', '1987-07-12', '303 Cedar St', 'F-2', '67890', 'Newcastle', 'Australia', 'New South Wales', '555-555-6666'),
(4, 4, 'Daniel Blue', '1990-03-19', '404 Pine St', 'G-1', '6725', 'Broome', 'Australia', 'Western Australia', '555-777-8888'),
(5, 1, 'Eva Pink', '1985-11-04', '505 Willow St', 'H-9', '0800', 'Darwin', 'Australia', 'Northern Territory', '555-999-0000'),
(6, 1, 'Faisal Khan', '1983-12-17', '601 Red Rd', 'I-7', '700000', 'Ho Chi Minh City', 'Vietnam', 'N/A', '555-111-3333'),
(7, 2, 'Gina Tan', '1991-04-28', '702 Blue Rd', 'J-2', '238859', 'Singapore', 'Singapore', 'e','555-444-5555'),
(8, 3, 'Hiroshi Yamamoto', '1988-09-14', '803 Yellow St', 'K-6', '10110', 'Bangkok', 'Thailand', 'e' ,'555-777-8888'),
(9, 2, 'Indira Patel', '1994-01-25', '904 Green Ave', 'L-10', '400001', 'Mumbai', 'India', 'e' ,'555-999-0000'),
(10, 5, 'James Lin', '1987-06-17', '1005 Orange St', 'M-4', '50000', 'Colombo', 'Sri Lanka', 'e' ,'555-888-9999');

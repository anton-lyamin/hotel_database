DROP TABLE IF EXISTS ReservationGuest;
DROP TABLE IF EXISTS FacilityBookee;
DROP TABLE IF EXISTS FacilityBooking;
DROP TABLE IF EXISTS HotelAdvertisement;
DROP TABLE IF EXISTS HotelPackage;
DROP TABLE IF EXISTS PackageItem;
DROP TABLE IF EXISTS ServiceFacility;
DROP TABLE IF EXISTS HotelService;
DROP TABLE IF EXISTS Facility;
DROP TABLE IF EXISTS ServiceItem;
DROP TABLE IF EXISTS PaymentInvoice;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS PaymentInformation;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Advertisement;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Hotel;
DROP TABLE IF EXISTS EmployeeRole;
DROP TABLE IF EXISTS Guest;
DROP TABLE IF EXISTS Package;
DROP TABLE IF EXISTS ServiceCategory;
DROP TABLE IF EXISTS FacilityType;
DROP TABLE IF EXISTS Country;


CREATE TABLE Country
(
	countryCode    CHAR(3) PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	currency       CHAR(3) NOT NULL
);
GO

CREATE TABLE FacilityType
(
	facilityTypeId INT PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	description    VARCHAR(255) NOT NULL,
	UNIQUE (name)
);
GO

CREATE TABLE ServiceCategory
(
	categoryCode   CHAR(3) PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	description    VARCHAR(255) NOT NULL,
	type           VARCHAR(50) NULL,
	UNIQUE (name)
);
GO

CREATE TABLE Package
(
	packageId      INT PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	description    VARCHAR(255) NOT NULL,
	inclusions     VARCHAR(255) NULL,
	exclusions     VARCHAR(255) NULL,
	status         VARCHAR(25) NOT NULL,
	UNIQUE (name)
);
GO

CREATE TABLE Guest
(
	guestId        INT PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	buildingNumber VARCHAR(10) NOT NULL,
	street         VARCHAR(100) NOT NULL,
	city           VARCHAR(100) NOT NULL,
	postcode       VARCHAR(10) NULL,
	state          VARCHAR(50) NULL,
	countryCode    CHAR(3) NOT NULL,
	phoneNumber    VARCHAR(20) NOT NULL,
	email          VARCHAR(100) NOT NULL,
	gender         VARCHAR(10) NOT NULL,
	dob            DATE NOT NULL,
	UNIQUE (email),
	UNIQUE (phoneNumber),
	CONSTRAINT FK_Guest_Country FOREIGN KEY (countryCode)
		REFERENCES Country(countryCode)
		ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE EmployeeRole
(
	roleCode       CHAR(3) PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	description    VARCHAR(255) NOT NULL,
	clearance      INT NOT NULL,
	UNIQUE (name)
);
GO

CREATE TABLE Hotel
(
	hotelId        INT PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	buildingNumber VARCHAR(10) NOT NULL,
	street         VARCHAR(100) NOT NULL,
	city           VARCHAR(100) NOT NULL,
	postcode       VARCHAR(10) NULL,
	state          VARCHAR(50) NULL,
	countryCode    CHAR(3) NOT NULL,
	phoneNumber    VARCHAR(20) NOT NULL,
	description    VARCHAR(255) NULL,
	UNIQUE (phoneNumber),
	UNIQUE (name, buildingNumber, street, city, countryCode),
	CONSTRAINT FK_Hotel_Country FOREIGN KEY (countryCode)
		REFERENCES Country(countryCode)
		ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE Employee
(
	employeeId     INT PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	buildingNumber VARCHAR(10) NOT NULL,
	street         VARCHAR(100) NOT NULL,
	city           VARCHAR(100) NOT NULL,
	postcode       VARCHAR(10) NULL,
	state          VARCHAR(50) NULL,
	countryCode    CHAR(3) NOT NULL,
	phoneNumber    VARCHAR(20) NOT NULL,
	gender         VARCHAR(10) NOT NULL,
	dob            DATE NOT NULL,
	roleCode       CHAR(3) NOT NULL,
	hotelId        INT NOT NULL,
	UNIQUE (phoneNumber),
	CONSTRAINT FK_Employee_EmployeeRole FOREIGN KEY (roleCode)
		REFERENCES EmployeeRole(roleCode)
		ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT FK_Employee_Hotel FOREIGN KEY (hotelId)
		REFERENCES Hotel(hotelId)
		ON DELETE NO ACTION,
	CONSTRAINT FK_Employee_Country FOREIGN KEY (countryCode)
		REFERENCES Country(countryCode)
		ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE Advertisement
(
	advertisementId     INT PRIMARY KEY,
	startDate           DATE NOT NULL,
	endDate             DATE NOT NULL,
	advertisedPrice     DECIMAL(10,2) NOT NULL,
	advertisedCurrency  CHAR(3) NOT NULL, /* Should be derived */
	gracePeriod         INT NOT NULL,
	packageId           INT NOT NULL,
	employeeId          INT NOT NULL,
	UNIQUE (startDate, packageId, employeeId, advertisedCurrency, advertisedPrice),
	UNIQUE (endDate, packageId, employeeId, advertisedCurrency, advertisedPrice),
	CONSTRAINT FK_Advertisement_Package FOREIGN KEY (packageId)
		REFERENCES Package(packageId)
		ON DELETE NO ACTION,
	CONSTRAINT FK_Advertisement_Employee FOREIGN KEY (employeeId)
		REFERENCES Employee(employeeId)
		ON DELETE NO ACTION
);
GO

CREATE TABLE Reservation
(
	reservationNumber   	INT PRIMARY KEY,
	guestId             	INT NOT NULL,
	grantingEmployeeId      INT NULL,
	authorisingEmployeeId   INT NULL,
	discountAmount          DECIMAL(10,2) NULL,
	CONSTRAINT FK_Reservation_Guest FOREIGN KEY (guestId)
		REFERENCES Guest(guestId)
        ON DELETE NO ACTION,
	CONSTRAINT FK_Reservation_GrantingEmployee FOREIGN KEY (grantingEmployeeId)
		REFERENCES Employee(employeeId)
        ON DELETE NO ACTION,
	CONSTRAINT FK_Reservation_AuthorisingEmployee FOREIGN KEY (authorisingEmployeeId)
        REFERENCES Employee(employeeId)
        ON DELETE NO ACTION
);
GO

CREATE TABLE PaymentInformation
(
	paymentInfoId 	INT PRIMARY KEY,
	vendorToken 	VARCHAR(255) NOT NULL,
	guestId 		INT NOT NULL,
	UNIQUE (vendorToken),
	CONSTRAINT FK_PaymentInformation_Guest FOREIGN KEY (guestId)
        REFERENCES Guest(guestId)
        ON DELETE CASCADE
);
GO

CREATE TABLE Booking
(
	bookingId 			INT PRIMARY KEY,
	reservationNumber 	INT NOT NULL,
	advertisementId 	INT NOT NULL,
	quantity 			INT NOT NULL,
	startDate 			DATE NOT NULL,
	endDate 			DATE NOT NULL,
	UNIQUE (reservationNumber, advertisementId, startDate, endDate),
	CONSTRAINT FK_Booking_Reservation FOREIGN KEY (reservationNumber)
		REFERENCES Reservation(reservationNumber)
		ON DELETE CASCADE,
	CONSTRAINT FK_Booking_Advertisement FOREIGN KEY (advertisementId)
		REFERENCES Advertisement(advertisementId)
		ON DELETE CASCADE
);
GO

CREATE TABLE PaymentInvoice
(
	invoiceNumber 		INT PRIMARY KEY,
	amount 				DECIMAL(10,2),
	date 				DATE NOT NULL,
	status 				VARCHAR(25) NOT NULL,
	reservationNumber 	INT NOT NULL,
	paymentInfoId 		INT NOT NULL,
	bookingId 			INT NOT NULL,
	CONSTRAINT FK_PaymentInvoice_PaymentInfo FOREIGN KEY (paymentInfoId)
		REFERENCES PaymentInformation(paymentInfoId)
		ON DELETE NO ACTION,
	CONSTRAINT FK_PaymentInvoice_Reservation FOREIGN KEY (reservationNumber)
		REFERENCES Reservation(reservationNumber)
		ON DELETE NO ACTION,
	CONSTRAINT FK_PaymentInvoice_Booking FOREIGN KEY (bookingId)
		REFERENCES Booking(bookingId)
		ON DELETE NO ACTION
);
GO

CREATE TABLE ServiceItem
(
	serviceId 		INT PRIMARY KEY,
	name 			VARCHAR(100) NOT NULL,
	description 	VARCHAR(255) NOT NULL,
	restrictions 	VARCHAR(255) NULL,
	notes 			VARCHAR(255) NULL,
	status 			VARCHAR(25) NOT NULL,
	categoryCode 	CHAR(3) NOT NULL,
	CONSTRAINT FK_ServiceItem_ServiceCategory FOREIGN KEY (categoryCode)
		REFERENCES ServiceCategory(categoryCode)
		ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

CREATE TABLE Facility
(
	facilityId 		INT PRIMARY KEY,
	name 			VARCHAR(100) NOT NULL,
	description 	VARCHAR(255) NOT NULL,
	status 			VARCHAR(25) NOT NULL,
	capacity       	INT NOT NULL,
	hotelId 		INT NOT NULL,
	facilityTypeId 	INT NOT NULL,
	UNIQUE (name, hotelId),
	CONSTRAINT FK_Facility_Hotel FOREIGN KEY (hotelId)
		REFERENCES Hotel(hotelId)
		ON DELETE CASCADE,
	CONSTRAINT FK_Facility_FacilityType FOREIGN KEY (facilityTypeId)
		REFERENCES FacilityType(facilityTypeId)
		ON DELETE NO ACTION
);
GO

CREATE TABLE HotelService
(
	hotelId 		INT NOT NULL,
	serviceId 		INT NOT NULL,
	startTime 		TIME(0) NOT NULL,
	endTime 		TIME(0) NOT NULL,
	capacity 		INT NULL,
	baseCost 		DECIMAL(10,2) NOT NULL,
	baseCurreny 	CHAR(3) NOT NULL, /* derived attribute */
	PRIMARY KEY (hotelId, serviceId, startTime),
	UNIQUE (hotelId, serviceId, endTime),
	CONSTRAINT FK_HotelService_Hotel FOREIGN KEY (hotelId)
		REFERENCES Hotel(hotelId)
		ON DELETE CASCADE,
	CONSTRAINT FK_HotelService_ServiceItem FOREIGN KEY (serviceId)
		REFERENCES ServiceItem(serviceId)
		ON DELETE CASCADE
);
GO

CREATE TABLE ServiceFacility
(
	facilityTypeId 	INT NOT NULL,
	serviceId 		INT NOT NULL,
	PRIMARY KEY (facilityTypeId, serviceId),
	CONSTRAINT FK_ServiceFacility_FacilityType FOREIGN KEY (facilityTypeId)
		REFERENCES FacilityType(facilityTypeId)
		ON DELETE CASCADE,
	CONSTRAINT FK_ServiceFacility_ServiceItem FOREIGN KEY (serviceId)
		REFERENCES ServiceItem(serviceId)
		ON DELETE CASCADE
);
GO

CREATE TABLE PackageItem
(
	packageId 	INT NOT NULL,
	serviceId 	INT NOT NULL,
	quantity	INT,
	PRIMARY KEY (packageId, serviceId),
	CONSTRAINT FK_PackageItem_Package FOREIGN KEY (packageId)
		REFERENCES Package(packageId)
		ON DELETE CASCADE,
	CONSTRAINT FK_PackageItem_ServiceItem FOREIGN KEY (serviceId)
		REFERENCES ServiceItem(serviceId)
		ON DELETE CASCADE
);
GO

CREATE TABLE HotelPackage
(
	hotelId 	INT NOT NULL,
	packageId 	INT NOT NULL,
	PRIMARY KEY (hotelId, packageId),
	CONSTRAINT FK_HotelPackage_Hotel FOREIGN KEY (hotelId)
		REFERENCES Hotel(hotelId)
		ON DELETE CASCADE,
	CONSTRAINT FK_HotelPackage_Package FOREIGN KEY (packageId)
		REFERENCES Package(packageId)
		ON DELETE CASCADE
);
GO

CREATE TABLE HotelAdvertisement
(
	hotelId 			INT NOT NULL,
	advertisementId 	INT NOT NULL,
	PRIMARY KEY (hotelId, advertisementId),
	CONSTRAINT FK_HotelAdvertisement_Hotel FOREIGN KEY (hotelId)
		REFERENCES Hotel(hotelId)
		ON DELETE CASCADE,
	CONSTRAINT FK_HotelAdvertisement_Advertisement FOREIGN KEY (advertisementId)
		REFERENCES Advertisement(advertisementId)
		ON DELETE CASCADE
);
GO

CREATE TABLE FacilityBooking
(
	facilityBookingId 	INT PRIMARY KEY,
	bookingId 			INT NOT NULL,
	facilityId 			INT NOT NULL,
	startDateTime 		DATETIME NOT NULL,
	endDateTime 		DATETIME NOT NULL,
	UNIQUE (bookingId, facilityId, startDateTime, endDateTime),
	CONSTRAINT FK_FacilityBooking_Booking FOREIGN KEY (bookingId)
		REFERENCES Booking(bookingId)
		ON DELETE CASCADE,
	CONSTRAINT FK_FacilityBooking_Facility FOREIGN KEY (facilityId)
		REFERENCES Facility(facilityId)
		ON DELETE CASCADE
);
GO

CREATE TABLE FacilityBookee
(
	facilityBookingId 	INT NOT NULL,
	guestId 			INT NOT NULL,
	PRIMARY KEY (facilityBookingId, guestId),
	CONSTRAINT FK_FacilityBookee_FacilityBooking FOREIGN KEY (facilityBookingId)
		REFERENCES FacilityBooking(facilityBookingId)
		ON DELETE CASCADE,
	CONSTRAINT FK_FacilityBookee_Guest FOREIGN KEY (guestId)
		REFERENCES Guest(guestId)
		ON DELETE CASCADE
);
GO

CREATE TABLE ReservationGuest
(
	reservationNumber 	INT NOT NULL,
	guestId 			INT NOT NULL,
	PRIMARY KEY (reservationNumber, guestId),
	CONSTRAINT FK_ReservationGuest_Reservation FOREIGN KEY (reservationNumber)
		REFERENCES Reservation(reservationNumber)
		ON DELETE NO ACTION,
	CONSTRAINT FK_ReservationGuest_Guest FOREIGN KEY (guestId)
		REFERENCES Guest(guestId)
		ON DELETE NO ACTION
);
GO

--The following data used to populate the DB was generated using CHAT GPT
-- Inserting data into Country table
INSERT INTO Country (countryCode, name, currency)
VALUES 
('AUS', 'Australia', 'AUD'),
('VNM', 'Vietnam', 'VND'),
('SGP', 'Singapore', 'SGD'),
('THA', 'Thailand', 'THB'),
('LKA', 'Sri Lanka', 'LKR'),
('IND', 'India', 'INR');

-- Inserting data into FacilityType table
INSERT INTO FacilityType (facilityTypeId, name, description)
VALUES 
(1, 'Swimming Pool', 'A pool for guests to swim and relax'),
(2, 'Gym', 'Fitness area with exercise equipment'),
(3, 'Spa', 'Relaxing area for massages and wellness services'),
(4, 'Restaurant', 'Dining area serving various cuisines');

-- Inserting data into ServiceCategory table
INSERT INTO ServiceCategory (categoryCode, name, description, type)
VALUES 
('RCP', 'Reception', 'Guest reception services', 'General'),
('HRS', 'Housekeeping', 'Room cleaning and maintenance', 'General'),
('FTS', 'Food & Beverage', 'Food and drink services', 'Service');

-- Inserting data into Package table
INSERT INTO Package (packageId, name, description, inclusions, exclusions, status)
VALUES 
(1, 'Luxury Stay', 'A 5-star luxury package for guests', 'Breakfast, Dinner, Spa', 'Airport transfer', 'Available'),
(2, 'Family Vacation', 'Ideal for family holidays', 'Breakfast, Tickets to local attractions', 'Meals for kids under 5', 'Unavailable');

-- Inserting data into Guest table
INSERT INTO Guest (guestId, name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
VALUES 
(1, 'John Doe', '123', 'Main St', 'Sydney', '2000', 'NSW', 'AUS', '0412345678', 'johndoe@email.com', 'Male', '1985-06-15'),
(2, 'Jane Smith', '456', 'Pine Ave', 'Cairns', '4870', 'QLD', 'AUS', '0422345678', 'janesmith@email.com', 'Female', '1990-02-22');

-- Inserting data into EmployeeRole table
INSERT INTO EmployeeRole (roleCode, name, description, clearance)
VALUES 
('ADM', 'Administrator', 'Handles all management and administrative tasks', 1),
('REC', 'Receptionist', 'Handles guest check-ins and check-outs', 2);

-- Inserting data into Hotel table
INSERT INTO Hotel (hotelId, name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, description)
VALUES 
(1, 'Leisure Hotel Brisbane', '10', 'River Rd', 'Brisbane', '4000', 'QLD', 'AUS', '0732123456', 'A 5-star hotel with amazing river views'),
(2, 'Leisure Resort Cairns', '25', 'Beach Rd', 'Cairns', '4870', 'QLD', 'AUS', '0741209876', 'Seaside resort with top-notch amenities');

-- Inserting data into Employee table
INSERT INTO Employee (employeeId, name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, gender, dob, roleCode, hotelId)
VALUES 
(1, 'Alice Brown', '789', 'Sunset Blvd', 'Brisbane', '4000', 'QLD', 'AUS', '0412345679', 'Female', '1988-11-30', 'ADM', 1),
(2, 'Bob Green', '101', 'Beach Ave', 'Cairns', '4870', 'QLD', 'AUS', '0422345679', 'Male', '1987-05-10', 'REC', 2);

-- Inserting data into Advertisement table
INSERT INTO Advertisement (advertisementId, startDate, endDate, advertisedPrice, advertisedCurrency, gracePeriod, packageId, employeeId)
VALUES 
(1, '2025-06-01', '2025-12-31', 150.00, 'AUD', 30, 1, 1),
(2, '2025-05-01', '2025-10-30', 120.00, 'AUD', 15, 2, 2);

-- Inserting data into Reservation table
INSERT INTO Reservation (reservationNumber, guestId, grantingEmployeeId, authorisingEmployeeId, discountAmount)
VALUES 
(1001, 1, 1, 2, 10.00),
(1002, 2, 2, 1, 5.00);

-- Inserting data into PaymentInformation table
INSERT INTO PaymentInformation (paymentInfoId, vendorToken, guestId)
VALUES 
(1, 'VENDOR12345', 1),
(2, 'VENDOR67890', 2);

-- Inserting data into Booking table
INSERT INTO Booking (bookingId, reservationNumber, advertisementId, quantity, startDate, endDate)
VALUES 
(1, 1001, 1, 2, '2025-06-01', '2025-06-07'),
(2, 1002, 2, 1, '2025-05-15', '2025-05-20');

-- Inserting data into PaymentInvoice table
INSERT INTO PaymentInvoice (invoiceNumber, amount, date, status, reservationNumber, paymentInfoId, bookingId)
VALUES 
(1, 300.00, '2025-06-01', 'Paid', 1001, 1, 1),
(2, 240.00, '2025-05-15', 'Paid', 1002, 2, 2);

-- Inserting data into ServiceItem table
INSERT INTO ServiceItem (serviceId, name, description, restrictions, notes, status, categoryCode)
VALUES 
(1, 'Spa Treatment', 'A full body massage for relaxation', 'Age 18+', 'Use of essential oils', 'Active', 'HRS'),
(2, 'Gym Access', 'Access to the hotel gym', NULL, 'Available 24/7', 'Active', 'RCP'),
(3, 'Yoga Session', 'A group yoga class for relaxation and flexibility', 'Age 16+', 'Held every morning', 'Active', 'HRS'),
(4, 'Room Service', 'Food and drink served directly to the guest’s room', 'Available 24/7', 'Menu includes snacks, meals, and beverages', 'Active', 'FTS'),
(5, 'Guided City Tour', 'A tour of the city with a local guide', 'Minimum 2 guests', 'Tours available daily', 'Active', 'RCP'),
(6, 'Diving Lesson', 'Introductory diving lesson for beginners', 'Age 18+; health waiver required', 'Equipment provided', 'Active', 'HRS'),
(7, 'Airport Transfer', 'Private shuttle service from the airport to the hotel', 'Requires advance booking', 'Available for all guests', 'Active', 'RCP'),
(8, 'Cooking Class', 'Learn to cook local dishes with a professional chef', 'Age 12+', 'Available weekly', 'Active', 'FTS'),
(9, 'Golf Course Access', 'Access to an 18-hole golf course', 'Golf clubs and balls available for rent', 'Golf lessons available', 'Active', 'HRS'),
(10, 'Pet Sitting', 'Pet sitting service for guests with pets', 'Pets must be under 10 kg', 'Available daily', 'Active', 'RCP'),
(11, 'Water Sports', 'Various water sports including kayaking and paddleboarding', 'Suitable for all ages', 'Equipment provided', 'Active', 'HRS'),
(12, 'Wine Tasting', 'Tasting of local wines with a sommelier', 'Age 18+', 'Held every weekend', 'Active', 'FTS');

-- Inserting data into Facility table
INSERT INTO Facility (facilityId, name, description, status, capacity, hotelId, facilityTypeId)
VALUES 
(1, 'Oceanview Pool', 'An outdoor swimming pool with ocean views', 'Available', 50, 1, 1),
(2, 'Fitness Center', 'A gym with modern fitness equipment', 'Available', 30, 2, 2);

-- Inserting data into HotelService table
INSERT INTO HotelService (hotelId, serviceId, startTime, endTime, capacity, baseCost, baseCurreny)
VALUES 
(1, 1, '09:00', '18:00', 10, 150.00, 'AUD'),
(2, 2, '06:00', '22:00', 20, 50.00, 'AUD');

-- Inserting data into ServiceFacility table
INSERT INTO ServiceFacility (facilityTypeId, serviceId)
VALUES 
(1, 1),
(2, 2);

-- Inserting data into PackageItem table
INSERT INTO PackageItem (packageId, serviceId, quantity)
VALUES 
(1, 1, 2),
(2, 2, 3);

-- Inserting data into HotelPackage table
INSERT INTO HotelPackage (hotelId, packageId)
VALUES 
(1, 1),
(2, 2);

-- Inserting data into HotelAdvertisement table
INSERT INTO HotelAdvertisement (hotelId, advertisementId)
VALUES 
(1, 1),
(2, 2);

-- Inserting data into FacilityBooking table
INSERT INTO FacilityBooking (facilityBookingId, bookingId, facilityId, startDateTime, endDateTime)
VALUES 
(1, 1, 1, '2025-06-01 09:00', '2025-06-01 11:00'),
(2, 2, 2, '2025-05-15 06:00', '2025-05-15 07:30');

-- Inserting data into FacilityBookee table
INSERT INTO FacilityBookee (facilityBookingId, guestId)
VALUES 
(1, 1),
(2, 2);

-- Inserting data into ReservationGuest table
INSERT INTO ReservationGuest (reservationNumber, guestId)
VALUES 
(1001, 1),
(1002, 2);

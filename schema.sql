/*
	* Database Schema
*/

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
	facilityTypeId INT IDENTITY(1,1) PRIMARY KEY,
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
	packageId      INT IDENTITY(1,1) PRIMARY KEY,
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
	guestId        INT IDENTITY(1,1) PRIMARY KEY,
	name           VARCHAR(100) NOT NULL,
	buildingNumber VARCHAR(10) NOT NULL,
	street         VARCHAR(100) NOT NULL,
	city           VARCHAR(100) NOT NULL,
	postcode       VARCHAR(10) NULL,
	state          VARCHAR(50) NULL,
	countryCode    CHAR(3) NOT NULL,
	phoneNumber    VARCHAR(20) NOT NULL,
	email          VARCHAR(100) NOT NULL,
	gender         VARCHAR(10) NULL,
	dob            DATE NULL,
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
	hotelId        INT IDENTITY(1,1) PRIMARY KEY,
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
	employeeId     INT IDENTITY(1,1) PRIMARY KEY,
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
	advertisementId     INT IDENTITY(1,1) PRIMARY KEY,
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
	reservationNumber   	INT IDENTITY(1,1) PRIMARY KEY,
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
	paymentInfoId 	INT IDENTITY(1,1) PRIMARY KEY,
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
	bookingId 			INT IDENTITY(1,1) PRIMARY KEY,
	reservationNumber 	INT NOT NULL,
	advertisementId 	INT NOT NULL,
	quantity 			INT NOT NULL,
	startDate 			DATE NOT NULL,
	endDate 			DATE NOT NULL,
	isInitialBooking	BIT NOT NULL, -- indicates wether a booking is part of reservation
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
	invoiceNumber 		INT IDENTITY(1,1) PRIMARY KEY,
	amount 				DECIMAL(10,2),
	date 				DATE NOT NULL,
	status 				VARCHAR(25) NOT NULL,
	reservationNumber 	INT NULL, -- can be nothing
	paymentInfoId 		INT NOT NULL,
	bookingId 			INT NULL, -- can be nothing
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
	serviceId 		INT IDENTITY(1,1) PRIMARY KEY,
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
	facilityId 		INT IDENTITY(1,1) PRIMARY KEY,
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
	baseCurrency 	CHAR(3) NOT NULL, /* derived attribute */
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
	quantity	INT NOT NULL, -- i.e. how many days of a stay or number of massages
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
	facilityBookingId 	INT IDENTITY(1,1) PRIMARY KEY,
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

CREATE TRIGGER derive_service_currency
ON HotelService
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO HotelService (hotelId, serviceId, startTime, endTime, capacity, baseCost, baseCurrency)
    SELECT 
        i.hotelId,
        i.serviceId,
        i.startTime,
		i.endTime,
		i.capacity,
		i.baseCost,
		c.currency AS baseCurrency
    FROM inserted i
		LEFT JOIN Hotel h on i.hotelId = h.hotelId
    	LEFT JOIN Country c ON h.countryCode = c.countryCode
END;
GO

CREATE TRIGGER enforce_same_country
ON HotelAdvertisement
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT i.advertisementId
        FROM inserted i
        INNER JOIN hotel h ON i.hotelId = h.hotelId
        GROUP BY i.advertisementId
        HAVING COUNT(DISTINCT h.countryCode) > 1
    )
    BEGIN
        RAISERROR ('All hotels associated with an advertisement must be in the same country.', 16, 1)
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        RETURN
    END

    INSERT INTO HotelAdvertisement (hotelId, advertisementId)
    SELECT hotelId, advertisementId
    FROM inserted
END;
GO


CREATE TRIGGER derive_advertisement_currency
ON HotelAdvertisement
AFTER INSERT
AS
BEGIN
	WITH AdCountries AS (
		SELECT 
			ha.advertisementId,
			COUNT(DISTINCT h.countryCode) AS countryCount,
			MAX(h.countryCode) AS countryCode
		FROM HotelAdvertisement ha
		INNER JOIN hotel h ON ha.hotelId = h.hotelId
		INNER JOIN inserted i ON ha.advertisementId = i.advertisementId
		GROUP BY ha.advertisementId
	)

	UPDATE a
	SET a.advertisedCurrency = c.currency
	FROM advertisement a
	INNER JOIN AdCountries ac ON a.advertisementId = ac.advertisementId
        INNER JOIN Country c ON ac.countryCode = c.countryCode
	WHERE ac.countryCount = 1
END;
GO

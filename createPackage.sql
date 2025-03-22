
DROP PROCEDURE IF EXISTS usp_GetErrorInfo;
DROP PROCEDURE IF EXISTS usp_createPackage;
DROP TYPE IF EXISTS ServiceItemList;

-- ===============================================
--remove this code below once integrated with others

DROP TABLE IF EXISTS Advertisement;
DROP TABLE IF EXISTS PackageItem;
DROP TABLE IF EXISTS Package;
DROP TABLE IF EXISTS ServiceItem;


CREATE TABLE Package(
packageId INT PRIMARY KEY, 
name VARCHAR(255), 
description VARCHAR(255)
);

CREATE TABLE ServiceItem (
	serviceItemId INT PRIMARY KEY
);

INSERT INTO ServiceItem(serviceItemId)
VALUES (1),(2),(3),(4);

CREATE TABLE PackageItem (
	serviceItemId INT,
	packageId INT,
	quantity INT,
	FOREIGN KEY (serviceItemId) REFERENCES ServiceItem(serviceItemId),
	FOREIGN KEY (packageId) REFERENCES Package(packageId),
	CONSTRAINT PK_PackageItem PRIMARY KEY (serviceItemId,packageId)
);

CREATE TABLE Advertisement (
	advertisementId INT PRIMARY KEY,
	packageId INT,
	employeeId INT,
	startDate DATE,
	endDate DATE,
	price DECIMAL(10,2),
	currency CHAR(3),
	gracePeriod VARCHAR(255),
	FOREIGN KEY (packageId) REFERENCES Package(packageId),
	FOREIGN KEY (employeeId) REFERENCES Employee(employeeId)

);

--remove this code above integrated with others
-- ===============================================

CREATE TYPE ServiceItemList AS TABLE(
serviceItemId INT,
quantity INT
);
go

CREATE PROCEDURE usp_createPackage 
	@packageName CHAR(255),
	@serviceItemList ServiceItemList READONLY,
	@description CHAR(255),
	@startDate DATE,
	@endDate DATE,
	@price DECIMAL (10,2),
	@currency CHAR(3),
	@employeeId INT,
	@packageId INT OUTPUT
AS
BEGIN
	--Insert into package package name, description and get packageId
	SELECT @packageId = ISNULL((SELECT MAX(packageId)+1 FROM Package),1);
	INSERT INTO Package (packageId,name,description)
	VALUES (
		@packageId,
		@packageName,
		@description);
	--serviceItemList goes on the packageItem. For each service item on the list
	INSERT INTO PackageItem(serviceItemId, packageId, quantity)
	SELECT serviceItemId, @packageId, quantity
	FROM @serviceItemList;
	--Insert packageId, price, currency, employeeId, startDate, and EndDate into advertisement
	INSERT INTO Advertisement (advertisementId, packageId, price, currency, employeeId, startDate, endDate)
	VALUES (
		ISNULL((SELECT MAX(advertisementId)+1 FROM Advertisement),1),
		@packageId, 
		@price,
		@currency,
		@employeeId,
		@startDate,
		@endDate
	);
END
go

CREATE PROCEDURE usp_GetErrorInfo
AS
SELECT
	ERROR_NUMBER() AS ErrorNumber,
	ERROR_SEVERITY() AS ErrorSeverity,
	ERROR_STATE() AS ErrorState,
	ERROR_PROCEDURE() AS ErrorProcedure,
	ERROR_LINE() AS ErrorLine,
	ERROR_MESSAGE() AS ErrorMessage;
GO


/*
	Create Package

	This procedure creates a package, associates it with service items and creates an advertisement for said package. 

	Assumptions and constraints:
	-	The package and advertisement are not associated with a hotel because this is not part of
		the procedure specification
*/

DROP PROCEDURE IF EXISTS usp_GetErrorInfo;
DROP PROCEDURE IF EXISTS usp_createPackage;
DROP TYPE IF EXISTS ServiceItemList;

CREATE TYPE ServiceItemList AS TABLE(
	serviceItemId INT,
	quantity INT
)
GO

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
	BEGIN TRANSACTION
	DECLARE @defaultPackageStatus CHAR(255) = 'Available'
	DECLARE @defaultGracePeriod INT = 30

	--Insert into package package name, description and get packageId

	INSERT INTO Package (name,description,status)
	VALUES (
		@packageName,
		@description,
		@defaultPackageStatus) 

	SELECT @packageId = packageId FROM Package WHERE name = @packageName

	--serviceItemList goes on the packageItem. For each service item on the list
	INSERT INTO PackageItem(serviceId, packageId, quantity)
	SELECT serviceItemId, @packageId, quantity
	FROM @serviceItemList

	--Insert packageId, price, currency, employeeId, startDate, and EndDate into advertisement
	INSERT INTO Advertisement (packageId, advertisedPrice, advertisedCurrency, employeeId, startDate, endDate, gracePeriod)
	VALUES (
		@packageId, 
		@price,
		@currency,
		@employeeId,
		@startDate,
		@endDate,
		@defaultGracePeriod
	)
	COMMIT TRANSACTION
END
GO

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


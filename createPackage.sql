DROP PROCEDURE IF EXISTS usp_GetErrorInfo;
DROP PROCEDURE IF EXISTS usp_createPackage;
DROP TYPE IF EXISTS ServiceItemList;

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

	DECLARE @defaultPackageStatus CHAR(255) = 'Available';
	DECLARE @defaultGracePeriod INT = 30;

	--Insert into package package name, description and get packageId
	SELECT @packageId = ISNULL((SELECT MAX(packageId)+1 FROM Package),1);
	INSERT INTO Package (packageId,name,description,status)
	VALUES (
		@packageId,
		@packageName,
		@description,
		@defaultPackageStatus); 
	--serviceItemList goes on the packageItem. For each service item on the list
	INSERT INTO PackageItem(serviceId, packageId, quantity)
	SELECT serviceItemId, @packageId, quantity
	FROM @serviceItemList;
	--Insert packageId, price, currency, employeeId, startDate, and EndDate into advertisement
	INSERT INTO Advertisement (advertisementId, packageId, advertisedPrice, advertisedCurrency, employeeId, startDate, endDate, gracePeriod)
	VALUES (
		ISNULL((SELECT MAX(advertisementId)+1 FROM Advertisement),1),
		@packageId, 
		@price,
		@currency,
		@employeeId,
		@startDate,
		@endDate,
		@defaultGracePeriod
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


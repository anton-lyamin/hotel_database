/*
	* Create Package Tests
*/

DECLARE @serviceItemList ServiceItemList
DECLARE @packageId INT
DECLARE @hotelName VARCHAR(100) = 'Grand Ocean Hotel'
DECLARE @packageName VARCHAR(100) = 'Couples Massage'

DECLARE @employeeId INT 
SELECT @employeeId = employeeId
FROM Employee WHERE phoneNumber = '0299001006'

DECLARE @ServiceMapping TABLE (
	name VARCHAR(100),
	quantity INT
)

INSERT INTO @ServiceMapping (name, quantity)
VALUES
	('massage', 2)

INSERT INTO @ServiceItemList(serviceItemId, quantity)
SELECT s.serviceId, m.quantity
FROM @ServiceMapping m
INNER JOIN ServiceItem s ON s.name = m.name


-- create massage package
BEGIN TRY
	EXECUTE usp_createPackage
	@packageName, 
	@serviceItemList,
	'An hour long massage for two',
	'2024-12-1',
	'2025-6-1',
	150.00,
	'---',
	@employeeId,
	@packageId OUT
END TRY
BEGIN CATCH
	EXECUTE usp_GetErrorInfo
END CATCH

PRINT 'The package id is:'+str(@packageId)

SELECT * 
FROM Package p
INNER JOIN advertisement a ON p.packageId = a.packageId
WHERE p.packageId = @packageId
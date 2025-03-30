DECLARE @serviceItemList ServiceItemList
DECLARE @packageId INT
DECLARE @packageName CHAR(255) = 'test package'

DELETE FROM Advertisement WHERE packageId =
	(SELECT packageId FROM Package WHERE name = @packageName);

DELETE FROM PackageItem WHERE packageId =
	(SELECT packageId FROM Package WHERE name = @packageName);

DELETE FROM Package WHERE name = @packageName;


INSERT INTO @serviceItemList (serviceItemId, quantity)
VALUES 
	(1,1),
	(2,1),
	(3,1),
	(4,1);

BEGIN TRY
	EXECUTE usp_createPackage
	@packageName, 
	@serviceItemList,
	'this is a description',
	'2025-03-22',
	'2025-03-22',
	1.00,
	'AUD',
	1,
	@packageId OUT
END TRY
BEGIN CATCH
	EXECUTE usp_GetErrorInfo
END CATCH;

PRINT 'The package id is:'+str(@packageId)

SELECT * from Package
WHERE packageId = @packageId;
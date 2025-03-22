DECLARE @serviceItemList ServiceItemList
DECLARE @packageId INT

INSERT INTO @serviceItemList (serviceItemId, quantity)
VALUES 
	(1,1),
	(2,2),
	(3,3),
	(4,3);

BEGIN TRY
	EXECUTE usp_createPackage
	'michael', 
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
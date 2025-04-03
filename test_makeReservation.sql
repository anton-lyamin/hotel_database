DECLARE @reservedAdvertisedPackageList ReservedAdvertisedPackageList
DECLARE @guestList GuestList
DECLARE @reservationId INT

/*
INSERT INTO @reservedAdvertisedPackageList (packageId, quantity, startDate, endDate)
VALUES 
	();


INSERT INTO @guestList (name, buildingNumber, street, city, postcode, state, countryCode, phoneNo, email)
VALUES
	();

*/

BEGIN TRY
	EXECUTE usp_makeReservation
	'test_michael',
	55,
	'test_street1',
	'test_city1',
	555,
	'test_state',
	'555',
	'555,555,555',
	'test_Email',
	@reservedAdvertisedPackageList,
	@guestList,
	@reservationId OUT
END TRY
BEGIN CATCH
	EXECUTE usp_GetErrorInfo
END CATCH;

PRINT 'The reservation id number is:'+str(@reservationId)

SELECT * from Reservation
WHERE reservationNumber = @reservationId;
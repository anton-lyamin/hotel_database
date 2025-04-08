/*
    * Make Reservation Tests
*/

/*
    TEST CASE: Valid reservation
*/

DECLARE @PackageReservations PackageReservationType
DECLARE @GuestList GuestListType
DECLARE @Res INT

INSERT INTO @PackageReservations (packageName, quantity, startDate, endDate)
VALUES ('Couples Retreat', 1, '2025-04-17', '2025-04-22')

INSERT INTO @GuestList (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
VALUES ('Christopher James', '101', 'Elizabeth St', 'Sydney', '2000', 'NSW', 'AUS', '0411222444', 'christopher.james@example.com', 'Male', '1984-09-18')

EXECUTE usp_makeReservation
    @CustomerName = 'Victoria Montgomery',
    @CustomerBuildingNumber = '101',
    @CustomerStreet = 'Elizabeth St',
    @CustomerCity = 'Sydney',
    @CustomerPostcode = '2000',
    @CustomerState = 'NSW',
    @CustomerCountryCode = 'AUS',
    @CustomerPhone = '0411222333',
    @CustomerEmail = 'victoria.montgomery@example.com',
    @CustomerGender = 'Female',
    @CustomerDOB = '1986-04-12',
    @HotelName = 'Grand Ocean Hotel',
    @ReservationNumber = @Res OUT,
    @PackageReservations = @PackageReservations,
    @GuestList = @GuestList

SELECT 
    b.reservationNumber,
    b.bookingId,
    p.name AS PackageName,
    p.inclusions AS inclusions,
    b.startDate AS BookingStartDate,
    b.endDate AS BookingEndDate,
    fb.facilityBookingId,
    f.name AS FacilityName,
    ft.name AS FacilityType,
    fb.startDateTime AS FacilityBookingStartDateTime,
    fb.endDateTime AS FacilityBookingEndDateTime
FROM Booking b
JOIN Advertisement a ON b.advertisementId = a.advertisementId
JOIN Package p ON a.packageId = p.packageId
LEFT JOIN FacilityBooking fb ON b.bookingId = fb.bookingId
LEFT JOIN Facility f ON fb.facilityId = f.facilityId
LEFT JOIN FacilityType ft ON f.facilityTypeId = ft.facilityTypeId
WHERE b.reservationNumber = @Res
ORDER BY b.bookingId, fb.facilityBookingId
GO

/*
    TEST CASE: No valid guest email
*/

DECLARE @PackageReservations PackageReservationType
DECLARE @GuestList GuestListType
DECLARE @Res INT

INSERT INTO @PackageReservations (packageName, quantity, startDate, endDate)
VALUES ('Couples Retreat', 1, '2025-04-17', '2025-04-22')

INSERT INTO @GuestList (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
VALUES ('Christopher James', '101', 'Elizabeth St', 'Sydney', '2000', 'NSW', 'AUS', '0411222444', 'christopher.james@example.com', 'Male', '1984-09-18')

EXECUTE usp_makeReservation
    @CustomerName = 'Victoria Montgomery',
    @CustomerBuildingNumber = '101',
    @CustomerStreet = 'Elizabeth St',
    @CustomerCity = 'Sydney',
    @CustomerPostcode = '2000',
    @CustomerState = 'NSW',
    @CustomerCountryCode = 'AUS',
    @CustomerPhone = '0411222333',
    @CustomerEmail = 'doesnt_exist@example.com',
    @CustomerGender = 'Female',
    @CustomerDOB = '1986-04-12',
    @HotelName = 'Grand Ocean Hotel',
    @ReservationNumber = @Res OUT,
    @PackageReservations = @PackageReservations,
    @GuestList = @GuestList

SELECT @Res AS reservationNumber
GO

/*
    TEST CASE: No payment info
*/

DECLARE @PackageReservations PackageReservationType
DECLARE @GuestList GuestListType
DECLARE @Res INT

INSERT INTO Guest (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
VALUES 
    ('No payment info guest', '101', 'Elizabeth St', 'Sydney', '2000', 'NSW', 'AUS', '0400000000', 'no.payment.info@example.com', 'Female', '1986-04-12')

INSERT INTO @PackageReservations (packageName, quantity, startDate, endDate)
VALUES ('Couples Retreat', 1, '2025-04-17', '2025-04-22')

INSERT INTO @GuestList (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
VALUES ('Christopher James', '101', 'Elizabeth St', 'Sydney', '2000', 'NSW', 'AUS', '0411222444', 'christopher.james@example.com', 'Male', '1984-09-18')

EXECUTE usp_makeReservation
    @CustomerName = 'Victoria Montgomery',
    @CustomerBuildingNumber = '101',
    @CustomerStreet = 'Elizabeth St',
    @CustomerCity = 'Sydney',
    @CustomerPostcode = '2000',
    @CustomerState = 'NSW',
    @CustomerCountryCode = 'AUS',
    @CustomerPhone = '0411222333',
    @CustomerEmail = 'no.payment.info@example.com',
    @CustomerGender = 'Female',
    @CustomerDOB = '1986-04-12',
    @HotelName = 'Grand Ocean Hotel',
    @ReservationNumber = @Res OUT,
    @PackageReservations = @PackageReservations,
    @GuestList = @GuestList

SELECT @Res AS reservationNumber
GO

/*
    TEST CASE: Reserving booked out facility 
*/

DECLARE @PackageReservations PackageReservationType
DECLARE @GuestList GuestListType
DECLARE @Res INT

INSERT INTO @PackageReservations (packageName, quantity, startDate, endDate)
VALUES ('Couples Retreat', 1, '2025-04-17', '2025-04-22')

INSERT INTO @GuestList (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
VALUES ('Christopher James', '101', 'Elizabeth St', 'Sydney', '2000', 'NSW', 'AUS', '0411222444', 'christopher.james@example.com', 'Male', '1984-09-18')

EXECUTE usp_makeReservation
    @CustomerName = 'Victoria Montgomery',
    @CustomerBuildingNumber = '101',
    @CustomerStreet = 'Elizabeth St',
    @CustomerCity = 'Sydney',
    @CustomerPostcode = '2000',
    @CustomerState = 'NSW',
    @CustomerCountryCode = 'AUS',
    @CustomerPhone = '0411222333',
    @CustomerEmail = 'victoria.montgomery@example.com',
    @CustomerGender = 'Female',
    @CustomerDOB = '1986-04-12',
    @HotelName = 'Grand Ocean Hotel',
    @ReservationNumber = @Res OUT,
    @PackageReservations = @PackageReservations,
    @GuestList = @GuestList

SELECT @Res AS reservationNumber
GO

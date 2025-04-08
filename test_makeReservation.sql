/*
    * Make Reservation Tests
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

/*
    * Make Reservation

    This stored procedure creates a reservation, accompanying bookings and facility bookings 
    associated with the packages selected.

    The functionality follows the below trail of logic:
    -- 1. check if guest exists based on customer details
    -- 2. if they dont exist make a new guest
    -- 3. for each package
        -- 3.1. find the active advertisement to use in each booking
        -- 3.2. for each service
            -- 3.2.1. if service has facilities
                -- check capacity of facility 
                    -- if capacity is 0, throw error
                    -- if capcity exists continue
                -- create facility booking data
            -- 3.2.2. create booking data
        -- 3.3. create reservation 

    Constraints and Assumptions:
    -   A user making a reservation should exist in the database as a guest before 
        they can make a booking.
    -   A guest must be associated with payment information before they can 
        make a booking.
    -   Facility Bookings are made with the booking start date and end date. 
        Specific start and end times are not asked for in the specification for this
        procedure. This means a massage is booked in for a whole date rather than a 
        particular date and time. 
    -   Guests are not associated with facility bookings because this input is
        not asked for in the specification for this procedure. 
*/

DROP PROCEDURE IF EXISTS usp_makeReservation; 
DROP TYPE IF EXISTS PackageReservationType;
DROP TYPE IF EXISTS GuestListType;

IF CURSOR_STATUS('global', 'ServiceCursor') >= -1
BEGIN
    CLOSE ServiceCursor
    DEALLOCATE ServiceCursor
END;
GO

CREATE TYPE PackageReservationType AS TABLE (
    packageName VARCHAR(100),
    quantity INT,
    startDate DATE,
    endDate DATE
);
GO

CREATE TYPE GuestListType AS TABLE (
    name VARCHAR(100),
    buildingNumber VARCHAR(10),
    street VARCHAR(100),
    city VARCHAR(100),
    postcode VARCHAR(10),
    state VARCHAR(50),
    countryCode CHAR(3),
    phoneNumber VARCHAR(20),
    email VARCHAR(100),
    gender VARCHAR(10),
    dob DATE
);
GO

CREATE PROCEDURE usp_makeReservation
  @CustomerName VARCHAR(100),
  @CustomerBuildingNumber VARCHAR(10),
  @CustomerStreet VARCHAR(100),
  @CustomerCity VARCHAR(100),
  @CustomerPostcode VARCHAR(10),
  @CustomerState VARCHAR(50),
  @CustomerCountryCode CHAR(3),
  @CustomerPhone VARCHAR(20),
  @CustomerEmail VARCHAR(100),
  @CustomerGender VARCHAR(10),
  @CustomerDOB DATE,
  @HotelName VARCHAR(100),
  @ReservationNumber INT OUTPUT,
  @PackageReservations PackageReservationType READONLY,
  @GuestList GuestListType READONLY

AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @PrimaryGuest INT
        DECLARE @PaymentInfoId INT
        DECLARE @PackageStatus INT
        DECLARE @ServiceStatus INT

        -- Check if primary guest exists, if not, insert a new guest
        SELECT @PrimaryGuest = guestId 
        FROM Guest 
        WHERE email = @CustomerEmail

        IF @PrimaryGuest IS NULL
        BEGIN
            RAISERROR ('No guest found for email %s', 16, 1, @CustomerEmail)
            ROLLBACK TRANSACTION
            RETURN
        END

        SELECT TOP 1 @PaymentInfoId = paymentInfoId 
        FROM PaymentInformation 
        WHERE guestId = @PrimaryGuest

        IF @PaymentInfoId IS NULL
        BEGIN
            RAISERROR ('No payment information found for account under %s', 16, 1, @CustomerEmail)
            ROLLBACK TRANSACTION
            RETURN
        END

        -- Insert additional guests from @GuestList if they don't exist
        INSERT INTO Guest (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
        SELECT g.name, g.buildingNumber, g.street, g.city, g.postcode, g.state, g.countryCode, g.phoneNumber, g.email, g.gender, g.dob
        FROM @GuestList g
        WHERE NOT EXISTS (SELECT 1 FROM Guest WHERE email = g.email)

        -- Create Reservation for the primary guest
        INSERT INTO Reservation (guestId, discountAmount)
        VALUES (@PrimaryGuest, 0.00)
        SET @ReservationNumber = SCOPE_IDENTITY()

        -- Link primary guest and additional guests to the reservation
        INSERT INTO ReservationGuest (reservationNumber, guestId)
        SELECT @ReservationNumber, guestId
        FROM Guest
        WHERE email = @CustomerEmail
           OR email IN (SELECT email FROM @GuestList)

        -- Process each package reservation from @PackageReservations
        DECLARE @PackageName VARCHAR(100), @Quantity INT, @StartDate DATE, @EndDate DATE
        DECLARE PackageCursor CURSOR FOR
            SELECT packageName, quantity, startDate, endDate
            FROM @PackageReservations
        OPEN PackageCursor
        FETCH NEXT FROM PackageCursor INTO @PackageName, @Quantity, @StartDate, @EndDate
        SET @PackageStatus = @@FETCH_STATUS
        WHILE @PackageStatus = 0
        BEGIN
            -- Find active advertisement for the package at the given hotel 
            DECLARE @AdId INT

            SELECT TOP 1 @AdId = a.advertisementId
            FROM Advertisement a
            INNER JOIN Package p ON a.packageId = p.packageId
            INNER JOIN HotelAdvertisement ha ON a.advertisementId = ha.advertisementId
            WHERE p.name = @PackageName
              AND ha.hotelId = (SELECT hotelId FROM Hotel WHERE name = @HotelName)
              AND (SELECT CAST(GETDATE() AS date)) BETWEEN a.startDate AND a.endDate

            IF @AdId IS NULL
            BEGIN
                RAISERROR ('No active advertisement found for package %s at hotel %s', 16, 1, @PackageName, @HotelName)
                ROLLBACK TRANSACTION
                RETURN
            END

            -- Create booking for the package reservation
            DECLARE @BookingId INT

            INSERT INTO Booking (reservationNumber, advertisementId, quantity, startDate, endDate, isInitialBooking)
            VALUES (@ReservationNumber, @AdId, @Quantity, @StartDate, @EndDate, 1)
            SET @BookingId = SCOPE_IDENTITY()

            -- Process each service in the package (via PackageItem)
            DECLARE @ServiceId INT, @FacilityTypeId INT
            DECLARE ServiceCursor CURSOR FOR
                SELECT pi.serviceId
                FROM PackageItem pi
                INNER JOIN Package p ON pi.packageId = p.packageId
                WHERE p.name = @PackageName
            OPEN ServiceCursor
            FETCH NEXT FROM ServiceCursor INTO @ServiceId
            SET @ServiceStatus = @@FETCH_STATUS
            WHILE @ServiceStatus = 0
            BEGIN
                -- Check if the service requires a facility
                SET @FacilityTypeId = NULL
                SELECT TOP 1 @FacilityTypeId = facilityTypeId
                FROM ServiceFacility
                WHERE serviceId = @ServiceId

                IF @FacilityTypeId IS NOT NULL
                BEGIN
                    -- Check if the facility is available
                    DECLARE @FacilityId INT

                    SET @FacilityId = NULL
                    SELECT TOP 1 @FacilityId = facilityId
                    FROM Facility
                    WHERE hotelId = (SELECT hotelId FROM Hotel WHERE name = @HotelName)
                    AND facilityTypeId = @FacilityTypeId
                    AND (
                        SELECT COUNT(*)
                        FROM FacilityBooking fb
                        WHERE fb.facilityId = Facility.facilityId
                            AND fb.startDateTime < @EndDate
                            AND fb.endDateTime > @StartDate
                        ) < Facility.capacity

                    IF @FacilityId IS NULL
                    BEGIN
                        RAISERROR ('No availability, all facilities of type %u have reached capacity.', 16, 1, @FacilityTypeId)
                        ROLLBACK TRANSACTION
                        RETURN
                    END

                    DECLARE @FacilityBookingId INT
                    -- Create facility booking
                    INSERT INTO FacilityBooking (bookingId, facilityId, startDateTime, endDateTime)
                    VALUES (@BookingId, @FacilityId, CAST(@StartDate AS DATETIME), CAST(@EndDate AS DATETIME) + '23:59:59')
                    SET @FacilityBookingId = SCOPE_IDENTITY()
                END
                FETCH NEXT FROM ServiceCursor INTO @ServiceId
                SET @ServiceStatus = @@FETCH_STATUS
            END
            CLOSE ServiceCursor
            DEALLOCATE ServiceCursor

            SELECT @PackageName = NULL, @Quantity = NULL, @StartDate = NULL, @EndDate = NULL
            FETCH NEXT FROM PackageCursor INTO @PackageName, @Quantity, @StartDate, @EndDate
            SET @PackageStatus = @@FETCH_STATUS
        END
        CLOSE PackageCursor
        DEALLOCATE PackageCursor

        -- Create Payment Invoice for deposit
        INSERT INTO PaymentInvoice (amount, date, status, reservationNumber, paymentInfoId)
        SELECT 
            0.25 * SUM(a.advertisedPrice * b.quantity),
            GETDATE(),
            'Pending',
            @ReservationNumber,
            @PaymentInfoId
        FROM Booking b
        JOIN Advertisement a ON b.advertisementId = a.advertisementId
        WHERE b.reservationNumber = @ReservationNumber

        COMMIT TRANSACTION
        RETURN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO




    
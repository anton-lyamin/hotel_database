/*
Make a reservation.
Ensure that a reservation does not exceed available capacity at a hotel at any given time.
If there aren’t sufficient capacity available for the reservation an error is raised with an
appropriate error message and the entire reservation is cancelled.
Appropriate bookings of facilities for the specified period needs to be saved in the
database at the time of saving a valid reservation. The total amount due and deposit due
needs to be calculated for the reservation. The deposit amount due is 25% of total amount
due.

INPUT PARAMETERS:
ustomer details – Details of customer making the reservation
 customer name – name of customer
 address – address of customer
 phone number – phone number of customer
 email – email of the customer
 List of services/packages reserved – A table valued parameter with each row consisting
of service or package id, quantity, start date and end date of each service/package.
 Guest list – A list of guests if provided (name, address, contact number and email)

Output parameter:
Reservation id – id of the created reservation

*/
DROP PROCEDURE IF EXISTS usp_makeReservation;
DROP TYPE IF EXISTS GuestList;
DROP TYPE IF EXISTS ReservedAdvertisedPackageList;
go

CREATE TYPE ReservedAdvertisedPackageList as TABLE(
	packageId INT,
	quantity INT,
	startDate DATE,
	endDate DATE
);
go

CREATE TYPE GuestList as TABLE (
	name CHAR(255),
	buildingNumber INT,
	street	CHAR(255),
	city	CHAR(255),
	postcode	INT,
	state	CHAR(255),
	countryCode CHAR(255),
	phoneNo	INT,
	email	CHAR(255)
);
go

CREATE PROCEDURE usp_makeReservation
	@name CHAR(255),
	@buildingNumber INT,
	@street	CHAR(255),
	@city	CHAR(255),
	@postcode	INT,
	@state	CHAR(255),
	@countryCode CHAR(255),
	@phoneNo	INT,
	@email	CHAR(255),
	@servicePackageList ReservedAdvertisedPackageList READONLY,
	@guestList GuestList READONLY,
	@reservationID INT OUT

AS
BEGIN

/*
tables required to make a reservation: 
	existing guest
		declare variable guestId and assign result of the following select
			select guestId from Guest WHERE @phoneNumnber 
	new guest if variable guestId  is = null
		Insert into guest
			guestId from ISNULL and SELECTING MAX +1, 
			name @cname        
			buildingNumber @buildingNumber
			street     @street
			city       @city
			postcode   @postCode
			state      @state
			countryCode  @countryCode
			phoneNumber   @phoneNo
			email        @email
	
	Insert into reservation - 
		reservationNumber new generated reservation number using ISNULL and SELECT MAX, 
		guestId @guestId of the guest making the reservation,
	
	For each guest in the guest list
		if guest exists 
			get guestId
		else
			create a new guest and get guest id
		insert guestId and reservationNumber into reservation table.
*/

	DECLARE @gName CHAR(255),
			@gbuildingNo INT,
			@gStreet CHAR(255), 
			@gCity CHAR(255), 
			@gPostcode CHAR(255), 
			@gState CHAR(255), 
			@gCountryCode CHAR(255),
			@gEmail CHAR(255),
			@gPhoneNo INT,
			@guestId INT;

	SET @guestId = (SELECT guestId FROM GUEST WHERE phoneNumber = @phoneNo);

	IF @guestId = NULL
		SET @guestId = ISNULL((SELECT MAX(guestId)+1 FROM Guest),1)
		INSERT INTO GUEST (guestId, name, buildingNumber, street, city, postcode, state, countryCode)
		VALUES (
				@guestId,
				@name,
				@buildingNumber,
				@street,
				@city,
				@postcode,
				@state,
				@countryCode);

	SET @reservationID = ISNULL((SELECT MAX(reservationNumber)+1 FROM Reservation),1)
	INSERT INTO Reservation (reservationNumber, guestId)
	VALUES (
			@reservationID,
			@guestId
	);
	
	DECLARE guestCursor CURSOR
	FOR
	SELECT *
	FROM @guestList;

	OPEN guestCursor;
	FETCH NEXT FROM guestCursor INTO @gName, @gBuildingNo, @gStreet, @gCity, @gPostCode, @gState, @gCountryCode, @gEmail, @gPhoneNo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @guestId = (SELECT guestId FROM GUEST WHERE phoneNumber = @gPhoneNo);
		IF @guestId = NULL
			SET @guestId = ISNULL((SELECT MAX(guestId)+1 FROM Guest),1)
			INSERT INTO GUEST (guestId, name, buildingNumber, street, city, postcode, state, countryCode)
			VALUES (
					@guestId,
					@name,
					@buildingNumber,
					@street,
					@city,
					@postcode,
					@state,
					@countryCode);	
		INSERT INTO ReservationGuest (guestId, reservationNumber)
		VALUES (
			@guestId,
			@reservationID
		);
		FETCH NEXT FROM guestCursor 
		INTO @gName, @gBuildingNo, @gStreet, @gCity, @gPostCode, @gState, @gCountryCode, @gEmail, @gPhoneNo
	END

	--TO DO: discuss with team on how to implement capacity and finish booking.

END
go

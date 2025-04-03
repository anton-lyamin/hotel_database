/**************************************************
* BASE DATA
*   - Countries
*   - Facility Types
*   - Service Categories
**************************************************/

-- Insert Countries
INSERT INTO Country (countryCode, name, currency)
VALUES 
    ('AUS', 'Australia', 'AUD'),
    ('USA', 'United States', 'USD');

-- Insert Facility Types
INSERT INTO FacilityType (name, description)
VALUES
    ('single room', 'A single occupancy room'),
    ('twin room', 'A room with two beds'),
    ('family room', 'A room suitable for families'),
    ('suite', 'A luxurious suite'),
    ('pool', 'Swimming pool facility'),
    ('spa', 'Spa and wellness facility'),
    ('restaurant', 'Dining facility'),
    ('conference room', 'Meeting and conference facility'),
    ('laundry', 'Laundry');

-- Insert Service Categories (note correction to "Accommodation")
INSERT INTO ServiceCategory (categoryCode, name, description, type)
VALUES
    ('ENT', 'Entertainment', 'Entertainment and leisure services', NULL),
    ('FNB', 'Food and Beverage', 'Food and beverage services', NULL),
    ('ACC', 'Accommodation', 'Accommodation related services', NULL),
    ('EVC', 'Events and Conferences', 'Events and conference services', NULL),
    ('MIN', 'Minibar', 'Minibar items', NULL),
    ('HSK', 'Housekeeping', 'Housekeeping services', NULL);


/**************************************************
* SERVICE ITEMS & FACILITY MAPPING
**************************************************/

-- Insert Service Items (commented-out rows removed)
INSERT INTO ServiceItem (name, description, restrictions, notes, status, categoryCode)
VALUES
    ('family stay', 'One night family room stay', NULL, NULL, 'Active', 'ACC'),
    ('suite stay', 'One night suite stay', NULL, NULL, 'Active', 'ACC'),
    ('pool visit', 'Access to the pool facility', NULL, NULL, 'Active', 'ENT'),
    ('massage', 'Generic massage service', NULL, NULL, 'Active', 'ENT'),
    ('buffet breakfast', 'Daily buffet breakfast', NULL, NULL, 'Active', 'FNB'),
    ('set menu dinner', 'Set menu dinner reservation', NULL, NULL, 'Active', 'FNB'),
    ('conference room hire', 'Hire of conference room', NULL, NULL, 'Active', 'EVC'),
    ('coca-cola', 'Bottle of coca-cola', NULL, NULL, 'Active', 'MIN'),
    ('juice', 'Juice drink', NULL, NULL, 'Active', 'MIN'),
    ('cookies', 'Pack of cookies', NULL, NULL, 'Active', 'MIN'),
    ('chips', 'Bag of chips', NULL, NULL, 'Active', 'MIN'),
    ('house wine', 'Glass of house wine', NULL, NULL, 'Active', 'MIN'),
    ('house beer', 'Glass of house beer', NULL, NULL, 'Active', 'MIN'),
    ('dry-cleaning', 'Dry-cleaning service', NULL, NULL, 'Active', 'HSK'),
    ('adult kayak tour', 'Adult kayak tour service', NULL, NULL, 'Active', 'ENT'),
    ('child kayak tour', 'Child kayak tour service', NULL, NULL, 'Active', 'ENT');

-- Map Service Items to Facility Types
DECLARE @ServiceFacilityMapping TABLE (
    Service VARCHAR(100),
    Facility VARCHAR(100)
)

INSERT INTO @ServiceFacilityMapping (Service, Facility)
VALUES 
    ('family stay', 'family room'),
    ('suite stay', 'family room'),
    ('pool visit', 'pool'),
    ('massage', 'spa'),
    ('buffet breakfast', 'restaurant'),
    ('set menu dinner', 'restaurant'),
    ('conference room hire', 'conference room')

INSERT INTO ServiceFacility (facilityTypeId, serviceId)
SELECT ft.facilityTypeId, si.serviceId
FROM @ServiceFacilityMapping m
JOIN FacilityType ft ON ft.name = m.Facility
JOIN ServiceItem si ON si.name = m.Service;


/**************************************************
* PACKAGES & PACKAGE ITEMS
**************************************************/

-- Insert Individual Service Packages (commented-out rows removed)
INSERT INTO Package (name, description, status)
VALUES
    ('family stay', 'Package for family stay service', 'Active'),
    ('suite stay', 'Package for suite stay service', 'Active'),
    ('pool visit', 'Package for pool visit service', 'Active'),
    ('massage', 'Package for massage service', 'Active'),
    ('conference room hire', 'Package for conference room hire', 'Active'),
    ('buffet breakfast', 'Package for buffet breakfast service', 'Active'),
    ('set menu dinner', 'Individual sale of a set menu dinner', 'Active'),
    ('coca-cola', 'Package for coca-cola service', 'Active'),
    ('juice', 'Package for juice service', 'Active'),
    ('cookies', 'Package for cookies service', 'Active'),
    ('chips', 'Package for chips service', 'Active'),
    ('house wine', 'Package for house wine service', 'Active'),
    ('house beer', 'Package for house beer service', 'Active'),
    ('dry-cleaning', 'Individual dry-cleaning service', 'Active'),
    ('adult kayak tour', 'Package for adult kayak tour service', 'Active'),
    ('child kayak tour', 'Package for child kayak tour service', 'Active');

-- Insert Bundle Packages
INSERT INTO Package (name, description, inclusions, exclusions, status)
VALUES
    ('Family Fun', 'Family fun package', 'family stay, daily buffet breakfast, daily pool visits', NULL, 'Active'),
    ('Couples Retreat', 'Couples retreat package', 'suite stay, house wine on arrival, massage (2 for two adults)', NULL, 'Active'),
    ('Family Kayak', 'Family kayak package', 'adult kayak tour and child kayak tour for each family member', NULL, 'Active');

-- Map Service Items to Packages
DECLARE @PackageItemsMapping TABLE (
    Package VARCHAR(100),
    Quantity INT,
    Service VARCHAR(100)
)

-- Mappings for individual service packages
INSERT INTO @PackageItemsMapping (Package, Quantity, Service)
VALUES 
    ('family stay', 1, 'family stay'),
    ('suite stay', 1, 'suite stay'),
    ('pool visit', 1, 'pool visit'),
    ('massage', 1, 'massage'),
    ('conference room hire', 1, 'conference room hire'),
    ('buffet breakfast', 1, 'buffet breakfast'),
    ('set menu dinner', 1, 'set menu dinner'),
    ('coca-cola', 1, 'coca-cola'),
    ('juice', 1, 'juice'),
    ('cookies', 1, 'cookies'),
    ('chips', 1, 'chips'),
    ('house wine', 1, 'house wine'),
    ('house beer', 1, 'house beer'),
    ('dry-cleaning', 1, 'dry-cleaning'),
    ('adult kayak tour', 1, 'adult kayak tour'),
    ('child kayak tour', 1, 'child kayak tour')

-- Mappings for bundle packages
INSERT INTO @PackageItemsMapping (Package, Quantity, Service)
VALUES 
    ('Family Fun', 1, 'family stay'),
    ('Family Fun', 10, 'buffet breakfast'),
    ('Family Fun', 5, 'pool visit'),
    ('Couples Retreat', 1, 'suite stay'),
    ('Couples Retreat', 2, 'house wine'),
    ('Couples Retreat', 2, 'massage'),
    ('Family Kayak', 2, 'adult kayak tour'),
    ('Family Kayak', 2, 'child kayak tour')

INSERT INTO PackageItem (packageId, quantity, serviceId)
SELECT p.packageId, m.Quantity, si.serviceId
FROM @PackageItemsMapping m
JOIN Package p ON p.name = m.Package
JOIN ServiceItem si ON si.name = m.Service;


/**************************************************
* HOTELS, FACILITIES & HOTEL SERVICES
**************************************************/

-- Insert Hotels
INSERT INTO Hotel (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, description)
VALUES 
    ('Grand Ocean Hotel', '178', 'Campbell Parade', 'Bondi', '2026', 'NSW', 'AUS', '0299000111', 'Luxury oceanfront hotel in Bondi Beach'),
    ('Lakeside Haven', '2359', 'Bittersweet Rd', 'Lake Ozark', '65049', 'MO', 'USA', '4172000222', 'Charming hotel by Lake Ozark');

-- Map Hotel Facilities
DECLARE @HotelFacilityMapping TABLE (
    FacilityName VARCHAR(100),
    Description VARCHAR(255),
    Status VARCHAR(50),
    Capacity INT,
    Hotel VARCHAR(50),
    FacilityType VARCHAR(50)
)

-- Facilities for Grand Ocean Hotel
INSERT INTO @HotelFacilityMapping (FacilityName, Description, Status, Capacity, Hotel, FacilityType)
VALUES
    ('Room 103', 'Family room on floor 1', 'Available', 4, 'Grand Ocean Hotel', 'family room'),
    ('Room 104', 'Suite on floor 1', 'Available', 2, 'Grand Ocean Hotel', 'suite'),
    ('Ocean Breeze Spa', 'Luxury spa facility', 'Available', 5, 'Grand Ocean Hotel', 'spa'),
    ('Salt and Sea', 'Hotel restaurant', 'Available', 50, 'Grand Ocean Hotel', 'restaurant'),
    ('Pacific Pool', 'Outdoor ocean view pool', 'Available', 30, 'Grand Ocean Hotel', 'pool'),
    ('Columbus', 'Conference room facility', 'Available', 20, 'Grand Ocean Hotel', 'conference room')

-- Facilities for Lakeside Haven
INSERT INTO @HotelFacilityMapping (FacilityName, Description, Status, Capacity, Hotel, FacilityType)
VALUES
    ('Room 103', 'Family room on floor 1', 'Available', 4, 'Lakeside Haven', 'family room'),
    ('Room 104', 'Suite on floor 1', 'Available', 2, 'Lakeside Haven', 'suite'),
    ('Still Waters Spa', 'Relaxing spa facility', 'Available', 5, 'Lakeside Haven', 'spa'),
    ('Waters'' Edge', 'Hotel restaurant', 'Available', 50, 'Lakeside Haven', 'restaurant'),
    ('Pinetree Pool', 'Refreshing outdoor pool', 'Available', 30, 'Lakeside Haven', 'pool'),
    ('Harmony Room', 'Modern conference room', 'Available', 20, 'Lakeside Haven', 'conference room')

INSERT INTO Facility (name, description, status, capacity, hotelId, facilityTypeId)
SELECT hf.FacilityName, hf.Description, hf.Status, hf.Capacity, h.hotelId, ft.facilityTypeId
FROM @HotelFacilityMapping hf
JOIN Hotel h ON h.name = hf.Hotel
JOIN FacilityType ft ON ft.name = hf.FacilityType;

-- Map Hotel Services
DECLARE @HotelServiceMappings TABLE (
    Hotel VARCHAR(100),
    Service VARCHAR(100),
    StartTime TIME(0),
    EndTime TIME(0),
    Capacity INT,
    BaseCost DECIMAL(10,2),
    BaseCurrency CHAR(3)
)

-- Mappings for Grand Ocean Hotel
INSERT INTO @HotelServiceMappings (Hotel, Service, StartTime, EndTime, Capacity, BaseCost, BaseCurrency)
VALUES 
    ('Grand Ocean Hotel', 'family stay', '14:00:00', '10:00:00', 4, 250.00, '---'),
    ('Grand Ocean Hotel', 'suite stay', '14:00:00', '10:00:00', 2, 350.00, '---'),
    ('Grand Ocean Hotel', 'pool visit', '09:00:00', '21:00:00', 30, 50.00, '---'),
    ('Grand Ocean Hotel', 'massage', '10:00:00', '18:00:00', 5, 80.00, '---'),
    ('Grand Ocean Hotel', 'buffet breakfast', '07:00:00', '10:00:00', 50, 40.00, '---'),
    ('Grand Ocean Hotel', 'set menu dinner', '18:00:00', '22:00:00', 50, 60.00, '---'),
    ('Grand Ocean Hotel', 'conference room hire', '08:00:00', '18:00:00', 20, 150.00, '---'),
    ('Grand Ocean Hotel', 'coca-cola', '00:00:00', '23:59:59', 1, 3.00, '---'),
    ('Grand Ocean Hotel', 'juice', '00:00:00', '23:59:59', 1, 3.00, '---'),
    ('Grand Ocean Hotel', 'cookies', '00:00:00', '23:59:59', 1, 2.00, '---'),
    ('Grand Ocean Hotel', 'chips', '00:00:00', '23:59:59', 1, 2.50, '---'),
    ('Grand Ocean Hotel', 'house wine', '00:00:00', '23:59:59', 1, 10.00, '---'),
    ('Grand Ocean Hotel', 'house beer', '00:00:00', '23:59:59', 1, 8.00, '---'),
    ('Grand Ocean Hotel', 'dry-cleaning', '08:00:00', '17:00:00', 1, 15.00, '---')

-- Mappings for Lakeside Haven
INSERT INTO @HotelServiceMappings (Hotel, Service, StartTime, EndTime, Capacity, BaseCost, BaseCurrency)
VALUES
    ('Lakeside Haven', 'family stay', '14:00:00', '11:00:00', 4, 220.00, '---'),
    ('Lakeside Haven', 'suite stay', '14:00:00', '11:00:00', 2, 320.00, '---'),
    ('Lakeside Haven', 'pool visit', '09:00:00', '21:00:00', 30, 45.00, '---'),
    ('Lakeside Haven', 'massage', '10:00:00', '18:00:00', 5, 75.00, '---'),
    ('Lakeside Haven', 'buffet breakfast', '07:00:00', '10:00:00', 50, 35.00, '---'),
    ('Lakeside Haven', 'set menu dinner', '18:00:00', '22:00:00', 50, 55.00, '---'),
    ('Lakeside Haven', 'conference room hire', '08:00:00', '18:00:00', 20, 140.00, '---'),
    ('Lakeside Haven', 'coca-cola', '00:00:00', '23:59:59', 1, 2.50, '---'),
    ('Lakeside Haven', 'juice', '00:00:00', '23:59:59', 1, 2.50, '---'),
    ('Lakeside Haven', 'cookies', '00:00:00', '23:59:59', 1, 1.50, '---'),
    ('Lakeside Haven', 'chips', '00:00:00', '23:59:59', 1, 2.00, '---'),
    ('Lakeside Haven', 'house wine', '00:00:00', '23:59:59', 1, 9.00, '---'),
    ('Lakeside Haven', 'house beer', '00:00:00', '23:59:59', 1, 7.50, '---'),
    ('Lakeside Haven', 'dry-cleaning', '08:00:00', '17:00:00', 1, 14.00, '---'),
    ('Lakeside Haven', 'adult kayak tour', '09:00:00', '17:00:00', 1, 110.00, '---'),
    ('Lakeside Haven', 'child kayak tour', '09:00:00', '17:00:00', 1, 70.00, '---')

INSERT INTO HotelService (hotelId, serviceId, startTime, endTime, capacity, baseCost, baseCurrency)
SELECT h.hotelId,
       si.serviceId,
       m.StartTime,
       m.EndTime,
       m.Capacity,
       m.BaseCost,
       m.BaseCurrency
FROM @HotelServiceMappings m
JOIN Hotel h ON h.name = m.Hotel
JOIN ServiceItem si ON si.name = m.Service;


/**************************************************
* EMPLOYEE ROLES & EMPLOYEES
**************************************************/

-- Insert Employee Roles
INSERT INTO EmployeeRole (roleCode, name, description, clearance)
VALUES 
    ('HSK', 'Housekeeping', 'Responsible for room cleaning and upkeep', 1),
    ('FNB', 'Restaurant Staff', 'Responsible for restaurant service', 2),
    ('SPA', 'Spa Staff', 'Responsible for spa treatments', 2),
    ('POL', 'Pool Staff', 'Responsible for pool maintenance and service', 2),
    ('CNF', 'Conference Staff', 'Responsible for conference room support', 2),
    ('MGR', 'Manager', 'Hotel management', 10);

-- Insert Employees for Grand Ocean Hotel (AUS)
INSERT INTO Employee (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, gender, dob, roleCode, hotelId)
VALUES
    ('Alice Johnson', '10', 'Harbour St', 'Sydney', '2000', 'NSW', 'AUS', '0299001001', 'Female', '1985-03-12', 'HSK', 1),
    ('Bob Smith', '11', 'Harbour St', 'Sydney', '2000', 'NSW', 'AUS', '0299001002', 'Male', '1980-07-15', 'FNB', 1),
    ('Catherine Brown', '12', 'Harbour St', 'Sydney', '2000', 'NSW', 'AUS', '0299001003', 'Female', '1982-11-20', 'SPA', 1),
    ('Daniel White', '13', 'Harbour St', 'Sydney', '2000', 'NSW', 'AUS', '0299001004', 'Male', '1983-05-05', 'POL', 1),
    ('Emily Davis', '14', 'Harbour St', 'Sydney', '2000', 'NSW', 'AUS', '0299001005', 'Female', '1979-08-08', 'CNF', 1),
    ('Frank Miller', '15', 'Harbour St', 'Sydney', '2000', 'NSW', 'AUS', '0299001006', 'Male', '1975-01-01', 'MGR', 1);

-- Insert Employees for Lakeside Haven (USA)
INSERT INTO Employee (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, gender, dob, roleCode, hotelId)
VALUES
    ('Grace Wilson', '20', 'Lakeside Blvd', 'Lake Ozark', '65049', 'MO', 'USA', '4172002001', 'Female', '1987-04-04', 'HSK', 2),
    ('Henry Taylor', '21', 'Lakeside Blvd', 'Lake Ozark', '65049', 'MO', 'USA', '4172002002', 'Male', '1981-09-09', 'FNB', 2),
    ('Isabella Anderson', '22', 'Lakeside Blvd', 'Lake Ozark', '65049', 'MO', 'USA', '4172002003', 'Female', '1983-12-12', 'SPA', 2),
    ('Jack Thomas', '23', 'Lakeside Blvd', 'Lake Ozark', '65049', 'MO', 'USA', '4172002004', 'Male', '1985-03-03', 'POL', 2),
    ('Karen Moore', '24', 'Lakeside Blvd', 'Lake Ozark', '65049', 'MO', 'USA', '4172002005', 'Female', '1980-06-06', 'CNF', 2),
    ('Louis Martin', '25', 'Lakeside Blvd', 'Lake Ozark', '65049', 'MO', 'USA', '4172002006', 'Male', '1978-02-02', 'MGR', 2);


/**************************************************
* ADVERTISEMENTS & HOTEL ADVERTISEMENT LINKS
**************************************************/

-- Map Advertisement Data
DECLARE @AdvertisementMappings TABLE (
    StartDate DATE,
    EndDate DATE,
    Price DECIMAL(10,2),
    Currency CHAR(3),
    GracePeriod INT,
    Package VARCHAR(100),
    EmployeePhone VARCHAR(20)
)

INSERT INTO @AdvertisementMappings (StartDate, EndDate, Price, Currency, GracePeriod, Package, EmployeePhone)
VALUES
    ('2024-12-01','2025-06-01',190.00, '---', 2, 'family stay', '0299001006'),
    ('2024-12-01','2025-06-01',310.00, '---', 2, 'suite stay', '0299001006'),
    ('2024-12-01','2025-06-01',55.00,  '---', 2, 'pool visit', '0299001006'),
    ('2024-12-01','2025-06-01',85.00,  '---', 2, 'massage', '0299001006'),
    ('2024-12-01','2025-06-01',40.00,  '---', 2, 'buffet breakfast', '0299001006'),
    ('2024-12-01','2025-06-01',65.00,  '---', 2, 'set menu dinner', '0299001006'),
    ('2024-12-01','2025-06-01',150.00, '---', 2, 'conference room hire', '0299001006'),
    ('2024-12-01','2025-06-01',3.00,   '---', 2, 'coca-cola', '0299001006'),
    ('2024-12-01','2025-06-01',3.00,   '---', 2, 'juice', '0299001006'),
    ('2024-12-01','2025-06-01',1.75,   '---', 2, 'cookies', '0299001006'),
    ('2024-12-01','2025-06-01',2.25,   '---', 2, 'chips', '0299001006'),
    ('2024-12-01','2025-06-01',9.50,   '---', 2, 'house wine', '0299001006'),
    ('2024-12-01','2025-06-01',8.50,   '---', 2, 'house beer', '0299001006'),
    ('2024-12-01','2025-06-01',15.00,  '---', 2, 'dry-cleaning', '0299001006'),
    -- Bundle Packages for Grand Ocean
    ('2024-12-01','2025-06-01',860.00, '---', 2, 'Family Fun', '0299001006'),
    ('2024-12-01','2025-06-01',690.00, '---', 2, 'Couples Retreat', '0299001006'),
    ('2024-12-01','2025-06-01',290.00, '---', 2, 'Family Kayak', '0299001006')

INSERT INTO @AdvertisementMappings (StartDate, EndDate, Price, Currency, GracePeriod, Package, EmployeePhone)
VALUES 
    ('2024-12-01','2025-06-01',200.00, '---', 2, 'family stay', '4172002006'),
    ('2024-12-01','2025-06-01',320.00, '---', 2, 'suite stay', '4172002006'),
    ('2024-12-01','2025-06-01',45.00,  '---', 2, 'pool visit', '4172002006'),
    ('2024-12-01','2025-06-01',75.00,  '---', 2, 'massage', '4172002006'),
    ('2024-12-01','2025-06-01',35.00,  '---', 2, 'buffet breakfast', '4172002006'),
    ('2024-12-01','2025-06-01',55.00,  '---', 2, 'set menu dinner', '4172002006'),
    ('2024-12-01','2025-06-01',140.00, '---', 2, 'conference room hire', '4172002006'),
    ('2024-12-01','2025-06-01',2.50,  '---', 2, 'coca-cola', '4172002006'),
    ('2024-12-01','2025-06-01',2.50,  '---', 2, 'juice', '4172002006'),
    ('2024-12-01','2025-06-01',1.50,  '---', 2, 'cookies', '4172002006'),
    ('2024-12-01','2025-06-01',2.00,  '---', 2, 'chips', '4172002006'),
    ('2024-12-01','2025-06-01',9.00,  '---', 2, 'house wine', '4172002006'),
    ('2024-12-01','2025-06-01',7.50,  '---', 2, 'house beer', '4172002006'),
    ('2024-12-01','2025-06-01',14.00, '---', 2, 'dry-cleaning', '4172002006'),
    ('2024-12-01','2025-06-01',110.00,'---', 2, 'adult kayak tour', '4172002006'),
    ('2024-12-01','2025-06-01',70.00, '---', 2, 'child kayak tour', '4172002006'),
    -- Bundle Packages for Lakeside Haven
    ('2024-12-01','2025-06-01',850.00, '---', 2, 'Family Fun', '4172002006'),
    ('2024-12-01','2025-06-01',680.00, '---', 2, 'Couples Retreat', '4172002006'),
    ('2024-12-01','2025-06-01',280.00, '---', 2, 'Family Kayak', '4172002006')

INSERT INTO Advertisement (startDate, endDate, advertisedPrice, advertisedCurrency, gracePeriod, packageId, employeeId)
SELECT m.StartDate,
       m.EndDate,
       m.Price,
       m.Currency,
       m.GracePeriod,
       p.packageId,
       e.employeeId
FROM @AdvertisementMappings m
JOIN Package p ON p.name = m.Package
JOIN Employee e ON e.phoneNumber = m.EmployeePhone;

-- Map Hotel Advertisement Associations
DECLARE @HotelAdMappings TABLE (
    Hotel VARCHAR(50),
    StartDate DATE,
    Package VARCHAR(100),
    EmployeePhone VARCHAR(50),
    Currency CHAR(3),
    Price DECIMAL(10,2)
)

INSERT INTO @HotelAdMappings (Hotel, StartDate, Package, EmployeePhone, Currency, Price)
VALUES
    ('Grand Ocean Hotel', '2024-12-01', 'family stay', '0299001006', '---', 190.00),
    ('Grand Ocean Hotel', '2024-12-01', 'suite stay', '0299001006', '---', 310.00),
    ('Grand Ocean Hotel', '2024-12-01', 'pool visit', '0299001006', '---', 55.00),
    ('Grand Ocean Hotel', '2024-12-01', 'massage', '0299001006', '---', 85.00),
    ('Grand Ocean Hotel', '2024-12-01', 'buffet breakfast', '0299001006', '---', 40.00),
    ('Grand Ocean Hotel', '2024-12-01', 'set menu dinner', '0299001006', '---', 65.00),
    ('Grand Ocean Hotel', '2024-12-01', 'conference room hire', '0299001006', '---', 150.00),
    ('Grand Ocean Hotel', '2024-12-01', 'coca-cola', '0299001006', '---', 3.00),
    ('Grand Ocean Hotel', '2024-12-01', 'juice', '0299001006', '---', 3.00),
    ('Grand Ocean Hotel', '2024-12-01', 'cookies', '0299001006', '---', 1.75),
    ('Grand Ocean Hotel', '2024-12-01', 'chips', '0299001006', '---', 2.25),
    ('Grand Ocean Hotel', '2024-12-01', 'house wine', '0299001006', '---', 9.50),
    ('Grand Ocean Hotel', '2024-12-01', 'house beer', '0299001006', '---', 8.50),
    ('Grand Ocean Hotel', '2024-12-01', 'dry-cleaning', '0299001006', '---', 15.00),
    ('Grand Ocean Hotel', '2024-12-01', 'Family Fun', '0299001006', '---', 860.00),
    ('Grand Ocean Hotel', '2024-12-01', 'Couples Retreat', '0299001006', '---', 690.00),
    ('Grand Ocean Hotel', '2024-12-01', 'Family Kayak', '0299001006', '---', 290.00),
    ('Lakeside Haven', '2024-12-01', 'family stay', '4172002006', '---', 200.00),
    ('Lakeside Haven', '2024-12-01', 'suite stay', '4172002006', '---', 320.00),
    ('Lakeside Haven', '2024-12-01', 'pool visit', '4172002006', '---', 45.00),
    ('Lakeside Haven', '2024-12-01', 'massage', '4172002006', '---', 75.00),
    ('Lakeside Haven', '2024-12-01', 'buffet breakfast', '4172002006', '---', 35.00),
    ('Lakeside Haven', '2024-12-01', 'set menu dinner', '4172002006', '---', 55.00),
    ('Lakeside Haven', '2024-12-01', 'conference room hire', '4172002006', '---', 140.00),
    ('Lakeside Haven', '2024-12-01', 'coca-cola', '4172002006', '---', 2.50),
    ('Lakeside Haven', '2024-12-01', 'juice', '4172002006', '---', 2.50),
    ('Lakeside Haven', '2024-12-01', 'cookies', '4172002006', '---', 1.50),
    ('Lakeside Haven', '2024-12-01', 'chips', '4172002006', '---', 2.00),
    ('Lakeside Haven', '2024-12-01', 'house wine', '4172002006', '---', 9.00),
    ('Lakeside Haven', '2024-12-01', 'house beer', '4172002006', '---', 7.50),
    ('Lakeside Haven', '2024-12-01', 'dry-cleaning', '4172002006', '---', 14.00),
    ('Lakeside Haven', '2024-12-01', 'adult kayak tour', '4172002006', '---', 110.00),
    ('Lakeside Haven', '2024-12-01', 'child kayak tour', '4172002006', '---', 70.00),
    ('Lakeside Haven', '2024-12-01', 'Family Fun', '4172002006', '---', 850.00),
    ('Lakeside Haven', '2024-12-01', 'Couples Retreat', '4172002006', '---', 680.00),
    ('Lakeside Haven', '2024-12-01', 'Family Kayak', '4172002006', '---', 280.00)

INSERT INTO HotelAdvertisement (hotelId, advertisementId)
SELECT h.hotelId,
       a.advertisementId
FROM @HotelAdMappings m
JOIN Hotel h ON h.name = m.Hotel
JOIN Package p ON p.name = m.Package
JOIN Employee e ON e.phoneNumber = m.EmployeePhone
JOIN Advertisement a ON a.packageId = p.packageId
    AND a.startDate = m.StartDate
    AND a.advertisedPrice = m.Price
    AND a.advertisedCurrency = m.Currency
    AND a.employeeId = e.employeeId;


/**************************************************
* COUPLES RESERVATION SCRIPT (USING VARIABLES)
*   Dates: March 14, 2025 to March 17, 2025
**************************************************/

-- Declare variables for lookups and guest IDs
DECLARE @CouplesRetreatAdId INT
DECLARE @SetMenuAdId INT
DECLARE @ExtraWineAdId INT
DECLARE @PoolVisitAdId INT
DECLARE @ResNumber INT
DECLARE @RetreatBookingId INT
DECLARE @DinnerBookingId INT
DECLARE @PoolBookingId INT
DECLARE @SuiteRoomFacilityId INT
DECLARE @RestaurantFacilityId INT
DECLARE @PoolFacilityId INT
DECLARE @SpaFacilityId INT
DECLARE @Guest1 INT
DECLARE @Guest2 INT

-- Lookup advertisement IDs by package name for Grand Ocean Hotel
SELECT @CouplesRetreatAdId = MIN(a.advertisementId)
FROM Advertisement a
INNER JOIN Package p ON a.packageId = p.packageId
INNER JOIN HotelAdvertisement ha ON a.advertisementId = ha.advertisementId
WHERE p.name = 'Couples Retreat'
  AND ha.hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

SELECT @SetMenuAdId = MIN(a.advertisementId)
FROM Advertisement a
INNER JOIN Package p ON a.packageId = p.packageId
INNER JOIN HotelAdvertisement ha ON a.advertisementId = ha.advertisementId
WHERE p.name = 'set menu dinner'
  AND ha.hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

-- For extra wine, we assume the package is "house wine"
SELECT @ExtraWineAdId = MIN(a.advertisementId)
FROM Advertisement a
INNER JOIN Package p ON a.packageId = p.packageId
INNER JOIN HotelAdvertisement ha ON a.advertisementId = ha.advertisementId
WHERE p.name = 'house wine'
  AND ha.hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

SELECT @PoolVisitAdId = MIN(a.advertisementId)
FROM Advertisement a
INNER JOIN Package p ON a.packageId = p.packageId
INNER JOIN HotelAdvertisement ha ON a.advertisementId = ha.advertisementId
WHERE p.name = 'pool visit'
  AND ha.hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

-- Lookup facility IDs for Grand Ocean Hotel
SELECT @SuiteRoomFacilityId = facilityId
FROM Facility
WHERE name = 'Room 104'
  AND hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

SELECT @RestaurantFacilityId = facilityId
FROM Facility
WHERE name = 'Salt and Sea' 
  AND hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

SELECT @PoolFacilityId = facilityId
FROM Facility
WHERE name = 'Pacific Pool'
  AND hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

SELECT @SpaFacilityId = facilityId
FROM Facility
WHERE name = 'Ocean Breeze Spa'
  AND hotelId = (SELECT hotelId FROM Hotel WHERE name = 'Grand Ocean Hotel')

-- Insert Guests
INSERT INTO Guest (name, buildingNumber, street, city, postcode, state, countryCode, phoneNumber, email, gender, dob)
VALUES 
    ('Victoria Montgomery', '101', 'Elizabeth St', 'Sydney', '2000', 'NSW', 'AUS', '0411222333', 'victoria.montgomery@example.com', 'Female', '1986-04-12'),
    ('Christopher James', '101', 'Elizabeth St', 'Sydney', '2000', 'NSW', 'AUS', '0411222444', 'christopher.james@example.com', 'Male', '1984-09-18')

-- Store guest IDs in variables
SELECT @Guest1 = guestId FROM Guest WHERE email = 'victoria.montgomery@example.com'
SELECT @Guest2 = guestId FROM Guest WHERE email = 'christopher.james@example.com'

-- Insert PaymentInfo
INSERT INTO PaymentInformation(vendorToken, guestId)
    VALUES
    ('tok_1N3T00LkdIwHu7ixt44h1F8k', @Guest1),
    ('tok_1N3T017kdIfGu8ixt41h1Abi', @Guest2)

-- Insert Reservation for Couples (primary guest: Victoria)
INSERT INTO Reservation (guestId, grantingEmployeeId, authorisingEmployeeId, discountAmount)
VALUES (@Guest1, 6, 6, 0.00)
SET @ResNumber = SCOPE_IDENTITY()

-- Link both guests to the reservation
INSERT INTO ReservationGuest (reservationNumber, guestId)
VALUES (@ResNumber, @Guest1),
       (@ResNumber, @Guest2)

-- Insert Bookings

-- Initial booking for the Couples Retreat package (suite stay; includes massage per package item)
INSERT INTO Booking (reservationNumber, advertisementId, quantity, startDate, endDate, isInitialBooking)
VALUES (@ResNumber, @CouplesRetreatAdId, 1, '2025-03-14', '2025-03-17', 1)
SET @RetreatBookingId = SCOPE_IDENTITY()

-- Additional booking for Set Menu Dinner
INSERT INTO Booking (reservationNumber, advertisementId, quantity, startDate, endDate, isInitialBooking)
VALUES (@ResNumber, @SetMenuAdId, 2, '2025-03-15', '2025-03-15', 0)
SET @DinnerBookingId = SCOPE_IDENTITY()

-- Additional booking for Extra Bottles of Wine
INSERT INTO Booking (reservationNumber, advertisementId, quantity, startDate, endDate, isInitialBooking)
VALUES (@ResNumber, @ExtraWineAdId, 2, '2025-03-15', '2025-03-15', 0)

-- Additional booking for Pool Visit Passes
INSERT INTO Booking (reservationNumber, advertisementId, quantity, startDate, endDate, isInitialBooking)
VALUES (@ResNumber, @PoolVisitAdId, 1, '2025-03-14', '2025-03-14', 0)
SET @PoolBookingId = SCOPE_IDENTITY()

-- Insert Facility Bookings

-- Facility booking for suite stay (Couples Retreat) at "Room 104"
INSERT INTO FacilityBooking (bookingId, facilityId, startDateTime, endDateTime)
VALUES (@RetreatBookingId, @SuiteRoomFacilityId, '2025-03-14 14:00:00', '2025-03-17 11:00:00')

-- Facility booking for massage (Couples Retreat) at "Ocean Breeze Spa"
INSERT INTO FacilityBooking (bookingId, facilityId, startDateTime, endDateTime)
VALUES (@RetreatBookingId, @SpaFacilityId, '2025-03-15 11:00:00', '2025-03-15 12:00:00')

-- Facility booking for set menu dinner at "Salt and Sea"
INSERT INTO FacilityBooking (bookingId, facilityId, startDateTime, endDateTime)
VALUES (@DinnerBookingId, @RestaurantFacilityId, '2025-03-15 19:00:00', '2025-03-15 21:00:00')

-- Facility booking for pool visit at "Pacific Pool"
INSERT INTO FacilityBooking (bookingId, facilityId, startDateTime, endDateTime)
VALUES (@PoolBookingId, @PoolFacilityId, '2025-03-14 16:00:00', '2025-03-14 17:00:00')

-- Insert Facility Bookees (link both guests to each facility booking)
DECLARE @FacilityBookeeMappings TABLE(
    BookingID INT, 
    FacilityID INT, 
    StartDateTime DATETIME, 
    EndDateTime DATETIME,
    GuestEmail VARCHAR(100)
)

INSERT INTO @FacilityBookeeMappings (BookingID, FacilityID, StartDateTime, EndDateTime, GuestEmail)
VALUES
    (@RetreatBookingId, @SuiteRoomFacilityId, '2025-03-14 14:00:00', '2025-03-17 11:00:00', 'victoria.montgomery@example.com'),
    (@RetreatBookingId, @SuiteRoomFacilityId, '2025-03-14 14:00:00', '2025-03-17 11:00:00', 'christopher.james@example.com'),
    (@RetreatBookingId, @SpaFacilityId, '2025-03-15 11:00:00', '2025-03-15 12:00:00', 'victoria.montgomery@example.com'),
    (@RetreatBookingId, @SpaFacilityId, '2025-03-15 11:00:00', '2025-03-15 12:00:00', 'christopher.james@example.com'),
    (@DinnerBookingId, @RestaurantFacilityId, '2025-03-15 19:00:00', '2025-03-15 21:00:00', 'victoria.montgomery@example.com'),
    (@DinnerBookingId, @RestaurantFacilityId, '2025-03-15 19:00:00', '2025-03-15 21:00:00', 'christopher.james@example.com'),
    (@PoolBookingId, @PoolFacilityId, '2025-03-14 16:00:00', '2025-03-14 17:00:00', 'victoria.montgomery@example.com'),
    (@PoolBookingId, @PoolFacilityId, '2025-03-14 16:00:00', '2025-03-14 17:00:00', 'christopher.james@example.com')

INSERT INTO FacilityBookee (facilityBookingId, guestId)
SELECT fb.facilityBookingId, g.guestId
FROM @FacilityBookeeMappings m
JOIN FacilityBooking fb 
  ON fb.bookingId = m.BookingID
  AND fb.facilityId = m.FacilityID
  AND fb.startDateTime = m.StartDateTime
  AND fb.endDateTime = m.EndDateTime
JOIN Guest g 
  ON g.email = m.GuestEmail

-- Insert Payment Invoices for each Booking in the Reservation
INSERT INTO PaymentInvoice (amount, date, status, reservationNumber, paymentInfoId, bookingId)
SELECT 
    a.advertisedPrice * b.quantity AS amount,
    GETDATE() AS date,
    'Pending' AS status,
    b.reservationNumber,
    pi.paymentInfoId,
    b.bookingId
FROM Booking b
JOIN Advertisement a 
    ON b.advertisementId = a.advertisementId
JOIN Reservation r 
    ON b.reservationNumber = r.reservationNumber
JOIN PaymentInformation pi 
    ON r.guestId = pi.guestId
WHERE b.reservationNumber = @ResNumber

GO

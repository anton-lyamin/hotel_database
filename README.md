# hotel_database
A schema and related query scripts for assignment 1 of Comp3350.


## Data script
# All Accomodation Acquirements (AAA) Database Prototype

This repository contains a prototype SQL Server database for **All Accomodation Acquirements (AAA)** – a hotel conglomerate that manages a diverse portfolio of hotels. The database is designed to capture comprehensive information about hotels, their facilities, services, packages, reservations, bookings, and billing. The prototype includes dynamic data insertion scripts that populate the schema with realistic sample data for two hotels and sample guest reservations.

## Overview

AAA’s database prototype supports the following core functions:
- **Hotel and Facility Management:**  
  Two hotels are featured:
  - **Grand Ocean Hotel** in Bondi Beach, Sydney, Australia (located at 178 Campbell Parade, Bondi, NSW, 2026).
  - **Lakeside Haven** in Lake Ozark, USA (located at 2359 Bittersweet Rd, Lake Ozark, MO 65049).

- **Service Offerings:**  
  Both hotels share a standard set of facility types, service categories, service items, and packages.  
  **Shared Facility Types:**  
  - single room, twin room, family room, suite, pool, spa, restaurant, conference room  
  **Shared Service Categories:**  
  - Entertainment, Food and Beverage, Accommodation, Events and Conferences, Minibar, Laundry  
  **Shared Service Items:**  
  - single stay, twin stay, family stay, suite stay, pool visit, massage (Swedish massage), facial, buffet breakfast, set menu dinner, breakfast catering, lunch catering, dinner catering, projector hire, coca-cola, juice, cookies, chips, house wine, house beer, dry-cleaning, ironing (per-item), adult kayak tour, child kayak tour  
  **Shared Packages:**  
  - *Family Fun:* Includes family stay, daily buffet breakfast, and daily pool visits.  
  - *Couples Retreat:* Includes suite stay, house wine on arrival, and a couples massage.  
  - *Business Stay:* Includes a single room and daily buffet breakfast.  

  In addition, each hotel may offer unique services. For example, Grand Ocean Hotel provides a sports massage and an ocean pool visit pass, while Lakeside Haven offers kayaking tours with couples and family packages.

## Database Schema

The schema comprises multiple interrelated tables that capture the following entities:

- **Country:** Stores country codes, names, and local currencies.
- **FacilityType:** Lists types of facilities (e.g., single room, suite, pool).
- **ServiceCategory:** Groups service items (e.g., Accommodation, Entertainment, Food and Beverage).
- **Package:** Represents both individual service packages (which have the same name as the service item) and bundled packages (e.g., Couples Retreat).
- **ServiceItem:** Contains detailed descriptions of individual services.
- **ServiceFacility:** Maps service items to the facility types required to provide the service.
- **PackageItem:** Associates a package with one or more service items along with the quantity (e.g., number of nights, number of sessions).
- **Hotel:** Contains hotel details and location information.
- **Facility:** Details individual facilities (rooms, spas, restaurants) at each hotel.
- **EmployeeRole & Employee:** Capture hotel staff roles and details.
- **Advertisement & HotelAdvertisement:** Provide pricing and promotion details for packages. Advertisements are region‑specific (e.g., using local currencies) and linked to hotels.
- **Reservation, ReservationGuest, Booking:** Capture guest reservations and their associated bookings. Bookings indicate whether the service was booked as part of the initial reservation or added later.
- **FacilityBooking & FacilityBookee:** Record facility usage details (e.g., check-in and check-out times) and the guests linked to each facility booking.
- **PaymentInformation & PaymentInvoice:** Manage guest payment information and invoice details for bookings.

## Sample Data Insertion

The provided data insertion scripts are organized into several steps:

1. **Base Data Insertion:**  
   - **Countries:** Inserts Australia and the USA along with their currencies.
   - **Facility Types & Service Categories:** Inserts a standard set of facility types and service categories.
   
2. **Service Items & ServiceFacility Mapping:**  
   - Inserts all shared service items (e.g., single stay, pool visit, massage, etc.) and then maps them to the corresponding facility types (e.g., a "suite stay" is associated with a suite).

3. **Package and PackageItem Data:**  
   - Inserts individual service packages (with names matching the service items) and bundled packages (e.g., Family Fun, Couples Retreat, etc.).
   - The PackageItem table maps each package to the relevant service items and specifies the quantity (e.g., three-night stay for a suite).

4. **Hotels and Facilities:**  
   - Inserts two hotels: Grand Ocean Hotel and Lakeside Haven.
   - Inserts facilities for each hotel (rooms, spa, restaurant, pool, and conference room) with details like capacity and status.

5. **Employee Roles and Employees:**  
   - Inserts employee roles and sample employees for each hotel.
   
6. **Advertisements and HotelAdvertisement Mapping:**  
   - Inserts advertisements for each package (individual and bundled) with advertised prices and grace periods.
   - Maps advertisements to the correct hotel using the HotelAdvertisement table. (Dynamic scripts use phone numbers and package names to look up the correct IDs.)
   
7. **Reservations and Bookings (Couples Reservation Example):**  
   - Inserts sample guest records for Victoria Montgomery and Christopher James.
   - Creates a reservation for the couples, links both guests, and inserts multiple bookings:
     - An initial booking for the Couples Retreat package (which includes a suite stay and massage as defined in the package items).
     - Additional bookings for set menu dinner, extra bottles of wine, and pool visit passes.
   - Facility bookings are created for the suite stay, massage session, set menu dinner, and pool visit, and both guests are linked as facility bookees.
   
8. **Payment Invoice Generation:**  
   - A set‑based script generates a PaymentInvoice for each booking by multiplying the advertised price by the booking quantity. Invoices are linked to the primary guest’s PaymentInformation record.

## Additional Data Considerations

- **Service Flexibility:**  
  Every service item is offered as an individual package and can also be combined into bundles. This design enables flexible pricing and marketing tailored to each hotel’s region and offerings.

- **Region-Specific Advertisements:**  
  Advertisements are inserted dynamically based on the hotel’s country so that the advertised currency matches the local currency. Instead of hard‑coding the currency, a placeholder (`'---'`) is used, with a trigger responsible for deriving the actual currency from the hotel's country.


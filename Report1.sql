CREATE TABLE loyal_customers( MemberID CHAR(8),
    Title VARCHAR(5), FName VARCHAR(15) not NULL,
    LName VARCHAR(15) not NULL, Birthdate DATE, 
    Gender CHAR(1), PassportN VARCHAR(13) not NULL
    primary key(MemberID));

CREATE TABLE Customers_contact(
    MemberID CHAR(8),
    Email VARCHAR(50) not NULL,
    Phone_CountryCode INT(4),
    PhoneNumber INT(12),
    PRIMARY KEY(Email),
    FOREIGN KEY(MemberID) REFERENCES loyal_customers(MemberID))

/* fix change name of db management to membership*/

CREATE TABLE Routes(
    Origin_City VARCHAR(25) not NULL,
    Origin_Country VARCHAR(25) not NULL,
    Destination_City VARCHAR(25) not NULL,
    Destination_Country VARCHAR(25) not NULL,
    Route_Number INT,
    AVG_Distance FLOAT,
    PRIMARY KEY(Route_Number))

CREATE TABLE Schedule(
    Route_number INT,
    Departure DATE,
    Arrival DATE,
    Aircraft_model VARCHAR(10)
    FOREIGN KEY(Route_Number) REFERENCES Routes(Route_Number)
)

CREATE TABLE Airplanes(
    TailNumber VARCHAR(6) PRIMARY KEY,
    Manufacturer VARCHAR,
    Model VARCHAR(10),
    Active_since INT,
    Manufactured_Year INT,
)

/*falta correr porque falta crear pilot ID*/
CREATE TABLE Flights(
    Flight_Num INT,
    F_Distance FLOAT,
    FDuration INT, /*minutes*/
    Plane_TailNumber INT,
    F_Terminal VARCHAR(5),
    Crew_Num INT, 
    Available_Seats INT,
    PEID INT,
    FOREIGN KEY(Route_Number) REFERENCES Routes(Route_Number),
    FOREIGN KEY(PEID) REFERENCES Pilot(PEID),
    FOREIGN KEY(Plane_TailNumber) REFERENCES Airplanes(Plane_TailNumber)
)
/* Falta correr porque falta correr flights*/
CREATE TABLE Alliance_flights(
    Operating_Company VARCHAR(25),
    Flight_Num int FOREIGN KEY REFERENCES Flights(Flight_Num)
)

create TABLE Gates(
    Flight_num FOREIGN KEY REFERENCES Flights(Flight_Num),
    Departure_gate VARCHAR(4),
    Arrival_gate VARCHAR(4) 
)

CREATE TABLE ETOPS(
    TailNumber VARCHAR(6) FOREIGN KEY REFERENCES Airplanes(TailNumber),
    RouteN int REFERENCES Routes(Route_number)
)

Create Table Cabins(
CabinType varchar(15),
NumSeats int,
AC_TailNum Varchar(6) REFERENCES Airplanes(TailNumber)
)

CREATE TABLE Airport(
    Airport_Code VARCHAR(4) PRIMARY KEY,
    Airport_Name VARCHAR(25),
    City VARCHAR(25),
    Timezone varchar(5)
)
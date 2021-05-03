/* 1- The following query creates and After trigger named trigOne. This trigger is to restrict insertion or date updates on table flights
below the year 2016 or above the year 2019. This means dates between year 2016 to 2019 are the only dates accepted.
What the query does is to check if there exists a date in the inserted data which is not permitted.
If this is so, then a rollback transaction will occur, preventing the addition or update from occuring.*/
 
CREATE TRIGGER trigOne on flights
AFTER INSERT, UPDATE
AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
if exists (SELECT *
          FROM flights as fl
          JOIN inserted AS insOne
          ON fl.flight_id = insOne.flight_id
          where YEAR(fl.date) < 2016 or YEAR(fl.date) > 2019)
BEGIN
RAISERROR('The proposed flight date is not allowed because of the year', 16, 1);
ROLLBACK TRANSACTION;
RETURN
END;
GO
 
 
INSERT into flights(flight_id,[date])
VALUES(9999999,SYSDATETIME())
 
 
/* 2- A trigger called trigTwo has been created on table planes to prevent the addition, update, or delete of any information(tuple)
into the table. When an addition, update, or delete is tried, a message appears showing such action is not allowed */
DROP TRIGGER trigTwo
CREATE TRIGGER trigTwo on planes
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    RAISERROR('Input, modification or deletion of rows not allowed',16,1);
END;
go
 
INSERT into planes(plane_id)
VALUES(1000)
GO
 
/* 3- 
Created a trigger called trigThree on ticket tables. This trigger prevents the update of a ticket's final price
if the proposed price is 20% or higher than the allowed price for that specific route and cabin type. It also prevents the update if the
proposed price is lower than the allowed price for that specific route and cabin type. If the proposed final_price is not allowed,
then the transaction will be cancelled and a message will appear with the reason of update abortion*/
 
CREATE TRIGGER trigThree on tickets
INSTEAD OF UPDATE
AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
IF exists   (SELECT * 
            from inserted as insTi
                JOIN flights as fl ON fl.flight_id = insTi.flight_id
                JOIN routes_cabin_types as rct on rct.route_id = fl.route_id AND rct.cabin_type_id = insTi.cabin_type_id
            WHERE insTi.final_price >= 1.2*rct.price or insTi.final_price < rct.price)
BEGIN
RAISERROR('Updated price is higher than possible value or lower than original value',16,1);
ROLLBACK TRANSACTION;
RETURN
END;
GO
 
EX: Does not run and shows message
UPDATE tickets set final_price = 290 WHERE ticket_id = 85 and flight_id = 1
Go
Does not run and shows message
UPDATE tickets set final_price = 100 WHERE ticket_id = 85 and flight_id = 1
GO
Does run
UPDATE tickets set final_price = 190 WHERE ticket_id = 85 and flight_id = 1
GO
 
 
 
/* 4  
 
The trigger fires on the customers table when someone tries to Insert or Update a first name with a length between the max and the min length of the first_name attribute. And for first names that are not in the limit the trigger is not fired. 
As we used a Instead Of trigger we created an “invisible table” for all inserted and updated values that needs to be verified before adding to the actual table. In other words,  names that are in between the parameters are not able to be added to the original table. */
 
 
CREATE TRIGGER trigFour ON customers
INSTEAD OF INSERT, UPDATE
AS 
IF (ROWCOUNT_BIG() = 0)
RETURN;
if exists (SELECT *
          FROM customers as cu
          where (SELECT LEN(first_name) FROM inserted) > (
			(SELECT TOP 1 LEN(first_name) FROM customers
			ORDER BY LEN(first_name) ASC))
		  AND (SELECT LEN(first_name) FROM inserted) < (
			(SELECT TOP 1 LEN(first_name) FROM customers
		    ORDER BY len(first_name) DESC))
		  )
BEGIN
RAISERROR('you are not allowed to insert or update first names', 16, 1);
ROLLBACK TRANSACTION;
RETURN
END;
 
SELECT TOP 1 LEN(first_name) FROM customers
		  ORDER BY LEN(first_name) ASC
Go
SELECT TOP 1 LEN(first_name) FROM customers
		  ORDER BY len(first_name) DESC
 
INSERT INTO customers(first_name)
Values('ghkjsdh')
 
Update customers Set first_name = 'm' 
where customer_id = 1
 
DROP TRIGGER trigFour
 
 
SELECT LEN(first_name) FROM customers
 
 
 
 
/* 5) Using the following table, you are asked to create an automatic audit system for the INSERT, UPDATE
and DELETE events using AFTER triggers for the planes table.
In the INSERT event, each column inserted (for each row) must generate a single row in
the tb_audit table
In  the  UPDATE  event,  each  column  updated  must  generate  a  single  row  in  the  tb_audit
table
In the DELETE event, each column deleted (for each row) must generate a single row in
the tb_audit table*/
 
/* An automatic audit system was created for all INSERT, UPDATE and DELETE using AFTER triggers. A single row must be created for each column for all the operations (insert, update and delete)*/
 
CREATE trigger AUDIT_PROCESS
ON planes
AFTER INSERT, UPDATE, DELETE
As
Set NOCOUNT ON;
BEGIN
   declare @plane_id int;
   declare @fabrication_date date;
   declare @first_use_date date;
   declare @brand varchar(80);
   declare @model varchar(80);
   declare @capacity int;
  
print 'inserted'
 
   if exists (SELECT * from inserted) AND NOT EXISTS (SELECT * FROM deleted)
   BEGIN
       Select @plane_id=plane_id From inserted ins;
       Select @fabrication_date=fabrication_date From inserted ins;
       Select @first_use_date=first_use_date From inserted ins;
       Select @brand=brand From inserted ins;
       Select @capacity=capacity From inserted ins;
       Select @model=model From inserted ins;
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       VALUES (HOST_NAME(),'INSERT',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'plane_id',NULL,@plane_id);
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       VALUES (HOST_NAME(),'INSERT',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'fabrication_date',NULL,@fabrication_date);
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       VALUES (HOST_NAME(),'INSERT',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'first_use_date',NULL,@first_use_date);
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       VALUES (HOST_NAME(),'INSERT',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'brand',NULL,@brand);
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       VALUES (HOST_NAME(),'INSERT',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'model',NULL,@model);
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       VALUES (HOST_NAME(),'INSERT',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'capacity',NULL,@model);
   END
   print 'update'
 
   IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
   BEGIN  
       DECLARE @temporalinserted TABLE(
       plane_id int not null,
       fabrication_date date null,
       first_use_date date null,
       brand varchar(60) null,
       model varchar(60) null,
       capacity int null);
       
       DECLARE @temporaldeleted table(
       plane_id int not null,
       fabrication_date date null,
       first_use_date date null,
       brand varchar(60) null,
       model varchar(60) null,
       capacity int null);
 
       INSERT INTO @temporalinserted([plane_id], [fabrication_date], [first_use_date], [brand], [model], [capacity])
       SELECT  [plane_id], [fabrication_date], [first_use_date], [brand], [model], [capacity]
        FROM INSERTED;
 
       INSERT INTO @temporaldeleted([plane_id], [fabrication_date], [first_use_date], [brand], [model], [capacity])
       SELECT  [plane_id], [fabrication_date], [first_use_date], [brand], [model], [capacity]
        FROM DELETED;
      
      
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       SELECT HOST_NAME(),'UPDATE',GETDATE(),GETDATE(),SYSTEM_USER,'PLANES',ti.plane_id,'plane_id',td.plane_id,ti.plane_id
       FROM @temporaldeleted td
       JOIN @temporalinserted ti on td.plane_id=ti.plane_id
       WHERE  td.plane_id!=ti.plane_id;
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       SELECT HOST_NAME(),'UPDATE',GETDATE(),GETDATE(),SYSTEM_USER,'PLANES',ti.fabrication_date,'fabrication_date',td.fabrication_date,ti.fabrication_date
       FROM @temporaldeleted td
       JOIN @temporalinserted ti on td.plane_id=ti.plane_id
        WHERE  td.plane_id!=ti.plane_id;
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       SELECT HOST_NAME(),'UPDATE',GETDATE(),GETDATE(),SYSTEM_USER,'PLANES',ti.first_use_date,'first_use_date',td.first_use_date,ti.first_use_date
       FROM @temporaldeleted td
       JOIN @temporalinserted ti on td.plane_id=ti.plane_id
       WHERE  td.plane_id!=ti.plane_id;
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       SELECT HOST_NAME(),'UPDATE',GETDATE(),GETDATE(),SYSTEM_USER,'PLANES',ti.brand,'brand',td.brand,ti.brand
       FROM @temporaldeleted td
       JOIN @temporalinserted ti on td.plane_id=ti.plane_id
        WHERE  td.plane_id!=ti.plane_id;
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       SELECT HOST_NAME(),'UPDATE',GETDATE(),GETDATE(),SYSTEM_USER,'PLANES',ti.model,'model',td.model,ti.model
       FROM @temporaldeleted td
       JOIN @temporalinserted ti on td.plane_id=ti.plane_id
       WHERE  td.plane_id!=ti.plane_id;
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       SELECT HOST_NAME(),'UPDATE',GETDATE(),GETDATE(),SYSTEM_USER,'PLANES',ti.capacity,'capacity',td.capacity,ti.capacity
       FROM @temporaldeleted td JOIN
       @temporalinserted ti on td.plane_id=ti.plane_id
       WHERE  td.plane_id!=ti.plane_id;
 
   END
  print 'deleted'
 
   IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
   BEGIN
       Select @plane_id=plane_id From deleted ins;
       Select @fabrication_date=fabrication_date From deleted ins;
       Select @first_use_date=first_use_date From deleted ins;
       Select @brand=brand From deleted ins;
       Select @capacity=capacity From deleted ins;
       Select @model=model From inserted ins;
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       values (HOST_NAME(),'DELETE',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'plane_id',@plane_id,NULL);
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       values (HOST_NAME(),'DELETE',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'fabrication_date',@FABRICATION_DATE,NULL);
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       values (HOST_NAME(),'DELETE',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'first_use_date',@FIRST_USE_DATE,NULL);
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       values (HOST_NAME(),'DELETE',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'brand',@BRAND,NULL);
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       values (HOST_NAME(),'DELETE',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'model',@MODEL,NULL);
 
       INSERT INTO tb_audit (aud_station,aud_operation ,aud_date, aud_time,aud_username,aud_table,aud_identifier_id,aud_column,aud_before,aud_after)
       values (HOST_NAME(),'DELETE',GETDATE(),CURRENT_TIMESTAMP,SYSTEM_USER ,'PLANES',@PLANE_ID,'capacity',@CAPACITY,NULL); 
 
   end
end
GO 
 
 
/* 6.  With this view we are able to retrieve the attributes: customer_id, first_name, last_name, birth_date, current_age, city_name where we get the first 100 youngest customers */
 
Create view viewOne AS
SELECT TOP 100 customer_id, first_name, last_name, birth_date, FLOOR(DATEDIFF(YEAR, birth_date, GETDATE())) as current_age, ci.name as city_name 
FROM customers as cu, cities_states as ci
WHERE ci.city_state_id= cu.city_state_id
ORDER BY current_age ASC, birth_date DESC
GO
 
/*7 created a view named Top 3 Sold routes for each weekday from 2016 and 2017 with its route id, and origin and destination city,
its weekday id and name od the day, and the number of customer who flew  */
 
CREATE VIEW [Top 3 Sold routes per weekday]
AS
SELECT *
FROM(SELECT top 3 ro.route_id, cs.name as origin_city, ci.name as destination_city,
we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id JOIN
    cities_states ci on ro.city_state_id_destination = ci.city_state_id JOIN
    cities_states cs on ro.city_state_id_origin = cs.city_state_id
WHERE we.name in ('Monday') and YEAR(ti.purchase_date) in (2016, 2017)
GROUP BY ro.route_id, we.name, we.weekday_id, ci.name, cs.name
ORDER BY COUNT(ticket_id) DESC) a 
UNION
SELECT *
FROM(SELECT top 3 ro.route_id, cs.name as origin_city, ci.name as destination_city,
we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id JOIN
    cities_states ci on ro.city_state_id_destination = ci.city_state_id JOIN
    cities_states cs on ro.city_state_id_origin = cs.city_state_id
WHERE we.name in ('Tuesday') and YEAR(ti.purchase_date) in (2016, 2017)
GROUP BY ro.route_id, we.name, we.weekday_id, ci.name, cs.name
ORDER BY COUNT(ticket_id) DESC) b
UNION
SELECT *
FROM(SELECT top 3 ro.route_id, cs.name as origin_city, ci.name as destination_city,
we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id JOIN
    cities_states ci on ro.city_state_id_destination = ci.city_state_id JOIN
    cities_states cs on ro.city_state_id_origin = cs.city_state_id
WHERE we.name in ('Wednesday') and YEAR(ti.purchase_date) in (2016, 2017)
GROUP BY ro.route_id, we.name, we.weekday_id, ci.name, cs.name
ORDER BY COUNT(ticket_id) DESC) c
UNION
SELECT *
FROM(SELECT top 3 ro.route_id, cs.name as origin_city, ci.name as destination_city,
we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id JOIN
    cities_states ci on ro.city_state_id_destination = ci.city_state_id JOIN
    cities_states cs on ro.city_state_id_origin = cs.city_state_id
WHERE we.name in ('Thursday') and YEAR(ti.purchase_date) in (2016, 2017)
GROUP BY ro.route_id, we.name, we.weekday_id, ci.name, cs.name
ORDER BY COUNT(ticket_id) DESC) d 
UNION
SELECT *
FROM(SELECT top 3 ro.route_id, cs.name as origin_city, ci.name as destination_city,
we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id JOIN
    cities_states ci on ro.city_state_id_destination = ci.city_state_id JOIN
    cities_states cs on ro.city_state_id_origin = cs.city_state_id
WHERE we.name in ('Friday') and YEAR(ti.purchase_date) in (2016, 2017)
GROUP BY ro.route_id, we.name, we.weekday_id, ci.name, cs.name
ORDER BY COUNT(ticket_id) DESC) e 
GO
 
 
 
 
 
 
/* 8.    With viewThree we get the first 20 cities that get the most flights from people that fly to the same city listed in their address which we suppose is the city that they live in.
Create a view on that shows the following columnsname (cities_states table)number of flights in 2016 and 2017
by customers whose address belong to that citynumber of flights in 2016 and 2017 by male customers whose address belong to that
 citynumber of flights in 2016 and 2017 by female customers whose address belong to that cityOnly return rows from the top 20
  first cities in descendent order by number of flights in 2016 and 2017 by customers whose address belong to that city */
 
Create view viewThree AS
SELECT TOP 20 ci.name as cities_name, count( cu.city_state_id) as total_flights, count(CASE WHEN cu.gender= 'M' THEN 1 END) AS [flights_male_customers], count(CASE WHEN cu.gender= 'F' THEN 1  END) AS [flights_female_customers]
From cities_states ci JOIN customers cu ON ci.city_state_id = cu.city_state_id
JOIN tickets ti ON ti.customer_id = cu.customer_id
JOIN flights fl on fl.flight_id = ti.flight_id
JOIN routes ro on ro.route_id = fl.route_id
WHERE YEAR(ti.boarding_date) = 2016 or YEAR(ti.boarding_date) = 2017
GROUP BY ci.name
ORDER BY total_flights DESC, ci.name
GO
 
 
 
 
 
/*9- created a view named historyData for years 2016 and 2017 where summary of cities for which customers
are counted if their address from their city is the same as from where the flight either departed or arrived.
This summary includes the count of customer per age group for which it happened. It is all organized by age group from highest count to lowest. Returns only top 3  */
 
create VIEW historyData
AS
SELECT top 3 ci.name, ci.city_state_id as city_id, count(cu.customer_id) as num_customers, COUNT( distinct fl.flight_id) as num_flights, 
        SUM(CASE WHEN FLOOR(DATEDIFF(YEAR,cu.birth_date,GETDATE())) < 25 THEN 1 ELSE 0 END) AS [25 and under],
        SUM(CASE WHEN FLOOR(DATEDIFF(YEAR,cu.birth_date,GETDATE())) BETWEEN 26 AND 40 THEN 1 ELSE 0 END) AS [26-40],
        SUM(CASE WHEN FLOOR(DATEDIFF(YEAR,cu.birth_date,GETDATE())) BETWEEN 41 AND 55 THEN 1 ELSE 0 END) AS [41-55],
        SUM(CASE WHEN FLOOR(DATEDIFF(YEAR,cu.birth_date,GETDATE())) BETWEEN 56 AND 70 THEN 1 ELSE 0 END) AS [56-70],
        SUM(CASE WHEN FLOOR(DATEDIFF(YEAR,cu.birth_date,GETDATE())) > 71 THEN 1 ELSE 0 END) AS [71 and older]
From cities_states ci JOIN customers cu ON ci.city_state_id = cu.city_state_id
JOIN tickets ti ON ti.customer_id = cu.customer_id
JOIN flights fl on fl.flight_id = ti.flight_id
JOIN routes ro on ro.route_id = fl.route_id 
WHERE YEAR(ti.boarding_date) = 2016 or YEAR(ti.boarding_date) = 2017
GROUP BY ci.name, ci.city_state_id
ORDER BY [25 and under] DESC, [26-40] DESC, [41-55] DESC, [56-70] DESC, [71 and older] DESC
GO
 
 
 
 
/* 10.  You are asked to create the indicated number of constraints (you can decide to use either check, unique or default)
that satisfies the current data on each of the following tables: */
 
alter table employees
Add Constraint Constraint1 check(employee_id <= 200),
 constraint constraint2 UNIQUE (ssn),
 constraint constraint3 UNIQUE (phone1),
 constraint constraint4 UNIQUE (employee_id),
 constraint constraint5 CHECK(gender='m' or gender='f'),
 constraint constraint6 CHECK(year(birth_date)<1990),
 constraint constraint7 CHECK(year(hire_date)<2014),
 constraint constraint8 CHECK(len(zipcode_id)=5);
 
/* For the table employees we applied 8 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 17 columns.*/
 
alter table customers
Add Constraint Constraint9 check(customer_id <= 5000),
 constraint constraint10 UNIQUE (customer_id),
 constraint constraint11 UNIQUE (email),
 constraint constraint12 CHECK(len(zipcode_id)<=5),
 constraint constraint13 CHECK(gender='m' or gender='f'),
 constraint constraint14 CHECK(year(birth_date)<1999);
 
/* For the table customers we applied 6 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 13 columns.*/
 
 alter table tickets
Add Constraint Constraint15 check(customer_id <= 5000),
 constraint constraint16 UNIQUE (ticket_id),
 constraint constraint17 CHECK(cabin_type_id=1 or cabin_type_id=2),
 constraint constraint18 CHECK(purchase_location_id<=7),
 constraint constraint19 CHECK(year(purchase_date)<2025),
 constraint constraint20 CHECK(year(boarding_date)<2025);
 
/* For the table tickets we applied 6 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 13 columns.*/
 
alter table locations
Add constraint constraint21 CHECK(len(zipcode_id)<=5),
 constraint constraint22 UNIQUE (location_id),
 constraint constraint23 UNIQUE (name);
 
/* For the table locations we applied 3 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 7 columns.*/
 
alter table planes
Add constraint constraint24 CHECK(capacity=16),
 constraint constraint25 UNIQUE (plane_id),
 constraint constraint26 CHECK(brand='Virgin PLanes');
 
/* For the table planes we applied 3 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 6 columns.*/
 
alter table flights
Add constraint constraint27 CHECK(year(date)<2025),
 constraint constraint28 UNIQUE (flight_id),
 constraint constraint29 CHECK(plane_id=1 or plane_id=2);
 
/* For the table flights we applied 3 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 6 columns.*/
 
alter table routes
Add constraint constraint30 CHECK(route_id<=112),
 constraint constraint31 UNIQUE (route_id),
 constraint constraint32 CHECK(weekday_id<=7);
 
/* For the table routes we applied 3 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 6 columns.*/
 
alter table discounts
Add constraint constraint33 CHECK(percentage<=1),
 constraint constraint34 UNIQUE (discount_id),
 constraint constraint35 UNIQUE (name);
 
/* For the table discounts we applied 3 constraints of the type UNIQUE and CHECK in order to satisfy the data that we were given and retrieve 6 columns.*/
 

/*q 1*/

SELECT fl.flight_id, pl.capacity, count(ti.ticket_id) as tickets_sold
FROM tickets ti JOIN
    flights fl ON fl.flight_id = ti.flight_id JOIN
    planes pl ON pl.plane_id = fl.plane_id
WHERE YEAR(fl.date) = 2016
GROUP BY fl.flight_id, pl.capacity
HAVING COUNT(ti.ticket_id) > (pl.capacity *0.5)
ORDER BY COUNT(ti.ticket_id) DESC

/* q 2*/

SELECT fl.flight_id, pl.capacity, count(ti.ticket_id) as tickets_sold, fl.[date] 
FROM tickets ti JOIN
    flights fl ON fl.flight_id = ti.flight_id JOIN
    planes pl ON pl.plane_id = fl.plane_id
WHERE YEAR(fl.[date]) = 2017
GROUP BY fl.flight_id, pl.capacity, fl.[date]
HAVING COUNT(ti.ticket_id) < (pl.capacity *0.75)
ORDER BY COUNT(ti.ticket_id) DESC

/*q 3*/

/*q 4*/

SELECT final_price * (select percentage from discounts WHERE name = 'Elderly Discount') total_discount
FROM tickets 
WHERE customer_id IN (select cu.customer_id FROM customers cu WHERE DATEDIFF(YEAR, cu.birth_date, purchase_date) >= 65) 
UNION
SELECT final_price * (select percentage from discounts WHERE name = 'Student Discount') total_discount
FROM tickets 
WHERE customer_id IN (select cu.customer_id FROM customers cu WHERE DATEDIFF(YEAR, cu.birth_date, purchase_date) >= 16 AND  DATEDIFF(YEAR, cu.birth_date, purchase_date) <= 23)

/*q5*/

/*q6 from tampa FL to orlando Fl, groupby weekday, most demanded route in terms of sold tickets */

SELECT we.name as Weekday, fl.route_id, COUNT(ticket_id) as ticket_sold
FROM weekdays we, routes ro, tickets ti, flights fl
WHERE we.weekday_id= ro.weekday_id AND ti.flight_id = fl.flight_id AND fl.route_id = ro.route_id AND ro.city_state_id_origin IN (SELECT ci.city_state_id
                                                                                                FROM cities_states ci, states st
                                                                                                 WHERE ci.state_id = st.state_id and ci.name = 'Tampa' AND st.name LIKE 'Fl%') AND  ro.city_state_id_destination IN(SELECT ci.city_state_id
                                                                                                                                                                                    FROM cities_states ci, states st
                                                                                                                                                                                    WHERE  ci.state_id = st.state_id and ci.name = 'Orlando' AND st.name LIKE '%Florida%')
GROUP BY we.name, fl.route_id
ORDER BY ticket_sold DESC

/*or*/

SELECT ro.route_id, we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id
WHERE ro.city_state_id_origin in (select ci.city_state_id FROM cities_states ci, states st where ci.name = 'Tampa' and st.name like 'FL%') AND 
    ro.city_state_id_destination in (select ci.city_state_id FROM cities_states ci, states st where ci.name = 'Orlando' and st.name like 'FL%')
GROUP BY ro.route_id, we.name, we.weekday_id
ORDER BY COUNT(ticket_id) DESC

/*or*/

SELECT ro.route_id, we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id
WHERE ro.city_state_id_origin = '2066' AND ro.city_state_id_destination = '2197'
GROUP BY ro.route_id, we.name, we.weekday_id
ORDER BY COUNT(ticket_id) DESC

/* q7 check with 6*/

SELECT we.name, ro.start_time, COUNT(ticket_id) as ticket_sold
FROM weekdays we, routes ro, tickets ti, flights fl
WHERE we.weekday_id= ro.weekday_id AND ti.flight_id = fl.flight_id AND fl.route_id = ro.route_id AND ro.city_state_id_origin IN (SELECT ci.city_state_id
                                                                                                FROM cities_states ci, states st
                                                                                                 WHERE ci.name = 'Tampa' AND st.name LIKE 'Fl%') AND  ro.city_state_id_destination IN(SELECT ci.city_state_id
                                                                                                                                                                                    FROM cities_states ci, states st
                                                                                                                                                                                    WHERE ci.name = 'Orlando' AND st.name LIKE '%Florida%')
GROUP BY we.name, ro.start_time
ORDER BY ticket_sold DESC





/* q8 which flights flew with less than 25% of full capacity in 2017 */

SELECT  YEAR(fl.[date]) as year, fl.flight_id, COUNT(ti.ticket_id) as tickets_sold, pl.capacity
FROM flights fl, planes pl, tickets ti
WHERE pl.plane_id = fl.plane_id and ti.flight_id = fl.flight_id AND year(fl.[date]) = 2017
GROUP BY  YEAR(fl.[date]), fl.flight_id, pl.capacity
HAVING COUNT(ti.ticket_id) < (pl.capacity * 0.25)


/* q9 lowest and highest yielding months in terms of sold tickets in 2017 ------ union not working because of order by, how to use limit? */

SELECT top 1 MONTH(ti.purchase_date) Month, count(ti.ticket_id) sold_tickets
FROM tickets ti
WHERE YEAR(ti.purchase_date) = 2017
GROUP BY MONTH(ti.purchase_date) 
order by count(ti.ticket_id) DESC

SELECT top 1 MONTH(ti.purchase_date) Month, COUNT(ti.ticket_id) sold_tickets
FROM tickets ti
WHERE YEAR(ti.purchase_date) = 2017
GROUP BY MONTH(ti.purchase_date)
ORDER BY COUNT(ti.ticket_id) ASC

/* q10 top 3 employees who have sold most tickets in 2017*/

SELECT TOP 3 em.employee_id, em.first_name, em.last_name, COUNT(em.employee_id) as tickets_sold
FROM employees em, tickets ti
where em.employee_id = ti.employee_id
GROUP BY em.employee_id, em.first_name, em.last_name
ORDER BY COUNT(em.employee_id) Desc  

/* q11 most in demand cabin in terms of sold tickets 2017*/
SELECT top 1 ca.name, COUNT(ti.ticket_id) as sold_tickets, YEAR(ti.purchase_date) as year
FROM cabin_types ca, tickets ti 
WHERE YEAR(ti.purchase_date) = 2017 AND ti.cabin_type_id = ca.cabin_type_id
GROUP BY ca.name, YEAR(ti.purchase_date)
ORDER BY COUNT(ti.ticket_id) DESC

/* q 16 */

Select datepart(HOUR,ti.purchase_time) as Hour, COUNT(*) as tickets_sold
from tickets as ti
where year(ti.purchase_date) = 2017 
group by datepart(HOUR,ti.purchase_time)
order by tickets_sold desc

/* q 17 */

SELECT top 3 cu.city_state_id, ci.name, COUNT(*) N_customers
FROM customers cu, cities_states ci
WHERE cu.city_state_id = ci.city_state_id
GROUP BY cu.city_state_id, ci.name
ORDER BY COUNT(*) DESC


/* q 20 */

SELECT top 3 ro.route_id, we.name AS day, we.weekday_id as day_id, count(ticket_id) as sold_tickets
FROM tickets ti JOIN
    flights fl on fl.flight_id = ti.flight_id JOIN
    routes ro on ro.route_id = fl.route_id JOIN
    weekdays we ON we.weekday_id = ro.weekday_id
WHERE we.name in ('Saturday', 'Sunday')
GROUP BY ro.route_id, we.name, we.weekday_id
ORDER BY COUNT(ticket_id) DESC
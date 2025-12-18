USE OlaUberDB;
GO
-- 1. Total number of successful trips
SELECT SUM(end_ride) AS no_of_successful_trips 
FROM trips_details;

-- 2. Total number of trips
SELECT COUNT(DISTINCT tripid) AS no_of_trips 
FROM trips_details;

-- 3. Total number of drivers
SELECT COUNT(DISTINCT driverid) AS no_of_drivers 
FROM trips;

-- 4. Total earnings
SELECT SUM(fare) AS total_earning 
FROM trips;

-- 5. Total searches
SELECT SUM(searches) AS no_of_searches 
FROM trips_details;

-- 6. Total searches which got estimates
SELECT SUM(searches_got_estimate) AS searches_got_estimates 
FROM trips_details;

-- 7. Total searches for quotes
SELECT SUM(searches_for_quotes) AS searches_for_quotes 
FROM trips_details;

-- 8. Total searches got quotes
SELECT SUM(searches_got_quotes) AS searches_got_quotes 
FROM trips_details;

-- 9. Total driver cancelled
SELECT COUNT(*) - SUM(driver_not_cancelled) AS total_driver_cancelled
FROM trips_details;

-- 10. Total OTP entered
SELECT SUM(otp_entered) AS total_otp_entered 
FROM trips_details;

-- 11. Total end rides
SELECT SUM(end_ride) AS total_end_rides 
FROM trips_details;

-- 12. Average distance per trip
SELECT ROUND(AVG(distance),2) AS average_distance 
FROM trips;

-- 13. Average fare per trip
SELECT ROUND(AVG(fare),2) AS average_fare 
FROM trips;

-- 14. Total distance travelled
SELECT SUM(distance) AS total_distance 
FROM trips;

-- 15. Most used payment method
SELECT TOP 1 p.id, p.method, COUNT(*) AS cnt
FROM trips t
JOIN payment p ON t.faremethod = p.id
GROUP BY p.id, p.method
ORDER BY cnt DESC;

-- 16. Payment revenue share
SELECT p.id, p.method, SUM(t.fare) AS total_fare
FROM trips t
JOIN payment p ON t.faremethod = p.id
GROUP BY p.id, p.method
ORDER BY total_fare DESC;

-- 17. Highest fare trip payment method
SELECT TOP 1 p.method, t.tripid, t.fare
FROM trips t
JOIN payment p ON t.faremethod = p.id
ORDER BY t.fare DESC;

-- 18. Top most trip route (loc_from → loc_to)
WITH CTE AS (
    SELECT loc_from, loc_to, COUNT(*) AS cnt,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM trips
    GROUP BY loc_from, loc_to
)
SELECT * FROM CTE WHERE rnk = 1;

-- 19. Top 5 highest earning drivers
SELECT TOP 5 driverid, SUM(fare) AS total_fare
FROM trips
GROUP BY driverid
ORDER BY total_fare DESC;

-- 20. Duration with most trips
SELECT TOP 1 duration, COUNT(*) AS cnt
FROM trips
GROUP BY duration
ORDER BY cnt DESC;

-- 21. Driver & Customer pair with most bookings
WITH CTE AS (
    SELECT driverid, custid, COUNT(*) AS cnt,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM trips
    GROUP BY driverid, custid
)
SELECT driverid, custid, cnt FROM CTE WHERE rnk = 1;

-- 22. Searches → Estimate Rate
SELECT (SUM(searches_got_estimate) * 100.0 / SUM(searches)) AS searches_to_estimate_rate
FROM trips_details;

-- 23. Estimate → Quote Rate
SELECT (SUM(searches_for_quotes) * 100.0 / SUM(searches_got_estimate)) AS estimate_to_quotes_rate
FROM trips_details;

-- 24. Quote → OTP Entry (Acceptance Rate)
SELECT (SUM(otp_entered) * 100.0 / SUM(searches_got_quotes)) AS quote_acceptance_rate
FROM trips_details;

-- 25. OTP → Ride Completion (Conversion within booking)
SELECT (SUM(end_ride) * 100.0 / SUM(otp_entered)) AS booking_conversion_rate
FROM trips_details;

-- 26. Total booking cancellation rate (driver+customer)
SELECT ((SUM(otp_entered) - SUM(end_ride)) * 100.0 / SUM(otp_entered)) AS cancellation_rate
FROM trips_details;

-- 27. FULL funnel conversion (search → completed trip)
SELECT (SUM(end_ride) * 100.0 / SUM(searches)) AS conversion_rate
FROM trips_details;

-- 28. Top area per duration
WITH CTE AS (
    SELECT duration, loc_from, COUNT(*) AS cnt,
           DENSE_RANK() OVER (PARTITION BY duration ORDER BY COUNT(*) DESC) AS rnk
    FROM trips
    GROUP BY duration, loc_from
)
SELECT * FROM CTE WHERE rnk = 1;

-- 29. Highest fare area
SELECT TOP 1 loc_from, SUM(fare) AS total_fare
FROM trips
GROUP BY loc_from
ORDER BY total_fare DESC;

-- 30A. Highest Driver Cancellation Area
WITH CTE AS (
    SELECT loc_from, (COUNT(*) - SUM(driver_not_cancelled)) AS cancelled,
           RANK() OVER (ORDER BY (COUNT(*) - SUM(driver_not_cancelled)) DESC) AS rnk
    FROM trips_details
    GROUP BY loc_from
)
SELECT loc_from, cancelled FROM CTE WHERE rnk = 1;

-- 30B. Highest Customer Cancellation Area
WITH CTE AS (
    SELECT loc_from, (COUNT(*) - SUM(customer_not_cancelled)) AS cancelled,
           RANK() OVER (ORDER BY (COUNT(*) - SUM(customer_not_cancelled)) DESC) AS rnk
    FROM trips_details
    GROUP BY loc_from
)
SELECT loc_from, cancelled FROM CTE WHERE rnk = 1;

-- 1-Identify the primary keys and foreign keys in maven movies db. Discuss the differences

SELECT * 
FROM actor;

SELECT DISTINCT country 
FROM country;

SELECT customer_id, first_name, last_name, email, address_id, active, create_date
FROM customer
WHERE active = 1;

SELECT rental_id
FROM rental
WHERE customer_id = 1;

SELECT title
FROM film
WHERE rental_duration > 5;

SELECT COUNT(*)
FROM film
WHERE replacement_cost > 15 AND replacement_cost < 20;

SELECT COUNT(DISTINCT first_name) AS unique_first_names_count
FROM actor;

SELECT * 
FROM customer
LIMIT 10;

SELECT title 
FROM film
WHERE rating = 'G'
LIMIT 5;

SELECT * 
FROM customer
WHERE first_name LIKE '%a';

SELECT city
FROM city
WHERE city LIKE 'a%a'
LIMIT 4;


SELECT first_name
FROM customer
WHERE first_name LIKE '%NI%';

SELECT first_name
FROM customer
WHERE first_name LIKE '_r%';

SELECT * 
FROM customer 
WHERE first_name COLLATE utf8mb4_general_ci LIKE 'A%o';

SELECT * 
FROM film 
WHERE rating IN ('PG', 'PG-13');

SELECT DISTINCT film_id
FROM inventory;


# 1. Retrieve the total number of rentals made in the Sakila database.
SELECT COUNT(*) AS total_rentals
FROM rental;

#2. Find the average rental duration (in days) of movies rented from the Sakila database.
SELECT AVG(rental_duration) AS average_rental_duration
FROM film;

#3. Display the first name and last name of customers in uppercase.
SELECT UPPER(first_name) AS first_name_upper, UPPER(last_name) AS last_name_upper
FROM customer;

# 4. Extract the month from the rental date and display it alongside the rental ID.

SELECT rental_id, MONTH(rental_date) AS rental_month
FROM rental;

# 5. Retrieve the count of rentals for each customer (display customer ID and the count of rentals).
SELECT customer_id, COUNT(rental_id) AS rental_count
FROM rental
GROUP BY customer_id;


# 6. Find the total revenue generated by each store.

SELECT s.store_id, SUM(p.amount) AS total_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
GROUP BY s.store_id;


#7. Determine the total number of rentals for each category of movies.

SELECT c.category_id, COUNT(r.rental_id) AS total_rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.category_id;


#8. Find the average rental rate of movies in each language.

SELECT l.name AS language, AVG(f.rental_rate) AS average_rental_rate
FROM film f
JOIN language l ON f.language_id = l.language_id
GROUP BY l.name;

# 9. Display the title of the movie, customer s first name, and last name who rented it.

SELECT f.title AS movie_title, c.first_name, c.last_name
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id;

# 10. Retrieve the names of all actors who have appeared in the film "Gone with the Wind."

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'Gone with the Wind';

# 11. Retrieve the customer names along with the total amount they've spent on rentals.

SELECT c.first_name, c.last_name, SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
JOIN rental r ON p.rental_id = r.rental_id
GROUP BY c.customer_id;

#12. List the titles of movies rented by each customer in a particular city (e.g., 'London').

SELECT c.first_name, c.last_name, f.title
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE ci.city = 'London'
ORDER BY c.first_name, c.last_name, f.title;

#Advanced Joins and GROUP BY:

# 13 Display the top 5 rented movies along with the number of times they've been rented.

SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 5;

# 14 Determine the customers who have rented movies from both stores (store ID 1 and store ID 2).

SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
WHERE i.store_id IN (1, 2)
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT i.store_id) = 2;

# Windows Function:

# 1. Rank the customers based on the total amount they've spent on rentals.

SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    SUM(p.amount) AS total_spent
FROM 
    customer c
JOIN 
    payment p ON c.customer_id = p.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    total_spent DESC;
    
# 2. Calculate the cumulative revenue generated by each film over time

SELECT 
    f.title, 
    r.rental_date, 
    SUM(p.amount) AS revenue,
    SUM(SUM(p.amount)) OVER (PARTITION BY f.film_id ORDER BY r.rental_date) AS cumulative_revenue
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
JOIN 
    payment p ON r.rental_id = p.rental_id
GROUP BY 
    f.film_id, f.title, r.rental_date
ORDER BY 
    f.film_id, r.rental_date;


# 3. Determine the average rental duration for each film, considering films with similar lengths.

SELECT 
    f.length, 
    AVG(TIMESTAMPDIFF(DAY, r.rental_date, r.return_date)) AS avg_rental_duration
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
GROUP BY 
    f.length
ORDER BY 
    f.length;


# 4. Identify the top 3 films in each category based on their rental counts.

WITH FilmRentalCount AS (
    SELECT 
        c.name AS category_name,
        f.title AS film_title,
        COUNT(r.rental_id) AS rental_count
    FROM 
        film f
    JOIN 
        film_category fc ON f.film_id = fc.film_id
    JOIN 
        category c ON fc.category_id = c.category_id
    JOIN 
        inventory i ON f.film_id = i.film_id
    JOIN 
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY 
        c.name, f.title
)
SELECT 
    category_name,
    film_title,
    rental_count,
    film_rank
FROM (
    SELECT 
        category_name,
        film_title,
        rental_count,
        RANK() OVER (PARTITION BY category_name ORDER BY rental_count DESC) AS film_rank
    FROM 
        FilmRentalCount
) AS ranked_films
WHERE 
    film_rank <= 3
ORDER BY 
    category_name, film_rank;

# 5. Calculate the difference in rental counts between each customer's total rentals and the average rentals across all customers

WITH CustomerRentalCount AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(r.rental_id) AS total_rentals
    FROM
        customer c
    JOIN
        rental r ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id
),
AverageRentalCount AS (
    SELECT
        AVG(total_rentals) AS avg_rentals
    FROM
        CustomerRentalCount
)
SELECT
    crc.customer_id,
    crc.first_name,
    crc.last_name,
    crc.total_rentals,
    arc.avg_rentals,
    (crc.total_rentals - arc.avg_rentals) AS rental_difference
FROM
    CustomerRentalCount crc, AverageRentalCount arc
ORDER BY
    rental_difference DESC;
    
# 6. Find the monthly revenue trend for the entire rental store over time

SELECT
    YEAR(p.payment_date) AS year,
    MONTH(p.payment_date) AS month,
    SUM(p.amount) AS total_revenue
FROM
    payment p
GROUP BY
    YEAR(p.payment_date), MONTH(p.payment_date)
ORDER BY
    year DESC, month DESC;


# 7. Identify the customers whose total spending on rentals falls within the top 20% of all customers.

WITH CustomerSpending AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(p.amount) AS total_spent
    FROM
        customer c
    JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name
),
RankedCustomers AS (
    SELECT
        cs.customer_id,
        cs.first_name,
        cs.last_name,
        cs.total_spent,
        ROW_NUMBER() OVER (ORDER BY cs.total_spent DESC) AS row_num,
        COUNT(*) OVER () AS total_customers
    FROM
        CustomerSpending cs
)
SELECT
    rc.customer_id,
    rc.first_name,
    rc.last_name,
    rc.total_spent
FROM
    RankedCustomers rc
WHERE
    rc.row_num <= 0.2 * rc.total_customers
ORDER BY
    rc.total_spent DESC;


# 8. Calculate the running total of rentals per category, ordered by rental count

WITH CategoryRentalCount AS (
    SELECT
        c.name AS category_name,
        COUNT(r.rental_id) AS rental_count
    FROM
        category c
    JOIN
        film_category fc ON c.category_id = fc.category_id
    JOIN
        film f ON fc.film_id = f.film_id
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY
        c.name
)
SELECT
    category_name,
    rental_count,
    SUM(rental_count) OVER (ORDER BY rental_count DESC) AS running_total
FROM
    CategoryRentalCount
ORDER BY
    rental_count DESC;

# 9. Find the films that have been rented less than the average rental count for their respective categories.

WITH FilmRentalCount AS (
    SELECT
        f.film_id,
        f.title AS film_title,
        c.name AS category_name,
        COUNT(r.rental_id) AS rental_count
    FROM
        film f
    JOIN
        film_category fc ON f.film_id = fc.film_id
    JOIN
        category c ON fc.category_id = c.category_id
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY
        f.film_id, f.title, c.name
),
CategoryAvgRentalCount AS (
    SELECT
        category_name,
        AVG(rental_count) AS avg_rental_count
    FROM
        FilmRentalCount
    GROUP BY
        category_name
)
SELECT
    frc.film_title,
    frc.category_name,
    frc.rental_count,
    car.avg_rental_count
FROM
    FilmRentalCount frc
JOIN
    CategoryAvgRentalCount car ON frc.category_name = car.category_name
WHERE
    frc.rental_count < car.avg_rental_count
ORDER BY
    frc.category_name, frc.rental_count;


# 10. Identify the top 5 months with the highest revenue and display the revenue generated in each month.

SELECT
    DATE_FORMAT(p.payment_date, '%Y-%m') AS month,
    SUM(p.amount) AS total_revenue
FROM
    payment p
GROUP BY
    month
ORDER BY
    total_revenue DESC
LIMIT 5;

# 5. CTE Basics:

 # a. Write a query using a CTE to retrieve the distinct list of actor names and the number of films they 
 #have acted in from the actor and film_actor tables.
 
 WITH ActorFilmCount AS (
    SELECT
        a.first_name,
        a.last_name,
        COUNT(fa.film_id) AS film_count
    FROM
        actor a
    JOIN
        film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY
        a.actor_id
)
SELECT
    first_name,
    last_name,
    film_count
FROM
    ActorFilmCount
ORDER BY
    film_count DESC;


# 6. CTE with Joins:

 #a. Create a CTE that combines information from the film and language tables to display the film title, 
 #language name, and rental rate.
 
 WITH FilmLanguageInfo AS (
    SELECT
        f.title AS film_title,
        l.name AS language_name,
        f.rental_rate
    FROM
        film f
    JOIN
        language l ON f.language_id = l.language_id
)
SELECT
    film_title,
    language_name,
    rental_rate
FROM
    FilmLanguageInfo
ORDER BY
    film_title;
    
    
# 7. CTE for Aggregation:

 #a. Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the customer and payment tables.

WITH CustomerRevenue AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(p.amount) AS total_revenue
    FROM
        customer c
    JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name
)
SELECT
    customer_id,
    first_name,
    last_name,
    total_revenue
FROM
    CustomerRevenue
ORDER BY
    total_revenue DESC;
    
# 8. CTE with Window Functions:
 #a. Utilize a CTE with a window function to rank films based on their rental duration from the film table.
 
 WITH FilmRentalRank AS (
    SELECT
        f.title,
        f.rental_duration,
        RANK() OVER (ORDER BY f.rental_duration DESC) AS rental_rank
    FROM
        film f
)
SELECT
    title,
    rental_duration,
    rental_rank
FROM
    FilmRentalRank
ORDER BY
    rental_rank;
    
# 9. CTE and Filtering:

# a. Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer table to retrieve additional customer details.

WITH CustomerRentalCount AS (
    SELECT
        r.customer_id,
        COUNT(r.rental_id) AS rental_count
    FROM
        rental r
    GROUP BY
        r.customer_id
    HAVING
        COUNT(r.rental_id) > 2
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    crc.rental_count
FROM
    customer c
JOIN
    CustomerRentalCount crc ON c.customer_id = crc.customer_id
ORDER BY
    crc.rental_count DESC;
    
    
# 10. CTE for Date Calculations:

 # a. Write a query using a CTE to find the total number of rentals made each month, considering the rental_date from the rental table


WITH MonthlyRentalCount AS (
    SELECT
        YEAR(r.rental_date) AS rental_year,
        MONTH(r.rental_date) AS rental_month,
        COUNT(r.rental_id) AS total_rentals
    FROM
        rental r
    GROUP BY
        YEAR(r.rental_date), MONTH(r.rental_date)
)
SELECT
    rental_year,
    rental_month,
    total_rentals
FROM
    MonthlyRentalCount
ORDER BY
    rental_year DESC, rental_month DESC;
    
    
# 11. CTE and Self-Join:

 # a. Create a CTE to generate a report showing pairs of actors who have appeared in the same film together, using the film_actor table.
 
 WITH ActorPairs AS (
    SELECT 
        fa1.actor_id AS actor_1_id,
        fa2.actor_id AS actor_2_id,
        fa1.film_id
    FROM
        film_actor fa1
    JOIN
        film_actor fa2 ON fa1.film_id = fa2.film_id
    WHERE
        fa1.actor_id < fa2.actor_id  -- Ensures pairs are unique (actor_1_id < actor_2_id)
)
SELECT
    a1.first_name AS actor_1_first_name,
    a1.last_name AS actor_1_last_name,
    a2.first_name AS actor_2_first_name,
    a2.last_name AS actor_2_last_name,
    ap.film_id
FROM
    ActorPairs ap
JOIN
    actor a1 ON ap.actor_1_id = a1.actor_id
JOIN
    actor a2 ON ap.actor_2_id = a2.actor_id
ORDER BY
    ap.film_id, a1.last_name, a2.last_name;


# 12. CTE for Recursive Search:

 # a. Implement a recursive CTE to find all employees in the staff table who report to a specific manager, considering the reports_to column

DESCRIBE staff;

ALTER TABLE staff ADD COLUMN reports_to TINYINT UNSIGNED;
UPDATE staff SET reports_to = 1 WHERE staff_id IN (2, 3);  
UPDATE staff SET reports_to = 2 WHERE staff_id = 4;        

WITH RECURSIVE EmployeeHierarchy AS (
    -- Base case: Select the manager (starting point)
    SELECT 
        staff_id, 
        first_name, 
        last_name, 
        reports_to
    FROM 
        staff
    WHERE 
        staff_id = 1  -- Replace with the specific manager's staff_id
    
    UNION ALL
    
    -- Recursive case: Find employees who report to the employees from the previous level
    SELECT 
        s.staff_id, 
        s.first_name, 
        s.last_name, 
        s.reports_to
    FROM 
        staff s
    JOIN 
        EmployeeHierarchy eh ON s.reports_to = eh.staff_id
)
SELECT 
    staff_id, 
    first_name, 
    last_name, 
    reports_to
FROM 
    EmployeeHierarchy;

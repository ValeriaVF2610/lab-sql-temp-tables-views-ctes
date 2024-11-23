USE Sakila;

-- Create a View
CREATE OR REPLACE VIEW rental_summary AS
SELECT 
    customer.customer_id,
    CONCAT(customer.first_name, ' ', customer.last_name) AS customer_name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM customer
LEFT JOIN rental ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, customer.email;

-- Create a Temporary Table
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    rental_summary.customer_id,
    SUM(payment.amount) AS total_paid
FROM rental_summary
LEFT JOIN payment ON rental_summary.customer_id = payment.customer_id
GROUP BY rental_summary.customer_id;

-- Create the CTE and Generate the Customer Summary Report
WITH customer_summary_cte AS (
    SELECT 
        rental_summary.customer_name,
        rental_summary.email,
        rental_summary.rental_count,
        customer_payment_summary.total_paid,
        CASE 
            WHEN rental_summary.rental_count > 0 THEN customer_payment_summary.total_paid / rental_summary.rental_count
            ELSE 0
        END AS average_payment_per_rental
    FROM rental_summary
    LEFT JOIN customer_payment_summary ON rental_summary.customer_id = customer_payment_summary.customer_id
) 
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(average_payment_per_rental, 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY customer_name;
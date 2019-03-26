USE sakila;


-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name,last_name
FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name," ",last_name)) AS Actor_Name
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, 
-- "Joe." What is one query would you use to obtain this information?
SELECT actor_id,first_name,last_name
FROM actor
WHERE first_name LIKE "Joe%";


-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name,last_name
FROM actor
WHERE last_name LIKE "%gen%";


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name,first_name
FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD COLUMN description BLOB NOT NULL AFTER last_update;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor 
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name 
HAVING COUNT(*) > 1;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
SET first_name="HARPO" 
WHERE first_name="GROUCHO" AND last_name="WILLIAMS";


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET first_name="GROUCHO" 
WHERE first_name="HARPO" AND last_name="WILLIAMS";


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

/*
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8 
*/


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name,last_name,address
FROM staff s
JOIN address a
ON s.address_id = a.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT CONCAT(s.first_name," ",s.last_name) AS "Staff Member", SUM(p.amount) AS "Total Amount"
FROM staff s
JOIN payment p USING(staff_id)
WHERE p.payment_date LIKE "2005-08%"
GROUP BY staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title AS "Movie Name", COUNT(*) AS "Number of Actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*)
FROM inventory
WHERE film_id IN 
	(
		SELECT film_id
		FROM film
		WHERE title = "Hunchback Impossible"
    );


-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- Total amount paid
SELECT last_name,first_name,SUM(amount)
FROM customer c
INNER JOIN payment p
ON c.customer_id=p.customer_id
GROUP BY last_name,first_name
ORDER BY last_name ASC;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id IN 
	(
    SELECT language_id
    FROM language
    WHERE name IN ("English")
	) 
    AND title LIKE "K%" OR title LIKE "Q%";


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(
		SELECT actor_id
        FROM film_actor
        WHERE film_id IN
			(
				SELECT film_id
                FROM film
                WHERE title LIKE "Alone Trip"
            )
    );


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT CONCAT(first_name," ",last_name) AS Customer_Name, email AS email_address
FROM customer 
JOIN address USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id)
WHERE country in ("Canada");


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT f.title, c.name
FROM film f
JOIN film_category fc USING(film_id)
JOIN category c USING(category_id)
WHERE c.name LIKE "Family";


-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.inventory_id) AS '# of Times Rented'
FROM rental r
JOIN inventory i USING(inventory_id)
JOIN film f USING(film_id)
GROUP BY f.title
ORDER BY '# of Times Rented' DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id AS "Store",SUM(p.amount) AS "Revenue USD"
FROM payment p
JOIN staff s USING(staff_id)
GROUP BY s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS "Store", c.city, co.country
FROM store s
JOIN address a USING(address_id)
JOIN city c USING(city_id)
JOIN country co USING (country_id);


-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS "Revenue"
FROM category c
JOIN film_category fc USING(category_id)
JOIN inventory i USING(film_id)
JOIN rental r USING(inventory_id)
JOIN payment p USING(rental_id)
GROUP BY c.name
ORDER BY "Revenue" DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS top5_genres;
CREATE VIEW top5_genres AS
SELECT c.name, SUM(p.amount) AS "Revenue"
FROM category c
JOIN film_category fc USING(category_id)
JOIN inventory i USING(film_id)
JOIN rental r USING(inventory_id)
JOIN payment p USING(rental_id)
GROUP BY c.name
ORDER BY "Revenue" DESC
LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_genres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5_genres;

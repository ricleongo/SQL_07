use sakila;

DESCRIBE actor;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(ucase(first_name), ' ', ucase(last_name)) 'full name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id 'actor ID', first_name 'first name', last_name 'last name' FROM actor WHERE lcase(first_name) like '%joe%';
 
 -- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id 'actor ID', first_name 'first name', last_name 'last name' FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id 'actor ID', first_name 'first name', last_name 'last name'  FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id 'country ID', country, last_update 'last update' FROM country WHERE country in('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD COLUMN description BLOB after  last_name;
DESCRIBE actor;
SELECT actor_id 'actor ID', first_name 'first name', last_name 'last name', description FROM actor LIMIT 5;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;
DESCRIBE actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) FROM actor GROUP BY last_name HAVING count(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT * FROM actor WHERE last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';
SELECT * FROM actor WHERE last_name = 'WILLIAMS';  

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address FROM staff s INNER JOIN address a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) 
	FROM staff s INNER JOIN payment p ON s.staff_id = p.staff_id 
	WHERE p.payment_date BETWEEN '2005-08-01' AND '2005-08-20'
	GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, count(fa.actor_id) 
	FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id
    GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(i.film_id)
	FROM film f INNER JOIN inventory i ON f.film_id = i.film_id
	WHERE title = 'Hunchback Impossible'
    GROUP BY i.film_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount) 
	FROM payment p INNER JOIN customer c ON p.customer_id = c.customer_id
    GROUP BY c.customer_id
    ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title  FROM film 
	WHERE (substring(title,1,1) = 'Q' OR substring(title,1,1) = 'K' )
	AND language_id IN(SELECT language_id FROM language  WHERE lcase(name) = 'english');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT a.actor_id, a.first_name, a.last_name 
	FROM actor a INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
    WHERE fa.film_id IN(SELECT film_id FROM film WHERE title = 'Alone Trip');

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email 
	FROM customer c 
		INNER JOIN store s ON c.store_id = s.store_id
		INNER JOIN address a ON s.address_id = a.address_id
		INNER JOIN city ci ON a.city_id = ci.city_id
		INNER JOIN country co ON ci.country_id = co.country_id
    WHERE lcase(co.country) = 'canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, c.name 
	FROM film f 
		INNER JOIN film_category fc ON f.film_id = fc.film_id
		INNER JOIN category c ON fc.category_id = c.category_id
	WHERE lcase(c.name) = 'family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, count(r.rental_id)
	FROM rental r 
		INNER JOIN inventory i ON r.inventory_id = i.inventory_id
        INNER JOIN film f ON i.film_id = f.film_id
	GROUP BY f.title
    HAVING count(r.rental_id) >= 30
    ORDER BY  count(r.rental_id) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id 'store ID', sum(p.amount) 'amount in dollars'
	FROM payment p 
		INNER JOIN rental r ON p.rental_id = r.rental_id
        INNER JOIN inventory i ON r.inventory_id = i.inventory_id
        INNER JOIN store s ON i.store_id = s.store_id
	GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id 'store ID', c.city, co.country
	FROM store s
		INNER JOIN address a ON s.address_id = a.address_id
        INNER JOIN city c ON a.city_id = c.city_id
        INNER JOIN country co ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT sum(p.amount) 'amount', c.name
	FROM payment p
		INNER JOIN rental r ON p.rental_id = r.rental_id
        INNER JOIN inventory i ON r.inventory_id = i.inventory_id
        INNER JOIN film_category fc ON i.film_id = fc.film_id
        INNER JOIN category c ON fc.category_id = c.category_id
	GROUP BY c.name
	ORDER BY sum(p.amount) DESC
    LIMIT 5;
        
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `top_five_genres` AS
	SELECT sum(p.amount) 'amount', c.name
		FROM payment p
			INNER JOIN rental r ON p.rental_id = r.rental_id
			INNER JOIN inventory i ON r.inventory_id = i.inventory_id
			INNER JOIN film_category fc ON i.film_id = fc.film_id
			INNER JOIN category c ON fc.category_id = c.category_id
		GROUP BY c.name
		ORDER BY sum(p.amount) DESC
		LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
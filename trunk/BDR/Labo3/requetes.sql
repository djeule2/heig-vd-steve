1)
SELECT 	title, release_year
FROM		film
WHERE		rating = 'G' AND length > 100 AND replacement_cost = 29.99;

2)
SELECT first_name, last_name
FROM customer
WHERE first_name = 'TRACY'
AND store_id =1
ORDER BY customer.customer_id DESC

3)
SELECT film_id, title 
FROM film
where length<55
order by film_id

4)
SELECT DISTINCT film.film_id, film.title, language.name AS langue
FROM film
INNER JOIN language ON film.language_id = language.language_id
INNER JOIN film_category ON film_category.film_id = film.film_id
INNER JOIN category ON category.category_id = film_category.category_id
INNER JOIN film_actor ON film.film_id = film_actor.film_id
INNER JOIN actor ON actor.actor_id = film_actor.actor_id
WHERE category.name = 'Sci-Fi'
AND actor.first_name
IN ( 
'ALAN', 'BEN')
ORDER BY film.film_id DESC 


5)
SELECT first_name AS prenom, last_name AS nom
FROM customer
JOIN address ON address.address_id = customer.address_id
WHERE city_id =321
AND store_id =2
AND active =1
ORDER BY nom

6)

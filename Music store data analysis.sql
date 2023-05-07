/* Q1:- Who is the senior most employee based on job title?*/

SELECT first_name, title
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Q2:- Which countries have the most Invoices?*/

SELECT billing_country,COUNT(*) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

/* Q3:- What are top 3 values of total invoice?*/

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Q4:- Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/

SELECT billing_city as city , SUM(total) as invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

/* Q4:- Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as invoice_total
FROM customer as c
INNER JOIN
invoice as i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY invoice_total DESC
LIMIT 1;

/* Q5:- Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A*/

SELECT  DISTINCT(c.email), c.first_name, c.last_name
FROM customer as c 
JOIN invoice as i 
ON c.customer_id = i.customer_id
JOIN invoice_line as il
ON i.invoice_id = il.invoice_id
WHERE il.track_id IN (SELECT t.track_id 
	   FROM track as t, genre as g 
	   WHERE t.genre_id = g.genre_id
	  AND g.name = 'Rock')
ORDER BY c.email ASC;

/* Q6:-  Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/

SELECT a.artist_id, a.name, COUNT(t.track_id) AS track_count
FROM artist as a
JOIN album as b
ON a.artist_id = b.artist_id
JOIN track as t
ON t.album_id = b.album_id
WHERE t.genre_id IN (SELECT genre_id
	  FROM genre
	  WHERE name = 'Rock')
GROUP BY a.artist_id
ORDER BY track_count DESC
LIMIT 10;

/* Q7:- Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first*/

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

/* Q8:- Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

WITH cte1 as (
	SELECT a.artist_id , a.name as artist_name, SUM(il.unit_price*il.quantity) as total_sales 
	FROM artist as a
	JOIN album as al
	ON a.artist_id = al.artist_id
	JOIN track as t
	ON al.album_id = t.album_id
	JOIN invoice_line as il
	ON t.track_id = il.track_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)	
SELECT c.customer_id, c.first_name, c.last_name , cte.artist_name, 
		SUM(il.unit_price*il.quantity) as money_spent
FROM customer as c
JOIN invoice as i
ON c.customer_id = i.customer_id
JOIN invoice_line as il
ON i.invoice_id = il.invoice_id
JOIN track as t
ON il.track_id = t.track_id
JOIN album as a
ON t.album_id = a.album_id
JOIN cte1 as cte
ON a.artist_id = cte.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q9:- We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query that returns 
each country along with the top Genre. For countries where the maximum number of purchases is
shared return all Genres*/

With popular_genre as (
	SELECT COUNT(il.quantity) as purchase , c.country, g.name, g.genre_id,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity)DESC) AS row_num
	FROM customer as c
	JOIN invoice as i
	ON c.customer_id = i.customer_id
	JOIN invoice_line as il
	ON i.invoice_id = il.invoice_id
	JOIN track as t
	ON il.track_id = t.track_id
	JOIN genre as g
	ON t.genre_id = g.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE row_num <=1;

/* Q10:- Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how much they 
spent. For countries where the top amount spent is shared, provide all customers who spent 
this amount*/

WITH Cte1 as (
	SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total),
	ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total)DESC) AS row_num
	FROM invoice as i
	JOIN customer as c
	ON i.customer_id = c.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC , 5 DESC
	)
SELECT * FROM cte1 where row_num <=1;
	


















-- SQL Project--> " MUSIC STORE DATA ANALYSIS "

-- NOTE--> The following questions will help the music store analyze its business growth and expand.

create database music;
use music;

-- Question Set 1 - Easy
-- 1. Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;


-- 2. Which countries have the most Invoices?
select count(*) as most_invoices, billing_country 
from invoice
group by billing_country
order by most_invoices desc;


-- 3. What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, sum(total) as city_revenue from invoice
group by billing_city
order by city_revenue desc
limit 1;


-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select concat(first_name,' ',last_name) as cust_name, c.customer_id, sum(total) 
from customer c 
join invoice i on c.customer_id=i.customer_id 
group by c.customer_id, cust_name
order by sum(total) desc
limit 1;


-- Question Set 2 – Moderate
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select c.email, c.first_name, c.last_name
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.name='rock';


select c.email, c.first_name, c.last_name
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
where track_id in ( select track_id from track t join genre g on t.genre_id=g.genre_id
					where g.name like 'Rock')
order by email;

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

select ar.artist_id, ar.name as artist_name, count(track_id) as number_of_songs 
from track t
join album2 al on t.album_id=al.album_id
join artist ar on al.artist_id=ar.artist_id
where t.genre_id=(select genre_id from genre where name like 'Rock')
group by 1,2
order by number_of_songs desc
limit 10;



-- 3. Return all the track names that have a song length longer than average song length. Return the Name and Milliseconds for each track. Order by song length with the longest songs listed first
select name, milliseconds from track
where milliseconds>(select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;


-- Question Set 3 – Advance
-- 1. Find how much amount spent by each customer on all artists? Write a query to return customer name, artist name and total spent

select concat(c.first_name,' ',c.last_name) as cust_name,sum(il.unit_price*il.quantity) as total_sales, a.name as artist_name
from customer c join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join album2 al on t.album_id=al.album_id
join artist a on al.artist_id=a.artist_id
group by cust_name, a.name
order by total_sales desc;



-- 2. Find the amount spend by each customer on the best selling artist.

with best_selling_artist as (
select ar.artist_id as artist_id, ar.name as artist_name, sum(il.unit_price* il.quantity) as total_sales
from invoice_line il
join track t on il.track_id=t.track_id
join album2 al on t.album_id=al.album_id
join artist ar on al.artist_id=ar.artist_id
group by 1,2
order by 3 desc
limit 1 )

select c.customer_id, concat(c.first_name,' ',c.last_name) as cust_name, bsa.artist_name,sum(il.unit_price* il.quantity) as total_sale
from invoice i join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=t.album_id
join album2 al on al.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=al.artist_id
group by 1,2,3
order by 4 desc;


-- 2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

with popular_genre as (
			select count(il.quantity) as purchases, c.country, g.name, g.genre_id,
            row_number() over(partition by c.country order by count(il.quantity) desc) as rownumber
            from invoice_line il
            join invoice i on i.invoice_id=il.invoice_id
            join customer c on c.customer_id=i.customer_id
            join track t on t.track_id=il.track_id
            join genre g on g.genre_id=t.genre_id
            group by 2,3,4
            order by 2 asc, 1 desc
            )
select * from popular_genre where rownumber<=1;


-- 3. Write query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.

with highest_spender as (
				select i.billing_country, c.customer_id, round(sum(i.total),2) as amount_spent,
                row_number() over(partition by i.billing_country order by sum(i.total) desc) as rownumber
                from customer c 
                join invoice i on c.customer_id=i.customer_id
                group by 1,2
                order by 1 asc, 3 desc
                )
select * from highest_spender where rownumber=1;



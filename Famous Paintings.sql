-- DATA EXPLORATION

USE FamousPaintings


-- Total Artists
SELECT COUNT(artist_id) artist_count
FROM artist


-- Total Museum
SELECT COUNT(museum_id) museum_count
FROM museum

-- Total Paintings
SELECT COUNT(name) painting_count
FROM work


-- Painting Subject Count
SELECT subject, COUNT(subject) subject_count
FROM subject
GROUP BY subject
ORDER BY subject_count DESC


-- Fetch all the paintings which are not displayed on any museums? 
SELECT work.name
FROM work
WHERE museum_id IS NULL


-- Are there museuems without any paintings?
SELECT museum.name
FROM museum
	WHERE NOT EXISTS (SELECT * FROM work
					 WHERE work.museum_id=museum.museum_id)


-- How many paintings have an asking price of more than their regular price?  
SELECT COUNT(work.name)
FROM work
LEFT JOIN product_size
	ON work.work_id = product_size.work_id
WHERE sale_price > regular_price


-- Identify the paintings whose asking price is less than 50% of its regular price
SELECT work.name, sale_price, regular_price
FROM work
LEFT JOIN product_size
	ON work.work_id = product_size.work_id
WHERE sale_price < (regular_price * 0.5)


-- Which canva size costs the most?
SELECT TOP 1 label, sale_price 
FROM canvas_size
JOIN product_size
	ON canvas_size.size_id = product_size.size_id
ORDER BY regular_price DESC


-- Identify the museums with invalid city information in the given dataset
SELECT * FROM museum
WHERE city = '^[0-9]'


-- Museum_Hours table has 1 invalid entry. Identify it and remove it.
SELECT day, COUNT(day)
FROM museum_hours
GROUP BY day

DELETE FROM museum_hours WHERE day = 'Thusday'

-- Fetch the top 10 most famous painting subject
SELECT TOP 10 subject, COUNT(subject) subject_count
FROM subject
GROUP BY subject
ORDER BY subject_count DESC

-- Identify the museums which are open on both Sunday and Monday. Display museum name, city.
SELECT DISTINCT name, city
FROM museum_hours mh1
LEFT JOIN museum
	ON mh1.museum_id = museum.museum_id
WHERE day = 'Sunday' AND EXISTS 
								(SELECT day FROM museum_hours mh2
								WHERE mh1.museum_id = mh2.museum_id
								AND mh2.day = 'Monday')


-- How many museums are open every single day?
SELECT COUNT(*)
	FROM (SELECT museum_id, COUNT(1)
		  FROM museum_hours
		  GROUP BY museum_id
		  HAVING COUNT(1) = 7)

-- Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
SELECT TOP 5 museum.name, COUNT(work_id) painting_count
FROM museum
JOIN work
	ON museum.museum_id = work.museum_id
GROUP BY museum.name
ORDER BY painting_count DESC


-- Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
SELECT TOP 5 artist.full_name, COUNT(work_id) painting_count
FROM work
JOIN artist
	ON work.artist_id = artist.artist_id
GROUP BY artist.full_name
ORDER BY painting_count DESC


-- Display the 3 least popular canva sizes
SELECT TOP 11 label, COUNT(label) label_count
FROM canvas_size
JOIN product_size
	ON canvas_size.size_id = product_size.size_id
GROUP BY label
ORDER BY label_count ASC


-- Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
SELECT time_open, time_close
FROM museum_hours


SELECT TOP 1 DATEDIFF(hour, time_open, time_close) hours_open,  museum.name museum_name, museum.state museum_state, day
FROM museum_hours
JOIN museum
	ON museum_hours.museum_id = museum.museum_id
ORDER BY hours_open DESC


-- Which museum has the most no of most popular painting style?
SELECT TOP 1 museum.name, style, COUNT(work.style) painting_count
FROM museum
JOIN work
	ON museum.museum_id = work.museum_id
GROUP BY museum.name, style
ORDER BY painting_count DESC

--using cte
WITH style_type AS 
				(SELECT style
				,RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
				FROM work
				GROUP BY style),
	cte AS
		(SELECT work.museum_id, museum.name museum_name, style_type.style, COUNT(1) painting_count
		,RANK() OVER(ORDER BY COUNT(1) desc) AS rnk
		FROM work
		JOIN museum
			ON museum.museum_id = work.museum_id
		JOIN style_type
			ON style_type.style = work.style
		WHERE museum.museum_id IS NOT NULL
		AND style_type.rnk = 1
		GROUP BY work.museum_id, museum.name, style_type.style)
	SELECT TOP 1 museum_name, style, painting_count
	FROM cte
	ORDER BY painting_count DESC;


-- Identify the artists whose paintings are displayed in multiple countries
WITH cte AS
		(SELECT DISTINCT artist.full_name as artist
		--, work.name as painting, museum.name as museum
		, museum.country
		from work 
		join artist on artist.artist_id=work.artist_id
		join museum on museum.museum_id=work.museum_id)
	SELECT artist,count(1) no_of_countries
	FROM cte
	GROUP BY artist
	HAVING COUNT(1)>1
	ORDER BY 2 DESC;


-- Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label
-- Most Expensive
SELECT TOP 5 artist.full_name, canvas_size.label, work.name painting_name, product_size.sale_price, museum.name museum_name, museum.city
FROM work 
JOIN product_size
	ON work.work_id = product_size.work_id
JOIN canvas_size
	ON product_size.size_id = canvas_size.size_id
JOIN museum
	ON work.museum_id = museum.museum_id
JOIN artist
	ON work.artist_id = artist.artist_id
ORDER BY sale_price DESC

-- Least Expensive
SELECT DISTINCT TOP 5 artist.full_name, canvas_size.label, work.name painting_name, product_size.sale_price, museum.name museum_name, museum.city
FROM work 
JOIN product_size
	ON work.work_id = product_size.work_id
JOIN canvas_size
	ON product_size.size_id = canvas_size.size_id
JOIN museum
	ON work.museum_id = museum.museum_id
JOIN artist
	ON work.artist_id = artist.artist_id
ORDER BY sale_price ASC



-- Which country has the 5th highest no of paintings?
--using cte
WITH cte AS 
			(SELECT country, ROW_NUMBER() OVER(ORDER BY COUNT(work.name) DESC) row_no, COUNT(work.name) painting_count
			FROM museum
			JOIN work
				ON museum.museum_id = work.museum_id
			GROUP BY country
			)
SELECT country, painting_count
FROM cte
WHERE row_no = 1


-- Which are the 3 most popular and 3 least popular painting styles?
--Most Popular
SELECT TOP 3 style, COUNT(style) style_count
FROM work
GROUP BY style
ORDER BY style_count DESC

--Least Popular
SELECT TOP 3 style, COUNT(style) style_count
FROM work
WHERE style IS NOT NULL
GROUP BY style
ORDER BY style_count ASC

-- USING CTE
WITH cte AS 
		(SELECT style, COUNT(style) as cnt
		, RANK() OVER(ORDER BY COUNT(style) DESC) rnk
		, COUNT(style) OVER() no_of_records
		FROM work
		WHERE style IS NOT NULL
		GROUP BY style)
	SELECT style
	, CASE WHEN rnk <=3 THEN 'Most Popular' ELSE 'Least Popular' END remarks 
	FROM cte
	WHERE rnk <=3
	OR rnk > no_of_records - 3;

-- Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.
SELECT TOP 1 artist.full_name, nationality, COUNT(work.style) painting_count
FROM artist
JOIN work
	ON artist.artist_id = work.artist_id
JOIN subject
	ON work.work_id = subject.work_id
JOIN museum
	ON work.museum_id = museum.museum_id
WHERE museum.country != 'USA' AND subject.subject = 'Portraits'
GROUP BY artist.full_name, nationality
HAVING COUNT(work.style) >= 1
ORDER BY painting_count DESC;
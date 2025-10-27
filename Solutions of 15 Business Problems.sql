-- Netflix Project

CREATE TABLE netflix(
		show_id	VARCHAR(10),
		type VARCHAR(20),
		title VARCHAR(150),
		director VARCHAR(208),
		casts VARCHAR(750),
		country	VARCHAR(150),
		date_added VARCHAR(20),
		release_year INT,
		rating VARCHAR(10),
		duration VARCHAR(10),
		listed_in VARCHAR(80),
		description VARCHAR(250)

);

COPY netflix
FROM 'C:\Users\Public\Documents\netflix_titles.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE netflix
ALTER COLUMN casts TYPE VARCHAR(1000);

SELECT * FROM netflix;

-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*) AS total_count
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT type, rating, total_rating
FROM (
SELECT type, rating, COUNT(rating) AS total_rating,
		DENSE_RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS ranking
FROM netflix
GROUP BY type, rating
) AS t1
WHERE ranking < 2;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE type= 'Movie'
AND release_year='2020';

-- 4. Find the top 5 countries with the most content on Netflix

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
		COUNT(*) AS total_contents
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT * FROM netflix
WHERE 
	duration = (SELECT MAX(duration) FROM netflix)
	AND 
	type= 'Movie';

-- 6. Find content added in the last 5 years

SELECT * FROM netflix
WHERE TO_DATE(date_added, 'Month DD, Year') >= (CURRENT_DATE- INTERVAL '5 Years');

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE 
	type='TV Show'
	AND
	SPLIT_PART(duration,' ', 1)::NUMERIC > 5;


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS listed_in, 
	COUNT(*) AS no_of_contents
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

/*10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	COUNT(*) AS yearly_contents,
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix 
						WHERE country ILIKE '%India%') * 100,2) AS avg_contents
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%';

-- 2ND SOLUTION FOR THIS SAME PROBLEM

SELECT 
		COALESCE(listed_in,'Grand_Total') AS listed_in,
		COUNT(*) AS total_contents
FROM netflix
WHERE listed_in ILIKE '%Documentaries%'
GROUP BY ROLLUP (listed_in)
ORDER BY 2;

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year > (EXTRACT (YEAR FROM CURRENT_DATE) - 10);


/*14. Find the top 10 actors who have appeared 
in the highest number of movies produced in India.*/

SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actors_,
	COUNT(*) AS total_contents
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*15. Categorize the content based on the presence of the keywords 
'kill' and 'violence' in the description field. Label content 
containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

WITH category_table AS (
	SELECT 
		*,
		CASE 
			WHEN description ILIKE '%kill%' OR
				description ILIKE '%violence%' THEN 'Bad Content'
			ELSE 'Good Content'
		END category
	FROM netflix
)
SELECT category, COUNT(*) AS total_contents
FROM category_table
GROUP  BY 1;
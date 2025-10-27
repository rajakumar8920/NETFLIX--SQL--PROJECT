# Netflix Movies and TV Shows Data Analysis using SQL

![](https://images.ctfassets.net/y2ske730sjqp/1aONibCke6niZhgPxuiilC/2c401b05a07288746ddf3bd3943fbc76/BrandAssets_Logos_01-Wordmark.jpg?w=940)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```sql
DROP TABLE IF EXISTS netflix;

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

ALTER TABLE netflix
ALTER COLUMN casts TYPE VARCHAR(1000);

COPY netflix
FROM 'C:\Users\Public\Documents\netflix_titles.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM netflix;
```
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT
	type,
	COUNT(*) AS total_count
FROM netflix
GROUP BY type;
```
### 2. Find the Most Common Rating for Movies and TV Shows
```sql
SELECT type, rating, total_rating
FROM (
SELECT type, rating, COUNT(rating) AS total_rating,
		DENSE_RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS ranking
FROM netflix
GROUP BY type, rating
) AS t1
WHERE ranking < 2;
```
### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM netflix
WHERE type= 'Movie'
AND release_year='2020';
```
### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
	COUNT(*) AS total_contents
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
### 5. Identify the Longest Movie

```sql
SELECT * FROM netflix
WHERE 
	duration = (SELECT MAX(duration) FROM netflix)
	AND 
	type= 'Movie';
```
### 6. Find Content Added in the Last 5 Years

```sql
SELECT * FROM netflix
WHERE TO_DATE(date_added, 'Month DD, Year') >= (CURRENT_DATE- INTERVAL '5 Years');
```
### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```
### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * FROM netflix
WHERE 
	type='TV Show'
	AND
	SPLIT_PART(duration,' ', 1)::NUMERIC > 5;
```
### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS listed_in, 
	COUNT(*) AS no_of_contents
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;
```
### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```
### 11. List All Movies that are Documentaries
```sql
SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%';
```
### 12. Find All Content Without a Director
```sql
SELECT * FROM netflix
WHERE director IS NULL;
```
### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year > (EXTRACT (YEAR FROM CURRENT_DATE) - 10);
```
### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```
### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
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
```
## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles.

Thank you for exploring this project! Feedback and suggestions for improvement are always welcome.



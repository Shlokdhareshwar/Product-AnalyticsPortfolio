drop database if exists netflix;
create database netflix;
use netflix;
set global local_infile=1;
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'
INTO TABLE netflix.netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from netflix;



-- 1. Count the number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;



-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rating_rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rating_rank = 1;



-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;



-- 4. Find the top 5 countries with the most content on Netflix

WITH RECURSIVE
  split_countries AS (
    SELECT
      SUBSTRING_INDEX(country, ',', 1) AS country_name,
      SUBSTRING_INDEX(country, ',', - (CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')))) AS remaining_countries,
      1 AS position
    FROM netflix
    WHERE country IS NOT NULL AND country != ''
    UNION ALL
    SELECT
      SUBSTRING_INDEX(remaining_countries, ',', 1) AS country_name,
      SUBSTRING_INDEX(remaining_countries, ',', - (CHAR_LENGTH(remaining_countries) - CHAR_LENGTH(REPLACE(remaining_countries, ',', '')))) AS remaining_countries,
      position + 1
    FROM split_countries
    WHERE remaining_countries != ''
  ),
  flattened_countries AS (
    SELECT
      TRIM(country_name) AS country
    FROM split_countries
  )
SELECT
  country,
  COUNT(*) AS total_content
FROM flattened_countries
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;



-- 5. Identify the longest movie

SELECT
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;



-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %e, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

WITH RECURSIVE
  split_directors AS (
    SELECT
      show_id, -- Keep an identifier for the original row
      TRIM(SUBSTRING_INDEX(director, ',', 1)) AS director_name,
      SUBSTRING_INDEX(director, ',', - (CHAR_LENGTH(director) - CHAR_LENGTH(REPLACE(director, ',', '')))) AS remaining_directors
    FROM netflix
    WHERE director IS NOT NULL AND director != ''
    UNION ALL
    SELECT
      show_id,
      TRIM(SUBSTRING_INDEX(remaining_directors, ',', 1)),
      SUBSTRING_INDEX(remaining_directors, ',', - (CHAR_LENGTH(remaining_directors) - CHAR_LENGTH(REPLACE(remaining_directors, ',', ''))))
    FROM split_directors
    WHERE remaining_directors != ''
  )
SELECT
  *
FROM netflix
WHERE show_id IN (
    SELECT show_id
    FROM split_directors
    WHERE director_name = 'Rajiv Chilaka'
);



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 2) AS UNSIGNED)>2;
  
  
  
-- 9. Count the number of content items in each genre

WITH RECURSIVE
  split_genres AS (
    SELECT
      TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre_name,
      SUBSTRING_INDEX(listed_in, ',', - (CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')))) AS remaining_genres
    FROM netflix
    WHERE listed_in IS NOT NULL AND listed_in != ''
    UNION ALL
    SELECT
      TRIM(SUBSTRING_INDEX(remaining_genres, ',', 1)),
      SUBSTRING_INDEX(remaining_genres, ',', - (CHAR_LENGTH(remaining_genres) - CHAR_LENGTH(REPLACE(remaining_genres, ',', ''))))
    FROM split_genres
    WHERE remaining_genres != ''
  )
SELECT
  genre_name AS genre,
  COUNT(*) AS total_content
FROM split_genres
GROUP BY genre_name
ORDER BY total_content DESC;



-- 10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release!

SELECT
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;



-- 11. List all movies that are documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';



-- 12. Find all content without a director

SELECT 
count(*)
FROM netflix
WHERE director= '';

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > YEAR(CURDATE()) - 10;



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

WITH RECURSIVE
  split_casts AS (
    SELECT
      show_id,
      TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor_name,
      SUBSTRING_INDEX(casts, ',', - (CHAR_LENGTH(casts) - CHAR_LENGTH(REPLACE(casts, ',', '')))) AS remaining_casts
    FROM netflix
    WHERE country = 'India' AND casts IS NOT NULL AND casts != ''
    UNION ALL
    SELECT
      show_id,
      TRIM(SUBSTRING_INDEX(remaining_casts, ',', 1)),
      SUBSTRING_INDEX(remaining_casts, ',', - (CHAR_LENGTH(remaining_casts) - CHAR_LENGTH(REPLACE(remaining_casts, ',', ''))))
    FROM split_casts
    WHERE remaining_casts != ''
  )
SELECT
  actor_name AS actor,
  COUNT(*) AS total_content
FROM split_casts
GROUP BY actor_name
ORDER BY total_content DESC
LIMIT 100;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;







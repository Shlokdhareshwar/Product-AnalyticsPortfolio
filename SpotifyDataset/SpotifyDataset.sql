drop database if exists spotify;
create database spotify;
use spotify;
set global local_infile=1;
drop table if exists spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min DOUBLE,
    title VARCHAR(255),
    channel VARCHAR(255),
    views BIGINT,
    likes BIGINT,
    comments BIGINT,
    licensed VARCHAR(5),
    official_video VARCHAR(5),
    stream BIGINT,
    energy_iveness FLOAT,
    most_playedon VARCHAR(50)
);
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_dataset.csv'
INTO TABLE spotify.spotify
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from spotify;


-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

select track from spotify where Stream>1000000000;

-- 2. List all albums along with their respective artists.

select distinct Artist, Album from spotify;


-- 3. Get the total number of comments for tracks where `licensed = TRUE`.

select sum(Comments) from spotify where Licensed= 'TRUE';

-- 4. Find all tracks that belong to the album type `single`.

select Track from spotify where Album_type='single';

-- 5. Count the total number of tracks by each artist.

select count(Track), Artist from spotify group by Artist;

-- 6. Calculate the average danceability of tracks in each album.

select album, avg(Danceability) as avg from spotify group by 1;

-- 7. Find the top 5 tracks with the highest energy values.

select track, energy from spotify order by 2 desc limit 5;

-- 8. List all tracks along with their views and likes where `official_video = TRUE`

	select track, views, likes from spotify where official_video='TRUE';
    
-- 9. For each album, calculate the total views of all associated tracks.

select Album, track, sum(views) from spotify group by 1,2;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.

select track, album from spotify where trim(most_playedon)= 'Spotify';
SELECT
  HEX(most_playedon)
FROM
  spotify
WHERE
  most_playedon LIKE '%Spotify%';
  
-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranked_tracks AS (
  SELECT
    artist,
    track,
    SUM(views) AS total_views,
    DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS track_rank
  FROM
    spotify
  GROUP BY
    artist,
    track
)
SELECT
  artist,
  track,
  total_views
FROM
  ranked_tracks
WHERE
  track_rank <= 3
ORDER BY
artist,
  total_views DESC;

-- 12. Write a query to find tracks where the liveness score is above the average.

select avg(liveness) from spotify;
select track, liveness from spotify where liveness> (select(avg(liveness))from spotify);

-- 13. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**

with cte as( select album, max(energy) as maxenergy, min(energy) as minenergy from spotify group by 1)
select album, maxenergy-minenergy as diff from cte order by 2;



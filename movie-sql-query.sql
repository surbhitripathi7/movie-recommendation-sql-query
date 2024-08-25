SELECT * FROM movie_recommendation.movies;

-- Easy Level
-- List all movies and their genres.

SELECT movieId, title, genres
FROM movie_recommendation.movies;


-- Count the number of movies in each genre.

SELECT genres, COUNT(*) AS number_of_movies
FROM movie_recommendation.movies
GROUP BY genres;

-- Get the average rating of all movies.

SELECT round(AVG(rating) ,1) AS average_rating
FROM movie_recommendation.ratings;

-- intermediate level
-- Find the average rating for each movie.

SELECT movie_recommendation.movies.movieId, movie_recommendation.movies.title, AVG(movie_recommendation.ratings.rating) AS average_rating
FROM movie_recommendation.movies
JOIN movie_recommendation.ratings ON movie_recommendation.movies.movieId = movie_recommendation.ratings.movieId
GROUP BY movie_recommendation.movies.movieId, movie_recommendation.movies.title;

-- List the top 5 movies with the highest average rating.

SELECT movie_recommendation.movies.movieId, movie_recommendation.movies.title, AVG(ratings.rating) AS average_rating
FROM movie_recommendation.movies
JOIN movie_recommendation.ratings ON movie_recommendation.movies.movieId = movie_recommendation.ratings.movieId
GROUP BY movie_recommendation.movies.movieId, movie_recommendation.movies.title
ORDER BY average_rating DESC
LIMIT 5;

-- Find the number of ratings given by each user.

SELECT movie_recommendation.ratings.userId, COUNT(*) AS number_of_ratings
FROM movie_recommendation.ratings
GROUP BY movie_recommendation.ratings.userId;

-- Advanced Level
-- Identify the highest-rated movie for each genre.

WITH GenreRatings AS (
    SELECT
        movies.genres,
        movies.title,
        AVG(ratings.rating) AS average_rating
    FROM movie_recommendation.movies AS movies
    JOIN movie_recommendation.ratings AS ratings
    ON movies.movieId = ratings.movieId
    GROUP BY movies.genres, movies.title
)
SELECT
    gr.genres,
    gr.title,
    gr.average_rating
FROM GenreRatings AS gr
JOIN (
    SELECT
        genres,
        MAX(average_rating) AS max_rating
    FROM GenreRatings
    GROUP BY genres
) AS max_ratings
ON gr.genres = max_ratings.genres AND gr.average_rating = max_ratings.max_rating;

-- Trend Analysis of Ratings Over Time for Top Genres. 

WITH GenreCounts AS (
    SELECT
        movie_recommendation.movies.genres AS genre,
        COUNT(DISTINCT movie_recommendation.movies.movieId) AS movie_count
    FROM movie_recommendation.movies AS movies
    GROUP BY movie_recommendation.movies.genres
),
TopGenres AS (
    SELECT genre
    FROM GenreCounts
    ORDER BY movie_count DESC
    LIMIT 3
),
MonthlyRatings AS (
    SELECT
        DATE_FORMAT(movie_recommendation.ratings.timestamp, '%Y-%m-01') AS month,  -- Format to the first day of the month
        movie_recommendation.movies.genres AS genre,
        AVG(movie_recommendation.ratings.rating) AS average_rating
    FROM movie_recommendation.ratings AS ratings
    JOIN movie_recommendation.movies AS movies
    ON movie_recommendation.ratings.movieId = movie_recommendation.movies.movieId
    WHERE movie_recommendation.movies.genres IN (SELECT genre FROM TopGenres)
    GROUP BY month, movie_recommendation.movies.genres
)
SELECT
    month,
    genre,
    average_rating
FROM MonthlyRatings
ORDER BY month, genre;







/*
Project: Rental Demand Analysis & Automated Genre Reporting
Author: Shanna Siebert
Tools: PostgreSQL, PL/pgSQL

Purpose:
This script builds a reporting workflow to analyze movie rental demand by
store location and genre. It creates a detailed rental table, a summarized
genre-by-store reporting table, and automation logic to refresh the summary
data when new rental records are added.

Business Question:
Which movie genres generate the highest rental demand at each store location?
*/


-- ============================================================
-- 1. CLEAN UP EXISTING OBJECTS
-- ============================================================

DROP TRIGGER IF EXISTS trg_refresh_genre_summary ON rental_genre_detail;
DROP FUNCTION IF EXISTS refresh_genre_summary();
DROP FUNCTION IF EXISTS get_rental_month(timestamp without time zone);
DROP FUNCTION IF EXISTS get_rental_year(timestamp without time zone);
DROP PROCEDURE IF EXISTS refresh_monthly_genre_report();

DROP TABLE IF EXISTS genre_by_store_summary;
DROP TABLE IF EXISTS rental_genre_detail;


-- ============================================================
-- 2. DATE TRANSFORMATION FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION get_rental_month(rental_date timestamp without time zone)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXTRACT(MONTH FROM rental_date);
END;
$$;


CREATE OR REPLACE FUNCTION get_rental_year(rental_date timestamp without time zone)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM rental_date);
END;
$$;


-- ============================================================
-- 3. CREATE DETAIL REPORTING TABLE
-- ============================================================

CREATE TABLE rental_genre_detail AS
SELECT
    r.rental_id,
    r.rental_date,
    get_rental_month(r.rental_date) AS rental_month,
    get_rental_year(r.rental_date) AS rental_year,
    i.inventory_id,
    i.store_id,
    f.film_id,
    f.title,
    c.category_id,
    c.name AS genre
FROM rental AS r
INNER JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
    ON i.film_id = f.film_id
INNER JOIN film_category AS fc
    ON f.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id;


-- ============================================================
-- 4. CREATE SUMMARY REPORTING TABLE
-- ============================================================

CREATE TABLE genre_by_store_summary AS
SELECT
    store_id,
    genre,
    COUNT(*) AS rental_count
FROM rental_genre_detail
GROUP BY store_id, genre
ORDER BY store_id, rental_count DESC;


-- ============================================================
-- 5. CREATE SUMMARY REFRESH FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION refresh_genre_summary()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE TABLE genre_by_store_summary;

    INSERT INTO genre_by_store_summary
    SELECT
        store_id,
        genre,
        COUNT(*) AS rental_count
    FROM rental_genre_detail
    GROUP BY store_id, genre
    ORDER BY store_id, rental_count DESC;

    RETURN NEW;
END;
$$;


-- ============================================================
-- 6. CREATE TRIGGER TO UPDATE SUMMARY TABLE
-- ============================================================

CREATE TRIGGER trg_refresh_genre_summary
AFTER INSERT ON rental_genre_detail
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_genre_summary();


-- ============================================================
-- 7. CREATE MONTHLY REFRESH PROCEDURE
-- ============================================================

CREATE OR REPLACE PROCEDURE refresh_monthly_genre_report()
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS genre_by_store_summary;
    DROP TABLE IF EXISTS rental_genre_detail;

    CREATE TABLE rental_genre_detail AS
    SELECT
        r.rental_id,
        r.rental_date,
        get_rental_month(r.rental_date) AS rental_month,
        get_rental_year(r.rental_date) AS rental_year,
        i.inventory_id,
        i.store_id,
        f.film_id,
        f.title,
        c.category_id,
        c.name AS genre
    FROM rental AS r
    INNER JOIN inventory AS i
        ON r.inventory_id = i.inventory_id
    INNER JOIN film AS f
        ON i.film_id = f.film_id
    INNER JOIN film_category AS fc
        ON f.film_id = fc.film_id
    INNER JOIN category AS c
        ON fc.category_id = c.category_id;

    CREATE TABLE genre_by_store_summary AS
    SELECT
        store_id,
        genre,
        COUNT(*) AS rental_count
    FROM rental_genre_detail
    GROUP BY store_id, genre
    ORDER BY store_id, rental_count DESC;
END;
$$;


-- ============================================================
-- 8. VALIDATION QUERIES
-- ============================================================

-- View sample detail records
SELECT *
FROM rental_genre_detail
LIMIT 10;


-- View genre demand by store
SELECT *
FROM genre_by_store_summary;


-- Identify the highest-rented genre for each store
SELECT
    store_id,
    genre,
    rental_count
FROM (
    SELECT
        store_id,
        genre,
        rental_count,
        RANK() OVER (
            PARTITION BY store_id
            ORDER BY rental_count DESC
        ) AS genre_rank
    FROM genre_by_store_summary
) ranked_genres
WHERE genre_rank = 1;


-- Monthly rental volume by store and genre
SELECT
    store_id,
    rental_year,
    rental_month,
    genre,
    COUNT(*) AS monthly_rental_count
FROM rental_genre_detail
GROUP BY
    store_id,
    rental_year,
    rental_month,
    genre
ORDER BY
    store_id,
    rental_year,
    rental_month,
    monthly_rental_count DESC;
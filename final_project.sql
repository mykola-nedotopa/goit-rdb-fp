-- =====================================================
-- Final Project
-- Relational Databases: Concepts and Techniques
-- =====================================================


-- =====================================================
-- Task 1. Create schema and check imported data
-- =====================================================

CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

-- The infectious_cases table is imported
-- using Table Data Import Wizard.

SELECT COUNT(*) AS imported_rows_count
FROM infectious_cases;

SELECT *
FROM infectious_cases
LIMIT 10;


-- =====================================================
-- Task 2. Normalize infectious_cases to 3NF
-- =====================================================

DROP TABLE IF EXISTS infectious_cases_normalized;
DROP TABLE IF EXISTS entities;

CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL,
    Code VARCHAR(10),
    UNIQUE (Entity, Code)
);

CREATE TABLE infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    Year INT,
    Number_yaws TEXT,
    polio_cases TEXT,
    cases_guinea_worm TEXT,
    Number_rabies TEXT,
    Number_malaria TEXT,
    Number_hiv TEXT,
    Number_tuberculosis TEXT,
    Number_smallpox TEXT,
    Number_cholera_cases TEXT,
    FOREIGN KEY (entity_id)
        REFERENCES entities(id)
);

INSERT INTO entities (
    Entity,
    Code
)
SELECT DISTINCT
    Entity,
    Code
FROM infectious_cases;

INSERT INTO infectious_cases_normalized (
    entity_id,
    Year,
    Number_yaws,
    polio_cases,
    cases_guinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
SELECT
    e.id,
    i.Year,
    i.Number_yaws,
    i.polio_cases,
    i.cases_guinea_worm,
    i.Number_rabies,
    i.Number_malaria,
    i.Number_hiv,
    i.Number_tuberculosis,
    i.Number_smallpox,
    i.Number_cholera_cases
FROM infectious_cases AS i
JOIN entities AS e
    ON e.Entity = i.Entity
    AND e.Code <=> i.Code;

SELECT
    (SELECT COUNT(*)
     FROM entities) AS entities_count,
    (SELECT COUNT(*)
     FROM infectious_cases_normalized) AS normalized_rows_count;


-- =====================================================
-- Task 3. Analyze Number_rabies
-- =====================================================

SELECT
    e.Entity,
    e.Code,
    AVG(CAST(ic.Number_rabies AS DECIMAL(20, 10))) AS avg_rabies,
    MIN(CAST(ic.Number_rabies AS DECIMAL(20, 10))) AS min_rabies,
    MAX(CAST(ic.Number_rabies AS DECIMAL(20, 10))) AS max_rabies,
    SUM(CAST(ic.Number_rabies AS DECIMAL(20, 10))) AS sum_rabies
FROM infectious_cases_normalized AS ic
JOIN entities AS e
    ON e.id = ic.entity_id
WHERE ic.Number_rabies <> ''
GROUP BY
    e.id,
    e.Entity,
    e.Code
ORDER BY
    avg_rabies DESC
LIMIT 10;


-- =====================================================
-- Task 4. Calculate the difference in years
-- =====================================================

SELECT
    Year,
    STR_TO_DATE(
        CONCAT(Year, '-01-01'),
        '%Y-%m-%d'
    ) AS year_start_date,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(
            CONCAT(Year, '-01-01'),
            '%Y-%m-%d'
        ),
        CURDATE()
    ) AS year_difference
FROM infectious_cases_normalized
LIMIT 10;


-- =====================================================
-- Task 5. Create and use a custom function
-- =====================================================

DROP FUNCTION IF EXISTS year_difference_from_year;

CREATE FUNCTION year_difference_from_year(input_year INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
RETURN TIMESTAMPDIFF(
    YEAR,
    STR_TO_DATE(
        CONCAT(input_year, '-01-01'),
        '%Y-%m-%d'
    ),
    CURDATE()
);

SELECT
    Year,
    year_difference_from_year(Year) AS year_difference
FROM infectious_cases_normalized
LIMIT 10;

SELECT
    1996 AS input_year,
    year_difference_from_year(1996) AS year_difference;
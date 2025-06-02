


Phase 1: Data Cleaning and Preparation
Step 1: Create a Safe Workspace (Schema & Staging Table)
Created a dedicated schema world_layoffs to organize the data.

Imported raw data into the table layoffs.

Created a staging table layoffs_staging as a safe workspace to clean data without modifying the original.

CREATE SCHEMA IF NOT EXISTS world_layoffs;
USE world_layoffs;

CREATE TABLE IF NOT EXISTS layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

Why?
Working on a copy ensures the original data remains intact. Any mistakes during cleaning won’t impact raw data.


Step 2: Remove Duplicates
Used ROW_NUMBER() window function over all columns to detect exact duplicates.

Retained only one record per duplicate set, deleting extras.

```sql
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  ROW_NUM INT
);
```

```sql
INSERT INTO layoffs_staging2
SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ORDER BY company
  ) AS ROW_NUM
FROM layoffs_staging;
```

DELETE FROM layoffs_staging2 WHERE ROW_NUM > 1;

SELECT * FROM layoffs_staging2 WHERE ROW_NUM > 1;  -- Should return 0 rows


Outcome:
Duplicates removed, ensuring each layoff event is uniquely counted.


Step 3: Standardize Columns (Clean percentage and Date)
Converted percentage_laid_off from text like "15%" to a decimal numeric type.

Converted date from text format to DATE datatype for easy querying.

ALTER TABLE layoffs_staging2 ADD COLUMN percentage_laid_off_num DECIMAL(5,2);

UPDATE layoffs_staging2
SET percentage_laid_off_num = CAST(REPLACE(percentage_laid_off, '%', '') AS DECIMAL(5,2));

ALTER TABLE layoffs_staging2 ADD COLUMN date_clean DATE;

UPDATE layoffs_staging2
SET date_clean = STR_TO_DATE(`date`, '%Y-%m-%d');

Why?
Numeric percentages enable calculations like averages. Proper dates allow time-series analysis.

Step 4: Handle Missing or Null Values
Checked for missing values in critical columns.

Removed rows missing essential data like company name or date.

SELECT 
  COUNT(*) AS total_rows,
  COUNT(total_laid_off) AS total_laid_off_not_null,
  COUNT(percentage_laid_off_num) AS percentage_not_null,
  COUNT(date_clean) AS date_not_null
FROM layoffs_staging2;

DELETE FROM layoffs_staging2
WHERE company IS NULL OR company = ''
OR date_clean IS NULL;


Outcome:
Data completeness ensured for accurate analysis.

Step 5: Remove Unnecessary Columns (Optional)
Created a final clean table with only needed columns for faster querying and analysis.

CREATE TABLE layoffs_clean AS
SELECT
  company,
  location,
  industry,
  total_laid_off,
  percentage_laid_off_num AS percentage_laid_off,
  date_clean AS date,
  stage,
  country,
  funds_raised_millions
FROM layoffs_staging2;


Why?
Simplifies working with clean, relevant data.

Summary of Cleaning
Removed duplicates for unique records.

Standardized percentage and date columns.

Removed rows with missing critical data.

Created a simplified, clean table ready for analysis.


Phase 2: Data Analysis(EDA)

1. When did layoffs begin and how long did they last?
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

Insight:
Layoffs started in March 2020, coinciding with the pandemic onset, and continue through March 2023, showing a prolonged multi-year wave.

Impact:
Layoffs persisted beyond the initial pandemic shock due to ongoing economic challenges.

2. Which year had the most layoffs?
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

Insight:

2022 had the highest layoffs (~160k).

2023 (only 3 months) had 125k layoffs, showing continued pressure.

2020 had an initial spike (~80k), while 2021 saw recovery (~16k layoffs).

Impact:
Reflects a "bust-boom-bust" economic pattern from pandemic shock to recovery and overexpansion corrections.

3. Are layoffs accelerating or decelerating?
WITH Rolling_Total AS (
  SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  WHERE SUBSTRING(`date`,1,7) IS NOT NULL
  GROUP BY 1
)
SELECT `Month`, total_laid_off,
       SUM(total_laid_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;

Impact:
Layoffs surged in late 2022 and early 2023, with cumulative totals steadily rising — no clear signs of stabilization by March 2023.

Takeaway:
The market correction remains ongoing, reflecting broader macroeconomic stress.

4. Who are the biggest culprits? (Top Companies)
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

Top offenders: Amazon, Google, Meta, Salesforce, Microsoft.

Impact:
Layoffs are not just startup phenomena but affect tech giants — a corporate recalibration at the highest level.

5. Did any companies lay off 100% of their workforce?
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
LIMIT 3;

Notable full shutdowns: Katerra, Butler Hospitality, Deliv.

Impact:
Complete shutdowns of large companies highlight vulnerabilities of heavily funded but unsustainable ventures.


6. Were failed companies well-funded?

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


Examples: Britishvolt ($2.4B), Quibi ($1.8B), Deliveroo Australia ($1.7B).

Impact:
High funding doesn’t guarantee survival — highlights inefficiencies and hype in the startup ecosystem.

7. Which industries were hit hardest?
SELECT industry, SUM(total_laid_off) AS industry_laid_off,
       (SUM(total_laid_off)/383320)*100 AS Percentage_of_total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

Top sectors: Consumer, Retail (over 22% combined layoffs).

Impact:
Demand-driven industries were most vulnerable to economic slowdown.

8. Where were layoffs concentrated geographically?
SELECT country, SUM(total_laid_off),
       (SUM(total_laid_off)/383320)*100 AS Percentage_of_total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

Top countries: United States (~67%), India (~9%).

Impact:
Silicon Valley dominates the layoff numbers; India follows but at a much smaller scale proportionally.

9. Which companies were most affected in the US and India?
SELECT country, company, SUM(total_laid_off)
FROM layoffs_staging2
WHERE country IN ('United States', 'India')
GROUP BY country, company
ORDER BY 3 DESC;

India: Byju's, Swiggy, Ola.

USA: Amazon, Google, Meta.

Impact:
EdTech and gig economy startups were hardest hit in India; US tech giants aggressively cut workforce.

10. Which funding stages saw the most layoffs?
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

Insight:
Post-IPO companies laid off the most employees (204k+).

Impact:
Mature companies face shareholder pressures to reduce costs during downturns.

Bonus: Year-on-Year Breakdown by Company
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1, 2
ORDER BY 3 DESC;

Examples:

Google: 12k layoffs in 2023.

Meta: 11k in 2022.

Amazon: 10k in 2022.

Impact:
Identifies peak layoff years per company — useful for investors and analysts.

Bonus: Top 5 Companies Per Year
WITH Company_Year (company, years, total_laid_off) AS (
  SELECT company, YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY 1, 2
),
company_year_rank AS (
  SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
  FROM Company_Year
)
SELECT *
FROM company_year_rank
WHERE Ranking <= 5;


Use Case:
Track top layoff contributors yearly to monitor company stability and talent sustainability risks.


Executive Summary & Conclusion
After analyzing 3 years of global layoff data (2020–2023), here are the critical insights:

Layoffs Are Not Episodic – They’re Systemic

The trend spans beyond the pandemic.

2022 and early 2023 saw the highest layoff volumes – driven by macroeconomic uncertainty, aggressive overhiring, and investor pressure.

Tech Is the Epicenter

Big Tech — including Amazon, Meta, and Google — contributed significantly to global layoffs.

Post-IPO and heavily funded companies were the most affected, disproving the notion that maturity ensures stability.

Consumer & Retail Industries Took the Biggest Hit

These sectors accounted for over 22% of all layoffs, showing vulnerability to demand-side volatility and interest rate shocks.

The USA Accounts for 2 in Every 3 Layoffs

Particularly Silicon Valley-based firms, emphasizing that innovation hubs are also risk centers in downturns.

India Is Catching Up

India ranks second globally, with layoffs primarily in EdTech and gig-economy startups, highlighting the aftershocks of pandemic-fueled expansions.

Layoffs Are Concentrated, Not Random

A small number of companies and countries drive the majority of global layoffs — a sign of structural inefficiencies, not scattered missteps.

Warning Sign: Several Firms Collapsed Entirely

Companies like Katerra and Britishvolt, despite hundreds of millions in funding, laid off 100% of their workforce — showing that capital alone can’t replace operational fundamentals.

🧠 What This Means for Leadership:
Future hiring needs to be sustainable, not opportunistic.

Economic signals must be integrated earlier into workforce planning.

Post-IPO accountability must balance growth with people stability.

Markets reward lean, resilient operations — not just speed and scale.

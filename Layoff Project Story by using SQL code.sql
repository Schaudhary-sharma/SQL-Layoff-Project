/*The Global Layoff Wave: A Data Story
🔍 Objective:
To explore the global layoff dataset from 2020 to 2023 and understand who got affected, when, where, and how badly. 
This analysis unpacks patterns across time, companies, industries, and countries — ultimately giving us insights into how economic waves hit tech and startup ecosystems.
*/

/*1. When did layoffs begin, and how far have they stretched?
  Question: What’s the time span of the layoffs in this dataset?*/

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

/*🧠 Insight:

The earliest recorded layoff was in March 2020 — the pandemic trigger point.

The latest was in March 2023, showing a 3-year window of layoff activity.

💥 Impact:
This suggests that layoffs didn’t just spike once during COVID — they persisted through economic uncertainties, post-pandemic corrections, inflationary pressure, and tech overhiring busts.*/


/* 2. Which year saw the highest number of layoffs?
Question: How did layoffs vary year by year?*/

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

/*🧠 Insight:

2022 saw the highest layoffs (~160k).

2023 (only 3 months in) had 125k, showing layoffs continued aggressively.

2020 had a heavy spike (~80k), but 2021 was a recovery year (~16k only).

📈 Impact:
This reflects the classic "bust-boom-bust" cycle:

COVID-led crash (2020),

Recovery optimism (2021),

Over-expansion correction (2022–2023)*/



/* 3. Are layoffs accelerating or decelerating?
   Question: What’s the monthly progression and rolling total of layoffs?*/

WITH Rolling_Total AS (
  SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  WHERE SUBSTRING(`date`,1,7) IS NOT NULL
  GROUP BY 1
)
SELECT `Month`, total_laid_off,
       SUM(total_laid_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;

/*Impact:

Layoffs surged in late 2022 and early 2023.

The cumulative number rising steadily highlights no clear stabilization point by March 2023.

🧠 Takeaway:
If we were to forecast the trend, it shows the market correction was still active, hinting at broader macroeconomic issues.*/


/* 4. Who were the biggest culprits? (Top Companies by Total Layoffs)
❓Question: Which companies laid off the most employees overall?*/

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

/*Top Offenders:

Amazon

Google

Meta

Salesforce

Microsoft

🧠 Impact:
These aren’t small startups — these are FAANG-level giants. This tells us the layoff wave wasn’t just a startup bubble burst, but a corporate recalibration at the highest levels.*/


/* 5. Did any company lay off 100% of their workforce?
Question: Which companies shut down completely?*/

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
LIMIT 3;


/* Companies That Ceased to Exist:

Katerra – 2434 employees

Butler Hospitality – 1000 employees

Deliv – 669 employees

🧠 Impact:
These weren’t micro-teams. Complete shutdowns of companies with 1000+ staff highlight how quickly venture-funded startups can collapse without sustainable models.*/


/* 6. Were these failed companies well-funded?
   Question: Did companies with big funding rounds also shut down?*/
   
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

/* Most Funded Collapsed Companies:

Britishvolt – $2400M

Quibi – $1800M

Deliveroo Australia – $1700M

🧠 Impact:
High funding ≠ safety net. This highlights inefficiency in capital deployment and perhaps hype over fundamentals in the startup ecosystem.*/


/* 7. Which industries were hit hardest?
Question: What industry laid off the most employees?*/

SELECT industry, SUM(total_laid_off) AS industry_laid_off,
       (SUM(total_laid_off)/383320)*100 AS Percentage_of_total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

/*Top Affected Sectors:

Consumer

Retail

🧠 Impact:
Consumer and Retail together made up 22%+ of all layoffs.
This indicates that demand-driven sectors were most vulnerable — a direct signal of economic slowdown and cautious consumer spending.*/


/*8. Where were layoffs geographically concentrated?
Question: Which countries had the most layoffs?*/

SELECT country, SUM(total_laid_off),
(SUM(total_laid_off)/383320)*100 AS Percentage_of_total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

/* Top Countries:

United States – ~67%

India – ~9%


🧠 Impact:
The U.S. took the biggest hit, suggesting Silicon Valley layoffs drove the bulk of the numbers. India's layoffs, while second-highest, were much lower proportionally.*/


/* 9. Which companies were most affected in the US and India?*/
SELECT country, company, SUM(total_laid_off)
FROM layoffs_staging2
WHERE country IN ('United States', 'India')
GROUP BY country, company
ORDER BY 3 DESC;

/*📍India:

Byju's, Swiggy and Ola topped the chart.

📍USA:

Amazon, Google, Meta led the list.

🧠 Impact:
EdTechs and gig-economy startups in India downsized, while tech majors in the US recalibrated headcount aggressively.*/

/*10. Which funding stages saw the most layoffs?*/

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

/*💡 Key Insight:

Post-IPO companies laid off the most — 204k+ employees.

🧠 Impact:
It shows that even companies in mature phases aren't immune.
It also reflects shareholder pressure to cut costs and meet earnings during downturns.*/

/*Bonus: Year-on-Year Breakdown by Company
 Question: How did individual companies lay off across different years?*/
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1, 2
ORDER BY 3 DESC;

/*🧠 Impact:
We see:

Google laid off 12k in 2023.

Meta laid off 11k in 2022.

Amazon had 10k layoffs in 2022.

This helps identify peak layoff moments per company — valuable for investors, job seekers, or analysts watching company health.*/



/*Try this by yourself, I am attaching the code*/

/*Finally, who were the top 5 companies per year?*/

WITH Company_Year (company, years, total_laid_off) AS (
  SELECT company, YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY 1,2
),
company_year_rank AS (
  SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
  FROM Company_Year
)
SELECT *
FROM company_year_rank
WHERE RANKING <= 5;

/*📌 Use Case:
Use this to visualize and compare top yearly layoff contributors and see if a company is frequently in the top 5 — a red flag for long-term talent sustainability.*/










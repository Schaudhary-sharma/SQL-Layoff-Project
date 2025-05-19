
Github Explanation:
Case Study: "Who Got Fired?" — Layoff Analysis (2020 to March 2023)\
"Who Got Fired?" — SQL Layoff Analysis
This case study dives into real-world tech layoffs from 2020 to March 2023. Through a series of SQL queries, we uncovered:
•	Layoff patterns by year, industry, and company
•	Total shutdowns (100% layoffs)
•	Impact of funding on layoff resilience
•	Top affected countries and company stages

🎯 Project Overview
Objective: Analyze layoff trends from 2020 to March 2023 to uncover industry patterns, company shutdowns, and the impact of funding on survival.
Business Use Case:
•	Understand macroeconomic impacts on employment
•	Identify vulnerable industries during crises
•	Predict signals of business shutdowns
•	Help job seekers and HR professionals assess market risks
Tools Used: SQL, PostgreSQL / MySQL, Excel (for cleaning), Tableau / Power BI (optional for visualization)
Dataset Source: Layoffs.fyi

🧵 Project Story — From Chaos to Clarity
The global economy went through a hiring frenzy in 2020... but what came next was unexpected. Mass layoffs shook the tech world from 2020 to 2023. We’ve heard the headlines, but the real question is:
What really happened — and what can we learn from it?
I rolled up my sleeves, wrote some SQL, and built a story out of numbers. Here's what I found...

🧠 Key Business Questions & Insights
Q1: Which year had the highest number of layoffs?
SELECT YEAR(date) AS Year, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs
GROUP BY YEAR(date)
ORDER BY Total_Laid_Off DESC;

Insight: 2023 (till March) had the highest layoffs, showing that the trend didn’t slow post-COVID — it escalated.


Q2: What industries were most affected?
SELECT industry, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs
GROUP BY industry
ORDER BY Total_Laid_Off DESC;

Insight: The tech industry was the most affected, especially sectors like Consumer, Retail, and Crypto.

Q3: Which companies had the highest layoffs?
SELECT company, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs
GROUP BY company
ORDER BY Total_Laid_Off DESC
LIMIT 10;

Insight: Amazon, Meta, Google, and Microsoft were among the top — proving even the biggest players weren’t immune.

Q4: Which companies shut down completely?
SELECT company, total_laid_off, percentage_laid_off
FROM layoffs
WHERE percentage_laid_off = 1;

Insight: Companies like Katerra, Quibi, and Britishvolt laid off 100% of their staff — signaling complete shutdown.


Q5: How does funding relate to layoffs? (Did billion-dollar companies fail?)
SELECT company, total_laid_off, funds_raised, percentage_laid_off
FROM layoffs
WHERE funds_raised > 1000000000
ORDER BY percentage_laid_off DESC;

Insight: Shockingly, even companies that raised billions weren’t safe. Britishvolt raised $2.4B yet laid off everyone.

Q6: Which countries had the highest layoffs?
SELECT country, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs
GROUP BY country
ORDER BY Total_Laid_Off DESC;

Insight: The U.S. led the world in layoffs, reaffirming it as the epicenter of tech job volatility.

Q7: Were smaller or bigger companies laying off more?
SELECT company, stage, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs
GROUP BY company, stage
ORDER BY Total_Laid_Off DESC;

Insight: Both early-stage and late-stage companies faced layoffs. Unicorns and IPO-stage companies weren’t protected.



🧠 What Can We Learn From This?
🔄 Strategic Takeaways:
•	Mass layoffs weren’t isolated to 2020 — it was a prolonged trend.
•	Funding doesn’t equal safety — execution and adaptability matter more.
•	Shutdown patterns can be predicted by monitoring % of layoffs.
🔮 For Job Seekers & Professionals:
•	Evaluate industry health before career moves.
•	Don’t assume size or funding = job security.
•	Use public layoff data to assess risk.

🌟 Final Thought
This isn’t just a data project. It’s a story of survival, mistakes, and market shifts — all hidden in rows and columns.
And the best part? You can learn from it, with just a few SQL queries.

	


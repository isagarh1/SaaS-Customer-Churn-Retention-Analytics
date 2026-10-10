## SaaS Customer Churn & Retention Analytics
A SQL and Power BI analytics project investigating customer churn, subscription status, payment outcomes, customer segments, product usage, and recurring-revenue exposure in a SaaS business.

## Project Overview

This project uses PostgreSQL and Power BI to examine SaaS customer and subscription health. The analysis moves from an overall business-health view to churn segmentation, revenue-related findings, and signup-month cohort analysis.

### Business objective: 
Identify customer segments and subscription patterns that deserve further investigation, quantify revenue associated with churned subscriptions, analyze product-usage patterns across signup cohorts, and recommend evidence-based retention and payment-recovery actions.

## Business Problem

A SaaS business needs to understand how many customers are active, how churn is distributed across customer and plan segments, and how payment, product-usage, and support patterns relate to churn. The goal is to turn subscription, payment, usage, and support data into practical priorities for customer retention and revenue monitoring.

## Tools

- **PostgreSQL** — SQL analysis, joins, aggregations, CTEs, conditional calculations, monthly analysis, and cohort analysis.

- **Power BI** — KPI cards, interactive filters, trend charts, segment and plan comparisons, cohort matrix, and business recommendations.

- **Power Query** — Normalization of identifier formatting by trimming whitespace and standardizing case to resolve mismatched joins.

## Data Model

The project uses these tables:

- dim_customers — customer attributes such as segment, country, industry, and signup date.

- dim_plans — plan name, billing cycle, and plan price.

- fact_subscriptions — customer-plan assignments, start/end dates, and subscription status.

- fact_payments — payment amounts, statuses, dates, and methods.

- fact_usage — product login and usage activity.

- fact_support (also referred to as fact_supports in the SQL script) — support tickets and resolution information.

## Analytical Workflow

- Business understanding: Define the business problem and questions the dashboard should answer.

- Data understanding: Inspect the schema and status values across customer, plan, subscription, payment, usage, and support tables.

- Data validation: Validate subscription counts and check customer and plan matching across tables.

- Identifier normalization: Standardize case and whitespace where formatting differences prevented successful joins.

- Churn analysis: Analyze churn status and customer segments using SQL aggregations and conditional logic.

- Payment and revenue analysis: Calculate paid revenue and estimated monthly plan value associated with churned subscriptions.

- Power BI reporting: Build dashboard pages and reconcile key metrics against SQL results.

- Cohort analysis: Group customers by signup month and calculate monthly product-usage rates using distinct active customers.

- Business recommendations: Translate findings into investigation priorities without claiming causation where the analysis only shows association.

## Power BI Dashboard

Page 1 — Business Health Overview

Shows total customers, churn rate, active customer rate, total paid revenue, paid revenue trends, and revenue by plan, customer segment, and country.

<img width="1195" height="722" alt="Screenshot 2026-10-10 102640" src="https://github.com/user-attachments/assets/10d5aa95-5562-4ff0-8f3f-f33f72702204" />


Page 2 — Customer Churn Analysis

Shows churned customer count and displayed churn rates by plan, customer segment, and industry. It also compares average usage/login activity and support-resolution time by ticket category. The monthly churn chart uses subscription end_date rather than payment month.

<img width="1216" height="726" alt="Screenshot 2026-10-10 102825" src="https://github.com/user-attachments/assets/6af2abb5-4f3c-4182-8300-b58e92b4e66d" />


Page 3 — Revenue Impact & Business Recommendations

Shows paid revenue associated with churned subscriptions, estimated monthly plan value associated with churned subscriptions, average revenue per customer, failed-payment rate, paid revenue by payment method, churn-associated paid revenue by industry, and business recommendations.

<img width="1207" height="721" alt="Screenshot 2026-10-10 102937" src="https://github.com/user-attachments/assets/1452d600-c89d-4011-afa6-72c649ef627f" />


Cohort Retention — Signup-Month Product Usage

A cohort matrix was added using the PostgreSQL view public.vw_saas_cohort_usage_retention.

<img width="1157" height="385" alt="Screenshot 2026-10-10 103005" src="https://github.com/user-attachments/assets/969c3ad3-96f0-4043-beda-82f9d10d1f21" />


Customers are grouped by signup month. For each cohort and subsequent activity month, the analysis counts distinct customers with at least one recorded fact_usage event and calculates the percentage of the original cohort active in that month.

## Methodology

- Cohort definition: Customers are assigned to the calendar month of their signup_date.

- Cohort size: The number of distinct customers with a non-null signup date in each cohort.

- Monthly active customers: Distinct cohort customers with at least one recorded product-usage event during the activity month.

- Usage rate: Monthly active customers divided by the original cohort size, multiplied by 100.

- Month 0: Actual recorded product usage during the signup month. It is not forced to 100%.

- Month 1 and later: The percentage of the original signup cohort with recorded usage in each subsequent month

Key Findings

The figures below reflect the current dashboard and the SQL reconciliation completed during the project audit. Revenue values are shown in the dataset's reporting units. A currency symbol is not assigned because the dataset currency has not been confirmed.

## Key Findings

| Business Area | Key Finding | Business Interpretation |
|---|---|---|
| Customer Churn | 151 customers were classified as churned out of 1,500 total customers, representing a **10.1% churn rate**. | Establishes the baseline level of customer churn for further investigation. |
| Customer Status | 1,043 customers were active, representing **69.5% of the customer base**. | Shows the proportion of customers currently classified as active; this is not a period-based retention rate. |
| Customer Segmentation | Small Business had the highest churn rate at **12.5%**, followed by Mid-Market at **9.8%** and Enterprise at **7.6%**. | Small Business is the first segment to investigate for potential churn-reduction opportunities. |
| Revenue Analysis | Total paid revenue was **258,370** across the dataset. | Provides a baseline for evaluating revenue contribution across customer segments. The dataset currency was not confirmed. |
| Revenue by Segment | Small Business contributed **99,319**, Enterprise **80,160**, and Mid-Market **78,891** in paid revenue. | Small Business contributed the largest share of recorded paid revenue among the three segments. |
| Churned Subscription Payments | Paid payment records associated with churned subscriptions totalled **10,997**. | Represents historical paid revenue associated with churned subscriptions, not a confirmed estimate of revenue lost because of churn. |
| Estimated Monthly Plan Value | Churned subscriptions had an estimated monthly-equivalent plan value of **8,632.33**, based on normalized plan prices. | Provides an estimate of the monthly-equivalent value associated with churned subscriptions; it is not necessarily current recurring revenue at risk. |
| Payment Performance | The dashboard reported a **24.8% failed-payment rate**. | Payment failures warrant further investigation, but the calculation and denominator should be documented before drawing stronger conclusions. |
| Product Usage Cohorts | For the January 2025 signup cohort, **36.8%** had recorded usage in their signup month, compared with **55.2%** in February 2025. | Demonstrates how observed product usage varied across months. Usage retention does not directly measure subscription retention or prove cancellation. |
| Data Quality | Customer and plan identifiers required case and whitespace normalization to achieve complete matching in the relevant joins. | Standardizing join keys improved data consistency and reduced mismatches during analysis. |


## Business Recommendations

- Prioritize retention investigation in Small Business: This segment has the highest displayed churn rate at 12.5%. Review onboarding, engagement, and support patterns before choosing an intervention.

- Investigate payment failures: The dashboard's failed-payment rate is 24.8%. Validate the metric definition, then investigate failure patterns and consider appropriate reminders or retry processes.

- Protect high-value revenue: Enterprise plans account for approximately 189K in paid revenue in the dashboard. Monitor renewals and account health.

- Review support responsiveness: Login Issues have the longest displayed average resolution time, approximately 38.1 in the dashboard's reported units. Confirm the units and investigate whether response-time improvements are warranted.

- Investigate cohort usage patterns: Compare monthly product usage across signup cohorts to identify when engagement is lower or higher. Use these patterns to guide further investigation rather than assuming that missing usage means cancellation.

- Avoid causal overstatement: Segment, industry, usage, support, and payment differences identify areas for further investigation; they do not establish that a factor caused churn.

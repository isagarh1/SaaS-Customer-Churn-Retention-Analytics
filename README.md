## SaaS-Customer-Churn-Retention-Analytics
 **End-to-End Data Analytics Project | PostgreSQL | Power BI | DAX | Business Intelligence**
 
---

### Project Overview

Customer churn is one of the biggest challenges for subscription-based SaaS businesses because losing customers directly impacts Monthly Recurring Revenue (MRR), customer lifetime value, and long-term business growth.

This project analyzes customer subscriptions, payments, product usage, and support interactions to identify the key drivers of churn, quantify its financial impact, and provide actionable business recommendations.

The solution was developed using **PostgreSQL** for data cleaning and business analysis and **Power BI** for interactive dashboard development.

---

### Business Problem

A SaaS company is experiencing increasing customer churn, resulting in recurring revenue loss and reduced customer retention.

Management wants to answer the following business questions:

- Which customers are most likely to churn?
- Which subscription plans generate the highest revenue?
- Which customer segments have the highest churn?
- How much Monthly Recurring Revenue (MRR) is at risk?
- Which industries contribute the highest revenue loss?
- What actions should management prioritize to improve customer retention?

---

### Project Objectives

- Analyze customer churn and retention trends.
- Measure the financial impact of customer churn.
- Evaluate subscription plan performance.
- Analyze customer engagement and support performance.
- Monitor payment success and failed payment trends.
- Deliver actionable business recommendations to improve customer retention and recurring revenue.

---

### Tech Stack

| Category | Technology |
|-----------|------------|
| Database | PostgreSQL |
| Visualization | Power BI |
| Query Language | SQL |
| Analytics | DAX |
| Data Modeling | Star Schema |
| Version Control | Git & GitHub |

---

### Data Model

The project follows a **Star Schema** consisting of two dimension tables and four fact tables.

#### Dimension Tables

- dim_customers
- dim_plans

#### Fact Tables

- fact_subscriptions
- fact_payments
- fact_usage
- fact_supports

---

### Dashboard Overview

<img width="995" height="627" alt="Overview" src="https://github.com/user-attachments/assets/7ddbc035-0792-4e03-a441-24f719f1d9c9" />

<img width="997" height="646" alt="customer_churn" src="https://github.com/user-attachments/assets/d32bb3f8-2f2c-4b5b-851a-6f19896ec93e" />

<img width="997" height="662" alt="recomendations" src="https://github.com/user-attachments/assets/1dee93b1-f405-4bd8-b76f-7f7606e88fc6" />

---

### Key Insights

- Enterprise plans generated **₹189K (73%)** of total revenue, making them the highest-value subscription tier.
- The overall churn rate was **10.1%**, with the **Small Business** segment recording the highest churn (**11.2%**).
- Customer churn resulted in approximately **₹26K** in revenue loss, with **₹8.63K** of Monthly Recurring Revenue (MRR) currently at risk.
- The failed payment rate was **24.8%**, indicating opportunities to improve revenue collection through payment recovery strategies.
- Healthcare customers contributed the highest revenue loss (**₹5.2K**) among all industries.
- Login Issues recorded the highest average support resolution time (**38.1 hours**), highlighting an opportunity to improve customer experience.

---

### Business Recommendations

- Prioritize retention initiatives for **Enterprise customers**, as they contribute the highest share of recurring revenue.
- Improve onboarding and engagement strategies for the **Small Business** segment to reduce churn.
- Implement automated payment reminders and retry mechanisms to reduce the **24.8% failed payment rate**.
- Launch targeted retention campaigns for **Healthcare customers**, where revenue loss due to churn is highest.
- Reduce support resolution time for **Login Issues** to improve customer satisfaction and strengthen retention.

---

# ⭐ Business Impact

| Business Challenge | Recommendation | Expected Business Impact |
|--------------------|----------------|--------------------------|
| Enterprise customers contribute the largest share of revenue | Prioritize Enterprise retention | Protect high-value recurring revenue |
| Small Business customers have the highest churn | Improve onboarding and engagement | Increase customer retention |
| High failed payment rate | Implement payment retries and reminders | Improve payment success and recurring revenue |
| Healthcare industry contributes the highest revenue loss | Launch targeted retention campaigns | Reduce revenue leakage |
| Login Issues have the longest support resolution time | Improve support response time | Enhance customer satisfaction and retention |

---











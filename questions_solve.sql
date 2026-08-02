
/* Business Analysis in SQL:

-- Business Health Overview : 
*/
-- Question 1: What is the overall customer churn rate?
-----------------------------------------------------------
-- Total Customers
SELECT COUNT(*) AS total_customers
FROM dim_customers;

--Active Customers
SELECT 
	COUNT(*) AS active_customers
FROM fact_subscriptions
WHERE subscription_status = 'Active';

--Churned Customers
SELECT 
	COUNT(*) AS active_customers
FROM fact_subscriptions
WHERE subscription_status = 'Churned';

--Churn Rate
SELECT
    COUNT(*) FILTER (WHERE subscription_status = 'Churned') AS churned_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) FILTER (WHERE subscription_status = 'Churned') * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM fact_subscriptions;


--Retention Rate
SELECT
    COUNT(*) FILTER (WHERE subscription_status = 'Active') AS active_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) FILTER (WHERE subscription_status = 'Active') * 100.0
        / COUNT(*),
        2
    ) AS retention_rate
FROM fact_subscriptions;


-- Revenue Overview:
-- Question 2: How much revenue does the company generate, and how much MRR is at risk due to churn?
-------------------------------------------------------------------------------------------------------
/*	Total Revenue
	Monthly Revenue
	Revenue Lost
	Average Revenue per Customer (ARPC)
*/

--Total Revenue
SELECT 
	SUM(amount) AS total_revenue
FROM fact_payments
WHERE payment_status = 'paid'

--Monthly Revenue
SELECT
    DATE_TRUNC('month', payment_date) AS month,
    SUM(amount) AS monthly_revenue
FROM fact_payments
WHERE payment_status = 'paid'
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month;

--Revenue Lost
SELECT 
	SUM(p.monthly_price) AS monthly_lost
FROM fact_subscriptions s
LEFT JOIN dim_plans p
ON s.plan_id = p.plan_id 
WHERE s.subscription_status = 'Churned'

------------------------------------------------------

SELECT 
	ROUND(SUM(CASE WHEN p.billing_cycle = 'Monthly' THEN monthly_price
			WHEN p.billing_cycle = 'Annual' THEN monthly_price /12.0
			END),2) AS mmr_risk
FROM fact_subscriptions s
LEFT JOIN dim_plans p
ON s.plan_id = p.plan_id 
WHERE s.subscription_status = 'Churned'


--Average Revenue per Customer
SELECT 
	ROUND(SUM(p.amount)/  COUNT(DISTINCT s.customer_id),2) AS avg_per_cust
FROM fact_payments p
LEFT JOIN fact_subscriptions s
ON p.subscription_id = s.subscription_id
/*LEFT JOIN dim_customers c
ON s.customer_id = c.customer_id */
WHERE p.payment_status = 'paid'

--: Customer Segmentation:
--Question 3: Which customer segments have the highest churn?
---------------------------------------------------------------
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT CASE
        WHEN s.subscription_status = 'Churned'
        THEN c.customer_id
    END) AS churned_customers,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN s.subscription_status = 'Churned'
            THEN c.customer_id
        END) * 100.0 /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS churn_rate
FROM dim_customers c
JOIN fact_subscriptions s
ON c.customer_id = s.customer_id
GROUP BY c.segment
ORDER BY churn_rate DESC;

--Subscription Analysis:
--Question 4: Which subscription plans have the highest churn and which generate the most revenue?
---------------------------------------------------------------------------------------------------
WITH CTE AS(
SELECT 
	p.plan_name,
	COUNT(CASE WHEN subscription_status = 'Churned' THEN s.subscription_id END) AS highest_churn ,
	SUM(CASE
            WHEN fp.payment_status = 'paid' THEN fp.amount ELSE 0 END) AS most_revenue,
	COUNT(DISTINCT s.subscription_id) AS total_subscription		
FROM fact_subscriptions s
LEFT JOIN dim_plans p
ON s.plan_id = p.plan_id
LEFT JOIN fact_payments fp
ON s.subscription_id = fp.subscription_id
GROUP BY p.plan_name	
HAVING p.plan_name IS NOT NULL
ORDER BY highest_churn DESC 
)
SELECT 
	plan_name,
	highest_churn,
	ROUND((highest_churn * 100.0 / total_subscription),2) AS churn_rate,
	most_revenue
FROM CTE


--Customer Engagement
--Question 5: Does product usage affect churn?
---------------------------------------------------
WITH customer_usage AS(
SELECT
	customer_id,
	SUM(login_count) AS total_logins
FROM fact_usage
GROUP BY customer_id
)
,login_bucket AS(
SELECT 	
	customer_id,
	total_logins,
	CASE
        WHEN total_logins <= 50 THEN 'Low (0-50)'
        WHEN total_logins <= 100 THEN 'Medium (51-100)'
        WHEN total_logins <= 150 THEN 'High (101-150)'
        ELSE 'Power User (150+)'
    END AS login_bucket
FROM customer_usage
),
churn_rates AS(
SELECT 
	lb.login_bucket,
	COUNT(DISTINCT s.subscription_id) AS total_subscription,
	COUNT(CASE WHEN s.subscription_status = 'Churned' THEN s.subscription_id
	END) AS churned_subscription
	
FROM login_bucket lb
LEFT JOIN fact_subscriptions s
ON lb.customer_id = s.customer_id
GROUP BY lb.login_bucket
)
SELECT 
	login_bucket,
	total_subscription,
	churned_subscription,
	ROUND((churned_subscription * 100.0 / total_subscription ),2) AS churn_rate
FROM churn_rates


-- Support Analysis 
--Question 6: Does customer support impact churn?
------------------------------------------------------
WITH support_summary AS (
    SELECT
        s.customer_id,
        s.subscription_id,
        s.subscription_status,
        COUNT(fs.ticket_id) AS total_tickets
    FROM fact_subscriptions s
    LEFT JOIN fact_supports fs
        ON s.customer_id = fs.customer_id
    GROUP BY
        s.customer_id,
        s.subscription_id,
        s.subscription_status
),
ticket_bucket AS (
    SELECT
        customer_id,
        subscription_id,
        subscription_status,
        total_tickets,
        CASE
            WHEN total_tickets = 0 THEN '0 Tickets'
            WHEN total_tickets = 1 THEN '1 Ticket'
            WHEN total_tickets BETWEEN 2 AND 3 THEN '2-3 Tickets'
            WHEN total_tickets BETWEEN 4 AND 5 THEN '4-5 Tickets'
            ELSE '6+ Tickets'
        END AS ticket_bucket
    FROM support_summary
)
SELECT
    ticket_bucket,
    COUNT(DISTINCT subscription_id) AS total_subscriptions,
    COUNT(
        DISTINCT CASE
            WHEN subscription_status = 'Churned'
            THEN subscription_id
        END
    ) AS churned_subscriptions,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN subscription_status = 'Churned'
                THEN subscription_id
            END
        ) * 100.0
        / COUNT(DISTINCT subscription_id),
        2
    ) AS churn_rate

FROM ticket_bucket
GROUP BY ticket_bucket
ORDER BY
    CASE ticket_bucket
        WHEN '0 Tickets' THEN 1
        WHEN '1 Ticket' THEN 2
        WHEN '2-3 Tickets' THEN 3
        WHEN '4-5 Tickets' THEN 4
        WHEN '6+ Tickets' THEN 5
    END;



-- Payment Analysis:
-- Question 7: Are payment issues associated with churn?

WITH payment_summary AS (
    SELECT
        subscription_id,
        COUNT(payment_id) AS total_payments,
        COUNT(
            CASE
                WHEN payment_status = 'failed'
                THEN payment_id
            END
        ) AS failed_payments
    FROM fact_payments
    GROUP BY subscription_id
),

payment_bucket AS (
    SELECT
        subscription_id,
        total_payments,
        failed_payments,
        CASE
            WHEN failed_payments = 0 THEN 'No Failed Payments'
            WHEN failed_payments = 1 THEN '1 Failed Payment'
            ELSE '2+ Failed Payments'
        END AS payment_bucket
    FROM payment_summary
)

SELECT
    pb.payment_bucket,

    COUNT(DISTINCT s.subscription_id) AS total_subscriptions,

    COUNT(
        DISTINCT CASE
            WHEN s.subscription_status = 'Churned'
            THEN s.subscription_id
        END
    ) AS churned_subscriptions,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN s.subscription_status = 'Churned'
                THEN s.subscription_id
            END
        ) * 100.0 /
        COUNT(DISTINCT s.subscription_id),
        2
    ) AS churn_rate

FROM payment_bucket pb
JOIN fact_subscriptions s
    ON pb.subscription_id = s.subscription_id

GROUP BY pb.payment_bucket

ORDER BY
    CASE pb.payment_bucket
        WHEN 'No Failed Payments' THEN 1
        WHEN '1 Failed Payment' THEN 2
        WHEN '2+ Failed Payments' THEN 3
    END;

--------------------------------------------------------
SELECT
    p.payment_method,
    COUNT(DISTINCT s.subscription_id) AS total_subscriptions,
    COUNT(
        DISTINCT CASE
            WHEN s.subscription_status = 'Churned'
            THEN s.subscription_id
        END
    ) AS churned_subscriptions,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN s.subscription_status = 'Churned'
                THEN s.subscription_id
            END
        ) * 100.0 /
        COUNT(DISTINCT s.subscription_id),
        2
    ) AS churn_rate
FROM fact_payments p
JOIN fact_subscriptions s
    ON p.subscription_id = s.subscription_id
GROUP BY p.payment_method
ORDER BY churn_rate DESC;
------------------------------------------------

SELECT
    payment_method,
    SUM(amount) AS total_revenue
FROM fact_payments
WHERE payment_status = 'paid'
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- Time-Based Analysis:
-- Question 8: How have subscriptions, churn, and revenue changed over time?
---------------------------------------------------------------------------------
-- New customer:
SELECT 
	DATE_TRUNC('month',signup_date)::DATE AS month_date,
	COUNT(customer_id) AS new_customer
FROM dim_customers
GROUP BY 1
ORDER BY month_date

-- Monthly Churn customer:
SELECT 
	DATE_TRUNC('month',end_date)::DATE AS months,
	COUNT(subscription_id) AS churn_customer
FROM fact_subscriptions
WHERE subscription_status = 'Churned'
GROUP BY 1
ORDER BY churn_customer DESC

-- Monthly Revenue:
SELECT 
	DATE_TRUNC('month',payment_date)::DATE AS months,
	SUM(amount) AS monthly_revenue
FROM fact_payments
WHERE payment_status = 'paid' 
GROUP BY 1
ORDER BY monthly_revenue DESC

-- Monthly Active Subscriptions:
SELECT
    DATE_TRUNC('month', start_date)::DATE AS month,
    COUNT(subscription_id) AS new_subscriptions
FROM fact_subscriptions
WHERE subscription_status = 'Active'
GROUP BY 1
ORDER BY 1;


-- High-Value Customer Analysis
-- Question 9: What are the characteristics of churned customers across revenue, product usage, and support history?
-------------------------------------------------------------------------------------------------------------------
WITH revenue_cte AS (
    SELECT
        s.customer_id,
        SUM(
            CASE
                WHEN p.payment_status = 'paid' THEN p.amount
                ELSE 0
            END
        ) AS lifetime_revenue
    FROM fact_payments p
    JOIN fact_subscriptions s
        ON p.subscription_id = s.subscription_id
    GROUP BY s.customer_id
),

usage_cte AS (
    SELECT
        customer_id,
        SUM(login_count) AS total_logins
    FROM fact_usage
    GROUP BY customer_id
),

support_cte AS (
    SELECT
        customer_id,
        COUNT(ticket_id) AS total_tickets
    FROM fact_supports
    GROUP BY customer_id
),

subscription_cte AS (
    SELECT
        s.customer_id,
        dp.plan_name,
        s.subscription_status,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.start_date DESC
        ) AS rn
    FROM fact_subscriptions s
    JOIN dim_plans dp
        ON s.plan_id = dp.plan_id
)

SELECT
    sc.customer_id,
    sc.plan_name AS current_plan,
    sc.subscription_status,
    COALESCE(r.lifetime_revenue, 0) AS lifetime_revenue,
    COALESCE(u.total_logins, 0) AS total_logins,
    COALESCE(sp.total_tickets, 0) AS total_tickets
FROM subscription_cte sc
LEFT JOIN revenue_cte r
    ON sc.customer_id = r.customer_id
LEFT JOIN usage_cte u
    ON sc.customer_id = u.customer_id
LEFT JOIN support_cte sp
    ON sc.customer_id = sp.customer_id
WHERE sc.rn = 1
  AND sc.subscription_status = 'Churned'
ORDER BY lifetime_revenue DESC,
         total_logins DESC;






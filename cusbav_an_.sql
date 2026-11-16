#Q1. Total revenue: male vs. female customers
SELECT Gender, SUM("Purchase_Amount") AS total_revenue
FROM cusbav_a
GROUP BY Gender;

#--Q2. Customers who used a discount but still spent more than the average purchase amount
SELECT "Customer_ID", "Purchase_Amount"
FROM  cusbav_a
WHERE "Discount_Applied" = 'Yes'
  AND "Purchase_Amount" > (SELECT AVG("Purchase_Amount") FROM cusbav_a);

#--Q3. Top 5 products by average review rating
SELECT "Item_Purchased", ROUND(AVG("Review_Rating"), 2) AS avg_rating
FROM cusbav_a
GROUP BY "Item_Purchased"
ORDER BY avg_rating DESC
LIMIT 5;

#--Q4. Average purchase amount: Standard vs. Express shipping
SELECT "Shipping_type", ROUND(AVG("Purchase_Amount"), 2) AS avg_purchase_amount
FROM cusbav_a
WHERE "Shipping_Type" IN ('Standard', 'Express')
GROUP BY "Shipping_Type";

#--Q5. Subscribers vs. non-subscribers: average spend and total revenue
SELECT "subscription_sta",
       COUNT(*) AS customers,
       ROUND(AVG("Purchase_Amount"), 2) AS avg_spend,
       SUM("Purchase_Amount") AS total_revenue
FROM cusbav_a
GROUP BY "Subscription_Sta"
ORDER BY total_revenue DESC;

#--Q6. Top 5 products with the highest % of purchases with discounts
SELECT "Item_Purchased",
       ROUND(100.0 * SUM(CASE WHEN "Discount_Applied" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_percentage
FROM cusbav_a
GROUP BY "Item_Purchased"
ORDER BY discount_percentage DESC
LIMIT 5;

#--Q7. Customer segments: New, Returning, Loyal
WITH customer_type AS (
    SELECT "Customer_ID", "Previous_Purchas",
           CASE
               WHEN "Previous_Purchas" = 1 THEN 'New'
               WHEN "Previous_Purchas" BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM cleaned_customer_shopping_behavior
)
SELECT customer_segment, COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment;

#--Q8. Top 3 most purchased products within each category
WITH item_counts AS (
    SELECT Category, "Item_Purchased",
           COUNT("Customer_ID") AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY COUNT("Customer_ID") DESC) AS item_rank
    FROM  cleaned_customer_shopping_behavior
    GROUP BY Category, "Item_Purchased"
)
SELECT item_rank, Category, "Item_Purchased", total_orders
FROM item_counts
WHERE item_rank <= 3;

#--Q9. Are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT CASE WHEN "Previous_Purchas" > 5 THEN 'Repeat buyer (>5)' ELSE 'Not repeat (<=5)' END AS buyer_type,
       COUNT(*) AS customers,
       SUM(CASE WHEN "Subscription_Sta" = 'Yes' THEN 1 ELSE 0 END) AS subscribers,
       ROUND(100.0 * SUM(CASE WHEN "Subscription_Sta" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS subscription_rate_pct
FROM cusbav_a
GROUP BY buyer_type;

#--Q10. Revenue contribution of each age group
SELECT CASE
           WHEN Age <= 25 THEN '18-25'
           WHEN Age <= 35 THEN '26-35'
           WHEN Age <= 45 THEN '36-45'
           WHEN Age <= 55 THEN '46-55'
           ELSE '56+'
       END AS age_group,
       SUM("Purchase_Amount") AS total_revenue,
       ROUND(100.0 * SUM("Purchase_Amount") / (SELECT SUM("Purchase_Amount") FROM cleaned_customer_shopping_behavior), 2) AS revenue_pct
FROM cusbav_a
GROUP BY age_group
ORDER BY age_group;
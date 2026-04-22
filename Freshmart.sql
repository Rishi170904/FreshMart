-- FreshMart – Stock Health Report
-- Setup and selection of Database
CREATE DATABASE IF NOT EXISTS FreshMart;
USE FreshMart;

DROP TABLE IF EXISTS Sales_Transactions;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;

-- 1A. Categories
CREATE TABLE Categories (
    Category_ID INT PRIMARY KEY AUTO_INCREMENT,
    Category_Name VARCHAR(100) NOT NULL,
    Description TEXT
);

-- 1B. Products
CREATE TABLE Products (
    Product_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_Name VARCHAR(150) NOT NULL,
    Category_ID INT NOT NULL,
    Unit_Price DECIMAL(10,2) NOT NULL CHECK (Unit_Price >= 0),
    Stock_Count INT NOT NULL DEFAULT 0 CHECK (Stock_Count >= 0),
    Expiry_Date DATE,
    FOREIGN KEY (Category_ID) REFERENCES Categories(Category_ID)
);

-- 1C. SalesTransactions
CREATE TABLE Sales_Transactions (
    Transaction_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_ID INT NOT NULL,
    Quantity_Sold INT NOT NULL CHECK (Quantity_Sold > 0),
    Sale_Price DECIMAL(10,2) NOT NULL CHECK (Sale_Price >= 0),
    Sale_Date DATE  NOT NULL,
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

-- SECTION 2 – DUMMY DATA

INSERT INTO Categories (Category_Name, Description) VALUES
    ('Dairy','Milk, cheese, yogurt, and related products'),
    ('Bakery','Breads, cakes, pastries, and confections'),
    ('Produce','Fresh fruits and vegetables'),
    ('Beverages','Juices, soft drinks, water, and tea'),
    ('Snacks','Chips, biscuits, nuts, and packaged snacks');

INSERT INTO Products (Product_Name, Category_ID, Unit_Price, Stock_Count, Expiry_Date) VALUES
    -- Dairy (IDs 1-5)
    ('Full Cream Milk 1L', 1, 55.00, 120, DATE_ADD(CURDATE(), INTERVAL 3 DAY)),
    ('Greek Yogurt 200g', 1, 45.00, 80, DATE_ADD(CURDATE(), INTERVAL 5 DAY)),
    ('Cheese 500g', 1, 180.00, 30, DATE_ADD(CURDATE(), INTERVAL 6 DAY)),
    ('Skimmed Milk 500ml', 1, 35.00, 60, DATE_ADD(CURDATE(), INTERVAL 10 DAY)),
    ('Butter Salted 100g', 1, 65.00, 55, DATE_ADD(CURDATE(), INTERVAL 2 DAY)),

    -- Bakery (IDs 6-9)
    ('Whole Wheat Bread', 2, 40.00, 90, DATE_ADD(CURDATE(), INTERVAL 4 DAY)),
    ('Multigrain Bread', 2, 50.00, 20, DATE_ADD(CURDATE(), INTERVAL 3 DAY)),
    ('CreamBun', 2, 90.00, 10, DATE_ADD(CURDATE(), INTERVAL 1 DAY)),
    ('Dilkush', 2, 35.00, 100, DATE_ADD(CURDATE(), INTERVAL 6 DAY)),

    -- Vegetable (IDs 10-14)
    ('Spinach', 3, 25.00, 70, DATE_ADD(CURDATE(), INTERVAL 3 DAY)),
    ('Tomatoes 500g', 3, 60.00, 80, DATE_ADD(CURDATE(), INTERVAL 5 DAY)),
    ('Broccoli', 3, 40.00, 30, DATE_ADD(CURDATE(), INTERVAL 7 DAY)),
    ('Banana (per dozen)', 3, 30.00, 200, DATE_ADD(CURDATE(), INTERVAL 4 DAY)),
    ('Avocado (each)', 3, 20.00, 15, DATE_ADD(CURDATE(), INTERVAL 2 DAY)),

    -- Beverages (IDs 15-19)
    ('Orange Juice 1L', 4, 85.00, 110, DATE_ADD(CURDATE(), INTERVAL 180 DAY)),
    ('Water 500ml (12pk)', 4, 120.00, 200, NULL),
    ('Green Tea (25 bags)', 4, 95.00, 50, DATE_ADD(CURDATE(), INTERVAL 365 DAY)),
    ('Mango juice 1L', 4, 75.00, 60, DATE_ADD(CURDATE(), INTERVAL 90 DAY)), 
    ('Soda 1L', 4, 55.00, 40, NULL),

    -- Snacks (IDs 20-23)
    ('Bingo Mad Angle 200g', 5, 30.00, 180, DATE_ADD(CURDATE(), INTERVAL 120 DAY)),
    ('Tasty Nuts 200g', 5, 150.00, 75, DATE_ADD(CURDATE(), INTERVAL 180 DAY)),
    ('MilkyBar 100g', 5, 80.00, 90, DATE_ADD(CURDATE(), INTERVAL 240 DAY)),
    ('Act II popcorn (pack of 6)', 5, 60.00, 30, DATE_ADD(CURDATE(), INTERVAL 200 DAY));

INSERT INTO Sales_Transactions (Product_ID, Quantity_Sold, Sale_Price, Sale_Date) VALUES
    -- Recent sales (within last 30 days)
    (1,10, 55.00,  DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
    (2,20, 45.00,  DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
    (4,12, 35.00,  DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
    (6,25, 40.00,  DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
    (10,30, 35.00, DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
    (14,50, 30.00, DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
    (17,60, 120.00,DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
    (21,70, 30.00, DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
    (22,20, 150.00,DATE_SUB(CURDATE(), INTERVAL 8 DAY)),
    (23,35, 80.00, DATE_SUB(CURDATE(), INTERVAL 5 DAY)),

    -- Only OLD sales (> 60 days ago)
    (18,5, 75.00,  DATE_SUB(CURDATE(), INTERVAL 70 DAY)),
    (19,8, 55.00,  DATE_SUB(CURDATE(), INTERVAL 80 DAY)),
    (20,12,30.00,  DATE_SUB(CURDATE(), INTERVAL 65 DAY)),

    -- Last-month sales for revenue report (IDs 1-23 only)
    (1,20, 55.00,  DATE_SUB(CURDATE(), INTERVAL 18 DAY)),
    (6,30, 40.00,  DATE_SUB(CURDATE(), INTERVAL 25 DAY)),
    (16,35, 85.00, DATE_SUB(CURDATE(), INTERVAL 15 DAY)),
    (21,60, 30.00, DATE_SUB(CURDATE(), INTERVAL 16 DAY));

-- ============================================================
-- REPORT 1 – EXPIRING SOON
-- ============================================================
SELECT '===== REPORT 1 – EXPIRING SOON (next 7 days, stock > 50) =====' AS 'Report Name';

SELECT
    p.Product_ID,
    p.Product_Name,
    c.Category_Name,
    p.Stock_Count,
    p.Unit_Price,
    p.Expiry_Date,
    DATEDIFF(p.Expiry_Date, CURDATE()) AS Days_Until_Expiry,
    ROUND(p.Stock_Count * p.Unit_Price, 2) AS Potential_Loss
FROM
    Products p
    JOIN Categories c ON p.Category_ID = c.Category_ID
WHERE
    p.Expiry_Date IS NOT NULL
    AND p.Expiry_Date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    AND p.Stock_Count > 50
ORDER BY
    Days_Until_Expiry ASC;

-- ============================================================
-- REPORT 2 – DEAD STOCK
-- ============================================================
SELECT '===== REPORT 2 – DEAD STOCK (no sales in last 60 days) =====' AS 'Report Name';

SELECT
    p.Product_ID,
    p.Product_Name,
    c.Category_Name,
    p.Stock_Count,
    p.Unit_Price,
    ROUND(p.Stock_Count * p.Unit_Price, 2) AS Total_Stock_Value
FROM
    Products p
    JOIN Categories c ON p.Category_ID = c.Category_ID
    LEFT JOIN Sales_Transactions st 
           ON st.Product_ID = p.Product_ID 
          AND st.Sale_Date >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
WHERE
    st.Transaction_ID IS NULL
GROUP BY
    p.Product_ID, p.Product_Name, c.Category_Name, p.Stock_Count, p.Unit_Price
ORDER BY
    Total_Stock_Value DESC;

-- ============================================================
-- REPORT 3 – REVENUE BY CATEGORY (last calendar month)
-- ============================================================
SELECT '===== REPORT 3 – REVENUE BY CATEGORY (last calendar month) =====' AS 'Report Name';

SELECT
    c.Category_Name,
    COUNT(DISTINCT st.Transaction_ID) AS Total_Transactions,
    SUM(st.Quantity_Sold) AS Total_Units_Sold,
    ROUND(SUM(st.Quantity_Sold * st.Sale_Price), 2) AS Total_Revenue,
    ROUND(
        SUM(st.Quantity_Sold * st.Sale_Price) * 100.0 / 
        NULLIF((SELECT SUM(s2.Quantity_Sold * s2.Sale_Price) 
                FROM Sales_Transactions s2 
                WHERE s2.Sale_Date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)), 0), 
        2
    ) AS Revenue_Share
FROM
    Sales_Transactions st
    JOIN Products p ON st.Product_ID = p.Product_ID
    JOIN Categories c ON p.Category_ID = c.Category_ID
WHERE
    st.Sale_Date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY
    c.Category_ID, c.Category_Name
ORDER BY
    Total_Revenue DESC;

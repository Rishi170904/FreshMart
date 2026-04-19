-- FreshMart – Stock Health Report
-- Create and select the database
CREATE DATABASE IF NOT EXISTS FreshMart;
USE FreshMart;

-- SECTION 1 – SCHEMA DESIGN
DROP TABLE IF EXISTS SalesTransactions;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;

-- 1A. Categories
CREATE TABLE Categories (
    CategoryID   INT          PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL,
    Description  TEXT
);

-- 1B. Products
CREATE TABLE Products (
    ProductID    INT            PRIMARY KEY AUTO_INCREMENT,
    ProductName  VARCHAR(150)   NOT NULL,
    CategoryID   INT            NOT NULL,
    UnitPrice    DECIMAL(10,2)  NOT NULL CHECK (UnitPrice >= 0),
    StockCount   INT            NOT NULL DEFAULT 0 CHECK (StockCount >= 0),
    ExpiryDate   DATE,
    CreatedAt    DATETIME       DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 1C. SalesTransactions
CREATE TABLE SalesTransactions (
    TransactionID  INT            PRIMARY KEY AUTO_INCREMENT,
    ProductID      INT            NOT NULL,
    QuantitySold   INT            NOT NULL CHECK (QuantitySold > 0),
    SalePrice      DECIMAL(10,2)  NOT NULL CHECK (SalePrice >= 0),
    SaleDate       DATE           NOT NULL,
    CreatedAt      DATETIME       DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- SECTION 2 – DUMMY DATA

INSERT INTO Categories (CategoryName, Description) VALUES
    ('Dairy',     'Milk, cheese, yogurt, and related products'),
    ('Bakery',    'Breads, cakes, pastries, and confections'),
    ('Produce',   'Fresh fruits and vegetables'),
    ('Beverages', 'Juices, soft drinks, water, and tea'),
    ('Snacks',    'Chips, biscuits, nuts, and packaged snacks');

INSERT INTO Products (ProductName, CategoryID, UnitPrice, StockCount, ExpiryDate) VALUES
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

INSERT INTO SalesTransactions (ProductID, QuantitySold, SalePrice, SaleDate) VALUES
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
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.StockCount,
    p.UnitPrice,
    p.ExpiryDate,
    DATEDIFF(p.ExpiryDate, CURDATE()) AS DaysUntilExpiry,
    ROUND(p.StockCount * p.UnitPrice, 2) AS PotentialLossINR
FROM
    Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE
    p.ExpiryDate IS NOT NULL
    AND p.ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    AND p.StockCount > 50
ORDER BY
    DaysUntilExpiry ASC;

-- ============================================================
-- REPORT 2 – DEAD STOCK
-- ============================================================
SELECT '===== REPORT 2 – DEAD STOCK (no sales in last 60 days) =====' AS 'Report Name';

SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.StockCount,
    p.UnitPrice,
    ROUND(p.StockCount * p.UnitPrice, 2) AS TotalStockValueINR
FROM
    Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
    LEFT JOIN SalesTransactions st 
           ON st.ProductID = p.ProductID 
          AND st.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
WHERE
    st.TransactionID IS NULL
GROUP BY
    p.ProductID, p.ProductName, c.CategoryName, p.StockCount, p.UnitPrice
ORDER BY
    TotalStockValueINR DESC;

-- ============================================================
-- REPORT 3 – REVENUE BY CATEGORY (last calendar month)
-- ============================================================
SELECT '===== REPORT 3 – REVENUE BY CATEGORY (last calendar month) =====' AS 'Report Name';

SELECT
    c.CategoryName,
    COUNT(DISTINCT st.TransactionID) AS TotalTransactions,
    SUM(st.QuantitySold) AS TotalUnitsSold,
    ROUND(SUM(st.QuantitySold * st.SalePrice), 2) AS TotalRevenueINR,
    ROUND(
        SUM(st.QuantitySold * st.SalePrice) * 100.0 / 
        NULLIF((SELECT SUM(s2.QuantitySold * s2.SalePrice) 
                FROM SalesTransactions s2 
                WHERE DATE_FORMAT(s2.SaleDate, '%Y-%m') = 
                      DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m')), 0), 
        2
    ) AS RevenueSharePct
FROM
    SalesTransactions st
    JOIN Products p ON st.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE
    DATE_FORMAT(st.SaleDate, '%Y-%m') = 
    DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m')
GROUP BY
    c.CategoryID, c.CategoryName
ORDER BY
    TotalRevenueINR DESC;
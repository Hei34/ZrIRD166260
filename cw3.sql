CREATE VIEW cw3_1 AS
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS ranga
FROM EMPLOYEES;

CREATE VIEW cw3_2
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    SUM(salary) OVER () AS calkowita_salarnia;
FROM EMPLOYEES;


Ad.3.
CREATE TABLE SALES AS 
SELECT * FROM HR.SALES;
CREATE TABLE PRODUCTS AS 
SELECT * FROM HR.PRODUCTS;

CREATE VIEW AS cw3_4
SELECT 
    t.last_name,
    t.product_name,
    t.total_sales,
    RANK() OVER (ORDER BY t.total_sales DESC) AS sales_rank
FROM (
    SELECT 
        e.last_name,
        p.product_name,
        SUM(s.quantity * s.price) AS total_sales  -- Obliczamy wartość sprzedaży
    FROM SALES s
    JOIN EMPLOYEES e ON s.employee_id = e.employee_id
    JOIN PRODUCTS p ON s.product_id = p.product_id
    GROUP BY e.last_name, p.product_name
) t;

SELECT 
    s.sale_date,
    e.last_name,
    p.product_name,
    s.price AS current_price,
    COUNT(s.sale_id) OVER (PARTITION BY s.sale_date, s.product_id) AS transaction_count,
    SUM(s.sale_quantity * s.price) OVER (PARTITION BY s.sale_date, s.product_id) AS total_amount,
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS previous_price,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS next_price
FROM SALES s
JOIN EMPLOYEES e ON s.employee_id = e.employee_id
JOIN PRODUCTS p ON s.product_id = p.product_id;

CREATE VIEW AS cw3_5
SELECT 
    s.sale_date,
    e.last_name,
    p.product_name,
    s.price AS current_price,
    COUNT(s.sale_id) OVER (PARTITION BY s.sale_date, s.product_id) AS transaction_count,
    SUM(s.quantity * s.price) OVER (PARTITION BY s.sale_date, s.product_id) AS total_amount,
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS previous_price,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS next_price
FROM SALES s
JOIN EMPLOYEES e ON s.employee_id = e.employee_id
JOIN PRODUCTS p ON s.product_id = p.product_id;

CREATE VIEW AS cw3_6
SELECT 
    p.product_name AS produkt_nazwa,
    p.product_category AS kategoria_produktu,
    s.sale_date,
    EXTRACT(MONTH FROM s.sale_date) AS miesiac,
    EXTRACT(YEAR FROM s.sale_date) AS rok,
    SUM(s.quantity * s.price) AS suma_calkowita,
    SUM(SUM(s.quantity * s.price)) OVER (PARTITION BY p.product_id, EXTRACT(MONTH FROM s.sale_date), EXTRACT(YEAR FROM s.sale_date) ORDER BY s.sale_date) AS suma_rosnaca
FROM 
    sales s
JOIN 
    products p ON s.product_id = p.product_id  -- Zmieniamy products na product
GROUP BY 
    p.product_name, p.product_category, s.sale_date, p.product_id
ORDER BY 
    p.product_name, rok, miesiac;

CREATE VIEW AS cw3_7
SELECT 
    p.product_name AS produkt_nazwa,
    p.product_category AS kategoria_produktu,
    t2022.price AS cena_2022,
    t2023.price AS cena_2023,
    (t2023.price - t2022.price) AS roznica_cen
FROM 
    products p
JOIN 
    (SELECT product_id, sale_date, price
     FROM sales
     WHERE EXTRACT(YEAR FROM sale_date) = 2022) t2022
    ON p.product_id = t2022.product_id
JOIN 
    (SELECT product_id, sale_date, price
     FROM sales
     WHERE EXTRACT(YEAR FROM sale_date) = 2023) t2023
    ON p.product_id = t2023.product_id 
    AND t2022.sale_date = t2023.sale_date
ORDER BY 
    p.product_name, t2022.sale_date;
	
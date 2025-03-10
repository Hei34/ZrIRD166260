CREATE TABLE COUNTRIES AS SELECT * FROM HR.COUNTRIES,
CREATE TABLE EMPLOYEES AS SELECT * FROM HR.EMPLOYEES,
CREATE TABLE DEPARTMENTS AS SELECT * FROM HR.DEPARTMENTS,
CREATE TABLE JOBS AS SELECT * FROM HR.JOBS,
CREATE TABLE JOB_GRADES AS SELECT * FROM HR.JOB_GRADES,
CREATE TABLE REGIONS AS SELECT * FROM HR.REGIONS,
CREATE TABLE LOCATIONS AS SELECT * FROM HR.LOCATIONS,


CREATE VIEW widok1 AS SELECT last_name || ' ' || salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50)
  AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

CREATE VIEW widok2 AS
SELECT hire_date, last_name, &podajkol
FROM employees
WHERE MANAGER_ID IS NOT NULL
  AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY podajkol;

CREATE VIEW widok3 AS 
SELECT first_name || ' ' || last_name AS full_name, salary, phone_number
FROM employees
WHERE last_name LIKE '__e%'
  AND first_name LIKE '%' || &userinput || '%'
ORDER BY 1 DESC, 2 ASC;

CREATE VIEW widok4 AS SELECT 
    first_name || ' ' || last_name AS full_name, 
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS months_worked, 
    CASE 
		WHEN months_worked < 150 THEN salary * 1.1
		WHEN months_worked BETWEEN 150 AND 200 THEN salary * 1.2
		WHEN months_worked > 200 THEN salary * 1.3
        ELSE salary * 1
    END AS wysokość_dodatku
FROM employees ORDER BY months_worked;


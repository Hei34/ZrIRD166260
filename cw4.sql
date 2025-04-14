create view v_wysokie_pensje as
select salary from employees where salary > 6000

CREATE OR REPLACE view v_wysokie_pensje as
select salary from employees where salary > 12000

DROP VIEW v_wysokie_pensje;

CREATE VIEW ad4 AS SELECT e.employee_id, e.last_name, e.first_name
FROM 
    employees e
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    d.department_name = 'Finance';
	
CREATE VIEW ad5 AS
SELECT 
    employee_id,
    last_name,
    first_name,
    salary,
    job_id,
    email,
    hire_date
FROM 
    employees
WHERE 
    salary BETWEEN 5000 AND 12000;
	

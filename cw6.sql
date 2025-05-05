/*Ad. Func.1.*/
CREATE OR REPLACE FUNCTION get_job_title(p_job_id IN jobs.job_id%TYPE)
RETURN jobs.job_title%TYPE
IS
    v_title jobs.job_title%TYPE;
BEGIN
    SELECT job_title INTO v_title
    FROM jobs
    WHERE job_id = p_job_id;

    RETURN v_title;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Brak pracy o podanym ID';
END;
/*Ad. Func.2.*/
CREATE OR REPLACE FUNCTION get_annual_salary(p_emp_id IN employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_salary       employees.salary%TYPE;
    v_commission   employees.commission_pct%TYPE;
BEGIN
    SELECT salary, commission_pct INTO v_salary, v_commission
    FROM employees
    WHERE employee_id = p_emp_id;

    RETURN (v_salary * 12) + (v_salary * NVL(v_commission, 0));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/*Ad. Func.3.*/
CREATE OR REPLACE FUNCTION extract_area_code(p_phone IN VARCHAR2)
RETURN VARCHAR2
IS
    v_area_code VARCHAR2(10);
BEGIN
    v_area_code := SUBSTR(p_phone, INSTR(p_phone, '(')+1, INSTR(p_phone, ')') - INSTR(p_phone, '(') - 1);
    RETURN v_area_code;
END;
Ad. Func.4.
CREATE OR REPLACE FUNCTION capitalize_edges(p_text IN VARCHAR2)
RETURN VARCHAR2
IS
    v_result VARCHAR2(4000);
    len      PLS_INTEGER;
BEGIN
    len := LENGTH(p_text);
    IF len = 0 THEN
        RETURN '';
    ELSIF len = 1 THEN
        RETURN UPPER(p_text);
    ELSE
        v_result := UPPER(SUBSTR(p_text, 1, 1)) ||
                    LOWER(SUBSTR(p_text, 2, len - 2)) ||
                    UPPER(SUBSTR(p_text, len, 1));
        RETURN v_result;
    END IF;
END;
/*Ad. Func.5.*/
CREATE OR REPLACE FUNCTION pesel_to_birthdate(p_pesel IN VARCHAR2)
RETURN DATE
IS
    v_year  NUMBER;
    v_month NUMBER;
    v_day   NUMBER;
BEGIN
    v_year := TO_NUMBER(SUBSTR(p_pesel, 1, 2));
    v_month := TO_NUMBER(SUBSTR(p_pesel, 3, 2));
    v_day := TO_NUMBER(SUBSTR(p_pesel, 5, 2));

    IF v_month BETWEEN 1 AND 12 THEN
        v_year := 1900 + v_year;
    ELSIF v_month BETWEEN 21 AND 32 THEN
        v_year := 2000 + v_year;
        v_month := v_month - 20;
    ELSIF v_month BETWEEN 81 AND 92 THEN
        v_year := 1800 + v_year;
        v_month := v_month - 80;
    ELSE
        RETURN NULL; -- nieprawidłowy PESEL
    END IF;

    RETURN TO_DATE(v_year || '-' || LPAD(v_month, 2, '0') || '-' || LPAD(v_day, 2, '0'), 'YYYY-MM-DD');
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/*Ad. Func.6.*/
CREATE OR REPLACE FUNCTION emp_dept_count_by_country(p_country_name IN countries.country_name%TYPE)
RETURN VARCHAR2
IS
    v_country_id   countries.country_id%TYPE;
    v_dept_count   NUMBER := 0;
    v_emp_count    NUMBER := 0;
BEGIN
    SELECT country_id INTO v_country_id
    FROM countries
    WHERE country_name = p_country_name;

    SELECT COUNT(*) INTO v_dept_count
    FROM departments
    WHERE location_id IN (
        SELECT location_id FROM locations WHERE country_id = v_country_id
    );

    SELECT COUNT(*) INTO v_emp_count
    FROM employees
    WHERE department_id IN (
        SELECT department_id FROM departments
        WHERE location_id IN (
            SELECT location_id FROM locations WHERE country_id = v_country_id
        )
    );

    RETURN 'Pracownicy: ' || v_emp_count || ', Departamenty: ' || v_dept_count;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Nie znaleziono kraju o nazwie: ' || p_country_name;
END;

/*========== WYZWALACZE ============
Ad. Wyzwalacz 1.*/

CREATE TABLE archiwum_departamentów (
    id              NUMBER,
    nazwa           VARCHAR2(100),
    data_zamknięcia DATE,
    ostatni_manager VARCHAR2(100)
);
CREATE OR REPLACE TRIGGER trg_departament_delete
AFTER DELETE ON departments
FOR EACH ROW
DECLARE
    v_manager_name VARCHAR2(100);
BEGIN
    SELECT first_name || ' ' || last_name
    INTO v_manager_name
    FROM employees
    WHERE employee_id = :OLD.manager_id;

    INSERT INTO archiwum_departamentów (
        id, nazwa, data_zamknięcia, ostatni_manager
    ) VALUES (
        :OLD.department_id,
        :OLD.department_name,
        SYSDATE,
        v_manager_name
    );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO archiwum_departamentów (
            id, nazwa, data_zamknięcia, ostatni_manager
        ) VALUES (
            :OLD.department_id,
            :OLD.department_name,
            SYSDATE,
            'BRAK DANYCH'
        );
END;
--Ad. Wyzwalacz 2.
CREATE TABLE złodziej (
    id          NUMBER GENERATED ALWAYS AS IDENTITY,
    "USER"      VARCHAR2(50),
    czas_zmiany DATE
);
CREATE OR REPLACE TRIGGER trg_check_salary
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        INSERT INTO złodziej("USER", czas_zmiany)
        VALUES (USER, SYSDATE);
        RAISE_APPLICATION_ERROR(-20001, 'Wynagrodzenie poza dozwolonym zakresem (2000–26000).');
    END IF;
END;
--Ad. Wyzwalacz 3.
CREATE SEQUENCE emp_seq START WITH 1000 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER trg_emp_autoinc
BEFORE INSERT ON employees
FOR EACH ROW
WHEN (NEW.employee_id IS NULL)
BEGIN
    SELECT emp_seq.NEXTVAL INTO :NEW.employee_id FROM dual;
END;
--Ad. Wyzwalacz 4.
CREATE OR REPLACE TRIGGER trg_block_job_grades
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'Operacje na tabeli JOB_GRADES są zabronione.');
END;
--Ad. Wyzwalacz 5.
CREATE OR REPLACE TRIGGER trg_jobs_block_salary_change
BEFORE UPDATE ON jobs
FOR EACH ROW
BEGIN
    IF :OLD.min_salary IS NOT NULL AND :OLD.min_salary != :NEW.min_salary THEN
        :NEW.min_salary := :OLD.min_salary;
    END IF;

    IF :OLD.max_salary IS NOT NULL AND :OLD.max_salary != :NEW.max_salary THEN
        :NEW.max_salary := :OLD.max_salary;
    END IF;
END;


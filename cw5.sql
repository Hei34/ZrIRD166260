--ad.1.
DECLARE
    numer_max departments.department_id%TYPE;
    nowy_department_name departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id)
    INTO numer_max
    FROM departments;
    INSERT INTO departments (department_id, department_name)
    VALUES (numer_max + 10, nowy_department_name);
    DBMS_OUTPUT.PUT_LINE('Dodano departament: ' || nowy_department_name || ' z numerem ' || (numer_max + 10));
END;
--ad.2.
DECLARE
    numer_max departments.department_id%TYPE;
    nowy_department_name departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id)
    INTO numer_max
    FROM departments;
    INSERT INTO departments (department_id, department_name)
    VALUES (numer_max + 10, nowy_department_name);
    UPDATE departments
    SET location_id = 3000
    WHERE department_id = numer_max + 10;
    DBMS_OUTPUT.PUT_LINE('Dodano departament: ' || nowy_department_name || ' z numerem ' || (numer_max + 10) || ' i ustawiono location_id na 3000');
END;
--ad.3.
CREATE TABLE nowa (
    tekst VARCHAR2(20)
);
DECLARE
BEGIN
    FOR i IN 1..10 LOOP
        IF i NOT IN (4, 6) THEN
            INSERT INTO nowa (tekst) VALUES (TO_CHAR(i));
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Wstawiono liczby od 1 do 10 bez 4 i 6.');
END;
--ad.4.
DECLARE
    kraj countries%ROWTYPE;
BEGIN
    SELECT *
    INTO kraj
    FROM countries
    WHERE country_id = 'CA';
   
    DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || kraj.country_name);
    DBMS_OUTPUT.PUT_LINE('Region ID: ' || kraj.region_id);
END;
--ad.5.
DECLARE
    CURSOR c_pracownicy IS
        SELECT last_name, salary
        FROM employees
        WHERE department_id = 50;

    v_last_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    FOR rec IN c_pracownicy LOOP
        IF rec.salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(rec.last_name || ' - nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(rec.last_name || ' - dać podwyżkę');
        END IF;
    END LOOP;
END;
--ad.6.
DECLARE
    CURSOR c_pracownicy(p_min_salary NUMBER, p_max_salary NUMBER, p_name_part VARCHAR2) IS
        SELECT salary, first_name, last_name
        FROM employees
        WHERE salary BETWEEN p_min_salary AND p_max_salary
          AND UPPER(first_name) LIKE '%' || UPPER(p_name_part) || '%';

BEGIN
    DBMS_OUTPUT.PUT_LINE('Pracownicy z zarobkami 1000-5000 i literą "a":');
    FOR rec IN c_pracownicy(1000, 5000, 'a') LOOP
        DBMS_OUTPUT.PUT_LINE(rec.first_name || ' ' || rec.last_name || ' - ' || rec.salary);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Pracownicy z zarobkami 5000-20000 i literą "u":');
    FOR rec IN c_pracownicy(5000, 20000, 'u') LOOP
        DBMS_OUTPUT.PUT_LINE(rec.first_name || ' ' || rec.last_name || ' - ' || rec.salary);
    END LOOP;
END;
--ad.9.a
CREATE OR REPLACE PROCEDURE dodaj_job (
    p_job_id    jobs.job_id%TYPE,
    p_job_title jobs.job_title%TYPE
)
IS
BEGIN
    INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
    VALUES (p_job_id, p_job_title, NULL, NULL);

    DBMS_OUTPUT.PUT_LINE('Dodano nowy job: ' || p_job_id || ' - ' || p_job_title);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Podany JOB_ID już istnieje.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
--ad.9.b
DECLARE
    e_no_update EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_update, -20001)

PROCEDURE zmien_job_title (
    p_job_id    jobs.job_id%TYPE,
    p_new_title jobs.job_title%TYPE
)
IS
BEGIN
    UPDATE jobs
    SET job_title = p_new_title
    WHERE job_id = p_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak stanowiska o podanym ID - nic nie zmodyfikowano.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano job_id: ' || p_job_id || ' na tytuł: ' || p_new_title);
    END IF;

EXCEPTION
    WHEN e_no_update THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Brak stanowiska do zmiany.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
--ad.9.c
DECLARE
    -- Definicja własnego wyjątku
    e_no_delete EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_delete, -20002); -- przypisanie własnego kodu błędu

PROCEDURE usun_job (
    p_job_id jobs.job_id%TYPE
)
IS
BEGIN
    DELETE FROM jobs
    WHERE job_id = p_job_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak stanowiska o podanym ID - nic nie usunięto.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Usunięto job_id: ' || p_job_id);
    END IF;

EXCEPTION
    WHEN e_no_delete THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Brak stanowiska do usunięcia.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
--ad.9.d
CREATE OR REPLACE PROCEDURE pobierz_pracownika (
    p_employee_id IN employees.employee_id%TYPE,
    p_last_name   OUT employees.last_name%TYPE,
    p_salary      OUT employees.salary%TYPE
)
IS
BEGIN
    SELECT last_name, salary
    INTO p_last_name, p_salary
    FROM employees
    WHERE employee_id = p_employee_id;
    
    DBMS_OUTPUT.PUT_LINE('Pracownik: ' || p_last_name || ', Wynagrodzenie: ' || p_salary);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o podanym ID.');
        p_last_name := NULL;
        p_salary := NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
        p_last_name := NULL;
        p_salary := NULL;
END;
--ad.9.e
CREATE OR REPLACE PROCEDURE dodaj_pracownika (
    p_first_name   IN employees.first_name%TYPE,
    p_last_name    IN employees.last_name%TYPE,
    p_email        IN employees.email%TYPE,
    p_hire_date    IN employees.hire_date%TYPE,
    p_job_id       IN employees.job_id%TYPE,
    p_salary       IN employees.salary%TYPE
)
IS
    v_employee_id employees.employee_id%TYPE;
BEGIN
    IF p_salary > 20000 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Wynagrodzenie pracownika nie może przekroczyć 20,000.');
    END IF;

    SELECT employees_seq.NEXTVAL
    INTO v_employee_id
    FROM dual;
    INSERT INTO employees (
        employee_id, first_name, last_name, email, hire_date, job_id, salary
    )
    VALUES (
        v_employee_id, p_first_name, p_last_name, p_email, p_hire_date, p_job_id, p_salary
    );

    DBMS_OUTPUT.PUT_LINE('Dodano nowego pracownika o ID: ' || v_employee_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
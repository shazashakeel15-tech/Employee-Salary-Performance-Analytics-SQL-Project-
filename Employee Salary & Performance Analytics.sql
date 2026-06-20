/*
Task 1: Employee Master Dataset

Objective:
Create a consolidated employee dataset by joining demographic,
salary, and department information.

SQL Concepts Used:
- INNER JOIN
- Primary/Foreign Keys
- Data Modeling

Output:
- first_name
- age
- gender
- department_name
- salary
*/



SELECT
    ed.employee_id,
    ed.first_name,
    ed.age,
    ed.gender,
    es.salary,
    es.dept_id,
    pd.department_name
FROM employee_demographics ed
JOIN employee_salary es
    ON ed.employee_id = es.employee_id
JOIN parks_departments pd
    ON es.dept_id = pd.department_id;
/*
Task 2: Department Salary Analysis

Objective:
Create a department-level salary summary to analyze workforce size,
salary distribution, and payroll costs by department.

SQL Concepts Used:
- INNER JOIN
- Aggregate Functions (COUNT, AVG, MAX, MIN, SUM)
- GROUP BY
*/

SELECT
    pd.department_name,
    COUNT(*) AS total_employees,
    AVG(es.salary) AS average_salary,
    MAX(es.salary) AS highest_salary,
    MIN(es.salary) AS lowest_salary,
    SUM(es.salary) AS total_department_payroll
FROM employee_salary AS es
INNER JOIN parks_departments AS pd
    ON es.dept_id = pd.department_id
GROUP BY pd.department_name;
/*
Task 3: Employee Ranking System

Objective:
Rank employees within each department based on salary
to identify top performers and analyze salary distribution.

SQL Concepts Used:
- Window Functions (RANK / DENSE_RANK)
- PARTITION BY
- ORDER BY
- INNER JOIN
*/

SELECT
    ed.first_name,
    es.dept_id,
    es.salary,
    pd.department_name,
    dense_rank() OVER (
        PARTITION BY es.dept_id
        ORDER BY es.salary DESC
    ) AS salary_rank
FROM employee_demographics AS ed
INNER JOIN employee_salary AS es
    ON ed.employee_id = es.employee_id
INNER JOIN parks_departments AS pd
    ON es.dept_id = pd.department_id;
/*
Task 4: Top 2 Employees per Department

Objective:
Identify the top 2 highest-paid employees within each department.

SQL Concepts Used:
- Common Table Expression (CTE)
- Window Functions (RANK)
- PARTITION BY
- INNER JOIN
- Filtering Ranked Results
*/

WITH employee_ranks AS (
    SELECT
        ed.first_name,
        pd.department_name,
        es.salary,
        RANK() OVER (
            PARTITION BY es.dept_id
            ORDER BY es.salary DESC
        ) AS salary_rank
    FROM employee_demographics AS ed
    INNER JOIN employee_salary AS es
        ON ed.employee_id = es.employee_id
    INNER JOIN parks_departments AS pd
        ON es.dept_id = pd.department_id
)

SELECT
    first_name,
    department_name,
    salary,
    salary_rank
FROM employee_ranks
WHERE salary_rank <= 2
ORDER BY department_name, salary_rank;
/*
Task 5: Salary Fairness Analysis

Objective:
Compare each employee's salary against their department's
average salary and classify whether they are paid above,
below, or at the department average.

SQL Concepts Used:
- INNER JOIN
- CTE (Common Table Expression)
- AVG() OVER(PARTITION BY ...)
- CASE WHEN
*/
WITH employee_data AS (
    SELECT
        es.first_name,
        pd.department_name,
        es.salary,
        AVG(es.salary) OVER (
            PARTITION BY es.dept_id
        ) AS department_avg_salary
    FROM employee_salary AS es
    INNER JOIN parks_departments AS pd
        ON es.dept_id = pd.department_id
)
SELECT
    first_name,
    department_name,
    salary,
    department_avg_salary,
    salary - department_avg_salary AS difference_from_department_avg,
    CASE
        WHEN salary > department_avg_salary THEN 'Above Average'
        WHEN salary < department_avg_salary THEN 'Below Average'
        ELSE 'Average'
    END AS salary_status
FROM employee_data order by department_name;
/*
Task 6: Payroll Contribution Analysis

Objective:
Calculate each employee's contribution to their department's total payroll.

SQL Concepts Used:
- INNER JOIN
- CTE
- SUM() OVER(PARTITION BY ...)
- Percentage Calculations
*/

WITH employee_data AS (
    SELECT
        ed.first_name,
        pd.department_name,
        es.salary,
        SUM(es.salary) OVER (
            PARTITION BY pd.department_name
        ) AS department_total_salary
    FROM employee_demographics AS ed
    INNER JOIN employee_salary AS es
        ON ed.employee_id = es.employee_id
    INNER JOIN parks_departments AS pd
        ON es.dept_id = pd.department_id
)

SELECT
    first_name,
    department_name,
    salary,
    department_total_salary,
    ROUND(
        (salary * 100.0 / department_total_salary),
        2
    ) AS contribution_percentage
FROM employee_data
ORDER BY department_name; 










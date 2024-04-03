/************* HR EMPLOYEE DATA SET ANALYSIS *************/
/* SELECT * FROM GENERAL_DATA$ */
/*Q--1 Retrieve the total number of employees in the dataset.*/

       SELECT COUNT(DISTINCT EMP_NAME)AS TOTAL_EMP FROM GENERAL_DATA$

/*Q--2 List all unique job roles in the dataset.*/

       SELECT DISTINCT JOBROLE FROM GENERAL_DATA$ 
	   
/*Q--3 Find the average age of employees.*/
      
	   SELECT ROUND(AVG(AGE),0) AS AVG_AGE FROM GENERAL_DATA$

/*Q--4 Retrieve the names and ages of employees who 
       have worked at the company for more than 5 years.*/

	   SELECT EMP_NAME, AGE, YEARSATCOMPANY AS WITH_ORG  FROM GENERAL_DATA$
	   WHERE YEARSATCOMPANY > 5
	   
/*Q--5 Get a count of employees grouped by their department.*/

       SELECT DEPARTMENT, COUNT( DISTINCT EMP_NAME)AS EMP_COUNT FROM GENERAL_DATA$
	   GROUP BY DEPARTMENT


/*Q--6 List employees who have 'High' Job Satisfaction.*/

       /* SELECT * FROM EMPLOYEE_SURVEY_DATA$ */
      
	   WITH ABC AS (SELECT * , CASE WHEN JOBSATISFACTION =1 THEN 'LOW'
	                   WHEN JOBSATISFACTION =2 THEN 'MEDIUM'
					   WHEN JOBSATISFACTION =3 THEN 'HIGH'
					   ELSE 'VERY HIGH' 
					   END AS SAT_LEVEL
					   FROM EMPLOYEE_SURVEY_DATA$)

	   SELECT A.EMP_NAME, A.EMPLOYEEID, JOBSATISFACTION , ABC.SAT_LEVEL 
	   FROM GENERAL_DATA$ A JOIN ABC ON A.EMPLOYEEID = ABC.EMPLOYEEID
	   WHERE ABC.SAT_LEVEL ='HIGH'

/*Q--7 Find the highest Monthly Income in the dataset.*/

       SELECT MAX(MONTHLYINCOME) FROM GENERAL_DATA$

	   SELECT TOP 1 WITH TIES EMP_NAME, MONTHLYINCOME FROM GENERAL_DATA$
	   ORDER BY MONTHLYINCOME DESC


/*Q--8  list employees who have 'Travel_Rarely' as their BusinessTravel type.*/

       SELECT DISTINCT EMP_NAME, BUSINESSTRAVEL FROM GENERAL_DATA$
	   WHERE BUSINESSTRAVEL = 'TRAVEL_RARELY'


/*Q--9  Retrieve the distinct MaritalStatus categories in the dataset.*/

       SELECT DISTINCT MARITALSTATUS, COUNT(EMP_NAME)AS TOT_EMPLOYEES FROM GENERAL_DATA$
	   GROUP BY MARITALSTATUS

/*Q--10  Get a list of employees with more than 2 years of work experience 
         but less than 4 years in their current role.*/

		 WITH CTE AS
		            (SELECT EMP_NAME, YEARSATCOMPANY, JOBROLE, 
					  RANK() OVER (PARTITION BY EMP_NAME ORDER BY AGE) AS JOBROLE_RNK
					   FROM GENERAL_DATA$
					 )
		 SELECT * FROM CTE 
		 WHERE YEARSATCOMPANY>=2 AND YEARSATCOMPANY <4 AND JOBROLE_RNK=1
		 ORDER BY EMP_NAME

/*Q--11 List employees who have changed their job roles within the company
        (JobLevel and JobRole differ from their previous job).*/

		SELECT EMPLOYEEID, EMP_NAME, COUNT(JOBROLE)-1 AS ROLE_CHANGES,  
		COUNT(JOBLEVEL)-1 AS LEVEL_CHANGE
		FROM GENERAL_DATA$
		GROUP BY  EMPLOYEEID, EMP_NAME
		HAVING COUNT(JOBROLE)>1
		ORDER BY EMP_NAME

/*Q--12 Find the average distance from home for employees in each department.*/

        SELECT DEPARTMENT, ROUND(AVG(DISTANCEFROMHOME),1) AS AVG_DIST 
		FROM GENERAL_DATA$
		GROUP BY DEPARTMENT
					 
/*Q--13 Retrieve the top 5 employees with the highest MonthlyIncome.*/
        

        SELECT TOP 5 WITH TIES EMP_NAME, MONTHLYINCOME 
		FROM GENERAL_DATA$
		ORDER BY MONTHLYINCOME DESC

/*Q--13.1   Also give all employees with top 5 salaries.
            (SELF EXPLORATORY QUESTION)*/

		WITH ABC AS 
		         (SELECT MONTHLYINCOME, EMP_NAME,
		           DENSE_RANK() OVER ( ORDER BY MONTHLYINCOME DESC) AS SAL_RNK
		           FROM GENERAL_DATA$)
		SELECT * FROM ABC WHERE SAL_RNK IN (1,2,3,4,5)

/*Q--14  Calculate the percentage of employees who have had a promotion in the last year.*/

         SELECT 
		 COUNT(EMPLOYEEID) AS TOT_EMP,
		 COUNT(CASE WHEN YEARSSINCELASTPROMOTION =1 THEN EMPLOYEEID END) AS PROM_EMP,
		 CONCAT(((COUNT(CASE WHEN YEARSSINCELASTPROMOTION =1 THEN EMPLOYEEID END)*100/COUNT(EMPLOYEEID))),'%') AS PERC_PROM
		 FROM GENERAL_DATA$

/*Q--15  List the employees with the highest and lowest EnvironmentSatisfaction.
         SELECT * FROM EMPLOYEE_SURVEY_DATA$ */

         SELECT A.EMP_NAME, B.ENVIRONMENTSATISFACTION AS HIGHEST_ENV_SAT, 
		 NULL AS LOWEST_ENV_SAT
		 FROM GENERAL_DATA$ A JOIN EMPLOYEE_SURVEY_DATA$ B
		 ON A.EMPLOYEEID = B.EMPLOYEEID
		 WHERE B.ENVIRONMENTSATISFACTION=4
		 
		 UNION ALL

		 SELECT A.EMP_NAME, NULL AS HIGHEST_ENV_SAT,
		 B.ENVIRONMENTSATISFACTION AS LOWEST_ENV_SAT		 
		 FROM GENERAL_DATA$ A JOIN EMPLOYEE_SURVEY_DATA$ B
		 ON A.EMPLOYEEID = B.EMPLOYEEID
		 WHERE B.ENVIRONMENTSATISFACTION=1

/*Q--16  Find the employees who have the same JobRole and MaritalStatus.*/

         --ONLY COUNT W.R.T JOBROLE AND MARITAL STATUS--
		 SELECT JOBROLE, MARITALSTATUS, COUNT(*)AS CNT_0F_EMP
		 FROM GENERAL_DATA$
		 GROUP BY JOBROLE, MARITALSTATUS
		 HAVING COUNT(*)>1

		 --WITH EMPLOYEE DETAILS HAVING SAME ROLE AND STATUS
		 SELECT DISTINCT e1.Emp_Name, e1.MaritalStatus, e1.JobRole, e1.EmployeeID
         FROM GENERAL_DATA$ e1
         JOIN GENERAL_DATA$ e2 ON e1.MaritalStatus = e2.MaritalStatus 
                      AND e1.JobRole = e2.JobRole
                      AND e1.EmployeeID <> e2.EmployeeID
         ORDER BY e1.MaritalStatus, e1.JobRole, e1.EmployeeID;

/*Q--17  List the employees with the highest TotalWorkingYears 
         who also have a PerformanceRating of 4.*/

		 SELECT TOP 1 WITH TIES A.EMPLOYEEID, A.EMP_NAME, 
		 B.PERFORMANCERATING, A.TOTALWORKINGYEARS 
		 FROM GENERAL_DATA$ A
		 INNER JOIN MANAGER_SURVEY_DATA$ B ON A.EMPLOYEEID = B.EMPLOYEEID
		 WHERE B.PERFORMANCERATING =4
		 ORDER BY 4 DESC

/*Q--18  Calculate the average Age and JobSatisfaction for 
         each BusinessTravel type.*/

		 SELECT BUSINESSTRAVEL, ROUND(AVG(AGE),2) AS AVG_AGE, ROUND(AVG(B.JOBSATISFACTION),2) AS AVG_JOBSAT
		 FROM GENERAL_DATA$ A
		 INNER JOIN EMPLOYEE_SURVEY_DATA$ B
		 ON A.EMPLOYEEID = B.EMPLOYEEID
		 GROUP BY BUSINESSTRAVEL

/*Q--19  Retrieve the most common EducationField among employees.*/

         SELECT EDUCATIONFIELD, COUNT(EMPLOYEEID) AS TOT_EMP
		 FROM GENERAL_DATA$
		 GROUP BY EDUCATIONFIELD
		 ORDER BY 2 DESC

/*Q--20  List the employees who have worked for the company 
         the longest but haven't had a promotion.*/

		 /***( CONSIDERING YEARS_SINCE_LAST_PROMOTION = 0 MEANS PROMOTION GOT IN THIS YEAR )***/
		 SELECT EMP_NAME, YEARSSINCELASTPROMOTION, YEARSATCOMPANY
		 FROM GENERAL_DATA$
		 WHERE YEARSSINCELASTPROMOTION = YEARSATCOMPANY
		 ORDER BY 3 DESC 


		 /***( CONSIDERING YEARS_SINCE_LAST_PROMOTION = 0 MEANS NO PROMOTION )***/

         SELECT EMP_NAME, YEARSSINCELASTPROMOTION, YEARSATCOMPANY
		 FROM GENERAL_DATA$
		 WHERE YEARSATCOMPANY = (SELECT MAX(YEARSATCOMPANY) FROM
		                          GENERAL_DATA$ 
								  WHERE YEARSSINCELASTPROMOTION=0)
		 AND  YEARSSINCELASTPROMOTION = 0 









         

		
		

       
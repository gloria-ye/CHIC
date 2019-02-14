/* 
2018 Q1: 2017-04-01 to 2018-03-31
Diabetes HbA1C < 8	
Source: HEDIS 2018 
Def: Percentage of diabetes Patients who had their HbA1c levels under 8% 
	Numerator Def:Patients with the most recent hemoglobin A1c (HbA1c) level less than 8.0%

			Numerator Exclusions: 
				A patient is not numerator compliant if
				•	if the result for the most recent HbA1c test is less than or equal to 8.0% 
				•	If missing a result
				•	If an HbA1c test was not done during the measurement year 
				but they will be a part of the denominator.
	Denominator Def:	Patients between 18 to 75 years of age at the end of the measurement year as with a diagnosis of diabetes (type 1 and type 2)
			Denominator inclusions: 
				At least two outpatient visits, observation visits, ED visits or non-acute inpatient on different dates of service, with a diagnosis of diabetes during the measurement year or year prior 
																										--OR-- 
				With at least one acute inpatient encounter with a diagnosis of diabetes during the measurement year or year prior. Visit type need not be the same for the two visits. 
			Denominator Exclusions: 
				•	who do not have a diagnosis of diabetes
				•	who had a diagnosis of gestational diabetes or steroid-induced diabetes in any setting, during the measurement year or the year prior to the measurement year
*/


/*
Numerator
	Patients with the most recent hemoglobin A1c (HbA1c) level less than 8.0%
*/

SELECT DISTINCT patient_diagnosis.person_id, MAX (lab_results_obx.observ_value) as last_A1c_test_result
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
INNER JOIN lab_results_obx on lab_results_obx.person_id = patient_diagnosis.person_id
WHERE 
billable_timestamp >= '2017-07-01 00:00.000'
AND billable_timestamp <='2018-06-30 23:59.999'
AND billable_ind = 'Y'
AND person.date_of_birth >= '1943-06-30'
AND person.date_of_birth <='2000-06-30'
AND diagnosis_code_id in ('E10', 'E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND lab_results_obx.obs_date_time >= '2017-07-01 00:00.000'
AND lab_results_obx.obs_date_time <= '2018-06-30 23:59.999'
AND lab_results_obx.obs_id like '50026400%'
AND (lab_results_obx.observ_value < '8.0' and LEN(lab_results_obx.observ_value) <= 3)
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 2


/* 2017 Q3: 436 */

/*Denominator
	Patients between 18 to 75 years of age at the end of the measurement year as with a diagnosis of diabetes (type 1 and type 2)
*/
SELECT DISTINCT patient_diagnosis.person_id, COUNT(patient_encounter.billable_timestamp)as number_of_encounters
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
WHERE 
billable_timestamp >= '2017-07-01 00:00.000'
AND billable_timestamp <='2018-06-30 23:59.999'
AND billable_ind = 'Y'
AND person.date_of_birth >= '1943-06-30'
AND person.date_of_birth <='2000-06-30' 
AND diagnosis_code_id in ('E10', 'E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 2


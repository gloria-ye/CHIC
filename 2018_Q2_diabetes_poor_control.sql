/* Diabetes HbA1C >9 
Poor Control
Source: HEDIS 2018
Def: Percentage of diabetes patients with poorly controlled HbA1c levels > 9%

Numerator:
Patients with the most recent hemoglobin A1c (HbA1c) level greater than 9.0%

Numerator Inclusion: 
	A patient is numerator compliant if: 
		If the most recent HbA1c level is >9.0%,
		If missing a result,
		If an HbA1c test was not done during the measurement year.

Numerator Exclusion: The patient is not numerator compliant if the result for the most recent HbA1c test during the measurement year is ≤9.0%.

Denominator:
Patients between 18 to 75 years of age at the end of the measurement year as with a diagnosis of diabetes (type 1 and type 2)
Denominator inclusions: 
At least two outpatient visits, observation visits, ED visits or non-acute inpatient on different dates of service, with a diagnosis of diabetes during the measurement year or year prior --OR-- With at least one acute inpatient encounter with a diagnosis of diabetes during the measurement year or year prior. Visit type need not be the same for the two visits. 
Denominator Exclusions: 
•	Patients who do not have a diagnosis of diabetes.
•	Patients who had a diagnosis of gestational diabetes or steroid-induced diabetes in any setting, during the measurement year or the year prior to the measurement year.
*/
	

/* Numerator */

/* 2017-07-01 to 2018-06-30 */
SELECT DISTINCT patient_diagnosis.person_id, MAX (lab_results_obx.observ_value) as last_A1c_test_result
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
INNER JOIN lab_results_obx on lab_results_obx.person_id = patient_diagnosis.person_id
WHERE 
billable_timestamp >= '2017-07-01'
AND billable_timestamp <='2018-06-30' 
AND billable_ind = 'Y'
AND person.date_of_birth >= '1943-06-30'
AND person.date_of_birth <='2000-06-30' 
AND diagnosis_code_id in ('E10', 'E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND lab_results_obx.obs_date_time >= '2017-07-01 00:00.000'
AND lab_results_obx.obs_date_time <= '2018-06-30 23:59.900'
and lab_results_obx.obs_id like '%A1c%'
AND (lab_results_obx.observ_value > '9.0' or (lab_results_obx.observ_value >= '10.0' and LEN(lab_results_obx.observ_value) >=4))
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 2



/* Denominator */
SELECT DISTINCT patient_diagnosis.person_id, count (patient_encounter.billable_timestamp) as number_of_enc
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
WHERE 
billable_ind = 'Y'
AND billable_timestamp >= '2017-07-01'
AND billable_timestamp <='2018-06-30'
AND person.date_of_birth >= '1943-06-30'
AND person.date_of_birth <='2000-06-30' 
AND diagnosis_code_id in ('E10', 'E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 2


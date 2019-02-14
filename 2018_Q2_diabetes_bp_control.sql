/* 
Diabetes BP <140/90
Def: Percentage of diabetes patients with their blood pressure under control 
*/

/* Numerator
Numerator Def:		Patients identified with their most recent blood pressure less than <140/90 mm Hg
			Numerator Inclusions:
				•	A patient is numerator compliant if the BP is <140/90 mm Hg. 
				Additional information/directions /notes:
				- Identify the most recent blood pressure (BP) reading taken during an outpatient visit or a non- acute inpatient encounter during the measurement year.
				- If there are multiple BPs on the same date of service, use the lowest systolic and lowest diastolic BP on that date as the representative BP.
				The systolic and diastolic results do not need to be from the same reading when multiple readings are recorded for a single date.
			Numerator Exclusions: 
				•	If the BP is more than or equal to 140/90 mm Hg
				•	If there is no BP reading during the measurement year 
				•	If the reading is incomplete (e.g., the systolic or diastolic level is missing). 
				•	Taken during an acute inpatient stay or an ED visit.
				•	Taken on the same day as a diagnostic test or diagnostic or therapeutic procedure that requires a change in diet or change in medication on or one day before the day of the test or procedure, with the exception of fasting blood tests.
				•	Reported by or taken by a patient.
 */
SELECT DISTINCT vital_signs_.person_id,
person_last_bp.last_time_bp_taken,
min (vital_signs_.bp_systolic)as min_bp_systolic,
min (vital_signs_.bp_diastolic)as min_bp_diastolic
FROM vital_signs_
INNER JOIN patient_encounter ON patient_encounter.enc_id = vital_signs_.enc_id
INNER JOIN patient_diagnosis ON vital_signs_.person_id = patient_diagnosis.person_id
INNER JOIN person ON vital_signs_.person_id = person.person_id
INNER JOIN (SELECT vital_signs_.person_id, count(*)as cnt,
MAX (vital_signs_.create_timestamp) as last_time_bp_taken 
FROM vital_signs_
WHERE
bp_systolic is NOT NULL and bp_diastolic is NOT NULL
GROUP BY vital_signs_.person_id) person_last_bp 
ON vital_signs_.person_id = person_last_bp.person_id 
AND vital_signs_.create_timestamp = person_last_bp.last_time_bp_taken
WHERE 
vital_signs_.create_timestamp >= '2017-07-01 00:00.000'
AND vital_signs_.create_timestamp <= '2018-06-30 23:59.999'
AND vital_signs_.bp_systolic is NOT NULL AND vital_signs_.bp_diastolic is NOT NULL
AND vital_signs_.bp_systolic < 140 AND vital_signs_.bp_diastolic < 90 
AND patient_diagnosis.diagnosis_code_id in ('E10', 'E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND patient_encounter.billable_timestamp >= '2017-07-01 00:00.000'
AND patient_encounter.billable_timestamp <='2018-06-30 23:59.999'
AND patient_encounter.billable_ind = 'Y'
AND person.date_of_birth >= '1943-06-30'
AND person.date_of_birth <='2000-06-30' 
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY vital_signs_.person_id, person_last_bp.last_time_bp_taken
HAVING COUNT(patient_encounter.billable_timestamp) >= 2

/* Denomitor 
Patients between 18 to 75 years of age at the end of the measurement year as with a diagnosis of diabetes (type 1 and type 2)
			Denominator inclusions: 
				At least two outpatient visits, observation visits, ED visits or non-acute inpatient on different dates of service, with a diagnosis of diabetes during the measurement year or year prior --OR-- With at least one acute inpatient encounter with a diagnosis of diabetes during the measurement year or year prior. Visit type need not be the same for the two visits. 
			Denominator Exclusions: 
				•	Patients who do not have a diagnosis of diabetes. 
				•	Patients who had a diagnosis of gestational diabetes or steroid-induced diabetes in any setting, during the measurement year or the prior to the measurement year
*/
SELECT DISTINCT patient_diagnosis.person_id, COUNT(patient_encounter.billable_timestamp)as number_of_encounters
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
WHERE 
billable_timestamp >= '2017-07-01 00:00.000'
AND billable_timestamp <= '2018-06-30 23:59.999'
AND billable_ind = 'Y'
AND person.date_of_birth >= '1943-06-30'
AND person.date_of_birth <='2000-06-30' 
AND diagnosis_code_id in ('E10', 'E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 2
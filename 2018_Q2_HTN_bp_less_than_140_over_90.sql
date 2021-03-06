/* Hypertension Control 
 Percentage of patients age 18-85 
 diagnosed with hypertension who have a blood pressure reading below 140/90 mmHg for the measurement period. */
 
 /* Numerator:
 "Patients in the denominator whose BP was adequately controlled during the measurement year.

Numerator inclusions: 
The Patients in the denominator whose most recent BP (both systolic and diastolic) is adequately controlled during the measurement year based on the following criteria:
i) Patients 18–59 years of age as of the last day of the measurement period whose BP was < 140/90 mm Hg.
ii) Patients 60–85 years of age as of the last day of the measurement period of who were flagged with a diagnosis of diabetes and whose BP was < 140/90 mm Hg.
iii) Patients 60–85 years of age as of as of the last day of the measurement period who were flagged as not having a diagnosis of diabetes and whose BP was < 150/90 mm Hg. 
• If there are multiple BPs on the same date of service, use the lowest systolic and lowest diastolic BP on that date as the representative BP.
• The reading must occur after the date when the diagnosis of hypertension was confirmed.   

Numerator exclusions: 
• If the BP reading did not meet the specified threshold or is missing, 
• if there is no BP reading during the measurement year 
• if the reading is incomplete (e.g., the systolic or diastolic level is missing).
• Taken during an acute inpatient stay or an ED visit.
• Taken on the same day as a diagnostic test or diagnostic or therapeutic procedure that requires a change in diet or change in medication on or one day before the day of the test or procedure, with the exception of fasting blood tests.
• Reported by or taken by a patient.
" */


/* Numerator */

/* Patients 60–85 years of age as of the last day of the measurement period 
who were flagged with a diagnosis of diabetes and whose BP was < 140/90 mm Hg.*/
SELECT  vital_signs_.person_id,
person_last_bp.last_time_bp_taken,
min (vital_signs_.bp_systolic)as min_bp_systolic,
min (vital_signs_.bp_diastolic)as min_bp_diastolic
FROM vital_signs_
INNER JOIN patient_encounter ON patient_encounter.enc_id = vital_signs_.enc_id
INNER JOIN patient_diagnosis ON vital_signs_.person_id = patient_diagnosis.person_id
INNER JOIN person ON vital_signs_.person_id = person.person_id
INNER JOIN 
    (SELECT vital_signs_.person_id, count(*)as cnt,
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
AND person.date_of_birth >= '1933-06-30'
AND person.date_of_birth <='1958-06-30' 
AND vital_signs_.bp_systolic < 140 AND vital_signs_.bp_diastolic < 90 
AND patient_diagnosis.diagnosis_code_id in ( 'I16.9', 'I16.0', 'I15.1','I10', 'I11', 'I12', 'I13', 'I14','I15', 'I16', '401.9', '997.91', '401.0','401.1', '402.11', '402.90', '403.10', '404.90', '404.91', 'R03.0', 'Z86.79', 'I15.9', 'E10', 'E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND patient_diagnosis.diagnosis_code_id NOT in ('585.6', '586', '584.9', 'N18.6', 'N17.9', 'N19')
AND patient_encounter.billable_timestamp >= '2017-07-01 00:00.000'
AND patient_encounter.billable_timestamp <='2018-06-30 23:59.999'
AND patient_encounter.billable_ind = 'Y' 
AND patient_diagnosis.create_timestamp <= DATEADD(MONTH, +6, '2017-07-01')
AND patient_diagnosis.create_timestamp >= DATEADD (YEAR, -1, '2017-07-01')
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY vital_signs_.person_id, person_last_bp.last_time_bp_taken
HAVING COUNT(patient_encounter.billable_timestamp) >= 1

UNION
/* Patients 60–85 years of age as of as of the last day of the measurement period 
who were flagged as not having a diagnosis of diabetes and whose BP was < 150/90 mm Hg. */
SELECT vital_signs_.person_id,
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
vital_signs_.create_timestamp >='2017-07-01 00:00.000'
AND vital_signs_.create_timestamp <= '2018-06-30 23:59.999'
AND vital_signs_.bp_systolic is NOT NULL AND vital_signs_.bp_diastolic is NOT NULL
AND person.date_of_birth >= '1933-06-30'
AND person.date_of_birth <='1958-06-30' 
AND vital_signs_.bp_systolic < 150 AND vital_signs_.bp_diastolic < 90 
AND patient_diagnosis.diagnosis_code_id in ( 'I16.9', 'I16.0', 'I15.1','I10', 'I11', 'I12', 'I13', 'I14','I15', 'I16', '401.9', '997.91', '401.0','401.1', '402.11', '402.90', '403.10', '404.90', '404.91', 'R03.0', 'Z86.79', 'I15.9')
AND patient_diagnosis.diagnosis_code_id NOT in ('585.6', '586', '584.9', 'N18.6', 'N17.9', 'N19', 'E10','E11', '250%', '250', '250.02','250.03', '250.43', '250.71', '648.01', 'E11.22', 'E11.65', 'E11.9', 'O24.439')
AND patient_encounter.billable_timestamp >= '2017-07-01 00:00.000'
AND patient_encounter.billable_timestamp <= '2018-06-30 23:59.999'
AND patient_encounter.billable_ind = 'Y' 
AND patient_diagnosis.create_timestamp <= DATEADD(MONTH, +6, '2017-07-01')
AND patient_diagnosis.create_timestamp >= DATEADD (YEAR, -1, '2017-07-01')
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY vital_signs_.person_id, person_last_bp.last_time_bp_taken
HAVING COUNT(patient_encounter.billable_timestamp) >= 1

UNION

/* Patients 18–59 years of age as of the last day of the measurement period whose BP was < 140/90 mm Hg. */
SELECT vital_signs_.person_id,
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
AND person.date_of_birth >= '1959-06-30'
AND person.date_of_birth <='2000-06-30' 
AND vital_signs_.bp_systolic < 140 AND vital_signs_.bp_diastolic < 90
AND patient_diagnosis.diagnosis_code_id in ( 'I16.9', 'I16.0', 'I15.1','I10', 'I11', 'I12', 'I13', 'I14','I15', 'I16', '401.9', '997.91', '401.0','401.1', '402.11', '402.90', '403.10', '404.90', '404.91', 'R03.0', 'Z86.79', 'I15.9')
AND patient_diagnosis.diagnosis_code_id NOT in ('585.6', '586', '584.9', 'N18.6', 'N17.9', 'N19')
AND patient_encounter.billable_timestamp >= '2017-07-01 00:00.000'
AND patient_encounter.billable_timestamp <= '2018-06-30 23:59.999'
AND patient_encounter.billable_ind = 'Y' 
AND patient_diagnosis.create_timestamp <= DATEADD(MONTH, +6, '2017-07-01')
AND patient_diagnosis.create_timestamp >= DATEADD (YEAR, -1, '2017-07-01')
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY vital_signs_.person_id, person_last_bp.last_time_bp_taken
HAVING COUNT(patient_encounter.billable_timestamp) >= 1

/* Denominator:
Patient between ages 18-85 with a diagnosis of Hypertension with at least one outpatient visit. To confirm the diagnosis, find notation of one of the following in the medical record:
• HTN
• High blood pressure (HBP)
• Elevated blood pressure (↑BP)
• Borderline HTN
• Intermittent HTN
• History of HTN
• Hypertensive vascular disease (HVD)
• Hyperpiesia
• Hyperpiesis

Important note:
Patients who were diagnosed with hypertension in the most recent six months of the measurement period should be excluded from the denominator. In other words, the diagnosis of HTN may have been made during the first six months of the measurement year or year prior, but not within the last six months of the measurement year. 

Denominator Exclusions:  
• Patients with evidence of end-stage renal disease (ESRD) or kidney transplant or kidney transplant on or prior to the end of the measurement year.
• Female patients with a diagnosis of pregnancy during the measurement year. */

/* SELECT patient_diagnosis.person_id
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.person_id = patient_diagnosis.person_id
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
WHERE  
billable_timestamp >= '2016-10-01 00:00.000'
AND billable_timestamp <= '2017-09-30 23:59.999'
AND billable_ind = 'Y'
AND person.date_of_birth >= '1932-12-31'
AND person.date_of_birth <='1999-12-31' 
AND patient_diagnosis.diagnosis_code_id in ('I16.9', 'I16.0', 'I15.1','I10', 'I11', 'I12', 'I13', 'I14','I15', 'I16', '401.9', '997.91', '401.0','401.1', '402.11', '402.90', '403.10', '404.90', '404.91', 'R03.0', 'Z86.79', 'I15.9')
AND patient_diagnosis.diagnosis_code_id NOT in ('585.6', '586', '584.9', 'N18.6', 'N17.9', 'N19')
AND patient_diagnosis.create_timestamp  <= DATEADD(MONTH, +6, '2016-10-01')
AND patient_diagnosis.create_timestamp >= DATEADD (YEAR, -1, '2016-10-01')
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 1 */

SELECT DISTINCT patient_diagnosis.person_id
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.person_id = patient_diagnosis.person_id
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
WHERE  
billable_timestamp >= '2017-07-01 00:00.000'
AND billable_timestamp <= '2018-06-30 23:59.999'
AND billable_ind = 'Y'
AND person.date_of_birth >= '1933-06-30'
AND person.date_of_birth <='2000-06-30' 
AND patient_diagnosis.diagnosis_code_id in ('I16.9', 'I16.0', 'I15.1','I10', 'I11', 'I12', 'I13', 'I14','I15', 'I16', '401.9', '997.91', '401.0','401.1', '402.11', '402.90', '403.10', '404.90', '404.91', 'R03.0', 'Z86.79', 'I15.9')
AND patient_diagnosis.diagnosis_code_id NOT in ('585.6', '586', '584.9', 'N18.6', 'N17.9', 'N19')
AND NOT (person.sex = 'F' and patient_diagnosis.create_timestamp >= '2017-07-01' and patient_diagnosis.create_timestamp <= '2018-03-31'and patient_diagnosis.diagnosis_code_id in ('Z34.8%', 'Z34.9%', 'Z39.%', 'Z3A.%', 'Z34.0%', 'Z32.01', 'Z33.1', 'Z33.2', 'V72.4%', 'V28.9', 'V22.%', 'V23.81', 'V23.84', 'S60.2', 'O99.%', '098.219', 'O98.419', 'O90.6', 'O90.89', 'O86.0', 'O86.13', 'O70.9', 'O70.9', 'O62.2', 'O48.0', 'O40.%', 'O43.113', 'O28.3', 'O26.%', 'O24.%', 'O23.%', 'O20.%', '016.5', '013.%', 'O12.03', 'O09.%', 'O00.1', 'F53', '676.%', '675.%', '674.%', '673.%','671.%', '670.%', '669.%', '664.%', '659.%', '654.%', '649.%', '648.%', '646.%', '643.%', '642.%', '640.%', '633.%'))
AND patient_diagnosis.create_timestamp <= DATEADD(MONTH, +6, '2017-07-01')
AND NOT (person.first_name like '%test' or person.last_name like '%test')
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 1
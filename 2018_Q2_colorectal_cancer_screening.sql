/*Fecal Occult*/
SELECT DISTINCT patient_.full_name, patient_diagnosis.person_id, MAX (lab_results_obx.observ_value) as last_fecal_test_result
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
INNER JOIN patient_ ON patient_.person_id = patient_diagnosis.person_id
INNER JOIN lab_results_obx on lab_results_obx.person_id = patient_diagnosis.person_id 
WHERE person.date_of_birth <= '1968-03-31'
AND person.date_of_birth >= '1943-03-31'
AND obs_id like '%fecal globin%' and (obs_id not like '%lipids%')and (obs_id not like '%fat%')
AND lab_results_obx.obs_date_time >= '2017-04-01'
AND lab_results_obx.obs_date_time <= '2018-03-31'
AND patient_encounter.enc_timestamp >= '2017-04-01 00:00:00.000' and patient_encounter.enc_timestamp <= '2018-03-31'
AND not(patient_.full_name like '%test%' or  patient_.full_name like '%patient%' )
AND billable_ind = 'Y'
GROUP by patient_.full_name, patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 1


/* colonoscopy*/
SELECT distinct patient_.full_name /* , order_.actText, order_.actStatus, order_.completedDate*/from order_
INNER JOIN patient_ ON patient_.person_id = order_.person_id
INNER JOIN person ON person.person_id = order_.person_id
INNER JOIN patient_encounter on patient_encounter.person_id = order_.person_id
WHERE order_.actText like '%colonoscopy%' 
AND order_.create_timestamp >= '2009-07-01' 
AND patient_encounter.create_timestamp between '2017-07-01' and '2018-06-30'
and order_.actStatus in ('completed', 'result received')
AND NOT (patient_.full_name like '%Test%' or patient_.full_name like '%patient%' or patient_.full_name  like '%MCHC%')
AND person.date_of_birth <= '1968-06-30'
AND person.date_of_birth >= '1943-06-30'


SELECT DISTINCT patient_.full_name, patient_diagnosis.person_id
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
INNER JOIN patient_ ON patient_.person_id = patient_diagnosis.person_id
INNER JOIN order_ on order_.person_id = patient_diagnosis.person_id 
WHERE person.date_of_birth <= '1968-03-31'
AND person.date_of_birth >= '1943-03-3'
AND order_.actDiagnosisCode in ('Z12.11', 'Z12.12','Z86.010','Z13.811')
AND order_.actText like 'colonoscopy%'
and (order_.actStatus = 'completed' or order_.actStatus = 'result received')
AND (CAST (order_.orderedDate  as datetime) >= '2009-04-01' OR (patient_encounter.enc_timestamp >= '2017-04-01 00:00:00.000' and patient_encounter.enc_timestamp <= '2018-06-30'))
AND NOT (patient_.full_name like '%test%' or  patient_.full_name like '%patient%' )
AND billable_ind = 'Y'
GROUP by patient_.full_name, patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 1

/* Flexible sigmoidpscopy */
SELECT DISTINCT patient_.full_name, patient_diagnosis.person_id
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
INNER JOIN patient_ ON patient_.person_id = patient_diagnosis.person_id
INNER JOIN order_ on order_.person_id = patient_diagnosis.person_id 
WHERE person.date_of_birth <= '1968-06-30'
AND person.date_of_birth >= '1943-06-30'
AND order_.actDescription like '%sigmoidoscopy%'
and (order_.actStatus = 'completed' or order_.actStatus = 'result received')
AND (CAST (order_.orderedDate  as datetime) >= '2014-07-01' OR patient_encounter.enc_timestamp >= '2017-07-01 00:00:00.000' and patient_encounter.enc_timestamp <= '2018-06-30')
AND NOT (patient_.full_name like '%test%' or  patient_.full_name like '%patient%' )
AND billable_ind = 'Y'
GROUP by patient_.full_name, patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 1

/* Denominator */
SELECT COUNT (DISTINCT patient_diagnosis.person_id)
FROM patient_diagnosis
INNER JOIN person ON person.person_id = patient_diagnosis.person_id 
INNER JOIN patient_encounter ON patient_encounter.person_id = patient_diagnosis.person_id
WHERE CAST (billable_timestamp as date) >= '2017-04-01'
AND CAST (billable_timestamp as date) <= '2018-03-31'
AND billable_ind = 'Y' 
AND person.date_of_birth <= '1968-03-31'
AND person.date_of_birth >= '1943-03-31'
AND patient_diagnosis.person_id = person.person_id
AND patient_diagnosis.diagnosis_code_id NOT IN ('C18.%', 'Z90.49')
HAVING COUNT(patient_encounter.billable_timestamp) >= 1


/* select distinct obs_id from lab_results_obx where obs_id like'%stool%' or obs_id like '%fecal%' and (obs_id not like '%lipids%')and (obs_id not like '%fat%')*/
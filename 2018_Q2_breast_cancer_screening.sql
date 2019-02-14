SELECT DISTINCT patient_diagnosis.person_id
FROM patient_diagnosis
INNER JOIN patient_encounter ON patient_encounter.enc_id = patient_diagnosis.enc_id 
INNER JOIN person ON person.person_id = patient_diagnosis.person_id
INNER JOIN patient_ ON patient_.person_id = patient_diagnosis.person_id
INNER JOIN order_ on order_.person_id = patient_diagnosis.person_id 
WHERE person.sex = 'F'
AND person.date_of_birth <= '1966-06-30'
AND person.date_of_birth >= '1944-06-30'
AND order_.actDiagnosisCode in ('Z12.31','Z12.39')
AND (order_.actStatus = 'completed' or /* order_.actStatus = 'obtained' or */ order_.actStatus = 'result received')
AND CAST (order_.orderedDate  as datetime) >= '2016-07-01' 
AND patient_encounter.enc_timestamp >= '2017-07-01 00:00:00.000' and patient_encounter.enc_timestamp <= '2018-06-30'
AND not(patient_.full_name like '%test%' or  patient_.full_name like '%patient%' )
GROUP BY patient_diagnosis.person_id
HAVING COUNT(patient_encounter.billable_timestamp) >= 1



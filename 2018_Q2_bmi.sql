/* The percentage of patients aged 18 years and older 
with a calculated BMI in the past six months or during the current visit documented in the medical record 
AND if the most recent BMI is outside parameters a follow-up plan is documented */
/* BMI > 18.5 and < 25 */
SELECT vital_signs_.person_id, MAX (vital_signs_.BMI_calc) most_recent_BMI_calc
FROM vital_signs_
INNER JOIN
	(SELECT vital_signs_.person_id, vital_signs_.enc_id
	FROM vital_signs_
	INNER JOIN 		
		(SELECT  vital_signs_.person_id  , MAX (vital_signs_.create_timestamp) max_vital_sign_time
		FROM vital_signs_
		INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
		INNER JOIN
			(SELECT DISTINCT vital_signs_.person_id, patient_encounter.create_timestamp max_enc_time
			FROM vital_signs_
			INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
			INNER JOIN
				(SELECT  vital_signs_.person_id, MAX (patient_encounter.create_timestamp) last_enc_time
				FROM vital_signs_
				INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
				WHERE vital_signs_.BMI_calc is NOT NULL
				group BY vital_signs_.person_id) last_enc
			ON vital_signs_.person_id = last_enc.person_id AND DATEDIFF (mm, patient_encounter.create_timestamp, last_enc.last_enc_time) < 6
			WHERE vital_signs_.BMI_calc is NOT NULL
			/* ORDER BY vital_signs_.person_id, patient_encounter.create_timestamp DESC */) most_recent_enc
		ON most_recent_enc.person_id = vital_signs_.person_id AND most_recent_enc.max_enc_time = patient_encounter.create_timestamp
		WHERE vital_signs_.BMI_calc is NOT NULL
		GROUP BY vital_signs_.person_id) most_recent_vital_time 
ON vital_signs_.person_id = most_recent_vital_time.person_id AND vital_signs_.create_timestamp = most_recent_vital_time.max_vital_sign_time) most_recent_vital_enc
ON most_recent_vital_enc.person_id = vital_signs_.person_id AND most_recent_vital_enc.enc_id = vital_signs_.enc_id
INNER JOIN master_im_ on master_im_.person_id = vital_signs_.person_id AND master_im_.enc_id = most_recent_vital_enc.enc_id
INNER JOIN patient_diagnosis ON patient_diagnosis.person_id = vital_signs_.person_id
INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
WHERE 
/* (vital_signs_.BMI_calc >= '25' or vital_signs_.BMI_calc <= '18.5')*/
(vital_signs_.BMI_calc < '25' AND vital_signs_.BMI_calc > '18.5')
AND patient_encounter.billable_timestamp >= '2017-07-01'
AND patient_encounter.billable_timestamp <='2018-06-30'
AND billable_ind = 'Y'
AND master_im_.age >= '18'
and NOT (master_im_.age >= '18' and master_im_.age <= '64'
and diagnosis_code_id in ('O09.211', 'O09.291', 'O09.511', 'O09.521', 'O09.891', 'O23.41', 'O23.591', 'O23.91','O24.410', 'O24.419', 'O24.911', 'O26.21', 'O26.841', 'O26.891', 'O30.001', 'O41.8X10', 'O99.011', 'O99.331', 'Z34.01', 'Z34.81', 'Z34.91', 'O09.212', 'O09.512', 'O09.522', 'O09.892', 'O16.2', 'O23.42', 'O24.410', 'O24.419', 'O26.02', 'O26.12', 'O26.892', 'O26.92', 'O30.002', 'O36.0120', 'O43.112', 'O43.192', 'O44.42', 'O99.012', 'O99.712', 'Z33.1', 'Z34.02', 'Z34.82', 'Z34.92', '644.03', 'O09.893', 'O12.03', 'O13.3', 'O14.93', 'O16.3', 'O23.43', 'O23.93', 'O24.410', 'O26.03', 'O26.613', 'O26.843', 'O36.0130', 'O36.5930', 'O36.63X0', 'O36.8130', 'O43.113', 'O99.013', 'O99.343', 'Z34.03', 'Z34.83', 'Z34.93'))
and NOT (master_im_.age > '65' and diagnosis_code_id in ('G30.8', 'G30.9', '294.8', 'F02.81', 'F03.90', '294.11', '294.10', 'F02.80', 'F03.91', 'G30.0', 'Z86.59', 'F06.8', '290.13', '290.10', '290.21', '290.0', 'F03.91', 'F01.51', '780.97', 'R41.82', 'F99', 'F48.9', '319', 'F79', 'V40.1', 'F81.9', 'V40.0', 'F79', 'F06.8', 'R68.89', 'Z86.59', 'Z91.89', '318.2', '318.1', 'V40.9', '319', '300.9', '310.9', '294.9', '309.0', 'F43.23', 'F41.8', 'F41.9', '300.4', '296.80', '779.2', 'F32.9', '311', 'O99.340', 'O99.345', 'O99.343', 'R51', 'F33.0', 'F33.1', 'F32.1', 'F53', 'F32.3', 'F32.8', 'F33.9', 'F41.8', '296.20', 'F34.1', '296.80', 'F32.2', 'R68.89', 'F43.21', '309.0', '298.9', 'R41.0', '281.8', 'Z71.1', 'D53.9', '269.9', 'D51.9', 'E53.8', '269.1', '266.9', 'E56.1', 'R74.8', 'Z86.39', 'E56.9', '268.9', 'E55.9', '268.9', 'R79.89', 'D51.3', '264.8', '281.1', 'D51.8', '264.9', '269.2', '264.2', '264.5', 'E50.5', 'E53.8', '281.1', '266.2', 'E56.9', '269.1','R79.0', '275.8', '799.4', 'R63.4', 'R63.5', '783.41', '783.1'))
and not vital_signs_.chk_Refused = '1'
GROUP BY vital_signs_.person_id
UNION
SELECT vital_signs_.person_id, MAX (vital_signs_.BMI_calc) most_recent_BMI_calc
FROM vital_signs_
INNER JOIN
	(SELECT vital_signs_.person_id, vital_signs_.enc_id
	FROM vital_signs_
	INNER JOIN 		
		(SELECT  vital_signs_.person_id  , MAX (vital_signs_.create_timestamp) max_vital_sign_time
		FROM vital_signs_
		INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
		INNER JOIN
			(SELECT DISTINCT vital_signs_.person_id, patient_encounter.create_timestamp max_enc_time
			FROM vital_signs_
			INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
			INNER JOIN
				(SELECT  vital_signs_.person_id, MAX (patient_encounter.create_timestamp) last_enc_time
				FROM vital_signs_
				INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
				WHERE vital_signs_.BMI_calc is NOT NULL
				group BY vital_signs_.person_id) last_enc
			ON vital_signs_.person_id = last_enc.person_id AND DATEDIFF (mm, patient_encounter.create_timestamp, last_enc.last_enc_time) < 6
			WHERE vital_signs_.BMI_calc is NOT NULL
			/* ORDER BY vital_signs_.person_id, patient_encounter.create_timestamp DESC */) most_recent_enc
		ON most_recent_enc.person_id = vital_signs_.person_id AND most_recent_enc.max_enc_time = patient_encounter.create_timestamp
		WHERE vital_signs_.BMI_calc is NOT NULL
		GROUP BY vital_signs_.person_id) most_recent_vital_time 
ON vital_signs_.person_id = most_recent_vital_time.person_id AND vital_signs_.create_timestamp = most_recent_vital_time.max_vital_sign_time) most_recent_vital_enc
ON most_recent_vital_enc.person_id = vital_signs_.person_id AND most_recent_vital_enc.enc_id = vital_signs_.enc_id
INNER JOIN master_im_ on master_im_.person_id = vital_signs_.person_id AND master_im_.enc_id = most_recent_vital_enc.enc_id
INNER JOIN patient_diagnosis ON patient_diagnosis.person_id = vital_signs_.person_id
INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
WHERE 
(vital_signs_.BMI_calc >= '25' or vital_signs_.BMI_calc <= '18.5')
AND master_im_.atxt_bmi_plan = '1'
AND patient_encounter.billable_timestamp >= '2017-07-01'
AND patient_encounter.billable_timestamp <='2018-06-30'
AND billable_ind = 'Y'
AND master_im_.age >= '18'
and NOT (master_im_.age >= '18' and master_im_.age <= '64'
and diagnosis_code_id in ('O09.211', 'O09.291', 'O09.511', 'O09.521', 'O09.891', 'O23.41', 'O23.591', 'O23.91','O24.410', 'O24.419', 'O24.911', 'O26.21', 'O26.841', 'O26.891', 'O30.001', 'O41.8X10', 'O99.011', 'O99.331', 'Z34.01', 'Z34.81', 'Z34.91', 'O09.212', 'O09.512', 'O09.522', 'O09.892', 'O16.2', 'O23.42', 'O24.410', 'O24.419', 'O26.02', 'O26.12', 'O26.892', 'O26.92', 'O30.002', 'O36.0120', 'O43.112', 'O43.192', 'O44.42', 'O99.012', 'O99.712', 'Z33.1', 'Z34.02', 'Z34.82', 'Z34.92', '644.03', 'O09.893', 'O12.03', 'O13.3', 'O14.93', 'O16.3', 'O23.43', 'O23.93', 'O24.410', 'O26.03', 'O26.613', 'O26.843', 'O36.0130', 'O36.5930', 'O36.63X0', 'O36.8130', 'O43.113', 'O99.013', 'O99.343', 'Z34.03', 'Z34.83', 'Z34.93'))
and NOT (master_im_.age > '65' and diagnosis_code_id in ('G30.8', 'G30.9', '294.8', 'F02.81', 'F03.90', '294.11', '294.10', 'F02.80', 'F03.91', 'G30.0', 'Z86.59', 'F06.8', '290.13', '290.10', '290.21', '290.0', 'F03.91', 'F01.51', '780.97', 'R41.82', 'F99', 'F48.9', '319', 'F79', 'V40.1', 'F81.9', 'V40.0', 'F79', 'F06.8', 'R68.89', 'Z86.59', 'Z91.89', '318.2', '318.1', 'V40.9', '319', '300.9', '310.9', '294.9', '309.0', 'F43.23', 'F41.8', 'F41.9', '300.4', '296.80', '779.2', 'F32.9', '311', 'O99.340', 'O99.345', 'O99.343', 'R51', 'F33.0', 'F33.1', 'F32.1', 'F53', 'F32.3', 'F32.8', 'F33.9', 'F41.8', '296.20', 'F34.1', '296.80', 'F32.2', 'R68.89', 'F43.21', '309.0', '298.9', 'R41.0', '281.8', 'Z71.1', 'D53.9', '269.9', 'D51.9', 'E53.8', '269.1', '266.9', 'E56.1', 'R74.8', 'Z86.39', 'E56.9', '268.9', 'E55.9', '268.9', 'R79.89', 'D51.3', '264.8', '281.1', 'D51.8', '264.9', '269.2', '264.2', '264.5', 'E50.5', 'E53.8', '281.1', '266.2', 'E56.9', '269.1','R79.0', '275.8', '799.4', 'R63.4', 'R63.5', '783.41', '783.1'))
and not vital_signs_.chk_Refused = '1'
GROUP BY vital_signs_.person_id

            
            
SELECT distinct vital_signs_.person_id from vital_signs_
INNER JOIN person ON person.person_id = vital_signs_.person_id
INNER JOIN master_im_ on master_im_.person_id = vital_signs_.person_id
INNER JOIN patient_encounter ON patient_encounter.person_id = vital_signs_.person_id
INNER JOIN patient_diagnosis ON patient_diagnosis.person_id = vital_signs_.person_id
WHERE
patient_encounter.billable_timestamp >= '2017-07-01'
and patient_encounter.billable_timestamp <='2018-06-30'
and billable_ind = 'Y'
and master_im_.age >= '18'
and NOT (master_im_.age >= '18' and master_im_.age <= '64'
and diagnosis_code_id in ('O09.211', 'O09.291', 'O09.511', 'O09.521', 'O09.891', 'O23.41', 'O23.591', 'O23.91','O24.410', 'O24.419', 'O24.911', 'O26.21', 'O26.841', 'O26.891', 'O30.001', 'O41.8X10', 'O99.011', 'O99.331', 'Z34.01', 'Z34.81', 'Z34.91', 'O09.212', 'O09.512', 'O09.522', 'O09.892', 'O16.2', 'O23.42', 'O24.410', 'O24.419', 'O26.02', 'O26.12', 'O26.892', 'O26.92', 'O30.002', 'O36.0120', 'O43.112', 'O43.192', 'O44.42', 'O99.012', 'O99.712', 'Z33.1', 'Z34.02', 'Z34.82', 'Z34.92', '644.03', 'O09.893', 'O12.03', 'O13.3', 'O14.93', 'O16.3', 'O23.43', 'O23.93', 'O24.410', 'O26.03', 'O26.613', 'O26.843', 'O36.0130', 'O36.5930', 'O36.63X0', 'O36.8130', 'O43.113', 'O99.013', 'O99.343', 'Z34.03', 'Z34.83', 'Z34.93'))
and NOT (master_im_.age > '65' and diagnosis_code_id in ('G30.8', 'G30.9', '294.8', 'F02.81', 'F03.90', '294.11', '294.10', 'F02.80', 'F03.91', 'G30.0', 'Z86.59', 'F06.8', '290.13', '290.10', '290.21', '290.0', 'F03.91', 'F01.51', '780.97', 'R41.82', 'F99', 'F48.9', '319', 'F79', 'V40.1', 'F81.9', 'V40.0', 'F79', 'F06.8', 'R68.89', 'Z86.59', 'Z91.89', '318.2', '318.1', 'V40.9', '319', '300.9', '310.9', '294.9', '309.0', 'F43.23', 'F41.8', 'F41.9', '300.4', '296.80', '779.2', 'F32.9', '311', 'O99.340', 'O99.345', 'O99.343', 'R51', 'F33.0', 'F33.1', 'F32.1', 'F53', 'F32.3', 'F32.8', 'F33.9', 'F41.8', '296.20', 'F34.1', '296.80', 'F32.2', 'R68.89', 'F43.21', '309.0', '298.9', 'R41.0', '281.8', 'Z71.1', 'D53.9', '269.9', 'D51.9', 'E53.8', '269.1', '266.9', 'E56.1', 'R74.8', 'Z86.39', 'E56.9', '268.9', 'E55.9', '268.9', 'R79.89', 'D51.3', '264.8', '281.1', 'D51.8', '264.9', '269.2', '264.2', '264.5', 'E50.5', 'E53.8', '281.1', '266.2', 'E56.9', '269.1','R79.0', '275.8', '799.4', 'R63.4', 'R63.5', '783.41', '783.1'))
and not vital_signs_.chk_Refused = '1'



           
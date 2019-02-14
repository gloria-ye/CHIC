
select distinct order_.person_id /* , order_.create_timestamp, order_.actText, order_.actStatus */
from order_
INNER JOIN person on person.person_id = order_.person_id
INNER JOIN patient_diagnosis on patient_diagnosis.person_id = order_.person_id
INNER JOIN patient_encounter on patient_encounter.person_id = order_.person_id
WHERE order_.actStatus = 'completed'
AND order_.create_timestamp >= DATEADD (YY, -2, '2017-07-01')
AND person.date_of_birth >= DATEADD (YY, -64, '2017-07-01')
AND person.date_of_birth <= DATEADD (YY, -23, '2017-07-01')
AND (order_.actText = 'PAP'
OR order_.actText = 'Pap Image Guided, Ct-Ng, rfx HPV ASCU'
OR order_.actText = 'Pap Image Guided, rfx HPV all pth'
OR order_.actText = 'Pap Image Guided, rfx HPV ASCU'
OR order_.actText = 'Pap Liquid Based w/ Rfx to HPV when ASC-U'
OR order_.actText = 'Pap Liquid Based, Ct'
OR order_.actText = 'Pap Liquid Based, Ct, rfx HPV all pth'
OR order_.actText ='Pap Liquid Based, Ct, rfx HPV ASCU'
OR order_.actText = 'Pap Liquid Based, HPV-high risk'
OR order_.actText = 'Pap Liquid Based, reflex HPV ASCU'
OR order_.actText = 'Pap Liquid Based, rfx HPV all pth'
OR order_.actText = 'PAP SMEAR'
OR order_.actText = 'Pap Smear, 2 Slide'
OR order_.actText = 'pap with HPV ordered due to stenotic os. FU pending results'
OR order_.actText = 'PAP, liquid based'
OR order_.actText = 'PAP, thin prep'
OR order_.actText = 'Pap-Liquid-based'
OR order_.actText = 'Pap/HPV testing'
OR order_.actText = 'SUREPATH FOCALPOINT-GS PAP W/REFLEX'
OR order_.actText = 'SUREPATH FPGS PAP W/ REFLEX TO HPV'
OR order_.actText = 'SUREPATH FPGS PAP, HR HPV, C TRACH  N GONORRHOEAE')
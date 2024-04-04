
**************************************************************************************
*Analysis of Recruitment and office screening and selection into into tyhe study
**************************************************************************************

clear
set more off


*********************************************************
*********************************************************
* Online Appendix Table A.1
* Eligibility and Selection of Study Participants
*********************************************************
*********************************************************

				
********************************************
********************************************
* (1) Recruitment screening survey summary 
********************************************
********************************************

use "$analysis_datasets/Final_recruitment_screening_data.dta", clear

*Rename and generate some variables
	rename p2_int p2_interviewer
	rename s1_a s1a_conduct_survey
	rename e9_b e9b_willing
	rename e9_c e9c_willing_reason

*Was the survey conducted?
	tab s1a_conduct_survey, m
	*4 missing values; no data for these observations.
	replace s1a_conduct_survey = 0 if s1a_conduct_survey == .

*Different reasons for ineligibility:

	*Rickshaw peddlers
	gen inel_rp=(s3>2 & s3!=.)	

	*Insufficient work days
	gen inel_work_days=(s4<5 & s4!=.)

	*Age (too young or too old)
	gen inel_age=((s5<24 | s5>60) & s5!=.)
				
	*Time in Chennai (this variable has changed name between versions)
	destring s6_call, replace
	destring s6_cal, replace
	replace s6_cal=s6_call if s6_cal==.
	gen inel_chen_live=(s6_cal<6 & s6_cal!=.)
			
*Drinking (this variable has changed name between versions)
	destring s7_call, replace
	destring s7_cal, replace
	replace s7_cal=s7_call if s7_cal==.
	
	*Drinks either too little or too much
	gen inel_drink=((s7_cal < 0.7 | s7_cal > 2) & s7_cal != .)

	*Drinks not enough:
	gen inel_drink_too_little = s7_cal < 0.7

	*Drinks too much:
	gen inel_drink_too_much = s7_cal > 2 & s7_cal != .
			
	tab inel_drink_too_little inel_drink_too_much if inel_drink == 1
						
*Leaving Chennai soon
	gen inel_chen_leave = (s8 == 1 & s8 != .)
	
*Overall eligibility
	gen temp = inel_rp + inel_work_days + inel_age + inel_chen_live + inel_drink + inel_chen_leave
	gen el_overall = (temp == 0 & temp != .)

	replace el_overall=. if s1a_conduct_survey!=1			
	tab el_overall s1a_conduct_survey, m	
		*118 declined to do the survey
		*112 ineligible
		*363 eligible

	tab el_overall, m
		
*Ineligible for other reasons than drinking
	drop temp
	gen temp = inel_rp + inel_work_days + inel_age + inel_chen_live + inel_chen_leave
	tab temp, m
	gen inel_other = (temp > 0)
	tab inel_other, m
	tab inel_other inel_drink, m

*Eligible and willing
	gen a = 1
	egen total_el = sum(a) if el_overall == 1
	foreach x in inel_rp inel_work_days inel_age inel_chen_live inel_drink inel_chen_leave {
	egen total_`x' = sum(a) if `x' == 1
		}
	
	egen total_willing=sum(a) if e9b_willing==1
	tab e9c_willing_reason, m
	egen total_unwilling_busy=sum(a) if e9c_willing_reason==1
	egen total_unwilling_not_int=sum(a) if e9c_willing_reason==2
		
*Number of people who answered screening questions
	assert p1_rid1!=""
	egen total=sum(a)
	egen total_conduct=sum(a) if s1a_conduct_survey==1

*Split new and old
	destring z1_rid2, replace
	
	assert p1_rid1 == z1_rid1
	assert p1_rid2 == z1_rid2
		
*Drop duplicate observations
	drop temp
	bys z1_rid1 z1_rid2: g temp=_n
	drop if temp>1
	drop temp
	
	destring z1_rid2, replace force

   *Merge with OS to get the guys who were willing but didn't complete OS
	merge m:m z1_rid1 z1_rid2 using "$analysis_datasets/Final_office_screening_data.dta", gen(_merge_OS) force
	
	tab _merge_OS, m
		*474 observations matched successfully

	generate completed_OS = (_merge_OS == 3)
	tab completed_OS, m

	generate did_not_complete_OS = (_merge_OS == 1)
	tab did_not_complete_OS, m
	
	tab e9b_willing did_not_complete_OS, m
	generate elig_noOS = (el_overall == 1 & did_not_complete_OS == 1)
	tab elig_noOS, m

	*Some checks:
	tab elig_noOS s1a_conduct_survey, m
	count if elig_noOS == 1 & s1a_conduct_survey == 0

	tab el_overall s1a_conduct_survey, m	
	count if elig_noOS == 1 & el_overall == 0

	count if completed_OS == 1 & el_overall == 0
	count if completed_OS == 1 & s1a_conduct_survey == 0
	
	generate check = 0
	replace check = 1 if completed_OS == 1 & s1a_conduct_survey == 0
	replace check = 1 if completed_OS == 1 & el_overall == 0
	tab check, m

	*Change four discrepancies		
		replace s1a_conduct_survey = 1 if check == 1
		replace el_overall = 1 if check == 1
		replace inel_drink_too_little = 0 if check == 1
		replace inel_drink_too_much = 0 if check == 1
		replace inel_other = 0 if check == 1


		
********************************************
*Create scalars for table
********************************************

*Total number of recruitment screening surveys attempted
	count 
	scalar total_contacted =  r(N)
		
*Fraction of individuals who declined to do the recruitment screening survey
	tab s1a_conduct_survey, m
	count if s1a_conduct_survey == 0
	scalar total_unwilling = r(N)
	scalar frac_unwilling = (total_unwilling/total_contacted)*100
	
*Fraction of individuals who were ineligible
	tab el_overall s1a_conduct_survey, m
	tab el_overall, m
	count if el_overall == 0
	scalar total_ineligible = r(N)
	scalar frac_ineligible = (total_ineligible/total_contacted)*100

*Fraction of individuals who were ineligle because they drink too little
	count if inel_drink_too_little == 1
	scalar total_drink_too_little = r(N)
	scalar frac_drink_too_little = (total_drink_too_little/total_contacted)*100

*Fraction of individuals who were ineligle because they drink too little
	count if inel_drink_too_much == 1
	scalar total_drink_too_much = r(N)
	scalar frac_drink_too_much = (total_drink_too_much/total_contacted)*100

*Fraction of individuals who were ineligle for other reasons
	count if inel_other == 1
	scalar total_inel_other = r(N)
	scalar frac_inel_other = (total_inel_other/total_contacted)*100

*Fraction of individuals who were eligible, but not interested
	tab el_overall completed_OS, m
	count if elig_noOS == 1
	scalar total_elig_noOS = r(N)
	scalar frac_elig_noOS = (total_elig_noOS/total_contacted)*100

*Fraction of individuals who are eligible and willing
	count if completed_OS == 1
	scalar total_completed_OS = r(N)
	scalar frac_elig_willing = (total_completed_OS/total_contacted)*100
	

********************************************
*Print first part of table
********************************************
	
cap file close _all
file open myfile using "$tables/8_Eligibility_table_FINAL.tex", write replace

file write myfile "\begin{tabular}{l c}"
file write myfile " \toprule "

file write myfile "\textbf{STAGE} & \textbf{FRACTION} \\"
file write myfile " & \textbf{(percent)} \\"
file write myfile " \midrule "
file write myfile "\textbf{Field Screening Survey} (N= " %7.0f (total_contacted) ") & \\"
file write myfile " \midrule "

file write myfile "{Eligible and willing to participate in next stage} & \textbf{"  %7.0f (frac_elig_willing) " } \\"
file write myfile "Not willing to conduct survey & " %7.0f (frac_unwilling) " \\"
file write myfile "Ineligle due to too low alcohol consumption & " %7.0f (frac_drink_too_little) " \\"
file write myfile "Ineligle due to too high alcohol consumption  & " %7.0f (frac_drink_too_much) " \\"
file write myfile "Ineligible for other reasons & " %7.0f (frac_inel_other) " \\"
file write myfile "Eligible, but not interested in next stage & " %7.0f (frac_elig_noOS) " \\"

file write myfile " \midrule "

file close myfile


**************************************
**************************************
* (2) Office screening survey summary 
**************************************
**************************************

use "$analysis_datasets/Final_office_screening_data.dta", clear
	
*Ineligibility due to profession
	tab e1, m
	tab s1, m
	rename e1 inel_rp_e1 
	*13 individuals ineligible because they are not rickshaw pullers
		
*Ineligibility for medical reasons
	
	*Sedative meds:
	tab e2, m
	rename e2 inel_med_sed_e2 
	*2 individuals ineligible

	*Diabetes or hypertension:
	tab e3, m
	rename e3 inel_med_diab_e3
	*10 individuals ineligible
		
	*Other health problems:
	tab e4, m
	rename e4 inel_med_other_e4 
	*36 individuals ineligle

	*Various specific health issues:
	
		*Episepsy
		tab s4a, m
		rename s4a inel_med_epi_s4a 
	
		*Head injuries
		tab s4b,m
		rename s4b inel_med_head_s4b 
	
		*Stroke
		tab s4c,m
		rename s4c inel_med_stroke_s4c
		
		*Brain/CNS tumor
		tab s4d,m
		rename s4d inel_med_brain_s4d 
		
		*Heart disease/failure
		tab s4e,m
		rename s4e inel_med_heart_s4e 
		
		*Seizure
		tab s4f,m
		rename s4f inel_med_seiz_s4f
	
		*Liver disease
		tab s4g,m
		rename s4g inel_med_liver_s4g
		
		*Hepatitis C
		tab s4h,m
		rename s4h inel_med_hepc_s4h 
		
		*Other CNS pathology
		tab s4i,m
		rename s4i inel_med_cns_s4i 
							
*Ineligibility due to drinking patterns
		
	tab e5_b,m 
	*9 individuals screened out according to this measure
	
	g inel_drink_e5b= (s6_cal<0.7 | s6_cal>2)
	tab inel_drink_e5b,m

	tab s6_cal, m
	*According to variable s6_cal, 25 individuals should have been ineligible due to drinking too little or too much
		
	*Check for these errors
	capture drop a
	gen a=(s6_cal<0.7 & e13==1)
	replace a=1 if s6_cal>2 & e13==1
	list rid date s6_cal e13 if a==1		
	drop a
	*3 individuals were admitted to the study who should have been screened out.
		
*Ineligibility due to severe symptoms from recent quit attempts		
	tab e6,m
	rename e6 inel_withdraw_e6 
	*6 individuals ineligible

*Ineligibility due to DTs
	tab e7,m
	rename e7 inel_dts_e7 
	*7 individuals ineligible
			
*Ineligibility due to fasting, austerities
	tab e8,m
	rename e8 inel_fast_e8 
	*9 individuals ineligible
	
	tab e9, m
	rename e9 inel_aust_e9 
	*21 individuals ineligible
		
*Leaving chennai
	tab e10,m
	rename e10 inel_leave_e10 
	*14 individuals ineligible
			
*Low BMI PRP
	tab e11,m
	rename e11 inel_bmi_e11 
	*52 individuals ineligible
	
*Overall eligibility
	g temp = inel_rp_e1 + inel_med_sed_e2 + inel_med_diab_e3 + inel_med_other_e4 + inel_drink_e5b + inel_withdraw_e6 + ///
			inel_dts_e7 + inel_fast_e8 + inel_aust_e9 + inel_leave_e10 + inel_bmi_e11
	
	g el_overall_OS = (temp==0 & temp!=.)
	drop temp
	tab el_overall_OS, m
	*349 individuals eligible
	*125 individuals ineligible
		
*Check correct
	tab el_overall e13,m
	rename e13 found_eligible_e13
	*Same 3 cases above who should not have been admitted to the study.
	
*Willing
	tab e14, m
	rename e14 willing_e14  
	*4 individuals not interested in participating.
	
********************************************
*Create scalars for table
********************************************

*Total number of office screening surveys conducted
	count
	scalar total_RS = r(N)
	
*Generate variable for medical eligibility
generate inel_med = .
	replace inel_med = 1 if inel_med_sed_e2 == 1
	replace inel_med = 1 if inel_med_diab_e3 == 1
	replace inel_med = 1 if inel_med_other_e4 == 1
	replace inel_med = 1 if inel_withdraw_e6 == 1
	replace inel_med = 1 if inel_dts_e7 == 1
	replace inel_med = 1 if inel_fast_e8 == 1
	
*Fraction of individuals who were found ineligible for medical reasons	
	tab inel_med, m
	count if inel_med == 1
	scalar total_inel_med = r(N)
	scalar frac_inel_med = (total_inel_med/total_RS)*100

*Generate variable for non-medical eligibility
generate inel_non_med = .
	
	replace inel_non_med = 1 if inel_rp_e1 == 1
	replace inel_non_med = 1 if inel_fast_e8 == 1
	replace inel_non_med = 1 if inel_aust_e9 == 1
	replace inel_non_med = 1 if inel_leave_e10 == 1
	replace inel_non_med = 1 if inel_bmi_e11 == 1

*Fraction of individuals who were found ineligible for other reasons
	tab inel_non_med, m
	count if inel_non_med == 1
	scalar total_inel_non_med = r(N)
	scalar frac_inel_non_med = (total_inel_non_med/total_RS)*100
	
*Fraction not willing to participate
	tab willing_e14, m
	count if willing_e14 == 0
	scalar total_OS_el_unwilling = r(N)
	scalar frac_OS_el_unwilling = (total_OS_el_unwilling/total_RS)*100
	
*Total number eligible and willing
	tab found_eligible_e13 willing_e14
	count if found_eligible_e13 == 1 & willing_e14 == 1
	scalar total_OS_el_willing = r(N)
	scalar frac_OS_el_willing = (total_OS_el_willing/total_completed_OS)*100
	
********************************************
*Print second part of table
********************************************

cap file close _all
file open myfile using "$tables/8_Eligibility_table_FINAL.tex", write append

file write myfile "\textbf{Office Screening Survey} (N= " %7.0f (total_completed_OS) ") \\"
file write myfile " \midrule "

file write myfile "Eligible and willing to participate in next stage & \textbf{"  %7.0f (frac_OS_el_willing) " } \\"

file write myfile "Ineligible for medical reasons & " %7.0f (frac_inel_med) " \\"
file write myfile "Ineligible for other reasons & " %7.0f (frac_inel_non_med) " \\"

file write myfile "Eligible, but not interested in further participation & " %7.0f (frac_OS_el_unwilling) " \\"

file write myfile " \midrule "

file close myfile


**************************************
**************************************
* (3) Lead-In Period Summary
**************************************
**************************************

*Add data on whether participant made it to day 4 and BAC on day 1
	sort pid
	merge 1:m pid using "$analysis_datasets/Final_alcohol_main_data.dta", gen(merge_day4)

*Order, sort, and keep variables
	order pid day_in_study day4
	sort pid day_in_study
	keep if day_in_study == 1 | day_in_study == 4
	keep pid rid day_in_study day4 sober_dummy BAC_result willing_e14
	tab day4, m

	duplicates report pid day_in_study

********************************************
*Create scalars for table
********************************************

*Total number who proceeded to enroll in the 
	count if day_in_study == 4
	scalar total_enrolled = r(N)
	
*Fraction of individuals who proceeded to enroll in the study
	scalar frac_enrolled = (total_enrolled/total_OS_el_willing)*100

*Sobriety status of individuals who did not make it past day 4
	tab willing_e14 if day_in_study == 1, m

	tab day4 if willing_e14 == 1 & day_in_study == 1, m
	*229 enrolled in study
	*119 did not make it past the lead-in phase

	tab sober_dummy if day4 == 0 & willing_e14 == 1 & day_in_study == 1, m
	tab BAC_result if day4 == 0 & willing_e14 == 1 & day_in_study == 1, m
	
	count if sober_dummy == 1 & day4 == 0 & willing_e14 == 1 & day_in_study == 1
	scalar total_not_enroll_sober = r(N)
	scalar frac_not_enroll_sober = (total_not_enroll_sober/total_OS_el_willing)*100
	
	count if sober_dummy != 1 & day4 == 0 & willing_e14 == 1 & day_in_study == 1
	scalar total_not_enroll_not_sober = r(N)
	scalar frac_not_enroll_not_sober = (total_not_enroll_not_sober/total_OS_el_willing)*100
		
********************************************
*Print third part of table
********************************************

cap file close _all
file open myfile using "$tables/8_Eligibility_table_FINAL.tex", write append

file write myfile " \textbf{Lead-In Period} (N= " %7.0f (total_OS_el_willing) ") \\"
file write myfile " \midrule "

file write myfile " Proceeded to fully enroll in the study & \textbf{"  %7.0f (frac_enrolled) " } \\"
file write myfile " Did not proceed and BAC $=$ 0 on day 1 & "  %7.0f (frac_not_enroll_sober) "  \\"
file write myfile " Did not proceed and BAC $>$ 0 on day 1 & "  %7.0f (frac_not_enroll_not_sober) "  \\"

file write myfile " \midrule "

file write myfile " \textbf{Fully Enrolled} (N= " %7.0f (total_enrolled) ")  \\"

file write myfile " \bottomrule "

file write myfile " \end{tabular} "

file close myfile

*DONE!
			

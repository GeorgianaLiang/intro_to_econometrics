
**************************************************************************************
*Analysis of Choices
**************************************************************************************

clear
set more off
	
**************************************************************************************
use "$analysis_datasets/Final_alcohol_main_data.dta", clear
**************************************************************************************


*Generate data with one observation for each week (1, 2, and 3) for each PID
keep if day_in_study == 4
keep pid tx_group
sort pid
expand 3
sort pid
generate week = mod(_n, 3) + 1
tab tx_group
sort pid week
tab week, m
tab pid, m
count 
save "$analysis_datasets/help.dta", replace


**************************************************************************************
*Get original dataset and merge
**************************************************************************************

use "$analysis_datasets/Final_alcohol_main_data.dta", clear


*Keep only if person was actually interviewed
keep if interviewer_choice != .
tab week, m

*Choice order variable
replace choice_order = 0 if choice_order == 2 // 
label var choice_order "Choice order ascending (Rs 90 first)"

*Create variable that indicates whether the person chose incentives in each week
generate chose_incentives1 = (choice1 == 1) if choice1 != .
generate chose_incentives2 = (choice2 == 1) if choice2 != .
generate chose_incentives3 = (choice3 == 1) if choice3 != .

sort pid week
generate present = 1
merge pid week using "$analysis_datasets/help.dta"
tab _merge

erase "$analysis_datasets/help.dta"

sort pid week _merge
order pid week _merge

*Count "chose incentives" as zero for people who are inconsistent:
replace chose_incentives1 = 0 if consistent_dummy == 0
replace chose_incentives2 = 0 if consistent_dummy == 0
replace chose_incentives3 = 0 if consistent_dummy == 0

*Count "chose incentives" as zero for people who are absent:
replace present = 0 if present == .
replace chose_incentives1 = 0 if present == 0
replace chose_incentives2 = 0 if present == 0
replace chose_incentives3 = 0 if present == 0

order pid week chose_incentives*


*********************************************************
*********************************************************
*Online Appendix Table A.5
*Attrition and Inconsistencies of Choices
*********************************************************
*********************************************************

*Columns 1 through 3 (Choice Group weeks 1 through 3)

forvalues j = 1(1)3{

count if tx_group == 2 & week == `j'
scalar n`j'1 =  r(N)
count if tx_group == 2 & week == `j' & present == 1 & consistent_dummy == 1
scalar n`j'2 =  r(N)
count if tx_group == 2 & week == `j' & present == 0
scalar n`j'3 =  r(N)
count if tx_group == 2 & week == `j' & present == 1 & consistent_dummy == 0
scalar n`j'4 =  r(N)

scalar frac`j'2 = n`j'2/n`j'1 * 100
scalar frac`j'3 = n`j'3/n`j'1 * 100
scalar frac`j'4 = n`j'4/n`j'1 * 100

}

*Column 4 (Incentive Group week 3)

count if tx_group == 1 & week == 3
scalar n41 =  r(N)
count if tx_group == 1 & week == 3 & present == 1 & consistent_dummy == 1
scalar n42 =  r(N)
count if tx_group == 1 & week == 3 & present == 0
scalar n43 =  r(N)
count if tx_group == 1 & week == 3  & present == 1 & consistent_dummy == 0
scalar n44 =  r(N)

scalar frac42 = n42/n41 * 100
scalar frac43 = n43/n41 * 100
scalar frac44 = n44/n41 * 100

*Column 5 (Incentive Group week 3)

count if tx_group == 3 & week == 3
scalar n51 =  r(N)
count if tx_group == 3 & week == 3 & present == 1 & consistent_dummy == 1
scalar n52 =  r(N)
count if tx_group == 3 & week == 3 & present == 0
scalar n53 =  r(N)
count if tx_group == 3 & week == 3  & present == 1 & consistent_dummy == 0
scalar n54 =  r(N)

scalar frac52 = n52/n51 * 100
scalar frac53 = n53/n51 * 100
scalar frac54 = n54/n51 * 100

*Print table

cap file close _all
file open myfile using "$tables/6a_Choice_sum_stats_table1_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c | c | c }"
file write myfile "\toprule"

file write myfile "& \multicolumn{3}{c}{\textbf{Choice Group}} & \multicolumn{1}{c}{\textbf{Incentive Group}} & \multicolumn{1}{c}{\textbf{Control Group}} \\"
file write myfile "\cmidrule(r){2-4} \cmidrule(r){5-5} \cmidrule(r){6-6}"
file write myfile "& Week 1 & Week 2 & Week 3 & Week 3 & Week 3 \\"
file write myfile " \midrule "
file write myfile "Present \& consistent (\%) & " %7.1f (frac12) "&" %7.1f (frac22) "&" %7.1f (frac32) "&"
file write myfile %7.1f (frac42) "&" %7.1f (frac52) "\\"
file write myfile "Absent (\%) & " %7.1f (frac13) "&" %7.1f (frac23) "&" %7.1f (frac33) "&"
file write myfile %7.1f (frac43) "&" %7.1f (frac53) "\\"
file write myfile "Inconsistent (\%) & " %7.1f (frac14) "&" %7.1f (frac24) "&" %7.1f (frac34) "&"
file write myfile %7.1f (frac44) "&" %7.1f (frac54) "\\"

file write myfile "\bottomrule"
file write myfile "\end{tabular}"

file close myfile


*********************************************************
*********************************************************
*Online Appendix Table A.6
*Fraction Choosing Incentives in Choice Group and Over Time
*********************************************************
*********************************************************

*Fraction choosing incentives in weks 1 through 3)

forvalues j = 1(1)3{

count if tx_group == 2 & week == `j'
scalar n`j'1 =  r(N)
count if tx_group == 2 & week == `j' & chose_incentives1 == 1
scalar n`j'2 =  r(N)
count if tx_group == 2 & week == `j' & chose_incentives2 == 1
scalar n`j'3 =  r(N)
count if tx_group == 2 & week == `j' & chose_incentives3 == 1
scalar n`j'4 =  r(N)

scalar frac`j'2 = n`j'2/n`j'1 * 100
scalar frac`j'3 = n`j'3/n`j'1 * 100
scalar frac`j'4 = n`j'4/n`j'1 * 100

}

*Column 4 (Incentive Group week 3)

count if tx_group == 1 & week == 3
scalar n41 =  r(N)
count if tx_group == 1 & week == 3 & chose_incentives1 == 1
scalar n42 =  r(N)
count if tx_group == 1 & week == 3 & chose_incentives2 == 1
scalar n43 =  r(N)
count if tx_group == 1 & week == 3 & chose_incentives3 == 1
scalar n44 =  r(N)

scalar frac42 = n42/n41 * 100
scalar frac43 = n43/n41 * 100
scalar frac44 = n44/n41 * 100

*Column 5 (Incentive Group week 3)

count if tx_group == 3 & week == 3
scalar n51 =  r(N)
count if tx_group == 3 & week == 3 & chose_incentives1 == 1
scalar n52 =  r(N)
count if tx_group == 3 & week == 3 & chose_incentives2 == 1
scalar n53 =  r(N)
count if tx_group == 3 & week == 3 & chose_incentives3 == 1
scalar n54 =  r(N)

scalar frac52 = n52/n51 * 100
scalar frac53 = n53/n51 * 100
scalar frac54 = n54/n51 * 100


*Print table

cap file close _all
file open myfile using "$tables/6b_Choice_sum_stats_table2_FINAL.tex", write replace
file write myfile "\begin{tabular}{c c c c c c c}"
file write myfile "\toprule"

file write myfile "& \textbf{Choice Features} &  \multicolumn{3}{c}{\textbf{Choice Group}} &"
file write myfile "\textbf{Incentive Group} & \textbf{Control Group} \\"
file write myfile "\cmidrule(r){2-2} \cmidrule(r){3-5}  \cmidrule(r){6-6}  \cmidrule(r){7-7}"
file write myfile "\# & Unconditional amount & Week 1 & Week 2 & Week 3 & Week 3 & Week 3 \\"
file write myfile " \midrule "

file write myfile "(1) & Rs.\ 90  & " %7.1f (frac12) "&" %7.1f (frac22) "&" %7.1f (frac32) "&"
file write myfile %7.1f (frac42) "&" %7.1f (frac52) "\\"

file write myfile "(2) & Rs.\ 120 & " %7.1f (frac13) "&" %7.1f (frac23) "&" %7.1f (frac33) "&"
file write myfile %7.1f (frac43) "&" %7.1f (frac53) "\\"

file write myfile "(3) & Rs.\ 150 & " %7.1f (frac14) "&" %7.1f (frac24) "&" %7.1f (frac34) "&"
file write myfile %7.1f (frac44) "&" %7.1f (frac54) "\\"

file write myfile "\bottomrule"
file write myfile "\end{tabular}"

file close myfile


*********************************************************
*********************************************************
*Figure 2 upper panel:
*Choices Across Treatment Groups and Over Time
*Demand for Incentives over Time
*********************************************************
*********************************************************
	
preserve
		
	*Keep only Choice Group observations:
	keep if tx_group == 2
	
	*Reshape and collapse data:
	generate n = _n
	reshape long chose chose_incentives, i(n) j(choice)
	order pid week chose_incentives choice
	keep pid week chose_incentives choice
	collapse (mean) mean_inc = chose_incentives (sd) sd_inc = chose_incentives (count) n = chose_incentives, by(week choice)

	*Generate 95% confidence intervals
	generate hi_inc = mean_inc + invttail(n-1,0.025)*(sd_inc / sqrt(n))
	generate low_inc = mean_inc - invttail(n-1,0.025)*(sd_inc / sqrt(n))

	*Spread out the graph
	generate week_choice = week + 1 if choice == 1
	replace week_choice = week + 5 if choice == 2
	replace week_choice = week + 9 if choice == 3
		
	twoway 	(bar mean_inc week_choice if choice == 1, barwidth(0.8) color(gs1)) ///
			(bar mean_inc week_choice if choice == 2, barwidth(0.8) color(navy)) ///
			(bar mean_inc week_choice if choice == 3, barwidth(0.8) color(eltblue)) ///
			(rcap hi_inc low_inc week_choice), ///
			legend(row(3) order( ///
			1 "Choice 1: unconditional payment = Rs 90" ///  
			2 "Choice 2: unconditional payment = Rs 120" ///
			3 "Choice 3: unconditional payment = Rs 150")) ///
			xlabel( 2 "1" 3 "2" 4 "3" 6 "1" 7 "2" 8 "3" 10 "1" 11 "2" 12 "3", noticks) ///
			xtitle("Week") ytitle("Fraction of Choice Group who chose incentives") ///
			title("Demand for Incentives over Time") ///
			ysc(r(0 0.8))  ymtick(0(0.2)0.8) ylabel(0(0.2)0.8) xsc(r(1 12)) ///
			graphregion(color(white)) bgcolor(white)

	graph export "$figures/6a_Choice_figure1_FINAL.eps", replace

restore


*********************************************************
*********************************************************
*Figure 2 lower panel:
*Choices Across Treatment Groups and Over Time
*Demand for Incentives across Treatment Groups
*********************************************************
*********************************************************

preserve

	*Keep only observations from week 3
	keep if week == 3
	tab tx_group
		
	generate n = _n
	reshape long chose chose_incentives, i(n) j(choice)
	order pid choice chose_incentives tx_group
	keep pid choice chose_incentives tx_group

	replace chose_incentives = 0 if chose_incentives == .
		
	collapse (mean) mean_inc = chose_incentives (sd) sd_inc = chose_incentives (count) n = chose_incentives, by(choice tx_group) ///

	*Generate 95% confidence intervals
	generate hi_inc = mean_inc + invttail(n-1,0.025)*(sd_inc / sqrt(n))
	generate low_inc = mean_inc - invttail(n-1,0.025)*(sd_inc / sqrt(n))

	*Spread out the graph
	generate week_choice = tx_group if choice == 1
	replace week_choice = tx_group + 4 if choice == 2
	replace week_choice = tx_group + 8 if choice == 3

	twoway 	(bar mean_inc week_choice if tx_group == 1, color(gs1) barwidth(0.8)) ///
			(bar mean_inc week_choice if tx_group == 2, color(forest_green) barwidth(0.8)) ///
			(bar mean_inc week_choice if tx_group == 3, color(maroon) barwidth(0.8) ) ///
			(rcap hi_inc low_inc week_choice), ///
			legend(row(1) order(1 "Incentive Group" 2 "Choice Group" 3 "Control Group")) ///
			xlabel( 2 "Choice 1 (Rs 90)" 6 "Choice 2 (Rs 120)" 10 "Choice 3 (Rs 150)", noticks) ///
			xtitle("") ytitle("Fraction of individuals who chose incentives") ///
			title("Demand for Incentive across Treatment Groups") ///
			ysc(r(0 0.9))  ymtick(0(0.2)0.9) ylabel(0(0.2)0.9) xsc(r(0 12)) ///
			graphregion(color(white)) bgcolor(white)
				
	graph export "$figures/6b_Choice_figure2_FINAL.eps", replace

restore

		
*********************************************************
*Additional data work for regressions	
*********************************************************
		
*Create dummy variables for each choice:
	generate chose_incentives90 = chose_incentives1
	generate chose_incentives120 = chose_incentives2
	generate chose_incentives150 = chose_incentives3

*Create treatment dummies
	gen Treatment = (tx_group == 1)
	gen Choice = (tx_group == 2)

*Generate fixed effects for choice example
	tab choice_example, gen(choice_example_FE_)

*Generate interviewer fixed effects:
	tab interviewer_choice, gen(interviewer_FE_)
	drop interviewer_FE_1

*Generate individual fixed effects
	tab pid, gen(individual_FE_)
	drop individual_FE_1

*Generate dummies for weeks 2 and 3
	gen Week2 = (week == 2)
	label var Week2 "Week 2"
	gen Week3 = (week == 3)
	label var Week3 "Week 3"

*Label some variables	
	label var sober_dummy "Sober during choice"
	label var BAC_result "BAC during choice"

*Generate variables for the fraction sober in each phase
	generate Frac_sober_phase1 = D_days_sober_phase1/3

	generate Frac_sober_phase2 = D_days_sober_phase2/3

	generate Frac_sober_phase3 = D_days_sober_phase3/6

	generate Frac_sober_phase4 = D_days_sober_phase4/6
	
*Generate variables for the difference in sobriety in each phase compared to phase 1

	*Phase 2 compared to phase 1
	generate Frac_sober_dif_phase2_phase1 = Frac_sober_phase2 - Frac_sober_phase1	
	generate Sober_dif_phases21_pos = (Frac_sober_dif_phase2_phase1 > 0) if Frac_sober_dif_phase2_phase1 != .
	label var Sober_dif_phases21_pos "Incentives increased sobriety in week 1"

	*Phase 3 compared to phase 1
	generate Frac_sober_dif_phase3_phase1 = Frac_sober_phase3 - Frac_sober_phase1
	generate Sober_dif_phases31_pos = (Frac_sober_dif_phase3_phase1 > 0) if Frac_sober_dif_phase3_phase1 != .
	label var Sober_dif_phases31_pos "Incentives increased sobriety in week 1"

	*Phase 4 compared to phase 1
	generate Frac_sober_dif_phase4_phase1 = Frac_sober_phase4 - Frac_sober_phase1
	generate Sober_dif_phases41_pos = (Frac_sober_dif_phase4_phase1 > 0) if Frac_sober_dif_phase4_phase1 != .
	label var Sober_dif_phases41_pos "Incentives increased sobriety in week 1"

	*Variable that indicates whether the difference in sobriety was positive in previous phase (compared to phase 1)
	generate Sober_dif_pos = .
	replace Sober_dif_pos = Sober_dif_phases21_pos if week == 1
	replace Sober_dif_pos = Sober_dif_phases31_pos if week == 2
	replace Sober_dif_pos = Sober_dif_phases41_pos if week == 3
	label var Sober_dif_pos "Increased sobriety in prev week"
	
	*Variables for expected future sobriety under incentives
	label var exp_sober_days "Exp sober days under incentives"
	
	generate exp_frac_sober = exp_sober_days/6
	label var exp_frac_sober "Exp frac sober under incentives"

	generate exp_frac_sober_week1 = C1_exp_sober_days_TT/6
	generate exp_frac_sober_week2 = C2_exp_sober_days_TT/6
		
		
*********************************************************
*********************************************************
*Online Appendix Figure A.4
*Beliefs About Future Sobriety (under Incentives)		
*Expected vs actual sobriety in weeks 2 and 3
*********************************************************
*********************************************************
	
forvalues j = 1(1)2{
	
	local k = `j' + 2
	local m = `j' + 1
			
	binscatter Frac_sober_phase`k' exp_frac_sober_week`j' if week == `j' & tx_group == 1, ///
	ysc(r(0 1)) ymtick(0(0.2)1) ylabel(0(0.2)1) ///
	ytitle("Actual fraction of sober days in week `m'") ///
	xtitle("Expected fraction of sober days in week `m'") ///
	graphregion(color(white)) bgcolor(white)

	graph export "$figures/6c`j'_Expected_sobriety_week`j'_FINAL.eps", replace 
	
}
		
*Create and label some additional variables:
	
	generate Frac_sober = .
	replace Frac_sober = Frac_sober_phase3 if week == 1
	replace Frac_sober = Frac_sober_phase4 if week == 2
	label var Frac_sober "Actual fraction shown up sober"
	
	label var D_days_sober_phase1 "Days sober in Phase 1"
	label var D_days_sober_phase2 "Days sober in Phase 2"
	label var exp_frac_sober "Exp frac sober under incentives"
	label var exp_sober_days "Expected \#  of sober days"
	label var Sober_dif_pos "Incentives increased sobriety"


*********************************************************
*********************************************************
*Table 2 upper panel:
*Demand for Sobriety Incentives
*Choices in the Choice Group
*********************************************************
*********************************************************


preserve

	keep if tx_group == 2

	tab chose_incentives90, m
	tab chose_incentives120, m
	tab chose_incentives150, m

	local slow = 2000

	local append_replace = "replace"
	
	file open myfile using "$tables/6c_Choice_table1_FINAL.tex", write replace
	file write myfile "\begin{tabular}{l c c c c c c}"
	file write myfile " \toprule "
	file close myfile

	eststo clear
	
	forvalues x = 90(30)150{

	sum chose_incentives`x' if week == 1
	local control_mean = r(mean)
	
	*Regress incentives chose on week2, week3, expected time sober, actual vs. expected difference
	eststo : regress chose_incentives`x' Week2 Week3 BAC_result choice_order interviewer_FE_*, r cluster(pid) nocons
	estadd scalar control_group_mean = `control_mean'
	estadd local obs = string(e(N))
	
	local append_replace = "append"

	*Regress incentives chose on week2, week3, expected time sober, actual vs. expected difference
	eststo: regress chose_incentives`x' Week2 Week3 exp_sober_days Sober_dif_pos choice_order interviewer_FE_*, r cluster(pid) nocons
	estadd scalar control_group_mean = `control_mean'
	estadd local obs = string(e(N))	

	}
		
esttab using "$tables/6c_Choice_table1_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(interviewer_FE_* `controls' choice_order Week2 Week3) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(BAC_result Sober_dif_pos exp_sober_days) ///
scalars("r2 R-squared" "control_group_mean Control group mean in Week 1") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)", pattern(1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable: chose incentives} & \multicolumn{2}{c}{\textbf{Rs 90}} & ///
		\multicolumn{2}{c}{\textbf{Rs 120}} & \multicolumn{2}{c}{\textbf{Rs 150}} \\ \cmidrule(lr){2-3} ///
		\cmidrule(lr){4-5} \cmidrule(lr){6-7} )) ///

eststo clear

cap file close _all
file open myfile using "$tables/6c_Choice_table1_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

		
		restore

	
*********************************************************
*********************************************************
*Table 2 lower panel:
*Demand for Sobriety Incentives
*Choices in week 3
*********************************************************
*********************************************************

preserve

	keep if week == 3

	sum chose_incentives90
	local control_mean1 = r(mean)
	sum chose_incentives120
	local control_mean2 = r(mean)
	sum chose_incentives150
	local control_mean3 = r(mean)

	label var Treatment "Incentives"

	*Drop redundant FE (that would be dropped anyway):
	drop interviewer_FE_4
	drop interviewer_FE_11
	drop interviewer_FE_13
	drop interviewer_FE_17

	local append_replace = "replace"
	
	file open myfile using "$tables/6d_Choice_table2_FINAL.tex", write replace
	file write myfile "\begin{tabular}{l c c c c c c}"
	file write myfile " \toprule "
	file close myfile

	eststo clear
	

	forvalues x = 90(30)150{

	sum chose_incentives`x' if tx_group == 3
	local control_mean = r(mean)
		
	*Regress incentives chose on treatment, choice, choice order, BAC result, expected days sober
	eststo: regress chose_incentives`x' Treatment Choice choice_order BAC_result interviewer_FE_* if week == 3, r nocons
	estadd scalar control_group_mean = `control_mean'
	estadd local obs = string(e(N))	

	local append_replace = "append"

	*Regress incentives chose on treatment, choice, choice order, BAC result, expected days sober
	eststo: regress chose_incentives`x' Pooled_treat choice_order BAC_result interviewer_FE_* if week == 3, r nocons
	estadd scalar control_group_mean = `control_mean'
	estadd local obs = string(e(N))	
	
	}

esttab using "$tables/6d_Choice_table2_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(interviewer_FE_* choice_order ) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(BAC_result Treatment Choice Pooled_treat) ///
scalars("r2 R-squared" "control_group_mean Control group mean in Week 3") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)", pattern(1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable: chose incentives} & \multicolumn{2}{c}{\textbf{Rs 90}} & ///
		\multicolumn{2}{c}{\textbf{Rs 120}} & \multicolumn{2}{c}{\textbf{Rs 150}} \\ \cmidrule(lr){2-3} ///
		\cmidrule(lr){4-5} \cmidrule(lr){6-7} )) ///

eststo clear

cap file close _all
file open myfile using "$tables/6d_Choice_table2_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile
	
restore 

*DONE!

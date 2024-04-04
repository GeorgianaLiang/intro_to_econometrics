
**************************************************************************************
*Analysis of Drinking Outcomes
**************************************************************************************

clear
set more off

**************************************************************************************
use "$analysis_datasets/Final_alcohol_main_data.dta", clear
**************************************************************************************

* Consider only individuals who made it at least to day 4 (i.e. who were assigned a treatment):
keep if day4 == 1

*Consider only individuals between days 1 and 20: 
keep if day_in_study < 20 & day_in_study > 1

*Check whether data are complete:
bys tx_group: tab day_in_study, m

	
*********************************************************
*********************************************************
*Figure 3 upper panel:
*The Impact of Incentives on Sobriety and Attendance
*Sobriety by day of study and treatment group
*********************************************************
*********************************************************
	
preserve
			
	collapse (mean) mean_sober = sober_dummy (sd) sd_sober = sober_dummy (sum) number, by(day_in_study tx_group)
	replace mean_sober = 100 * mean_sober
			
	twoway 	(scatter mean_sober day_in_study if tx_group == 1, sort mcolor(gs1) lcolor(gs1) connect(l) ///
			msize(medium) msymbol(circle) lwidth(medthick) xline(4.5, lcolor(navy))) ///
			(scatter mean_sober day_in_study if tx_group == 2, sort mcolor(forest_green) lcolor(forest_green) connect(l) ///
			msize(medium) msymbol(square_hollow)) ///
			(scatter mean_sober day_in_study if tx_group == 3, sort mcolor(maroon) lcolor(maroon) connect(l) ///
			msize(medium) msymbol(diamond_hollow) lwidth(medthick) lpattern(shortdash_dot) ///
			text(31 8.6 "{&larr} Sobriety incentives assigned", color(navy))) , ///
			ysc(r(30 60)) ymtick(30(10)60) ylabel(30(10)60) ///
			xsc(r(1.5 19.5)) xmtick(2 5 10 15 19) xlabel(2 5 10 15 19) ///
			graphregion(color(white)) bgcolor(white) ///
			xtitle("Day in Study") ytitle("Fraction Sober (%)") title("Sobriety at the Study Office") ///
			legend(label(1 "Incentives") label(2 "Choice") label(3 "Control") rows(1))

	*Save graph
	graph export "$figures/3a_Sobriety_figure_FINAL.eps", replace 
	
restore
		

*********************************************************
*********************************************************
*Online Appendix Figure A.5
*The Impact of Incentives on Sobriety -- Splitting up the Choice Group
*********************************************************
*********************************************************

preserve
	
	generate chose_incentives1 = (third_choice == 1) if day_in_study == 7 & tx_group == 2
	replace chose_incentives1 = 0 if present_today == . & day_in_study == 7 & tx_group == 2
	tab chose_incentives1, m

	sort pid day_in_study
	order tx_group pid day_in_study chose_incentives1 choice1
	bysort pid: egen chose_incentives1b = max(chose_incentives1)
	order tx_group pid day_in_study chose_incentives1 chose_incentives1b choice1
	replace tx_group = 4 if chose_incentives1b == 1
	replace tx_group = 5 if chose_incentives1b == 0
		
	collapse (mean) mean_sober = sober_dummy (sd) sd_sober = sober_dummy (sum) number, by(day_in_study tx_group)
	replace mean_sober = 100 * mean_sober
			
	twoway 	(scatter mean_sober day_in_study if tx_group == 1, sort mcolor(gs1) lcolor(gs1) ///
			connect(l) msize(medium) msymbol(circle) lwidth(medthick) xline(4.5, lcolor(navy))) ///
			(scatter mean_sober day_in_study if tx_group == 3, sort mcolor(maroon) lcolor(maroon) ///
			connect(l) msize(medium) msymbol(diamond_hollow) lwidth(medthick) lpattern(shortdash_dot)) ///
			(scatter mean_sober day_in_study if tx_group == 4, sort mcolor(forest_green) lcolor(forest_green) ///
			connect(l) msize(medium) msymbol(square_hollow)) ///
			(scatter mean_sober day_in_study if tx_group == 5, sort mcolor(forest_green) lcolor(forest_green) ///
			connect(l) msize(medium) msymbol(square_hollow) lpattern(shortdash_dot) ///	
			text(31 8.4 "{&larr} Alcohol treatment assigned", color(navy))), ///
			ysc(r(30 60)) ymtick(30(10)60) ylabel(30(10)60) ///
			xsc(r(1.5 19.5)) xmtick(2 5 10 15 19) xlabel(2 5 10 15 19) ///
			graphregion(color(white)) bgcolor(white) ///
			xtitle("Day in Study") ytitle("Fraction Sober (%)") title("Sobriety at the Study Office") ///
			legend(label(1 "Incentives") label(2 "Control") label(3 "Chose Incentives") ///
			label(4 "Did Not Choose Incentives") rows(2))

	*Save graph
	graph export "$figures/3b_Sobriety_figure_bychoice_FINAL.eps", replace 
	
restore	


*********************************************************
*********************************************************
*Figure 4 upper panel:
*The Impact of Incentives on Day Drinking and Overall Drinking
*Number of drinks before office visit and overall
*********************************************************
*********************************************************

preserve
	
	collapse (mean) mean_std_drinks_today = std_drinks_today (mean) mean_std_drinks_ystd = std_drinks_1day ///
	(sum) number, by(day_in_study tx_group)

	twoway (scatter mean_std_drinks_today day_in_study if tx_group == 1, sort mcolor(gs1) lcolor(gs1) ///
	connect(l) msize(medium) msymbol(circle) lwidth(medthick)) ///
	(scatter mean_std_drinks_today day_in_study if tx_group == 2, sort mcolor(forest_green) lcolor(forest_green) ///
	connect(l) msize(medium) msymbol(square_hollow)) ///
	(scatter mean_std_drinks_today day_in_study if tx_group == 3, sort mcolor(maroon) lcolor(maroon) ///
	connect(l) msize(medium) msymbol(diamond_hollow) lwidth(medthick) lpattern(shortdash_dot)) ///
	(scatter mean_std_drinks_ystd day_in_study if tx_group == 1, sort mcolor(gs1) lcolor(gs1) ///
	connect(l) msize(medium) msymbol(circle) lwidth(medthick)) ///
	(scatter mean_std_drinks_ystd day_in_study if tx_group == 2, sort mcolor(forest_green) lcolor(forest_green) ///
	connect(l) msize(medium) msymbol(square_hollow)) ///
	(scatter mean_std_drinks_ystd day_in_study if tx_group == 3, sort mcolor(maroon) lcolor(maroon) connect(l) ///
	msize(medium) msymbol(diamond_hollow) lwidth(medthick) lpattern(shortdash_dot) ///
	graphregion(color(white)) bgcolor(white) ///
	text(0.8 10 "{&uarr}", color(navy)) ///
	text(0.4 10 "drinking before study office visit", color(navy)) ///
	text(6.5 10 "overall drinking", color(navy)) ///
	text(6.0 10 "{&darr}", color(navy)) ///
	xline(4.5, lcolor(navy)) ysc(r(0 7)) ymtick(0(1)7) ylabel(0(1)7)), ///
	xsc(r(1 20)) xmtick(1 5 10 15 19) xlabel(1 5 10 15 19) ///
	xtitle("Day in Study") ytitle("Number of Standard Drinks") title("Drinking before Study Office Visit and Overall")  ///
	legend(order(1 2 3) label(1 "Incentives") label(2 "Choice") label(3 "Control") rows(1)) ///
								
	*Save graph
	capture graph export "$figures/3c_Drinks_figure_FINAL.eps", replace 

restore
		

*********************************************************
*********************************************************
*Figure 4 lower panel:
*The Impact of Incentives on Day Drinking and Overall Drinking
*Time of first drink
*********************************************************
*********************************************************

distplot line time_first_drink if day_in_study > 4 & day_in_study < 20, ///
mcolor(gs1) by(tx_group) xtitle("Time of day (24h)") ytitle("Fraction of individuals who started drinking") ///
lcolor(gs1 forest_green maroon) lwidth(medthick) ///
lpattern(solid longdash_dot solid) legend(label(1 "Incentives") label(2 "Choice") label(3 "Control") rows(1)) ///
xline(18, lcolor(navy)) xsc(r(6 24)) xlabel(6(2)24) text(0.8 15.4 "Study office opens {&rarr}", color(navy)) ///
graphregion(color(white)) bgcolor(white) title("Time of First Drink") recast(line)
	
graph export "$figures/3d_Time_drinks_figure_FINAL.eps", replace 	


*********************************************************
*********************************************************
*Online Appendix Figure A.6 and A.7
*Unconditional Distribution of Breathalyzer Scores by Treatment
*********************************************************
*********************************************************

preserve

	hist BAC_result if BAC_result < 0.3 & day_in_study <= 4, by(tx_group, col(1) graphregion(color(white)) ///
	bgcolor(white)) bin(50) fraction color(navy) subtitle(,fcolor(white) lcolor(white)) 
	capture graph export "$figures/3e1_BAC_dist_before_treat_all_FINAL.eps", replace 
	
	hist BAC_result if BAC_result < 0.3 & day_in_study > 4, by(tx_group, col(1) graphregion(color(white)) ///
	bgcolor(white)) bin(50) fraction color(navy) subtitle(,fcolor(white) lcolor(white)) 
	capture graph export "$figures/3e2_BAC_dist_during_treat_all_FINAL.eps", replace 

	hist BAC_result if BAC_result < 0.3 & BAC_result > 0 & day_in_study <= 4, by(tx_group, col(1) graphregion(color(white)) ///
	bgcolor(white)) bin(50) fraction color(navy) subtitle(,fcolor(white) lcolor(white)) 
	capture graph export "$figures/3e3_BAC_dist_before_treat_pos_FINAL.eps", replace 

	hist BAC_result if BAC_result < 0.3 & BAC_result > 0 & day_in_study > 4, by(tx_group, col(1) graphregion(color(white)) ///
	bgcolor(white)) bin(50) fraction color(navy) subtitle(,fcolor(white) lcolor(white)) 
	capture graph export "$figures/3e4_BAC_dist_during_treat_pos_FINAL.eps", replace 

restore


*********************************************************
*********************************************************
*Table 3: The Effect of Incentives on Sobriety
*********************************************************
*********************************************************
	
*********************************************************
*Table 3 upper panel
*********************************************************
file open myfile using "$tables/3a_Drinking_table1_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile " \toprule "
file close myfile

*********************************************************
*(i) Fraction sober at study office
*********************************************************

tab sober_dummy if day_in_study > 4, m

*Summarize sober dummy variable if in treatment group 3 and study day is between 4 and 20
sum sober_dummy if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo clear

eststo est1: regress sober_dummy Treat_group Choice_group $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est2: regress sober_dummy Pooled_treat $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))


*********************************************************
*(ii) BAC at study office
*********************************************************

*Summarize BAC result if in treatment group 3 and study day is between 4 and 20
sum BAC_result if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est3: regress BAC_result Treat_group Choice_group $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est4: regress BAC_result Pooled_treat $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*********************************************************
*(iii) Number of drinks before coming to study office
*********************************************************

*Summarize number of drinks today in control group for study days between 4 and 20
sum std_drinks_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean2 = r(mean)

eststo est5: regress std_drinks_today Treat_group Choice_group $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))

eststo est6: regress std_drinks_today Pooled_treat $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))


esttab using "$tables/3a_Drinking_table1_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls $controls_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group Pooled_treat) ///
scalars("r2 R-squared" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)", pattern(1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable:} & \multicolumn{2}{c}{\textbf{Sober}} & ///
		\multicolumn{2}{c}{\textbf{BAC}} & \multicolumn{2}{c}{\textbf{\# Drinks}} \\ \cmidrule(lr){2-3} ///
		\cmidrule(lr){4-5} \cmidrule(lr){6-7} )) ///

eststo clear

cap file close _all
file open myfile using "$tables/3a_Drinking_table1_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

*********************************************************
*Table 3 lower panel
*********************************************************
file open myfile using "$tables/3b_Drinking_table2_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile " \toprule "
file close myfile


*********************************************************
*(iv) Number of drinks yesterday
*********************************************************
	
*Summarize number of drinks yesterday in control group for study days between 4 and 20
sum std_drinks_1day if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo clear

eststo est1: regress std_drinks_1day Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est2: regress std_drinks_1day Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))


*********************************************************
*(v) Abstinence
*********************************************************

*Summarize no drinks dummy variable in control group for study days between 4 and 20
sum no_drink_1day if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est3: regress no_drink_1day Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est4: regress no_drink_1day Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))


*********************************************************
*(vi) Overall expenditures yesterday
*********************************************************

*Summarize amount spent on alcohol if in treatment group 3 and study day is between 4 and 20
sum Rs_alcohol if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est5: regress Rs_alcohol Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est6: regress Rs_alcohol Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))


esttab using "$tables/3b_Drinking_table2_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls $controls_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group Pooled_treat) ///
scalars("r2 R-squared" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)", pattern(1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable:} & \multicolumn{2}{c}{\textbf{\# Drinks}} & ///
		\multicolumn{2}{c}{\textbf{No drink}} & \multicolumn{2}{c}{\textbf{Rs./day}} \\ \cmidrule(lr){2-3} ///
		\cmidrule(lr){4-5} \cmidrule(lr){6-7} )) ///

eststo clear

cap file close _all
file open myfile using "$tables/3b_Drinking_table2_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile


*********************************************************
*********************************************************
*Online Appendix Table A.9: Lee bounds for Impacts on Sobriety and Savings
*********************************************************
*********************************************************

**************************************
*Lee Bounds on sobriety results
**************************************

generate sober_dummy_Lee = sober_dummy if BAC_result != .
regress sober_dummy Pooled_treat if day_in_study > 4

*****************************
*Sober Incentives
*****************************

regress sober_dummy_Lee Treat_group if day_in_study > 4 & Choice_group != 1
leebounds sober_dummy_Lee Treat_group if day_in_study > 4 & Choice_group != 1, cieffect

matrix lee_bounds_sober_i = e(b)
matrix lee_bounds_sober_i_var = e(V)

scalar lee_lower_sober_i = lee_bounds_sober_i[1,1]
scalar lee_upper_sober_i = lee_bounds_sober_i[1,2]

scalar lee_lower_sober_i_se = sqrt(lee_bounds_sober_i_var[1,1])
scalar lee_upper_sober_i_se = sqrt(lee_bounds_sober_i_var[2,2])

scalar lee_lower_ci_sober_i =  e(cilower)
scalar lee_upper_ci_sober_i =  e(ciupper)

*****************************
*Sober Choice
*****************************

regress sober_dummy_Lee Choice_group if day_in_study > 4 & Treat_group != 1
leebounds sober_dummy_Lee Choice_group if day_in_study > 4 & Treat_group != 1, cieffect

matrix lee_bounds_sober_c = e(b)
matrix lee_bounds_sober_c_var = e(V)

scalar lee_lower_sober_c = lee_bounds_sober_c[1,1]
scalar lee_upper_sober_c = lee_bounds_sober_c[1,2]

scalar lee_lower_sober_c_se = sqrt(lee_bounds_sober_c_var[1,1])
scalar lee_upper_sober_c_se = sqrt(lee_bounds_sober_c_var[2,2])

scalar lee_lower_ci_sober_c =  e(cilower)
scalar lee_upper_ci_sober_c =  e(ciupper)

*****************************
*Sober Pooled
*****************************

regress sober_dummy_Lee Pooled_treat if day_in_study > 4
leebounds sober_dummy_Lee Pooled_treat if day_in_study > 4, cieffect

matrix lee_bounds_sober_p = e(b)
matrix lee_bounds_sober_p_var = e(V)

scalar lee_lower_sober_p = lee_bounds_sober_p[1,1]
scalar lee_upper_sober_p = lee_bounds_sober_p[1,2]

scalar lee_lower_sober_p_se = sqrt(lee_bounds_sober_p_var[1,1])
scalar lee_upper_sober_p_se = sqrt(lee_bounds_sober_p_var[2,2])

scalar lee_lower_ci_sober_p =  e(cilower)
scalar lee_upper_ci_sober_p =  e(ciupper)

**************************************
*Lee Bounds on savings results
**************************************

generate save_today_Lee = save_today if present_today == 1
regress save_today_Lee Pooled_treat if day_in_study > 4

*****************************
*Save Incentives
*****************************

regress save_today_Lee Treat_group if day_in_study > 4 & Choice_group != 1
leebounds save_today_Lee Treat_group if day_in_study > 4 & Choice_group != 1, cieffect

matrix lee_bounds_save_i = e(b)
matrix lee_bounds_save_i_var = e(V)

scalar lee_lower_save_i = lee_bounds_save_i[1,1]
scalar lee_upper_save_i = lee_bounds_save_i[1,2]

scalar lee_lower_save_i_se = sqrt(lee_bounds_save_i_var[1,1])
scalar lee_upper_save_i_se = sqrt(lee_bounds_save_i_var[2,2])

scalar lee_lower_ci_save_i =  e(cilower)
scalar lee_upper_ci_save_i =  e(ciupper)

*****************************
*Save Choice
*****************************

regress save_today_Lee Choice_group if day_in_study > 4 & Treat_group != 1
leebounds save_today_Lee Choice_group if day_in_study > 4 & Treat_group != 1, cieffect

matrix lee_bounds_save_c = e(b)
matrix lee_bounds_save_c_var = e(V)

scalar lee_lower_save_c = lee_bounds_save_c[1,1]
scalar lee_upper_save_c = lee_bounds_save_c[1,2]

scalar lee_lower_save_c_se = sqrt(lee_bounds_save_c_var[1,1])
scalar lee_upper_save_c_se = sqrt(lee_bounds_save_c_var[2,2])

scalar lee_lower_ci_save_c =  e(cilower)
scalar lee_upper_ci_save_c =  e(ciupper)

*****************************
*Save Pooled
*****************************

regress save_today_Lee Pooled_treat if day_in_study > 4
leebounds save_today_Lee Pooled_treat if day_in_study > 4, cieffect

matrix lee_bounds_save_p = e(b)
matrix lee_bounds_save_p_var = e(V)

scalar lee_lower_save_p = lee_bounds_save_p[1,1]
scalar lee_upper_save_p = lee_bounds_save_p[1,2]

scalar lee_lower_save_p_se = sqrt(lee_bounds_save_p_var[1,1])
scalar lee_upper_save_p_se = sqrt(lee_bounds_save_p_var[2,2])

scalar lee_lower_ci_save_p =  e(cilower)
scalar lee_upper_ci_save_p =  e(ciupper)


cap file close _all
file open myfile using "$tables/3e_Lee_bounds_table_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile "\toprule"
file write myfile "  & \multicolumn{2}{c}{\textbf{Incentives}} & \multicolumn{2}{c}{\textbf{Choice}} & \multicolumn{2}{c}{\textbf{Pooled}} \\"
file write myfile "\cmidrule(r){2-3} \cmidrule(r){4-5} \cmidrule(r){6-7}"
file write myfile " & Lower & Upper & Lower  & Upper  & Lower & Upper \\ "
file write myfile " & (1) & (2) & (3) & (4) & (5) & (6) \\ "

file write myfile " \midrule "

file write myfile "\\"

*Lee Bounds point estimates for sobriety
file write myfile "\textbf{\underline{Panel A: Sobriety}}" "\\" 
 
file write myfile ///
"Lee Bounds" "&" /// 
%7.3f (lee_lower_sober_i) "&" %7.3f (lee_upper_sober_i) "&" ///
%7.3f (lee_lower_sober_c) "&" %7.3f (lee_upper_sober_c) "&" ///
%7.3f (lee_lower_sober_p) "&" %7.3f (lee_upper_sober_p) "\\"

*Lee Bounds standard errors
file write myfile  ///
"Standard Error" "&" /// 
"(\!\!" %7.3f (lee_lower_sober_i_se) ")" "&" "(\!\!" %7.3f (lee_upper_sober_i_se) ")" "&" ///
"(\!\!" %7.3f (lee_lower_sober_c_se) ")" "&" "(\!\!" %7.3f (lee_upper_sober_c_se) ")" "&" ///
"(\!\!" %7.3f (lee_lower_sober_p_se) ")" "&" "(\!\!" %7.3f (lee_upper_sober_p_se) ")" "\\"

*Lee Bounds confidence intervals
file write myfile ///
"Imbens-Manski 95\% CI" ///
"& \multicolumn{2}{c}{" "[\!\!" %7.3f (lee_lower_ci_sober_i) "," %7.3f (lee_upper_ci_sober_i) "]}" ///
"& \multicolumn{2}{c}{" "[\!\!" %7.3f (lee_lower_ci_sober_c) "," %7.3f (lee_upper_ci_sober_c) "]}" ///
"& \multicolumn{2}{c}{" "[\!\!" %7.3f (lee_lower_ci_sober_p) "," %7.3f (lee_upper_ci_sober_p) "]}" "\\"

*file write myfile "\midrule"

file write myfile "\\"

*Lee Bounds point estimates for savings
file write myfile "\textbf{\underline{Panel B: Savings}}" "\\" 
 
file write myfile ///
"Lee Bounds" "&" /// 
%7.3f (lee_lower_save_i) "&" %7.3f (lee_upper_save_i) "&" ///
%7.3f (lee_lower_save_c) "&" %7.3f (lee_upper_save_c) "&" ///
%7.3f (lee_lower_save_p) "&" %7.3f (lee_upper_save_p) "\\"

*Lee Bounds standard errors
file write myfile  ///
"Standard Error" "&" /// 
"(\!\!" %7.3f (lee_lower_save_i_se) ")" "&" "(\!\!" %7.3f (lee_upper_save_i_se) ")" "&" ///
"(\!\!" %7.3f (lee_lower_save_c_se) ")" "&" "(\!\!" %7.3f (lee_upper_save_c_se) ")" "&" ///
"(\!\!" %7.3f (lee_lower_save_p_se) ")" "&" "(\!\!" %7.3f (lee_upper_save_p_se) ")" "\\"

*Lee Bounds confidence intervals
file write myfile ///
"Imbens-Manski 95\% CI" ///
"& \multicolumn{2}{c}{" "[\!\!" %7.3f (lee_lower_ci_save_i) "," %7.3f (lee_upper_ci_save_i) "]}" ///
"& \multicolumn{2}{c}{" "[\!\!" %7.3f (lee_lower_ci_save_c) "," %7.3f (lee_upper_ci_save_c) "]}" ///
"& \multicolumn{2}{c}{" "[\!\!" %7.3f (lee_lower_ci_save_p) "," %7.3f (lee_upper_ci_save_p) "]}" "\\"

file write myfile "\\"

file write myfile "\bottomrule"
file write myfile "\end{tabular}"

file close myfile


*********************************************************
*********************************************************
*Online Appendix Table A.7:
*Times of Study Office Visits and First Drinks
*********************************************************
*********************************************************

file open myfile using "$tables/3f_Hours_table_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c}"
file write myfile " \toprule "
file close myfile

**************************************
*(i) Time of office visits
**************************************

*Summarize start time if in treatment group 3 and study day is between 4 and 20
sum hours_visit if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo clear
*Regress start time

eststo est1: regress hours_visit Treat_group Choice_group $controls_BL $controls if day_in_study > 4 & day_in_study < 20, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est2: regress hours_visit Pooled_treat $controls_BL $controls if day_in_study > 4 & day_in_study < 20, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

**************************************
*(ii) Time of first drink
**************************************

sum time_first_drink if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est3: regress time_first_drink Treat_group Choice_group $controls_BL $controls if day_in_study > 4 & day_in_study < 20, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est4: regress time_first_drink Pooled_treat $controls_BL $controls if day_in_study > 4 & day_in_study < 20, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

esttab using "$tables/3f_Hours_table_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls $controls_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group Pooled_treat) ///
scalars("r2 R-squared" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)", pattern(1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable:} & \multicolumn{2}{c}{\textbf{Time of study office visit}} & ///
		\multicolumn{2}{c}{\textbf{Time of first drink}} \\ \cmidrule(lr){2-3} ///
		\cmidrule(lr){4-5})) ///

eststo clear

cap file close _all
file open myfile using "$tables/3f_Hours_table_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

*DONE

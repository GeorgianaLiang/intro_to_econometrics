
**************************************************************************************
*Analysis of Attendance
**************************************************************************************

clear
set more off

**************************************************************************************
use "$analysis_datasets/Final_alcohol_main_data.dta", clear
**************************************************************************************

* Consider only individuals who made it at least to day 4 (i.e. who made it past the lead-in period):
keep if day4 == 1 

*Consider only individuals between days 1 and 20: 
keep if day_in_study < 20 & day_in_study > 1

*Check whether data are complete:
bys tx_group: tab day_in_study, m


**************************************************************************************
*Calculate mean attendance
**************************************************************************************

*Overall attendance
sum present_today
bys tx_group: sum present_today

*Attendance post phase 1
sum present_today if day_in_study > 4 & day_in_study < 20
bys tx_group: sum present_today if day_in_study > 4 & day_in_study < 20

**************************************************************************************
* Figure 3 lower panel:
* The Impact of Incentives on Sobriety and Attendance
* Graph for attendance by day in study by sobriety incentive treatment
**************************************************************************************

preserve
						
	collapse (mean) mean_present = present_today, by(day_in_study tx_group)
	replace mean_present = 100 * mean_present

	twoway 	(scatter mean_present day_in_study if tx_group == 1, sort mcolor(gs1) lcolor(gs1) connect(l) ///
			msize(medium) msymbol(circle) lwidth(medthick) xline(4.5, lcolor(navy))) ///
			(scatter mean_present day_in_study if tx_group == 2, sort mcolor(forest_green) lcolor(forest_green) connect(l) ///
			msize(medium) msymbol(square_hollow)) ///
			(scatter mean_present day_in_study if tx_group == 3, sort mcolor(maroon) lcolor(maroon) connect(l) ///
			msize(medium) msymbol(diamond_hollow) lwidth(medthick) lpattern(shortdash_dot) ///
			text(98 8.6 "{&larr} Sobriety incentives assigned", color(navy))), ///
			ysc(r(70 100)) ymtick(70(5)100) ylabel(70(5)100) ///
			xsc(r(1.5 19.5)) xmtick(2 5 10 15 19) xlabel(2 5 10 15 19) ///
			graphregion(color(white)) bgcolor(white) ///
			xtitle("Day in Study") ytitle("Attendance (%)") title("Attendance by Day in Study") ///
			legend(label(1 "Incentives") label(2 "Choice") label(3 "Control") rows(1))

	graph export "$figures/2_Attendance_figure_FINAL.eps", replace 

restore


**************************************************************************************
* Online Appendix Table A.8 The Effect of Incentives on Attendance
**************************************************************************************

*Control mean
sum present_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

*Reformat baseline savings variable to make table readable
generate savings_BL_100 = (savings_BL*4)/100
label var savings_BL_100 "Amount saved in Phase 1 (divided by 100)"

*Generate interaction between baseline savings and treatments
gen savings_BL_100_X_Treat_group = savings_BL_100 * Treat_group
label var savings_BL_100_X_Treat_group "Incentives X Amount saved in Phase 1"

gen savings_BL_100_X_Choice_group = savings_BL_100 * Choice_group
label var savings_BL_100_X_Choice_group "Choice X Amount saved in Phase 1"

*Generate tables
file open myfile using "$tables/2_Attendance_table_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c c}"
file write myfile " \toprule "
file close myfile

eststo clear
eststo: regress present_today Treat_group Choice_group if day_in_study > 4, r cluster(pid)
estadd local phase1_controls "NO"
estadd local baseline_controls "NO"
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo: regress present_today Treat_group Choice_group $controls_BL if day_in_study > 4, r cluster(pid)
estadd local phase1_controls "YES"
estadd local baseline_controls "NO"
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo: regress present_today Treat_group Choice_group $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd local phase1_controls "YES"
estadd local baseline_controls "YES"
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo: regress present_today Treat_group Choice_group frac_sober_BL if day_in_study > 4, r cluster(pid)
estadd local phase1_controls "NO"
estadd local baseline_controls "NO"
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo: regress present_today Treat_group Choice_group frac_sober_BL frac_sober_BL_X_Treat_group frac_sober_BL_X_Choice_group if day_in_study > 4, r cluster(pid)
estadd local phase1_controls "NO"
estadd local baseline_controls "NO"
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo: regress present_today Treat_group Choice_group savings_BL_100 if day_in_study > 4, r cluster(pid)
estadd local phase1_controls "NO"
estadd local baseline_controls "NO"
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo: regress present_today Treat_group Choice_group savings_BL_100 savings_BL_100_X_Treat_group savings_BL_100_X_Choice_group if day_in_study > 4, r cluster(pid)
estadd local phase1_controls "NO"
estadd local baseline_controls "NO"
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

esttab using "$tables/2_Attendance_table_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls Std_drinks_today_BL Std_drinks_overall_BL mean_BAC_BL earnings_BL savings_BL Rs_alcohol_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group frac_sober_BL frac_sober_BL_X_Treat_group frac_sober_BL_X_Choice_group savings_BL_100 savings_BL_100_X_Treat_group savings_BL_100_X_Choice_group) ///
scalars("r2 R-squared" "baseline_controls Baseline survey controls" "phase1_controls Phase 1 controls" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)", pattern(1 1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(&\multicolumn{7}{c}{\textbf{Dependent variable: present at study office}}\\\cmidrule(lr){2-8}) ) ///

eststo clear

cap file close _all
file open myfile using "$tables/2_Attendance_table_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

*DONE!

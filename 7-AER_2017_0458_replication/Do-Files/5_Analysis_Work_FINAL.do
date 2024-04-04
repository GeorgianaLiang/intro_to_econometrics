
**************************************************************************************
*Analysis of Work Outcomes
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

*Re-add baseline savings to baseline controls
global controls_BL "frac_sober_BL Std_drinks_today_BL Std_drinks_overall_BL mean_BAC_BL earnings_BL Rs_alcohol_BL savings_BL"
local controls_BL $controls_BL


*********************************************************
*********************************************************
*Table 4: The Effect of Sobriety Incentives on Labor Market Outcomes
*********************************************************
*********************************************************

file open myfile using "$tables/5_Earnings_table_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile " \toprule "
file close myfile

eststo clear

*********************************************************
*Column 1 and 2: Earnings (Rs/day)
*********************************************************

*Summarize and regress earned today
sum earn_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est1: regress earn_today Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est2: regress earn_today Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*********************************************************
*Columns 3 and 4: Labor Supply (extensive margin)
*********************************************************

*Summarize and regress worked today
sum work_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est3: regress work_today Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est4: regress work_today Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*********************************************************
*Columns 5 and 6: Hours worked 
*********************************************************

*Summarize and regress hours worked today
sum hours_worked_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est5: regress hours_worked_today Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est6: regress hours_worked_today Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

esttab using "$tables/5_Earnings_table_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls $controls_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group Pooled_treat) ///
scalars("r2 R-squared" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)", pattern(1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable:} & \multicolumn{2}{c}{\textbf{Earnings}} & ///
		\multicolumn{2}{c}{\textbf{Did any work}} & \multicolumn{2}{c}{\textbf{Hours worked}} \\ \cmidrule(lr){2-3} ///
		\cmidrule(lr){4-5} \cmidrule(lr){6-7} )) ///

eststo clear

cap file close _all
file open myfile using "$tables/5_Earnings_table_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

*DONE!

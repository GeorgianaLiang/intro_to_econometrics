
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


*********************************************************
*********************************************************
* Online Appendix Table A.11
* Effect of Sobriety Incentives on Family Resources and Other Expenses
*********************************************************
*********************************************************

file open myfile using "$tables/7_Other_expenses_table_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c c c c c c c}"
file write myfile " \toprule "
file write myfile " & \multicolumn{6}{c}{\textbf{Money given to family (Rs./day)}} & \multicolumn{6}{c}{\textbf{Other expenses (Rs./day)}} \\ \cmidrule(lr){2-7} \cmidrule(lr){8-13} "
file write myfile "& \multicolumn{2}{c}{\textbf{To wife}} & \multicolumn{2}{c}{\textbf{To others}} & \multicolumn{2}{c}{\textbf{Total}} & \multicolumn{2}{c}{\textbf{Food}} & \multicolumn{2}{c}{\textbf{Coffee \& tea}} & \multicolumn{2}{c}{\textbf{Tobacco \& paan}} \\"
file close myfile

eststo clear

****************************************
*Money given to wife
****************************************

*Summarize and regress money given to wife
sum Rs_to_wife_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est1: regress Rs_to_wife_today Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est2: regress Rs_to_wife_today Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

****************************************
*Money given to other family members
****************************************

replace Rs_to_family_today = Rs_to_family_today + Rs_to_household_today

*Summarize and regress money given to other family members
sum Rs_to_family_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est3: regress Rs_to_family_today Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est4: regress Rs_to_family_today Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

****************************************
*Overall family resources
****************************************

generate Rs_family_overall = Rs_to_wife_today + Rs_to_family_today

*Summarize and regress money given to entire family
sum Rs_family_overall if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est5: regress Rs_family_overall Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est6: regress Rs_family_overall Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

****************************************
*Other expenses
****************************************

generate Rs_food = Rs_spent_food_outside + Rs_spent_sidedishes_alc
generate Rs_cig_paan = Rs_spent_cigs + Rs_spent_paan

*Summarize and regress money spent on food
sum Rs_food if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est7: regress Rs_food Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est8: regress Rs_food Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*Summarize and regress money spent on coffee and tea
sum Rs_spent_coffeetea if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est9: regress Rs_spent_coffeetea Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est10: regress Rs_spent_coffeetea Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*Summarize and regress money spent on cigarettes/paan
sum Rs_cig_paan if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est11: regress Rs_cig_paan Treat_group Choice_group $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

eststo est12: regress Rs_cig_paan Pooled_treat $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

esttab using "$tables/7_Other_expenses_table_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls $controls_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group Pooled_treat) ///
scalars("r2 R-squared" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)" "(11)" "(12)", pattern(1 1 1 1 1 1 1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9} \cmidrule(lr){10-11} \cmidrule(lr){12-13} ))  

eststo clear

cap file close _all
file open myfile using "$tables/7_Other_expenses_table_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

*DONE!

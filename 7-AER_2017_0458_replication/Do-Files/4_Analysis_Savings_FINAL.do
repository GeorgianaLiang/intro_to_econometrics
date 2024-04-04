
**************************************************************************************
*Analysis of Savings Outcomes
**************************************************************************************

clear
set more off

**************************************************************************************
use "$analysis_datasets/Final_alcohol_main_data.dta", clear
**************************************************************************************

* Consider only individuals who made it at least to day 4 (i.e. who were assigned a treatment):
keep if day4 == 1

*Consider only individuals between days 1 and 20: 
keep if day_in_study < 20 & day_in_study > 0

*Check whether data are complete:
bys tx_group: tab day_in_study, m

*Take out baseline savings from "controls_BL" (will be added separately)
global controls_BL "frac_sober_BL Std_drinks_today_BL Std_drinks_overall_BL mean_BAC_BL earnings_BL Rs_alcohol_BL"
local controls_BL $controls_BL
		
		
*********************************************************
*********************************************************
*Figure 5 upper panel:
*Total savings by study day and treatment group
*********************************************************
*********************************************************
				
preserve
	
	collapse (mean) mean_savings = savings_total_postvisit (sd) sd_savings = savings_total_postvisit  (sum) number, by(day_in_study tx_group)
	
	twoway 	(scatter mean_savings day_in_study if tx_group == 1, sort mcolor(gs1) lcolor(gs1) ///
			connect(l) msize(medium) msymbol(circle) lwidth(medthick) xline(4.5, lcolor(navy))) ///
			(scatter mean_savings day_in_study if tx_group == 2, sort mcolor(forest_green) lcolor(forest_green) ///
			connect(l) msize(medium) msymbol(square_hollow)) ///
			(scatter mean_savings day_in_study if tx_group == 3, sort mcolor(maroon) lcolor(maroon) ///
			connect(l) msize(medium) msymbol(diamond_hollow) lwidth(medthick) lpattern(shortdash_dot) ///
			text(600 8.7 "{&larr} Sobriety incentives assigned", color(navy))) , ///
			graphregion(color(white)) bgcolor(white) ///
			ysc(r(0 700)) ymtick(0 200 400 600) ylabel(0 200 400 600) ///
			xsc(r(0.5 19.5)) xmtick(1 5 10 15 19) xlabel(1 5 10 15 19) ///
			xtitle("Day in Study") ytitle("Cumulative savings at study office (Rs)") title("Cumulative Savings by Treatment Group") ///
			legend(label(1 "Incentives") label(2 "Choice") label(3 "Control")  rows(1))
		
	graph export "$figures/4a_Savings_figure_FINAL.eps", replace 

restore


*********************************************************
*********************************************************
*Figure 5 lower panel:
*Study payments by study day and treatment group
*********************************************************
*********************************************************
	
preserve
	
	collapse (mean) mean_payment = payment_total (sd) sd_payment = payment_total (sum) number, by(day_in_study tx_group)

	generate hi_payment = mean_payment + invttail(n-1,0.025)*(sd_payment / sqrt(number))
	generate low_payment = mean_payment - invttail(n-1,0.025)*(sd_payment / sqrt(number))
		
	twoway 	(scatter mean_payment day_in_study if tx_group == 1, sort mcolor(gs1) lcolor(gs1) ///
			connect(l) msize(medium) msymbol(circle) lwidth(medthick) xline(4.5, lcolor(navy))) ///
			(scatter mean_payment day_in_study if tx_group == 2, sort mcolor(forest_green) lcolor(forest_green) ///
			connect(l) msize(medium) msymbol(square_hollow)) ///
			(scatter mean_payment day_in_study if tx_group == 3, sort mcolor(maroon) lcolor(maroon) ///
			connect(l) msize(medium) msymbol(diamond_hollow) lwidth(medthick) lpattern(shortdash_dot) ///
			text(1550 8.7 "{&larr} Sobriety incentives assigned", color(navy))) , ///
			ysc(r(0 1800)) ymtick(0(500)1500) ylabel(0(500)1500) ///
			xsc(r(0.5 19.5)) xmtick(1 5 10 15 19) xlabel(1 5 10 15 19) ///
			graphregion(color(white)) bgcolor(white) ///
			xtitle("Day in Study") ytitle("Cumulative study payments (Rs)") title("Cumulative Study Payments by Treatment Group") ///
			legend(label(1 "Incentives") label(2 "Choice") label(3 "Control") rows(1))
		
	graph export "$figures/4b_Payments_figure_FINAL.eps", replace 

restore
		

*********************************************************
*********************************************************
*Figure 6 upper panel:
*Interaction of Sobriety Incentives and Commitment Savings
*Daily Savings
*********************************************************
*********************************************************
	
preserve
		
	collapse (mean) mean_savings = savings_total_postvisit (sd) sd_savings = savings_total_postvisit (sum) number, by(day_in_study Pooled_treat Commit_group)

	twoway 	(scatter mean_savings day_in_study if Pooled_treat == 1 & Commit_group == 1, color(gs1)  	sort c(l) msymbol(triangle_hollow))  ///
			(scatter mean_savings day_in_study if Pooled_treat == 1 & Commit_group == 0, color(maroon) 	sort c(l) msymbol(circle_hollow)) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & Commit_group == 1, color(eltblue) sort c(l) msymbol(square) ) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & Commit_group == 0, color(forest_green) sort c(l) msymbol(circle) ), ///
			xtitle("Day in Study") ytitle("Cumulative savings (Rs)") title("Interaction of Sobriety Incentives and Commitment Savings") ///
			legend( ///
			label(1 "Sobriety incentives, commitment savings") ///
			label(2 "Sobriety incentives, no commitment savings") ///
			label(3 "No sobriety incentives, commitment savings") ///
			label(4 "No sobriety incentives, no commitment savings") ///
			rows(4)) graphregion(color(white)) bgcolor(white) ///
			ysc(r(0 700))  ymtick(0(200)700) ylabel(0(200)700) ///
			xsc(r(0.5 19.5)) xmtick(1 5 10 15 19) xlabel(1 5 10 15 19)

	graph export "$figures/4c_Savings_commit_figure_FINAL.eps", replace 
	
restore


*********************************************************
*********************************************************
*Figure 6 lower panel:
*Interaction of Sobriety Incentives and Matching Contribution
*Daily Savings
*********************************************************
*********************************************************

preserve

	collapse (mean) mean_savings = savings_total_postvisit (sd) sd_savings = savings_total_postvisit (sum) number, ///
	by(day_in_study Pooled_treat High_interest_group)
		
	twoway	(scatter mean_savings day_in_study if Pooled_treat == 1 & High_interest_group == 1, ///
			color(gs1) sort c(l) msymbol(triangle_hollow) )  ///
			(scatter mean_savings day_in_study if Pooled_treat == 1 & High_interest_group == 0, ///
			color(maroon) 	sort c(l) msymbol(circle_hollow)) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & High_interest_group == 1, ///
			color(eltblue) sort c(l) msymbol(square) ) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & High_interest_group == 0, ///
			color(forest_green) sort c(l) msymbol(circle) ), ///
			xtitle("Day in Study") ytitle("Cumulative savings (Rs)") title("Interaction of Sobriety Incentives and Matching Contribution") ///
			legend( ///
			label(1 "Sobriety incentives, high matching contribution") /// 
			label(2 "Sobriety incentives, low matching contribution") ///
			label(3 "No sobriety incentives, high matching contribution") ///
			label(4 "No sobriety incentives, low matching contribution") ///
			rows(4)) graphregion(color(white)) bgcolor(white)

		graph export "$figures/4d_Savings_match_figure_FINAL.eps", replace 
	
restore


*********************************************************
*********************************************************
*Figure 7 upper panel:
*Interaction of Sobriety Incentives and Commitment Savings
*Deposits
*********************************************************
*********************************************************

preserve
		
	collapse (mean) mean_savings = save_deposit_sum (sd) sd_savings = save_deposit_sum (sum) number, ///
	by(day_in_study Pooled_treat Commit_group)
		
	twoway 	(scatter mean_savings day_in_study if Pooled_treat == 1 & Commit_group == 1, color(gs1)  	sort c(l) msymbol(triangle_hollow) ) ///
			(scatter mean_savings day_in_study if Pooled_treat == 1 & Commit_group == 0, color(maroon) 	sort c(l) msymbol(circle_hollow)) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & Commit_group == 1, color(eltblue) sort c(l) msymbol(square) ) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & Commit_group == 0, color(forest_green) sort c(l) msymbol(circle) ), ///
			xtitle("Day in Study") ytitle("Cumulative depsits (Rs)") title("Sobriety vs. Commitment Savings: Cumulative Deposits") ///
			legend( ///
			label(1 "Sobriety incentives, commitment savings") ///
			label(2 "Sobriety incentives, no commitment savings") ///
			label(3 "No sobriety incentives, commitment savings") ///
			label(4 "No sobriety incentives, no commitment savings") /// 
			rows(4)) graphregion(color(white)) bgcolor(white) 
				
	graph export "$figures/4e_Savings_interact_deposits_figure_FINAL.eps", replace 
	
restore


*********************************************************
*********************************************************
*Figure 7 lower panel:
*Interaction of Sobriety Incentives and Commitment Savings
*Withdrawals
*********************************************************
*********************************************************

preserve
				
	collapse (mean) mean_savings = save_withdraw_sum (sd) sd_savings = save_withdraw_sum (sum) number, ///
	by(day_in_study Pooled_treat Commit_group)
		
	twoway 	(scatter mean_savings day_in_study if Pooled_treat == 1 & Commit_group == 1, color(gs1)  	sort c(l) msymbol(triangle_hollow) )  ///
			(scatter mean_savings day_in_study if Pooled_treat == 1 & Commit_group == 0, color(maroon) 	sort c(l) msymbol(circle_hollow)) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & Commit_group == 1, color(eltblue) sort c(l) msymbol(square) ) ///
			(scatter mean_savings day_in_study if Pooled_treat == 0 & Commit_group == 0, color(forest_green) sort c(l) msymbol(circle) ), ///
			xtitle("Day in Study") ytitle("Cumulative withdrawals (Rs)") title("Sobriety vs. Commitment Savings: Cumulative Withdrawals") ///
			legend( ///
			label(1 "Sobriety incentives, commitment savings") ///
			label(2 "Sobriety incentives, no commitment savings") ///
			label(3 "No sobriety incentives, commitment savings") ///
			label(4 "No sobriety incentives, no commitment savings") /// 
			rows(4)) graphregion(color(white)) bgcolor(white) 
				
	graph export "$figures/4f_Savings_interact_withdrawals_figure_FINAL.eps", replace 
	
restore


*********************************************************
*********************************************************
*Online Appendix Figure A.10 upper panel:
*Interaction of Sobriety Incentives and Commitment Savings
*(not pooled)
*********************************************************
*********************************************************
		
preserve

	collapse (mean) mean_savings = savings_total_postvisit (sd) sd_savings = savings_total_postvisit (sum) number, ///
	by(day_in_study tx_group Commit_group)
	
	twoway	(scatter mean_savings day_in_study if tx_group == 1 & Commit_group == 1, color(gs1)  	sort c(l) msymbol(triangle_hollow))  ///
			(scatter mean_savings day_in_study if tx_group == 1 & Commit_group == 0, color(maroon) 	sort c(l) msymbol(circle_hollow)) ///
			(scatter mean_savings day_in_study if tx_group == 2 & Commit_group == 1, color(navy)	sort c(l) msymbol(plus)) ///
			(scatter mean_savings day_in_study if tx_group == 2 & Commit_group == 0, color(gs8)		sort c(l) msymbol(triangle)) ///
			(scatter mean_savings day_in_study if tx_group == 3 & Commit_group == 1, color(eltblue) sort c(l) msymbol(square) ) ///
			(scatter mean_savings day_in_study if tx_group == 3 & Commit_group == 0, color(forest_green) sort c(l) msymbol(circle) ), ///
			xtitle("Day in Study") ytitle("Total savings") title("Interaction of Sobriety Incentives and Commitment Savings") ///
			legend( ///
			label(1 "Incentives, commit save") label(2 "Incentives, no commit save") ///
			label(3 "Choice, commit save") label(4 "Choice, no commit save") ///
			label(5 "Control, commit save") label(6 "Control, no commit save") rows(3)) ///
			graphregion(color(white)) bgcolor(white)
					
	graph export "$figures/4g_Savings_commit_figure_notpooled_FINAL.eps", replace 
		
restore


*********************************************************
*********************************************************
*Online Appendix Figure A.10 lower panel:
*Interaction of Sobriety Incentives and Matching Contribution
*(not pooled)
*********************************************************
*********************************************************

preserve

	collapse (mean) mean_savings = savings_total_postvisit (sd) sd_savings = savings_total_postvisit (sum) number, ///
	by(day_in_study tx_group High_interest_group)

	twoway	(scatter mean_savings day_in_study if tx_group == 1 & High_interest_group == 1, ///
			color(gs1) sort c(l) msymbol(triangle_hollow) )  ///
			(scatter mean_savings day_in_study if tx_group == 1 & High_interest_group == 0, color(maroon) sort c(l) msymbol(circle_hollow)) ///
			(scatter mean_savings day_in_study if tx_group == 2 & High_interest_group == 1, color(navy)	sort c(l) msymbol(plus)) ///
			(scatter mean_savings day_in_study if tx_group == 2 & High_interest_group == 0, color(gs8) sort c(l) msymbol(triangle)) ///
			(scatter mean_savings day_in_study if tx_group == 3 & High_interest_group == 1, color(eltblue) sort c(l) msymbol(square) ) ///
			(scatter mean_savings day_in_study if tx_group == 3 & High_interest_group == 0, color(forest_green) sort c(l) msymbol(circle) ), ///
			  xtitle("Day in Study") ytitle("Total savings") title("Sobriety Incentives vs. Matching Contribution") ///
			xtitle("Day in study") ytitle("Cumulative savings (Rs)") title("Interaction of Sobriety Incentives and Matching Contribution") ///
			legend(label(1 "Incentives, high match") label(2 "Incentives, low match") ///
			label(3 "Choice, high match") label(4 "Choice, low match") ///
			label(5 "Control, high match") label(6 "Control, low match") rows(3)) ///
			graphregion(color(white)) bgcolor(white)
			
	graph export "$figures/4h_Savings_match_figure_notpooled_FINAL.eps", replace 

restore


*********************************************************
*********************************************************
*Online Appendix Figure A.8: Binscatters
*********************************************************
*********************************************************

*********************************************************
*Panel (a): Overall correlation between daily savings and BAC
*********************************************************

	binscatter save_today BAC_result if tx_group == 3, ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("BAC") ytitle("Amount saved per day (Rs)") reportreg nq(25)
	graph export "$figures/4i_Save_BAC_binscatter_FINAL.eps", replace 

*********************************************************
*Panel (b): Same correlation, now controlling for fixed effects
*********************************************************

	binscatter save_today BAC_result if tx_group == 3, ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("BAC") ytitle("Amount saved per day (Rs)") absorb(pid) reportreg  nq(25)
	graph export "$figures/4j_Save_BAC_binscatter_FE_FINAL.eps", replace 

*********************************************************
*Panel (c): Comparing means of daily savings and BAC across people
*********************************************************

preserve

	collapse save_today BAC_result tx_group, by(pid)
	keep if tx_group == 3
	binscatter save_today BAC_result,  nq(25) ///
	graphregion(color(white)) bgcolor(white) ///
	xtitle("BAC") ytitle("Amount saved per day (Rs)")
	graph export "$figures/4k_Save_BAC_binscatter_cross_FINAL.eps", replace 
	
restore


*********************************************************
*Control group means
*********************************************************

*Summarize today's savings for control group and not last day of study.
sum save_today if tx_group == 3 & day_in_study < 20
local control_mean1 = r(mean)

*Summarize today's savings for control group once incentive treatments are in place.
sum save_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean2 = r(mean)

sum save_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)


*********************************************************
*********************************************************
*Table 5: The Effect of Sobriety Incentives on Savings
*********************************************************
*********************************************************

file open myfile using "$tables/4_Savings_table_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c c}"
file write myfile " \toprule "
file close myfile

*********************************************************
*Columns 1 and 2: Incentives and choice separately
*********************************************************
eststo clear

*(1) controlling for a bunch of stuff
eststo est1: regress save_today Treat_group Choice_group High_interest_group Commit_group $controls_BL $controls savings_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*(2) controlling additionally for study payments
eststo est2: regress save_today Treat_group Choice_group High_interest_group Commit_group payment $controls_BL $controls savings_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*********************************************************
*Columns 3 and 4: Pooled regressions
*********************************************************

*(3) controlling for a bunch of stuff
eststo est3: regress save_today Pooled_treat High_interest_group Commit_group savings_BL $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*(4) controlling additionally for study payments
eststo est4: regress save_today Pooled_treat High_interest_group Commit_group payment savings_BL $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*********************************************************
*Columns 5 through 7: Interaction
*********************************************************

*(5) interaction for daily savings
eststo est5: regress save_today Pooled_treat High_interest_group Commit_group Pooled_X_Commit Pooled_X_interest savings_BL $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*(6) interaction for deposits
generate deposit_today = (save_today > 0)*save_today
sum deposit_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est6: regress deposit_today Pooled_treat High_interest_group Commit_group Pooled_X_Commit Pooled_X_interest savings_BL $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*(7) interaction for withdrawals
generate withdraw_today = (save_today < 0)*save_today
sum withdraw_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

eststo est7: regress withdraw_today Pooled_treat High_interest_group Commit_group Pooled_X_Commit Pooled_X_interest savings_BL $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))


esttab using "$tables/4_Savings_table_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls $controls_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group Pooled_treat High_interest_group Commit_group savings_BL payment Pooled_X_Commit Pooled_X_interest) ///
scalars("r2 R-squared" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)", pattern(1 1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable:} & \multicolumn{5}{c}{\textbf{Amount saved at study office}} & ///
		+ & - \\ \cmidrule(lr){2-6} \cmidrule(lr){7-7} \cmidrule(lr){8-8})) 

eststo clear

cap file close _all
file open myfile using "$tables/4_Savings_table_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile


*********************************************************
*********************************************************
*Online Appendix Table A.10: The Effect of Sobriety Incentives on Savings
*Regressions with winsorized data
*********************************************************
*********************************************************

file open myfile using "$tables/4_Savings_table_winsor_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c c c c}"
file write myfile " \toprule "
file close myfile


sum save_today if tx_group == 3 & day_in_study < 20 & day_in_study > 4
local control_mean = r(mean)

*********************************************************
*Columns 1 through 3: Not controlling for study payments
*********************************************************

eststo clear

*(1): no winsorization
eststo est1: regress save_today Treat_group Choice_group High_interest_group Commit_group savings_BL $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*(2): 1% winsor (0.005 on each side)
winsor save_today, gen(save_today_w) p(0.005)
eststo est2: regress save_today_w Treat_group Choice_group High_interest_group Commit_group savings_BL $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))
drop save_today_w

*(3) 2% winsor (0.01 on each side)
winsor save_today, gen(save_today_w) p(0.01)
eststo est3: regress save_today_w Treat_group Choice_group High_interest_group Commit_group savings_BL $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))
drop save_today_w

*********************************************************
*Columns 4 through 6: Controlling for study payments
*********************************************************

*(4): no winsorization, controlling additionally for study payments
eststo est4: regress save_today Treat_group Choice_group High_interest_group Commit_group savings_BL payment $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*(5): 1% winsor (0.005 on each side), controlling additionally for study payments
winsor save_today, gen(save_today_w) p(0.005)
eststo est5: regress save_today_w Treat_group Choice_group High_interest_group Commit_group savings_BL payment $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))
drop save_today_w

*(6): 2% winsor (0.01 on each side), controlling additionally for study payments
winsor save_today, gen(save_today_w) p(0.01)
eststo est6: regress save_today_w Treat_group Choice_group High_interest_group Commit_group savings_BL payment $controls_BL $controls if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))
drop save_today_w

*********************************************************
*Columns 7 through 9: Interactions
*********************************************************

*(7): no winsorization, including interaction
eststo est7: regress save_today Treat_group Choice_group High_interest_group Commit_group Pooled_X_Commit Pooled_X_interest savings_BL $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

*(8): 1% winsor (0.005 on each side), including interaction
winsor save_today, gen(save_today_w) p(0.005)
eststo est8: regress save_today_w Treat_group Choice_group High_interest_group Commit_group Pooled_X_Commit Pooled_X_interest savings_BL $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))
drop save_today_w

*(9): 2% winsor (0.01 on each side), including interaction
winsor save_today, gen(save_today_w) p(0.01)
eststo est9: regress save_today_w Treat_group Choice_group High_interest_group Commit_group Pooled_X_Commit Pooled_X_interest savings_BL $controls $controls_BL if day_in_study > 4, r cluster(pid)
estadd scalar control_group_mean = `control_mean'
estadd local obs = string(e(N))

esttab using "$tables/4_Savings_table_winsor_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons savings_BL $controls $controls_BL) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Treat_group Choice_group High_interest_group Commit_group Pooled_X_Commit Pooled_X_interest payment) ///
scalars("r2 R-squared" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)", pattern(1 1 1 1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs( & \multicolumn{9}{c}{\textbf{Dependent variable: Amount saved at study office (Rs./day)}} \\ ///
		\cmidrule(lr){2-10} Fraction of winsorized data: & $0\%$ & $1\%$ & $2\%$ & $0\%$ & $1\%$ & $2\%$ ///
		& $0\%$ & $1\%$ & $2\%$ \\ )) 

eststo clear

cap file close _all
file open myfile using "$tables/4_Savings_table_winsor_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile


*********************************************************
*********************************************************
*Online Appendix Table A.12: Marginal propensity to save
*********************************************************
*********************************************************

file open myfile using "$tables/4_Savings_MPS_table_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile " \toprule "
file close myfile

eststo clear

eststo est1: regress save_today Pooled_treat High_interest_group Commit_group had_lottery_ystd lottery_amt_ystd if day_in_study > 4, r cluster(pid)
estadd local baseline_controls "NO"
estadd local phase1_controls "NO"
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))

eststo est2: regress save_today Pooled_treat $controls_BL High_interest_group Commit_group had_lottery_ystd lottery_amt_ystd if day_in_study > 4, r cluster(pid)
estadd local baseline_controls "NO"
estadd local phase1_controls "YES"
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))

eststo est3: regress save_today Pooled_treat $controls_BL $controls High_interest_group Commit_group had_lottery_ystd lottery_amt_ystd if day_in_study > 4, r cluster(pid)
estadd local baseline_controls "YES"
estadd local phase1_controls "YES"
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))

eststo est4: regress save_today Pooled_treat High_interest_group Commit_group had_lottery_ystd Pooled_treat_X_Lottery_amount Control_group_X_Lottery_amount if day_in_study > 4, r cluster(pid)
estadd local baseline_controls "NO"
estadd local phase1_controls "NO"
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))

eststo est5: regress save_today Pooled_treat $controls_BL High_interest_group Commit_group Pooled_treat_X_Lottery_amount had_lottery_ystd Control_group_X_Lottery_amount if day_in_study > 4, r cluster(pid)
estadd local baseline_controls "NO"
estadd local phase1_controls "YES"
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))

eststo est6: regress save_today Pooled_treat $controls_BL $controls High_interest_group Commit_group Pooled_treat_X_Lottery_amount had_lottery_ystd Control_group_X_Lottery_amount if day_in_study > 4, r cluster(pid)
estadd local baseline_controls "YES"
estadd local phase1_controls "YES"
estadd scalar control_group_mean = `control_mean2'
estadd local obs = string(e(N))

esttab using "$tables/4_Savings_MPS_table_FINAL.tex", append b(2) se(2) label noconstant booktabs ///
fragment drop(_cons $controls $controls_BL had_lottery_ystd High_interest_group Commit_group) ///
nonumbers nodepvars nomtitles nonote nostar ///
order(Pooled_treat lottery_amt_ystd Pooled_treat_X_Lottery_amount Control_group_X_Lottery_amount) ///
scalars("r2 R-squared" "baseline_controls Baseline survey controls" "phase1_controls Phase 1 controls" "control_group_mean Control group mean") ///
sfmt(2) ///
mgroups("(1)" "(2)" "(3)" "(4)" "(5)" "(6)", pattern(1 1 1 1 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span ///	
		lhs(\textbf{Dependent variable} & \multicolumn{6}{c}{\textbf{Amount saved at study office (Rs./day)}} \\ ///
		\cmidrule(lr){2-7}))

eststo clear

cap file close _all
file open myfile using "$tables/4_Savings_MPS_table_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

*DONE!

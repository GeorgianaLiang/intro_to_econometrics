
**************************************************************************************
*Balances Tables for Sobriety Incentives
**************************************************************************************

clear
set more off

**************************************************************************************
use "$analysis_datasets/Final_alcohol_main_data.dta", clear
**************************************************************************************

*Only keep if participant made it to day 4 of study
keep if day_in_study == 4

**************************************
*DEMOGRAPHICS
**************************************

#delimit;
local vars1 "
age married num_children wife_live_together wife_paid_work educ_years 
read_newspaper num_add_correct num_mult_correct distance_office 
live_Chennai_total ration_card_dum has_electricity own_tv self_ladder
";
#delimit cr;

label var age "Age"
label var distance_office "Distance of home from office (km)"
label var married "Married"
label var wife_live_together "Lives with wife in Chennai"
label var num_children "Number of children"
label var wife_paid_work "Wife earned income during past month"
label var self_ladder "Happiness ladder score (0 to 10)"
label var educ_years "Years of education"
label var read_newspaper "Able to read the newspaper"
label var ration_card_dum "Reports having ration card"
label var live_Chennai_total "Years lived in Chennai"
label var has_electricity "Has electricity"
label var own_tv "Owns TV"

foreach k of local vars1{
			tab `k', m
		}
		
**************************************
*WORK, EARNINGS, AND SAVINGS
**************************************

#delimit;
local vars2 "
work_years work_days_sum regular_employment
owns_rickshaw no_rickshaw_money earnings_BL savings_total owe_total savings_BL
";
#delimit cr;

label var work_years "Years worked as a rickshaw puller"
label var work_days_sum "Number of days worked last week"
label var earnings_BL "Reported labor income in Phase 1 (Rs./day)"
label var regular_employment "Has regular employment arrangement"
label var owns_rickshaw "Owns rickshaw"
label var no_rickshaw_money "Says 'no money' reason for not owning rickshaw"
label var savings_total "Total savings (Rs.)"
label var owe_total "Total borrowings (Rs.)"
label var savings_BL "Savings at study office in Phase 1 (Rs./day)"

**************************************
*ALCOHOL CONSUMPTION
**************************************

#delimit;
local vars3 "
drink_duration Rs_alcohol_BL Std_drinks_overall_BL
Std_drinks_today_BL frac_sober_BL total_AUDIT_score drink_alone_dummy 
life_better_TASMAC_close favor_prohibition increase_price
";
#delimit cr;

label var frac_sober_BL "Baseline fraction sober"
label var Std_drinks_today_BL "\# of standard drinks during day in Phase 1"
label var Std_drinks_overall_BL "\# of standard drinks per day in Phase 1"
label var drink_duration "Years drinking alcohol"
label var Rs_alcohol_BL "Alcohol expenditures in Phase 1 (Rs./day)"
label var drink_alone_dummy "Drinks usually alone"
label var total_AUDIT_score "Alcohol Use Disorders Identification Test score"
label var life_better_TASMAC_close "Reports life would be better if liquor stores closed"


**************************************************************************************
* Online Appendix Tables A.2 through A.4
* Balance Table for Sobriety Incentive Group
*************************************************************************************

*Count number of variables in total
	local all_vars "`vars1' `vars2' `vars3'"
	
	forvalues m = 1(1)3{
		local K_`m' 0
	
		foreach k of local vars`m'{
			local K_`m' = `K_`m'' + 1
		}
	}
	
	local K 0
	
		foreach k of local all_vars{
			local K = `K' + 1
		}
		
label define treat 1 "Incentives" 2 "Choice" 3 "Control"
label var tx_group treat

count if tx_group == 1
local N_1 = r(N)

count if tx_group == 2
local N_2 = r(N)

count if tx_group == 3
local N_3 = r(N)

*Generate pooled treatment variable
gen Pooled_alc_treat = Treat_group + Choice_group


cap file close _all
file open myfile using "$tables/1a_Balance_table1_FINAL.tex", write replace
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile "\toprule"
file write myfile " & \multicolumn{3}{c}{\textbf{Treatment groups}} & \multicolumn{3}{c}{\textbf{p value for test of:}} \\"
file write myfile "\cmidrule(r){2-4} \cmidrule(r){5-7}"
file write myfile " & Control & Incentives & Choice & 1=2 & 1=3 & $1=(2\cup3)$ \\ "
file write myfile " & (N=`N_3') & (N=`N_1') & (N=`N_2') &  &  & \\   "
file write myfile " & (1) & (2) & (3) & (4) & (5) & (6) \\ \midrule "
file close myfile

cap file close _all
file open myfile using "$tables/1b_Balance_table2_FINAL.tex", write replace 
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile "\toprule"
file write myfile " & \multicolumn{3}{c}{\textbf{Treatment groups}} & \multicolumn{3}{c}{\textbf{p value for test of:}} \\"
file write myfile "\cmidrule(r){2-4} \cmidrule(r){5-7}"
file write myfile " & Control & Incentives & Choice & 1=2 & 1=3 & $1 = (2 \cup 3)$ \\ "
file write myfile " & (N=`N_3') & (N=`N_1') & (N=`N_2') &  &  & \\   "
file write myfile " & (1) & (2) & (3) & (4) & (5) & (6) \\ \midrule "
file close myfile

cap file close _all
file open myfile using "$tables/1c_Balance_table3_FINAL.tex", write replace 
file write myfile "\begin{tabular}{l c c c c c c}"
file write myfile "\toprule"
file write myfile " & \multicolumn{3}{c}{\textbf{Treatment groups}} & \multicolumn{3}{c}{\textbf{p value for test of:}} \\"
file write myfile "\cmidrule(r){2-4} \cmidrule(r){5-7}"
file write myfile " & Control & Incentives & Choice & 1=2 & 1=3 & $1 = (2 \cup 3)$ \\ "
file write myfile " & (N=`N_3') & (N=`N_1') & (N=`N_2') &  &  & \\   "
file write myfile " & (1) & (2) & (3) & (4) & (5) & (6) \\ \midrule "

file close myfile


for var `vars1' `vars2' `vars3' \ num 1/`K': global depvarY = "X"

local i 1

while `i' <= `K' {

	*Get means and standard deviations 
	forvalues j = 1(1)3{
	
	sum ${depvar`i'} if tx_group == `j'
	
	scalar mean_`j' = r(mean)
	scalar std_`j' = r(sd)

	}
		
	*Regression for p-values
	reg ${depvar`i'} Choice_group Treat_group Control_group, nocons r
	
	*Incentives vs Control
	test Treat_group = Control_group
	scalar p_1 = r(p)
		
	*Choice vs Control
	test Choice_group = Control_group
	scalar p_2 = r(p)
	
	*Joint treat vs control
	
	*Regression for p-values
	reg ${depvar`i'} Pooled_alc_treat Control_group, nocons r

	*Choice vs Control
	test Pooled_alc = Control_group
	scalar p_3 = r(p)
	
	cap file close _all
	
	local z = 2
	
	if `i' <= `K_1' + `K_2' - 1 & `i' > `K_1' + `K_2' - 3 {
	
		local z = 0
	
	}
	
	if `i' <= `K_1'{

	file open myfile using "$tables/1a_Balance_table1_FINAL.tex", write append

	}
	
	if `i' > `K_1' & `i' <= `K_1' + `K_2'{

	file open myfile using "$tables/1c_Balance_table3_FINAL.tex", write append
	}

	if `i' > `K_1' + `K_2'{

	file open myfile using "$tables/1b_Balance_table2_FINAL.tex", write append
	}
	
	*Write means
	file write myfile "`: var label ${depvar`i'}'" "&" %7.`z'f (mean_3) "&" %7.`z'f (mean_1) "&" %7.`z'f (mean_2) "&" ///
	%7.2f (p_1) "&"   %7.2f (p_2)  "&"  %7.2f (p_3) "\\"
	
	*Write standard deviations
	file write myfile "& (\!\!" %7.`z'f (std_3) ") & (\!\!"% 7.`z'f (std_1) ") & (\!\!" %7.`z'f (std_2) ") &&& \\ "
	file close myfile
	
	local i = `i' + 1

	}

cap file close _all
file open myfile using "$tables/1a_Balance_table1_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

cap file close _all
file open myfile using "$tables/1b_Balance_table2_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

capture file close myfile
file open myfile using "$tables/1c_Balance_table3_FINAL.tex", write append
file write myfile "\bottomrule"
file write myfile " \end{tabular} "
file close myfile

capture file close myfile

**************************************************************************************
* Online Appendix Figure A.3
* Reported Total Savings by Incentive Treatment Group at Baseline
**************************************************************************************


label var tx_group "Treatment group"

hist savings_total, by(tx_group, col(1) graphregion(color(white)) bgcolor(white)) bin(30) fraction  ///
subtitle(,fcolor(white) lcolor(white)) color(navy) ///
ysc(r(0 1))  ymtick(0(0.2)1) ylabel(0(0.2)1)

graph export "$figures/1a_Balance_savings1_FINAL.eps", replace 

hist savings_total if savings_total < 200000, by(tx_group, col(1) graphregion(color(white)) bgcolor(white)) bin(30) fraction  ///
subtitle(,fcolor(white) lcolor(white)) color(navy) ///
ysc(r(0 1))  ymtick(0(0.2)1) ylabel(0(0.2)1)

graph export "$figures/1b_Balance_savings2_FINAL.eps", replace 

*DONE!

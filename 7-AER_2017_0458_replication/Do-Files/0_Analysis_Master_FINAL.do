
***********************************************************************************
*This file is the master do-file that runs all do-files that create the tables
*and figures of the paper "Alcohol and Self-Control: A Field Experiment in India",
*including the online appendix
***********************************************************************************

clear
set more off, perm

*Set main data path:
cd "~/Dropbox (MIT)/1.Research/Alcohol Project/Replication"
						
* Specify subfolders

	*Input data files
	global analysis_datasets		    "Data Files"

	*Output files	
	global figures		 				"Output/Figures"
	global tables		 				"Output/Tables"

	*Do-files
	global analysis_do_files			"Do Files"	


*Use main dataset
**************************************************************************************
use "$analysis_datasets/Final_alcohol_main_data.dta", clear
**************************************************************************************

	
******************************
*Three sets of control variables:
******************************

**************************************
*(1) DEMOGRAPHICS
**************************************

#delimit;
global vars1 "
age distance_office num_children married wife_live_together wife_paid_work
self_ladder educ_years read_newspaper num_add_correct num_mult_correct 
ration_card_dum live_Chennai_total has_electricity own_tv
";
#delimit cr;

local vars1 $vars1

**************************************
*(2) WORK, EARNINGS, AND SAVINGS
**************************************

#delimit;
global vars2 "
work_years owns_rickshaw no_rickshaw_money regular_employment
work_days_sum savings_total owe_total 
";
#delimit cr;

local vars2 $vars2

**************************************
*(3) ALCOHOL CONSUMPTION
**************************************

#delimit;
global vars3 "
drink_alone_dummy drink_duration total_AUDIT_score 
life_better_TASMAC_close favor_prohibition increase_price
";
#delimit cr;

local vars3 $vars3

********************************************************
*Pull together all control vars
********************************************************

global controls "$vars1 $vars2 $vars3"
local controls $controls

global controls_BL "frac_sober_BL Std_drinks_today_BL Std_drinks_overall_BL mean_BAC_BL earnings_BL Rs_alcohol_BL savings_BL"
local controls_BL $controls_BL

	
**************************************************************************************************************
*Run analysis do files
**************************************************************************************************************

	do "$analysis_do_files/1_Analysis_Balance_FINAL.do"
	do "$analysis_do_files/2_Analysis_Attendance_FINAL.do"
	do "$analysis_do_files/3_Analysis_Drinking_FINAL.do"
	do "$analysis_do_files/4_Analysis_Savings_FINAL.do"
	do "$analysis_do_files/5_Analysis_Work_FINAL.do"
	do "$analysis_do_files/6_Analysis_Choices_FINAL.do"
	do "$analysis_do_files/7_Analysis_Other_Expenses_FINAL.do"
	do "$analysis_do_files/8_Analysis_Recruiting_FINAL.do"
	do "$analysis_do_files/9_Analysis_Prevalence_FINAL.do"
	
*DONE!

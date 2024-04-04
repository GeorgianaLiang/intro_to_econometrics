
**************************************************************************************
*Analysis of Prevalence of Drinking
**************************************************************************************

clear
set more off
						
**************************************************************************************
use "$analysis_datasets/Final_prevalence_data.dta", clear 
**************************************************************************************


*********************************************************
*********************************************************
*(1) Prevalence of drinking
* Online Appendix Figure A.1 upper panel
*********************************************************
*********************************************************

preserve
		
	# d ;
	collapse (mean) frac_drink_yest = P_p15_drinkyest 
		     (mean) exp_drink       = P_p12_avgdrink 
			 (sd)   sd_drink_yest   = P_p15_drinkyest 
		     (count) n              = count_var, by(P_p05_ptprof);
	
	* Generate 95% confidence intervals;
	gen hiratio  = frac_drink_yest + invttail(n-1,0.025)*(sd_drink_yest / sqrt(n));
	gen lowratio = frac_drink_yest - invttail(n-1,0.025)*(sd_drink_yest / sqrt(n));
	
	sort frac_drink_yest;
	gen obs = _n if frac_drink_yest != .;
	label define profession_label2 1 "Porters" 
								   2 "Construction workers"
								   3 "Autorickshaw drivers" 
								   4 "Loadmen"  
								   5 "Shopkeepers" 
								   6 "Fishermen" 
								   7 "Fruit/vegetable vendors" 
								   8 "Rickshaw peddlers" 
								   9 "Rag pickers" 
								   10 "Sewage workers";
	label values obs profession_label2;
	
	twoway (bar frac_drink_yest obs if obs <= 10, barwidth(.7))
		   (rcap hiratio lowratio obs, color(orange)),
		   legend(off)
		   xlabel(1 " Porters"
		  		  2 " Construction workers"
		   		  3 " Autorickshaw drivers"
		   		  4 " Loadmen"
				  5 " Shopkeepers"
			   	  6 " Fishermen"
				  7 " Fruit/vegetable vendors" 
		   		  8 " Rickshaw peddlers"
				  9 " Rag pickers"
		   		  10 "Sewage workers", angle(-65) labsize(small) notick)
		   ylabel(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%", labs(vsmall))
		   xtitle("")
		   xsize(6)
		   graphregion(color(white)) bgcolor(white) 
		   title("Fraction Reporting Drinking Alcohol on Previous Day", size(medium));
		
	# d cr
	graph export "$figures/9a_Prevalence_drinking_ystd_FINAL.eps", replace

restore


*********************************************************
*********************************************************
*(2) Physical lcquantities consumed per day (conditional on drinking yesterday)
* Online Appendix Figure A.1 lower panel
*********************************************************
*********************************************************
	
preserve

	*Generate variable for number of drinks consumed yesterday
	egen drinks_per_day = rowtotal(P_p16bt_toddyyest P_p16lb_lbeersyest P_p16pa_arrackyest P_p16qtr_qtrsyest P_p16sb_sbeersyest)
	
	*Use only people who drank yesterday (want the conditional amount)
	replace drinks_per_day = . if drinks_per_day == 0 
		
	# d ;
	collapse (mean) frac_drink_yest       = P_p15_drinkyest 
			 (mean) exp_drink             = P_p12_avgdrink 
			 (mean) mean_drinks_per_day   = drinks_per_day
			 (sd)   sd_drinks_per_day     = drinks_per_day
			 (count) n                    = count_var, by(P_p05_ptprof);

	* Generate 95% confidence intervals;		 
	gen hiratio  = mean_drinks_per_day + invttail(n-1,0.025)*(sd_drinks_per_day / sqrt(n));
	gen lowratio = mean_drinks_per_day - invttail(n-1,0.025)*(sd_drinks_per_day / sqrt(n));
	
	* Order same as above;
	sort frac_drink_yest;
	generate obs = _n if frac_drink_yest != .;
	# d ;
	label define profession_label2 1 "Porters" 
								   2 "Construction workers"
								   3 "Autorickshaw drivers" 
								   4 "Loadmen"  
								   5 "Shopkeepers" 
								   6 "Fishermen" 
								   7 "Fruit/vegetable vendors" 
								   8 "Rickshaw peddlers" 
								   9 "Rag pickers" 
								   10 "Sewage workers";
	label values obs profession_label2;

	*Create graph;
	twoway (bar mean_drinks_per_day obs if obs <= 10, barwidth(.7)) 
		   (rcap hiratio lowratio obs, color(orange))
		   ,
		   legend(off)
		   xlabel(1 " Porters"
		   		  2 " Construction workers"
			   	  3 " Autorickshaw drivers"
			   	  4 " Loadmen"
			   	  5 " Shopkeepers"
				  6 " Fishermen"
				  7 " Fruit/vegetable vendors" 
				  8 " Rickshaw peddlers"
			   	  9 " Rag pickers"
			   	  10 "Sewage workers", angle(-65) labsize(small) notick)
			ylabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" , labs(small))
			xtitle("")
			xsize(6)
		    graphregion(color(white)) bgcolor(white) 
			title("Number of Standard Drinks Consumed on Previous Day (Conditional on Drinking)", size(medium));
			# d cr
			   
	graph export "$figures/9b_Prevalence_qty_consumed_ystd_FINAL.eps", replace
			
restore


*********************************************************
*********************************************************
*(3) Shares of income spent on alcohol
* Online Appendix Figure A.2 upper panel
*********************************************************
*********************************************************

preserve
		
	*Create some of the vars used below
	tab P_p08_paid7, m
	replace P_p08_paid7_days = 0 if P_p08_paid7 == "0"
	generate earn_wk = P_p08_paid7_days * P_p09_avgearn
	count if earn_wk != earn_wk

	tab P_p11_dayswkdrink, m
	replace P_p11_dayswkdrink_days = 0 if P_p11_dayswkdrink == "0"
	generate drink_wk = P_p11_dayswkdrink_days * P_p12_avgdrink
	replace drink_wk = 0 if P_p11_dayswkdrink_days == 0

	generate alc_ratio = drink_wk/earn_wk
	replace alc_ratio = 0 if drink_wk == 0

	*alc_ratio 
		
	# d ;
	collapse (mean) frac_drink_yest = P_p15_drinkyest 
			 (mean) exp_drink       = P_p12_avgdrink 
			 (mean) mean_alc_ratio  = alc_ratio
			 (sd)   sd_alc_ratio    = alc_ratio
			 (count) n = count_var, by(P_p05_ptprof);

	* Generate 95% confidence intervals;		 
	gen hiratio  = mean_alc_ratio + invttail(n-1,0.025)*(sd_alc_ratio / sqrt(n));
	gen lowratio = mean_alc_ratio - invttail(n-1,0.025)*(sd_alc_ratio / sqrt(n));
	
	* Order same as above;
	sort frac_drink_yest;
	generate obs = _n if frac_drink_yest != .;
	# d ;
	label define profession_label2 1 "Porters" 
								   2 "Construction workers"
								   3 "Autorickshaw drivers" 
								   4 "Loadmen"  
								   5 "Shopkeepers" 
								   6 "Fishermen" 
								   7 "Fruit/vegetable vendors" 
								   8 "Rickshaw peddlers" 
								   9 "Rag pickers" 
								   10 "Sewage workers";
	label values obs profession_label2;
	*Create graph;
	twoway (bar mean_alc_ratio obs if obs <= 10, barwidth(.7))
		   (rcap hiratio lowratio obs, color(orange))
		   ,
	       legend(off)
		   xlabel(1 " Porters"
		   		  2 " Construction workers"
				  3 " Autorickshaw drivers"
		   		  4 " Loadmen"
		   		  5 " Shopkeepers"
				  6 " Fishermen"
		   		  7 " Fruit/vegetable vendors" 
		   		  8 " Rickshaw peddlers"
		  		  9 " Rag pickers"
		   		  10 "Sewage workers", angle(-65) labsize(small) notick)
		  ylabel(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%", labs(small))
    	  xtitle("")
		  xsize(6)
		  graphregion(color(white)) bgcolor(white) 
		  title("Fraction of Weekly Income Spent on Alcohol", size(medium));
		   # d cr
			    
		graph export "$figures/9c_Prevalence_income_drinking_FINAL.eps", replace
	
restore


*********************************************************
*********************************************************
*(4) Fraction inebriated during the day
* Online Appendix Figure A.2 lower panel
*********************************************************
*********************************************************

preserve

	generate drunk_dummy_check = (P_p25c_btestscore1 > 0)
	count if drunk_dummy == drunk_dummy_check
	
	# d ;
	collapse (mean) frac_drink_yest       = P_p15_drinkyest 
		     (mean) exp_drink             = P_p12_avgdrink 
			 (mean) mean_drunk_dummy      = drunk_dummy
			 (sd)   sd_drunk_dummy     = drunk_dummy
			 (count) n                    = count_var, by(P_p05_ptprof);
	
	* Generate 95% confidence intervals;		 
	gen hiratio  = mean_drunk_dummy + invttail(n-1,0.025)*(sd_drunk_dummy / sqrt(n));
	gen lowratio = mean_drunk_dummy - invttail(n-1,0.025)*(sd_drunk_dummy / sqrt(n));
			 
	* Order same as above;
	sort frac_drink_yest;
	generate obs = _n if frac_drink_yest != .;
	# d ;
	label define profession_label2 1 "Porters" 
								   2 "Construction workers"
								   3 "Autorickshaw drivers" 
								   4 "Loadmen"  
								   5 "Shopkeepers" 
								   6 "Fishermen" 
								   7 "Fruit/vegetable vendors" 
								   8 "Rickshaw peddlers" 
								   9 "Rag pickers" 
								   10 "Sewage workers";
	
	label values obs profession_label2;
	
	*Create graph;
	twoway 	(bar mean_drunk_dummy obs if obs <= 10,  barwidth(.7))
			(rcap hiratio lowratio obs, color(orange))
	 	   ,
		    legend(off)
			xlabel(1 " Porters"
				   2 " Construction workers"
		     	   3 " Autorickshaw drivers"
			   	   4 " Loadmen"
				   5 " Shopkeepers"
		   		   6 " Fishermen"
		   		   7 " Fruit/vegetable vendors" 
		   		   8 " Rickshaw peddlers"
		  		   9 " Rag pickers"
		  		   10 "Sewage workers", angle(-65) labsize(small) notick)
			ylabel(0 "0%".1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%", labs(small))
			ytitle("")
			xtitle("")
		    graphregion(color(white)) bgcolor(white) 
			xsize(6)
			title("Fraction with Positive Breathalyzer Score during Survey", size(medium));
			# d cr

		graph export "$figures/9d_Prevalence_breathalyzer_FINAL.eps", replace
			
restore

*DONE

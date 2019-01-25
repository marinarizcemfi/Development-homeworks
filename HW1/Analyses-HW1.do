**** Analises

***				Marina Rizzi
***				20 January 2019


*** In order to produce the final dataset used for the analyses, plese refer to 
*** the following do file:

**	do "Preparation Dataset-HW1.do"

clear
global path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/Data/UGA_2013_UNPS_v01_M_STATA8"
global dofiles_path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/HW1"
global figure_path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/Figures"

cd "$path"
use CIWdata_Uganda2013.dta, clear
cd "$figure_path"


************** STARTING POINT, of the ANALYSES
*** N.B.: I will do the analyses on the logs variables

** 1) Report average CIW per household separately for rural and urban areas.

*** TABLES for average CIW, divided by RURAL and URBAN
*** Table all together:
estpost tabstat consumpt income_tot wealth_tot, by(urban) listwise statistics(mean) columns(statistics)
esttab using "$figure_path/CIW_urbrur.tex", cells("mean(fmt(a3))") replace


*** Single Tables
*** CONSUMTPION 

*table urban, c(mean consumpt) 
*tabstat consumpt, by (urban)
*** To save it, directly in a table:
*estpost tabstat consumpt, by(urban) listwise statistics(mean) columns(statistics)
*esttab using "$figure_path/consumpt_urbrur.tex", cells("mean(fmt(a3))") replace
*esttab using consum_rururb.rtf, cells("mean(fmt(a3))") replace

*** WEALTH 
*tabstat wealth_tot, by (urban)
*estpost tabstat wealth_tot, by(urban) listwise statistics(mean) columns(statistics)
*esttab using "$figure_path/wealth_urbrur.tex", cells("mean(fmt(a3))") replace

**** CIW All together:
*tabstat consumpt income_tot wealth_tot, by(urban)


*** 2.1)  CIW Inequality.  (CONSUMPTION, INCOME AND WEALTH)

***  	  Histogram for CIW for rural and urban areas

*** Divided, Urban and Rural
*** i) Two graphs, in different images 
*** (I save each of them separately)
histogram consumpt_log,fcolor(ebblue) lcolor(black) density by(urban,note("") col(1)) legend(off)  //saving(cons_byurb, replace) 
graph export cons_byurb_divided.png, replace

histogram income_log, fcolor(sandb) lcolor(black) density by(urban,note("") col(1)) //saving(income_byurb, replace)
graph export income_byurb_divided.png, replace
 
histogram wealth_tot_log, fcolor(cranberry) lcolor(black) density by(urban,note("") col(1))   //saving(wealth_byurb, replace)
graph export wealth_byurb_divided.png, replace
 

*** Combining the graphs:
histogram consumpt_log,fcolor(ebblue) lcolor(black) density by(urban,note("") col(2)) legend(off)  saving(cons_byurb, replace) 
histogram income_log, fcolor(sandb) lcolor(black) density by(urban,note("") col(2)) saving(income_byurb, replace)
histogram wealth_tot_log, fcolor(cranberry) lcolor(black) density by(urban,note("") col(2))   saving(wealth_byurb, replace)
gr combine cons_byurb.gph income_byurb.gph wealth_byurb.gph, col(1)
graph export CIW_byurb_divided.png, replace
erase cons_byurb.gph
erase income_byurb.gph
erase wealth_byurb.gph

*** OVERLAID GRAPHS

*** ii) Two graphs overlaid:
twoway (histogram consumpt_log if urban==1, bin(50) fcolor(ltkhaki) lcolor(none)) (histogram consumpt_log if urban==0, bin(50) fcolor(none) lcolor(blue)), legend(order(1 "Urban" 2 "Rural")) saving(consumpt_overlaid, replace)
*graph export consump_urbrur_overlaid.png, replace
twoway (histogram wealth_tot_log if urban==1, bin(50) fcolor(ltkhaki) lcolor(none)) (histogram wealth_tot_log if urban==0, bin(50) fcolor(none) lcolor(blue)), legend(order(1 "Urban" 2 "Rural")) saving(wealth_overlaid, replace)
*graph export wealth_urbrur_overlaid.png, replace 
twoway (histogram income_log if urban==1, bin(50) fcolor(ltkhaki) lcolor(none)) (histogram income_log if urban==0, bin(50) fcolor(none) lcolor(blue)), legend(order(1 "Urban" 2 "Rural")) saving(income_overlaid, replace)
*graph export income_urbrur_overlaid.png, replace 
gr combine consumpt_overlaid.gph income_overlaid.gph wealth_overlaid.gph
graph export CIW_byurb_overlaid.png, replace
erase consumpt_overlaid.gph
erase income_overlaid.gph
erase wealth_overlaid.gph


**** WEALTH
**   Histogram rural and urban areas
*graph export wealth_urbrur_separated.png, replace 

*** INCOME
**   Histogram rural and urban areas
*graph export income_urbrur_separated.png, replace 



*** 2.2) Calculate (and show) Variance of Logs of CIW (divided for URBAN and RURAL parts):

estpost tabstat consumpt_log income_log wealth_tot_log, by(urban) statistics(variance) columns(statistics) listwise 
esttab using "$figure_path/CIW_var.tex", cells("variance(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels(none) label booktabs replace

*tabstat consumpt_log income_log wealth_tot_log, by(urban) stat(variance)

*** 3) Describe the joint cross-sectional behavior of CIW

estpost correlate consumpt_log income_log wealth_tot_log, matrix listwise
esttab using "$figure_path/CIW_corr.tex",  unstack not noobs compress nostar nonumber nonote nomtitle label booktabs replace
*corr consumpt_log income_log wealth_tot_log

*** 4) Describe the CIW level, inequality, and covariances over the lifecycle.

***** CIW, means
cd "$figure_path"
use "$path/CIWdata_Uganda2013.dta", clear
collapse (mean) consumpt (mean) consumpt_log (firstnm) urban, by(age)
drop if (age<18 | age>80)
twoway (line consumpt_log age, ylabel(, angle(0)) xtitle("Age in years") saving(cons_mean_lifecy, replace))

use "$path/CIWdata_Uganda2013.dta", clear
collapse (mean) income_log, by(age)
drop if (age<18 | age>80)
twoway (line income_log age,  ylabel(, angle(0)) xtitle("Age in years") saving(income_mean_lifecy, replace))

use "$path/CIWdata_Uganda2013.dta", clear
collapse (mean) wealth_tot_log, by(age)
drop if (age<18 | age>80)
twoway (line wealth_tot_log age, ylabel(, angle(0)) xtitle("Age in years") saving(wealth_mean_lifecy, replace))

gr combine cons_mean_lifecy.gph income_mean_lifecy.gph wealth_mean_lifecy.gph, col(1)
graph export "$figure_path/CIW_mean_lifecycle.png", replace
erase cons_mean_lifecy.gph
erase income_mean_lifecy.gph
erase wealth_mean_lifecy.gph




***** CIW, variances
**** CONSUMPTION

use "$path/CIWdata_Uganda2013.dta", clear
collapse (sd) consumpt_log, by(age)
drop if (age<18 | age>80)
twoway (line consumpt_log age, ylabel(, angle(0)) xtitle("Age in years") saving(cons_var_lifecy, replace))

**** INCOME

use "$path/CIWdata_Uganda2013.dta", clear
collapse (sd) income_log, by(age)
drop if (age<18 | age>80)
twoway (line income_log age,  ylabel(, angle(0)) xtitle("Age in years") saving(income_var_lifecy, replace))

**** WEALTH

use "$path/CIWdata_Uganda2013.dta", clear
collapse (sd) wealth_tot_log, by(age)
drop if (age<18 | age>80)
twoway (line wealth_tot_log age,  ylabel(, angle(0)) xtitle("Age in years") saving(wealth_var_lifecy, replace))

gr combine cons_var_lifecy.gph income_var_lifecy.gph wealth_var_lifecy.gph, col(1)
graph export "$figure_path/CIW_vars_lifecycle.png", replace
erase cons_var_lifecy.gph
erase income_var_lifecy.gph
erase wealth_var_lifecy.gph

*** For a table of the variances, we have:

tabstat consumpt income_tot wealth_tot, by(age) statistic(variance)


**** CORRELATIONS
use "$path/CIWdata_Uganda2013.dta", clear
*bys age: corr consumpt income_tot wealth_tot


**** Install egen_more
***  use a command, that is inside "egen_more"...
*	 ssc install egenmore

*bys age: egen corr_consump_inc_byage=corr(consumpt income_tot)
***  ??? Let's ask moooooreeee :D:D:D;P;P;P

*egen corr_consump_inc_byage=corr(consumpt income_tot), by(age) 
*corr(wealth_tot income_tot), by(age) 
*corr(wealth_tot consumpt), by(age) 

*use CIWdata_Uganda2013.dta, clear

**** 5. Rank your households by income, and dicuss the behavior of the top and bottom 
***  of the consumption and wealth distributions conditional on income.

use "$path/CIWdata_Uganda2013.dta", clear

*pctile quintiles_inc = income_tot, nq(5)


*_pctile income_tot, p(1 10 50 90 99) 
*ret li 

*gen bin = 1 if !missing(income_tot) 
*quietly forval j = 1/5 { 
*    replace bin = bin + 1  if age > r(r`j') 
*} 

*tab bin 
*scatter bin income_tot 
*tabstat consumpt, by(bin) s(n mean sd)


*********** QUESTION 2 ***************
***. Question 2. Inequality in Labor Supply
***1. Redo Question 1 for intensive and extensive margins of labor supply.

*** INTENSIVE Margin: How much you work. EXTENSIVE Margin: Whether you work.
*** int_labour.  vs ext_labour

* 1) Report average labour supply per household separately for rural and urban areas.
use "$path/CIWdata_Uganda2013.dta", clear

estpost tabstat int_labour ext_labour, by(urban) listwise statistics(mean) columns(statistics)
esttab using "$figure_path/laboursupply_byurb.tex", cells("mean(fmt(a3))") replace

* 2) Labour supply inequality: (1) Show histogram for labour supply separately for rural 
*    and urban areas; (2) Report the variance of logs for labour supply, separately for rural and urban areas.

*** Intensive Labour Supply
cd "$figure_path
histogram int_labour,fcolor(ebblue) lcolor(black) density by(urban,note("") col(1)) xtitle("Intensive Labour Supply (hours worked per household)") saving(inlabour_byurb, replace) 
twoway (histogram int_labour if urban==1, bin(50) fcolor(ltkhaki) lcolor(none)) (histogram int_labour if urban==0, bin(50) fcolor(none) lcolor(blue)), legend(order(1 "Urban" 2 "Rural")) xtitle("Intensive Labour Supply (hours worked per household)") saving(inlabour_overl, replace)
*twoway (histogram ext_labour if urban==1, bin(50) fcolor(ltkhaki) lcolor(none)) (histogram ext_labour if urban==0, bin(50) fcolor(none) lcolor(blue)), legend(order(1 "Urban" 2 "Rural"))
gr combine inlabour_byurb.gph inlabour_overl.gph, col(1)
gr export "$figure_path/intensive_labour_byurb.png", replace

erase inlabour_byurb.gph 
erase inlabour_overl.gph


*** Extensive Labour Supply:
*** To do a better graph, I also calculate the following measure:
gen no_working=1-ext_labour

cd "$figure_path

graph bar ext_labour no_working, over(urban) stack  ylabel(, angle(0)) 
gr export "$figure_path/extlabour_byurb.png", replace


gen log_intlabour=log(int_labour)
**** 2.2) Report the variance of logs for labour supply, separately for rural and urban areas.
estpost tabstat log_intlabour, by(urban) listwise statistics(variance) columns(statistics)
esttab using "$figure_path/intlabour_var.tex", cells("variance(fmt(a3))") replace

*tabstat int_labour ext_labour, by(urban) stat(variance)

* 3) Describe the joint cross-sectional behavior of CIW
corr int_labour consumpt income_tot wealth_tot
corr ext_labour consumpt income_tot wealth_tot

*estpost corr int_labour consumpt_log income_tot wealth_tot_log, matrix listwise
*esttab using "$figure_path/intlabour_corr.tex", replace



* 4) Describe the CIW level, inequality, and covariances over the lifecycle.


*** Levels
use "$path/CIWdata_Uganda2013.dta", clear
collapse (mean) int_labour, by(age)
drop if (age<18 | age>80)
twoway (line int_labour age, ylabel(, angle(0)) xtitle("Age in years") title("Intensive Labour Supply") saving(intlabour_mean_lifecy, replace))

use "$path/CIWdata_Uganda2013.dta", clear
collapse (mean) ext_labour, by(age)
drop if (age<18 | age>80)
twoway (line ext_labour age, ylabel(, angle(0)) xtitle("Age in years") title("Extensive Labour Supply") saving(extlabour_mean_lifecy, replace))

gr combine intlabour_mean_lifecy.gph extlabour_mean_lifecy.gph, col(1)
gr export "$figure_path/intextlabour_mean_lifecycle.png", replace



*** Variances
use "$path/CIWdata_Uganda2013.dta", clear
collapse (sd) int_labour, by(age)
drop if (age<18 | age>80)
twoway (line int_labour age, ylabel(, angle(0)) xtitle("Age in years") title("Intensive Labour Supply") saving(intlabour_var_lifecy, replace))

use "$path/CIWdata_Uganda2013.dta", clear
collapse (sd) ext_labour, by(age)
drop if (age<18 | age>80)
twoway (line ext_labour age, ylabel(, angle(0)) xtitle("Age in years") title("Extensive Labour Supply") saving(extlabour_var_lifecy, replace))

gr combine intlabour_var_lifecy.gph extlabour_var_lifecy.gph, col(1)
gr export "$figure_path/intextlabour_var_lifecycle.png", replace




***** 2] QUESTION 2, FOR Women and Men
**** 2) Redo separately for women and men [and by education groups (less than primary school completed, primary school completed, and secondary school completed or higher).]

*tab urban sex, sum(consumpt) means
** Same table as: "table urban sex, c(mean consumpt)" 
** [But, with tab.... You can do estpost.......:D;P;P;P;P]

***** 1. average CIW per household separately for rural and urban areas.
**** CIW, all together:
use "$path/CIWdata_Uganda2013.dta", clear
estpost tabstat consumpt income_tot wealth_tot if sex==1, by(urban) listwise statistics(mean) columns(statistics)
esttab using "$figure_path/CIW_male.tex", cells("mean(fmt(a3))") replace

estpost tabstat consumpt income_tot wealth_tot if sex==2, by(urban) listwise statistics(mean) columns(statistics)
esttab using "$figure_path/CIW_female.tex", cells("mean(fmt(a3))") replace


*****************

**** 2.1. Show histogram for CIW separately for rural and urban areas
*** CONSUMPTION (I do it, in logs)

*histogram consumpt if sex==1, by(urban) title(Male consumption) fcolor(eltblue) lcolor(black) ///
*			xscale(range(0 6000000)) ylabel(, angle(0)) saving(consumpt_male, replace)
*histogram consumpt if sex==2, by(urban) title(Female consumption) fcolor(cranberry) lcolor(black) ///
*			xscale(range(0 6000000)) ylabel(, angle(0)) saving(consumpt_female, replace)
histogram consumpt_log if sex==1, by(urban) title(Male consumption) fcolor(eltblue) lcolor(black) ///
			xscale(range(8 15)) yscale(range(0 0.8)) ylabel(, angle(0)) saving(consumpt_male, replace)
histogram consumpt_log if sex==2, by(urban) title(Female consumption) fcolor(cranberry) lcolor(black) ///
			xscale(range(8 15)) ylabel(, angle(0)) saving(consumpt_female, replace)
gr combine consumpt_male.gph consumpt_female.gph, col(1) //iscale(1)
graph export cons_bysex.png, replace
erase consumpt_male.gph 
erase consumpt_female.gph

****  INCOME
histogram income_log if sex==1, by(urban) title(Male Income) fcolor(eltblue) lcolor(black) xscale(range(5 25)) ///
			ylabel(, angle(0)) saving(income_male, replace)
histogram income_log if sex==2, by(urban) title(Female income) fcolor(cranberry) lcolor(black) xscale(range(5 25)) ///
			ylabel(, angle(0)) saving(income_female, replace)
gr combine income_male.gph income_female.gph, col(1) //iscale(1)
graph export "$figure_path/income_bysex.png", replace
erase income_male.gph 
erase income_female.gph


**** WEALTH
histogram wealth_tot_log if sex==1, by(urban) title(Male Wealth) fcolor(eltblue) lcolor(black) xscale(range(5 25)) ///
			ylabel(, angle(0)) saving(wealth_male, replace)
histogram wealth_tot_log if sex==2, by(urban) title(Female Wealth) fcolor(cranberry) lcolor(black) xscale(range(10 25)) ///
			ylabel(, angle(0)) saving(wealth_female, replace)
gr combine wealth_male.gph wealth_female.gph, col(1) //iscale(1)
graph export wealth_bysex.png, replace
erase wealth_male.gph 
erase wealth_female.gph


***  2.2. Report the Variance of Logs:
**** CIW, all together:
estpost tabstat consumpt_log income_log wealth_tot_log if sex==1, by(urban) listwise statistics(variance) columns(statistics)
esttab using "$figure_path/CIW_var_male.tex", cells("variance(fmt(a3))") replace

estpost tabstat consumpt_log income_log wealth_tot_log if sex==2, by(urban) listwise statistics(variance) columns(statistics)
esttab using "$figure_path/CIW_var_female.tex", cells("variance(fmt(a3))") replace





***** Histograms of CIW, divided by education 
**** 2.1. Show histogram for CIW separately for rural and urban areas
*** CONSUMPTION (I do it, in logs)


histogram consumpt_log if urban==1, by(educat) title("Urban consumption, by education") fcolor(eltblue) lcolor(black) ///
			xscale(range(8 15))  ylabel(, angle(0)) col(3)      //yscale(range(0 0.8))
gr export "$figure_path/urban_con_byeduc.png", replace
histogram consumpt_log if urban==0, by(educat) title("Rural consumption") fcolor(cranberry) lcolor(black) ///
			xscale(range(8 15)) ylabel(, angle(0)) 
gr export "$figure_path/rural_con_byeduc.png", replace

*gr combine consumpt_male.gph consumpt_female.gph, col(1)  //iscale(1)
*graph export cons_bysex.png, replace
*erase consumpt_male.gph 
*erase consumpt_female.gph

****  INCOME
*histogram income_log if sex==1, by(urban) title(Male Income) fcolor(eltblue) lcolor(black) xscale(range(5 25)) ///
*			ylabel(, angle(0)) saving(income_male, replace)
*histogram income_log if sex==2, by(urban) title(Female income) fcolor(cranberry) lcolor(black) xscale(range(5 25)) ///
*			ylabel(, angle(0)) saving(income_female, replace)
*gr combine income_male.gph income_female.gph, col(1) //iscale(1)
*graph export "$figure_path/income_bysex.png", replace
*erase income_male.gph 
*erase income_female.gph


**** WEALTH
*histogram wealth_tot_log if sex==1, by(urban) title(Male Wealth) fcolor(eltblue) lcolor(black) xscale(range(5 25)) ///
*			ylabel(, angle(0)) saving(wealth_male, replace)
*histogram wealth_tot_log if sex==2, by(urban) title(Female Wealth) fcolor(cranberry) lcolor(black) xscale(range(10 25)) ///
*			ylabel(, angle(0)) saving(wealth_female, replace)
*gr combine wealth_male.gph wealth_female.gph, col(1) //iscale(1)
*graph export wealth_bysex.png, replace
*erase wealth_male.gph 
*erase wealth_female.gph


***** 3) Question 3. Inequality Across Space

***** 3.1) Plot the level of CIW and labor supply by zone (or district) against the level of household income by zone.

use "$path/CIWdata_Uganda2013.dta", clear
collapse (mean) consumpt_log (mean) int_labour (mean) wealth_tot_log (mean) income_log, by(district)

*** Scatterplots...
cd "$figure_path"
twoway (scatter consumpt_log income_log, ylabel(, angle(0))), saving(cons_income, replace)
twoway (scatter int_labour income_log, ylabel(, angle(0))), saving(labour_income, replace)
twoway (scatter wealth_tot_log income_log, ylabel(, angle(0))), saving(wealth_income, replace)
gr combine cons_income.gph labour_income.gph wealth_income.gph, col(2) iscale(1) 
graph export CIWmean_bydistrict.png, replace

erase cons_income.gph
erase labour_income.gph
erase wealth_income.gph



****** 3.2) Plot the inequality of CIW and labor supply by zone (or district) against the level of household income by zone. 

use "$path/CIWdata_Uganda2013.dta", clear
collapse (sd) consumpt_log (sd) int_labour (sd) wealth_tot_log (mean) income_log, by(district)

*** Scatterplots...
cd "$figure_path"
twoway (scatter consumpt_log income_log, ylabel(, angle(0))), saving(cons_var_income, replace)
twoway (scatter int_labour income_log, ylabel(, angle(0))), saving(labour_var_income, replace)
twoway (scatter wealth_tot_log income_log, ylabel(, angle(0))), saving(wealth_var_income, replace)
gr combine cons_var_income.gph labour_var_income.gph wealth_var_income.gph, col(2) iscale(1) 
graph export CIWvar_bydistrict.png, replace

erase cons_var_income.gph
erase labour_var_income.gph
erase wealth_var_income.gph






*histogram consumpt if urban==0, frequency saving(cons_rural)
*histogram consumpt if urban==1, frequency saving(cons_urban)
*gr combine cons_urban.gph cons_rural.gph, col(1) iscale(1)


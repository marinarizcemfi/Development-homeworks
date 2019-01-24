*** Document that prepare the datasets with the measures of consumptions, wealth,and income
*** 		for each household in the LSMS-ISA Survey of Uganda for 2013-2014

**  Link:   http://microdata.worldbank.org/index.php/catalog/2663/related_materials

*** The steps followed in the procedures are mainly following De Magalhãesa and 
*** Santaeulàlia-Llopis (2018)


clear
global path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/Data/UGA_2013_UNPS_v01_M_STATA8"
global dofiles_path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/HW1"
cd "$path"


******************** CONSUMPTION   ****************************
*** I create the measure of consumption (I use the already prepared measure "cpexp30", that is 
***		availbale in "UNPS 2013-14 Consumption Aggregate.dta").

**  In addition, I do the logarithm, of consumption
use "UNPS 2013-14 Consumption Aggregate.dta", clear
gen consumpt=cpexp30
gen consumpt_log=log(consumpt)


** I check for duplicates
duplicates report 
** We found one duplicate - then, I will drop it
duplicates drop

** I collapse the dataset (I keep the variables consumpt, consumpt_original, and urban)
collapse (mean) consumpt consumpt_log (firstnm) urban, by(HHID)

** I relabel "urban" (since the labels have been lost)
label define urban_lab 0 "Rural" 1 "Urban" 
label values urban urban_lab

save consumpt_Uganda2013.dta, replace

******************** INCOME ****************************
cd "$dofiles_path"
do "Income Calculations-HW1.do"
use "$path/income_tot_Ug2013.dta", clear

******************** WEALTH ****************************

**   I execute the do file "Wealth Calculations-HW1.do", that creates the required measure for Wealth
cd "$dofiles_path"
do "Wealth Calculations-HW1.do"
use "$path/wealth_Ug2013.dta", clear

gen wealth_tot_log=log(wealth_tot)


*** Merging the three resulting datasets
merge 1:1 HHID using consumpt_Uganda2013.dta
drop _merge
save CIWdata_Uganda2013.dta, replace

merge 1:1 HHID using income_tot_Ug2013.dta
drop _merge

gen income_log=log(income_tot)

** I put also wealth (and income), in logs:

save CIWdata_Uganda2013.dta, replace




**** I prepare the part of the dataset for age for the households (I just take the age of the Head of the Household).
use "$path/GSEC2.dta", clear

tab h2q4
tab h2q4, nol

*** Keeping only the Head of the Household
keep if h2q4==1
duplicates report HHID
duplicates drop HHID,force

keep HHID h2q3 h2q8
rename h2q3 sex
rename h2q8 age

merge 1:1 HHID using CIWdata_Uganda2013.dta
drop _merge

rename hoursWorkedLastWeek hours_worked_lastweek
save CIWdata_Uganda2013.dta, replace


*** I add the district
use GSEC1, clear
duplicates report HHID
collapse (firstnm) h1aq1a, by(HHID)
rename h1aq1a district
merge 1:1 HHID using CIWdata_Uganda2013.dta

drop _merge
save CIWdata_Uganda2013.dta, replace


*** I add the variables for education

*** For selecting the Head

use GSEC4.dta, clear
duplicates drop PID, force
save GSEC4-noduplic.dta, replace

use GSEC2.dta, clear

tab h2q4
tab h2q4, nol
*** Keeping only the Head of the Household
keep if h2q4==1
duplicates report HHID
duplicates drop HHID,force

rename h2q4 head_househ
collapse (firstnm) head_househ, by(PID)

merge 1:1 PID using GSEC4-noduplic.dta
keep if head_househ==1
*merge 1:1 PID using GSEC4.dta

tab h4q7 
tab h4q7, nol
gen educat=.
replace educat=1 if h4q7<=17
replace educat=2 if (h4q7>=17 & h4q7<=35)
replace educat=3 if h4q7>35
replace educat=. if h4q7==99
replace educat=. if h4q7==.

label define educat_lab 1 "less than primary school completed" 2 "primary school completed" ///
		3 "secondary school completed or higher"
label values educat educat_lab

rename h4q7 level_edu_detailed
keep HHID PID educat level_edu_detailed
duplicates report HHID
drop if (PID=="P22110-041" &  HHID=="H22110-04-02")
merge 1:1 HHID using CIWdata_Uganda2013.dta
save CIWdata_Uganda2013.dta, replace



*** I rename the number of hours worked per week int_labour [And I create ext_labour, created when
**  that quantity is positive

gen int_labour=hours_worked_lastweek
gen ext_labour=.
replace ext_labour=1 if hours_worked_lastweek>0
replace ext_labour=0 if hours_worked_lastweek==0

save "$path/CIWdata_Uganda2013.dta", replace




*collapse (firstnm) PID (firstnm) head_househ, by(HHID)
*duplicates drop PID, force

*use GSEC4.dta, clear.  // For the level of education of the person in the household


**** Comments:
*label define urban 0 "Rural", add

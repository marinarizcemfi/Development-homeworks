*** Homework 3    ---    Development Economics
***						 Rizzi Marina
***						 26 February 2019

global path3 "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/HW3"
global data "$path3/data"
global tables "$path3/tables"
global regressions "$path3/regressions"
global graphs "$path3/graphs"

cd "$data"
use "$data/dataUGA.dta", clear

*** Putting label in the data



*************************************

** 	QUESTION 1   ********************

*************************************

** Creating some variables
gen log_ctotal=log(ctotal)
gen log_income=log(inctotal)

*** Aggregate consumption, by region and year
bysort year region: egen cons_aggreg=total(ctotal)
gen log_aggregcons=log(cons_aggreg)

*** Create the residuals
**   RESIDUALS for CONSUMPTION
reg log_ctotal age age_sq familysize i.year i.ethnic i.female i.urban
predict consresid_log, residuals

***   RESIDUALS for INCOME
reg log_income age age_sq familysize i.year i.ethnic i.female i.urban
predict incresid_log, residuals

*predict double incresid_log, residuals
save "$data/dataUGA_modified.dta", replace

*** I put year 2009, where the wave is wave 2009/2010 (and 2010 for wave 2010/2011)
replace year=2009 if wave=="2009-2010"
replace year=2010 if wave=="2010-2011"
save "$data/dataUGA_modified.dta", replace


*** Balance the panel dataset
xtset hh year
sort hh year

** Number of years, between observations
bysort hh: gen d_year = year - year[_n-1]

** Growth rates (of residuals, and consumption aggregates)
by hh: gen cons_growth = (consresid_log - consresid_log[_n-1])
by hh: gen inc_growth = (incresid_log - incresid_log[_n-1])
by hh: gen consaggr_growth = (log_aggregcons - log_aggregcons[_n-1])

** I annualized the growth rate 
replace cons_growth = cons_growth/d_year
replace inc_growth = inc_growth/d_year
replace consaggr_growth = consaggr_growth/d_year
save "$data/dataUGA_modified.dta", replace

** Defining a Panel structure:
use "$data/dataUGA_modified.dta", clear
xtset hh year

**** Save betas, for each person:
*** [I use the variables I constructed before, that allow me to annualize the growth rate]
statsby _b, by(hh) saving("$data/coefficients.dta", replace): regress cons_growth inc_growth consaggr_growth, noconst

*statsby _b, by(hh) saving("$data/coefficients.dta", replace): reg d.consresid_log d.incresid_log d.log_aggregcons, nocons
use coefficients.dta, clear

rename _b_inc_growth  beta_coeff
rename _b_consaggr_growth phi_coeff
*rename _stat_1 beta_coeff
*rename _stat_2 phi_coeff
label variable beta_coeff "Beta"
label variable phi_coeff "Phi"
save coefficients.dta, replace

** I eliminate extreme values (first and last percentile)
xtile percentile_beta =beta_coeff , n(100)
tabstat beta_coeff, by(percentile_beta)
drop if percentile_beta==1 | percentile_beta==100
xtile percentile_phi =phi_coeff , n(100)
tabstat phi_coeff, by(percentile_phi)
drop if percentile_phi==1 | percentile_phi==100
save coefficients.dta, replace


** Table for mean and median of coefficients
tabstat beta_coeff phi_coeff, stat(mean median)

estpost tabstat beta_coeff phi_coeff, stat(mean median) columns(statistics) listwise 
esttab using "$tables/mean_coefficients.tex", cells("mean(fmt(a2)) p50(fmt(a2))") nostar unstack noobs nonote nomtitle nonumber collabels("Mean" "Median") label booktabs replace
*esttab using "$tables/mean_coefficients.tex", cells("mean(fmt(a3))" "p50(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels(none) label booktabs replace


*** Histograms
histogram beta_coeff, fcolor(ebblue) lcolor(black) xtitle("Beta coefficients") saving("$graphs/beta", replace)
histogram phi_coeff, fcolor(maroon) lcolor(black) xtitle("Phi coefficients") saving("$graphs/phi", replace)
gr combine "$graphs/beta.gph" "$graphs/phi.gph", col(1)
gr export "$graphs/coefficients_histograms.png", replace

erase "$graphs/beta.gph" 
erase "$graphs/phi.gph" 


** For having mean and median of coefficients
*sum, detail

*** Merging together the two datasets
use "$data/dataUGA_modified.dta", clear
merge m:1 hh using coefficients.dta
save "$data/dataUGA_modified.dta", replace


*************************************

** 	QUESTION 2   ********************

*************************************

*** a) For each household, compute the average household income across all waves Y_i. 
**	   Rank individuals by income and define five groups of income from bottom 20% to 
**	   richest 20%. Within each income group compute the mean and median βi and dicuss 
**	   your results.

use "$data/dataUGA_modified.dta", clear
collapse (mean) inctotal beta_coeff phi_coeff, by(hh)


*** Generating Quintiles, by Income:

xtile quintile = inctotal, n(5)
bys quintile: egen mean_beta=mean(beta_coeff)
bys quintile: egen median_beta=median(beta_coeff)
tab mean_beta
tab median_beta

table quintile mean_beta

tabstat mean_beta median_beta, by(quintile) statistics(mean)

*** Labels:
label define qnt_lab 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
label values quintile qnt_lab  

label variable mean_beta "Mean of Beta"
label variable median_beta "Median of Beta"

**** Export the table in latex
estpost tabstat mean_beta median_beta, by(quintile) statistics(mean) columns(statistics) listwise 
esttab using "$tables/meanmedian_beta.tex", cells("mean(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels(none) label booktabs replace


*** Quintiles by Betas

*sort beta_coeff
xtile quintile_beta = beta_coeff, n(5)
bys quintile_beta: egen mean_income_quint=mean(inctotal)
label variable mean_income_quint "Mean of Income"

tabstat mean_income_quint, by(quintile_beta) statistics(mean)

*** Labels:
*label define qnt_lab 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
label values quintile_beta qnt_lab  

*** Export the table in latex
estpost tabstat mean_income_quint, by(quintile_beta) statistics(mean) columns(statistics) listwise 
esttab using "$tables/meanincome_bybeta.tex", cells("mean(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels("Mean of Income") label booktabs replace


save short_database_UGA.dta, replace



******************************************

***********    QUESTION 3   **************

******************************************

use "$data/dataUGA_modified.dta", clear
xtset hh year

label variable cons_growth "Delta Resid. Cons."
label variable inc_growth "Delta Resid. Inc."
label variable consaggr_growth "Delta Aggr. Cons"

reg cons_growth inc_growth consaggr_growth, noconst
*reg d.consresid_log d.incresid_log d.cons_aggreg, nocons
outreg2 using "$regressions/regression_quest3", tex(fragment) replace nocons label adjr2 


******************************************

***********    QUESTION 4   **************

******************************************

*** In order to redo it divided by urban and rural, I redo the passages above, but with the database
**  only with people for urban or rural areas.

******************************************
***				 URBAN
******************************************

use "$data/dataUGA.dta", clear
keep if urban==1

save "$data/dataUGA_urban.dta", replace


** Creating variables
gen log_ctotal=log(ctotal)
gen log_income=log(inctotal)

bysort year region: egen cons_aggreg=total(ctotal)
gen log_aggregcons=log(cons_aggreg)

**   RESIDUALS for CONSUMPTION
reg log_ctotal age age_sq familysize i.year i.ethnic i.female
predict consresid_log, residuals
***   RESIDUALS for INCOME
reg log_income age age_sq familysize i.year i.ethnic i.female
predict incresid_log, residuals

replace year=2009 if wave=="2009-2010"
replace year=2010 if wave=="2010-2011"

** Balance the dataset
xtset hh year
sort hh year

** Number of years, between observations
bysort hh: gen d_year = year - year[_n-1]

** Growth rates (of residuals, and consumption aggregates)
by hh: gen cons_growth = (consresid_log - consresid_log[_n-1])
by hh: gen inc_growth = (incresid_log - incresid_log[_n-1])
by hh: gen consaggr_growth = (log_aggregcons - log_aggregcons[_n-1])

** I annualized the growth rate 
replace cons_growth = cons_growth/d_year
replace inc_growth = inc_growth/d_year
replace consaggr_growth = consaggr_growth/d_year

save "$data/dataUGA_urban.dta", replace
xtset hh year

**** Save betas, for each person:
statsby, by(hh) saving("$data/coefficients_urban.dta", replace): regress cons_growth inc_growth consaggr_growth, noconst

*statsby _b, by(hh) saving("$data/coefficients_urban.dta", replace): reg d.consresid_log d.incresid_log d.log_aggregcons, nocons
use coefficients_urban.dta, clear

rename _b_inc_growth  beta_coeff
rename _b_consaggr_growth phi_coeff
label variable beta_coeff "Beta"
label variable phi_coeff "Phi"

** I eliminate extreme values (first and last percentile)
xtile percentile_beta =beta_coeff , n(100)
tabstat beta_coeff, by(percentile_beta)
drop if percentile_beta==1 | percentile_beta==100
xtile percentile_phi =phi_coeff , n(100)
tabstat phi_coeff, by(percentile_phi)
drop if percentile_phi==1 | percentile_phi==100
save coefficients_urban.dta, replace

*** Summary Statistics, and Histograms
*tabstat beta_coeff phi_coeff, stat(mean median)
estpost tabstat beta_coeff phi_coeff, stat(mean median) columns(statistics) listwise 
esttab using "$tables/mean_coefficients_urban.tex", cells("mean(fmt(a2)) p50(fmt(a2))") nostar unstack noobs nonote nomtitle nonumber collabels("Mean" "Median") label booktabs replace
*esttab using "$tables/mean_coefficients_urban.tex", cells("mean(fmt(a3))" "p50(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels(none) label booktabs replace


*** Histograms
histogram beta_coeff, fcolor(ebblue) lcolor(black) xtitle("Beta coefficients") saving("$graphs/beta_urb", replace)
histogram phi_coeff, fcolor(maroon) lcolor(black) xtitle("Phi coefficients") saving("$graphs/phi_urb", replace)
gr combine "$graphs/beta_urb.gph" "$graphs/phi_urb.gph", col(1)
gr export "$graphs/coefficients_histograms_urban.png", replace

erase "$graphs/beta_urb.gph" 
erase "$graphs/phi_urb.gph" 


*** Merging
use "$data/dataUGA_urban.dta", clear
merge m:1 hh using coefficients_urban.dta
save "$data/dataUGA_urban.dta", replace

**** Question n.2, for URBAN
use "$data/dataUGA_urban.dta", clear
collapse (mean) inctotal beta_coeff phi_coeff, by(hh)

*** Generating Quintiles, by Income:
xtile quintile = inctotal, n(5)
bys quintile: egen mean_beta=mean(beta_coeff)
bys quintile: egen median_beta=median(beta_coeff)
tab mean_beta
tab median_beta

*** Labels:
cap label define qnt_lab 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
label values quintile qnt_lab  

label variable mean_beta "Mean of Beta"
label variable median_beta "Median of Beta"

**** Export the table in latex
estpost tabstat mean_beta median_beta, by(quintile) statistics(mean) columns(statistics) listwise 
esttab using "$tables/meanmedian_beta_urban.tex", cells("mean(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels(none) label booktabs replace


*** Quintiles by Betas
xtile quintile_beta = beta_coeff, n(5)
bys quintile_beta: egen mean_income_quint=mean(inctotal)
label values quintile_beta qnt_lab  

*** Export the table in latex
estpost tabstat mean_income_quint, by(quintile_beta) statistics(mean) columns(statistics) listwise 
esttab using "$tables/meanincome_bybeta_urban.tex", cells("mean(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels("Mean of Income") label booktabs replace


**** Question n.3, for URBAN
use "$data/dataUGA_urban.dta", clear
xtset hh year
label variable cons_growth "Delta Resid. Cons."
label variable inc_growth "Delta Resid. Inc."
label variable consaggr_growth "Delta Aggr. Cons"

reg cons_growth inc_growth consaggr_growth, noconst
*reg d.consresid_log d.incresid_log d.cons_aggreg, nocons
outreg2 using "$regressions/regression_quest3", tex(fragment) append nocons label adjr2 




******************************************
***				 RURAL
******************************************

use "$data/dataUGA.dta", clear
keep if urban==0

save "$data/dataUGA_rural.dta", replace


** Creating variables
gen log_ctotal=log(ctotal)
gen log_income=log(inctotal)

bysort year region: egen cons_aggreg=total(ctotal)
gen log_aggregcons=log(cons_aggreg)

**   RESIDUALS for CONSUMPTION
reg log_ctotal age age_sq familysize i.year i.ethnic i.female
predict consresid_log, residuals
***   RESIDUALS for INCOME
reg log_income age age_sq familysize i.year i.ethnic i.female
predict incresid_log, residuals

replace year=2009 if wave=="2009-2010"
replace year=2010 if wave=="2010-2011"

** Balance the dataset
xtset hh year
sort hh year

** Number of years, between observations
bysort hh: gen d_year = year - year[_n-1]

** Growth rates (of residuals, and consumption aggregates)
by hh: gen cons_growth = (consresid_log - consresid_log[_n-1])
by hh: gen inc_growth = (incresid_log - incresid_log[_n-1])
by hh: gen consaggr_growth = (log_aggregcons - log_aggregcons[_n-1])

** I annualized the growth rate 
replace cons_growth = cons_growth/d_year
replace inc_growth = inc_growth/d_year
replace consaggr_growth = consaggr_growth/d_year

save "$data/dataUGA_rural.dta", replace
xtset hh year

**** Save betas, for each person:
statsby, by(hh) saving("$data/coefficients_rural.dta", replace): regress cons_growth inc_growth consaggr_growth, noconst

*statsby _b, by(hh) saving("$data/coefficients_rural.dta", replace): reg d.consresid_log d.incresid_log d.log_aggregcons, nocons
use coefficients_rural.dta, clear

rename _b_inc_growth  beta_coeff
rename _b_consaggr_growth phi_coeff
label variable beta_coeff "Beta"
label variable phi_coeff "Phi"

** I eliminate extreme values (first and last percentile)
xtile percentile_beta =beta_coeff , n(100)
tabstat beta_coeff, by(percentile_beta)
drop if percentile_beta==1 | percentile_beta==100
xtile percentile_phi =phi_coeff , n(100)
tabstat phi_coeff, by(percentile_phi)
drop if percentile_phi==1 | percentile_phi==100
save coefficients_rural.dta, replace

*** Summary Statistics, and Histograms
estpost tabstat beta_coeff phi_coeff, stat(mean median) columns(statistics) listwise 
esttab using "$tables/mean_coefficients_rural.tex", cells("mean(fmt(a3)) p50(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels("Mean" "Median") label booktabs replace

*** Histograms
histogram beta_coeff, fcolor(ebblue) lcolor(black) xtitle("Beta coefficients") saving("$graphs/beta_rur", replace)
histogram phi_coeff, fcolor(maroon) lcolor(black) xtitle("Phi coefficients") saving("$graphs/phi_rur", replace)
gr combine "$graphs/beta_rur.gph" "$graphs/phi_rur.gph", col(1)
gr export "$graphs/coefficients_histograms_rural.png", replace

erase "$graphs/beta_rur.gph" 
erase "$graphs/phi_rur.gph" 


*** Merging
use "$data/dataUGA_rural.dta", clear
merge m:1 hh using coefficients_rural.dta
save "$data/dataUGA_rural.dta", replace

**** Question n.2, for RURAL
use "$data/dataUGA_rural.dta", clear
collapse (mean) inctotal beta_coeff phi_coeff, by(hh)

*** Generating Quintiles, by Income:
xtile quintile = inctotal, n(5)
bys quintile: egen mean_beta=mean(beta_coeff)
bys quintile: egen median_beta=median(beta_coeff)
tab mean_beta
tab median_beta

cap label define qnt_lab 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
label values quintile qnt_lab  

label variable mean_beta "Mean of Beta"
label variable median_beta "Median of Beta"


**** Export the table in latex
estpost tabstat mean_beta median_beta, by(quintile) statistics(mean) columns(statistics) listwise 
esttab using "$tables/meanmedian_beta_rural.tex", cells("mean(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels(none) label booktabs replace


*** Quintiles by Betas
xtile quintile_beta = beta_coeff, n(5)
bys quintile_beta: egen mean_income_quint=mean(inctotal)
label values quintile_beta qnt_lab  
*** Export the table in latex
estpost tabstat mean_income_quint, by(quintile_beta) statistics(mean) columns(statistics) listwise 
esttab using "$tables/meanincome_bybeta_rural.tex", cells("mean(fmt(a3))") nostar unstack noobs nonote nomtitle nonumber collabels("Mean of Income") label booktabs replace


**** Question n.3, for RURAL
use "$data/dataUGA_rural.dta", clear
xtset hh year
label variable cons_growth "Delta Resid. Cons."
label variable inc_growth "Delta Resid. Inc."
label variable consaggr_growth "Delta Aggr. Cons"

reg cons_growth inc_growth consaggr_growth, noconst
*reg d.consresid_log d.incresid_log d.cons_aggreg, nocons
outreg2 using "$regressions/regression_quest3", tex(fragment) append nocons label adjr2 













*** To see, how many people have variables, for each year:
*bys hh: gen obs=_n
*tab obs

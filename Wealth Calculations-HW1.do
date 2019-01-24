** I calculate separately the Wealth


clear
global path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/Data/UGA_2013_UNPS_v01_M_STATA8"
cd "$path"
use GSEC14A.dta, clear

*** 1) ASSETS (GSEC14A)	
** h14q5  (GSEC14A)	What is the total estimated value of all the assets own by your household? ? 

* ---> I will collapse, doing the sum, on these values, with respect to HHID
*	   [And then save it, separately]

collapse (sum) h14q5, by(HHID)
rename h14q5 value_housing_assets
save wealth_Ug2013.dta, replace
*******************************************


*** 2) LAND (AGSEC2A)
** hh: it is the old HHID
use AGSEC2A.dta, clear
** a2aq4	A2BQ4: Size of the Parcel in Acres
** a2aq14	A2BQ16:How much rent did you or will you receive (if sharecropped -out give the

*** Just 40 prices (in rents) ------> 
**  I will do the mean of the prices, for each separate land quality (i.e. mean for good quality,
**    mean for fair quality, etc) ----> Then I will multiply the land quantity by the correspective price

** For the land quantity, we put the GPS measure when it is available, otherwise we put the estimation
**   of the person (if that data is not available).

gen land_quantity=.
replace land_quantity= a2aq4
replace land_quantity= a2aq5 if land_quantity==.
count if land_quantity==.

** Land quality variable:  a2aq17
tab a2aq17
tab a2aq17, nol
** For each land quality, we calculate the mean price for that land quality

egen mprice_good=mean(a2aq14) if a2aq17==1
egen mprice_fair=mean(a2aq14) if a2aq17==2
egen mprice_poor=mean(a2aq14) if a2aq17==3
** No observations, here

gen price_land=.
replace price_land= mprice_good if a2aq17==1
replace price_land= mprice_fair if a2aq17==2
replace price_land= 77307 if a2aq17==3

** We calculate the % change from good_price to fair_price; we apply the same
**	    % change, between fair_price, and poor_price.

** mprice_good= 234040.  ; mprice_fair= 134510 ; P_fair/P_good=0.57473
** mprice_poor= 0.57473*P_fair=77307

** I create the variable, for the land value (yearly value of the rent)
gen land_value= (price_land*12)*land_quantity
** I do it yearly

** I collapse, summing the land values, by hh
duplicates report hh
collapse (sum) land_value, by(hh)
rename hh HHID

** Merge, with previous dataset:
merge 1:1 HHID using wealth_Ug2013.dta
drop _merge
save wealth_Ug2013.dta, replace
*******************************************

*** 3) LIVESTOCK - Cattle, and pack animals (AGSEC6A)
use AGSEC6A.dta, clear

** a6aq3a	A6AQ3A:How many of [...] are owned by your household now (present at your farm o
** a6aq13b	What was, on average, the value of each [LiveStockID] BOUGHT [NOsold]? <font color = red>(U
** a6aq14b	A6AQ14B: What was, on aveage, the value of each sold?
**     [The final value is obtained multiplying the quantity, times the value of each sold..........................:D;P;P;P;P]

** Since we only have 178 prices (in a6aq14b), and observations that have animals are more than 1000, we have to impute prices, for the cases in 
**	   which there are not prices.

*****
tab LiveStockID a6aq14b, nol
** We can see that if we use a6aq14b (price of animals sold), we have all the categories of animals (codified in 
**     LiveStockID), except from 11 and 12 (that are missing also in a6aq13b, price of animals bought).

tab LiveStockID a6aq3a, nol
** We can see that noone bought an indigenous horse (code 12), and just two people bought an indigenous donkey, so we
** 		will probably ignore these two prices (since for horses it's useless, and for donkey we are not sure, how to 
**		infer a right price).

forvalues i=1/12 {
egen mean_price_`i'=mean(a6aq14b) if LiveStockID==`i'
}

gen price_animal=.

forvalues i=1/12 {
replace price_animal=mean_price_`i' if LiveStockID==`i'
}

*egen mean_price_1=mean(a6aq14b) if LiveStockID==1


** Now that we have each price for each animal, we calculate the value of each group of animal
**		(that is: quantity * price)

gen value_cattle= price_animal*a6aq3a

** We now collapse again the data, calculating the sum of the value_cattle by hh
collapse (sum) value_cattle, by(hh)
rename hh HHID

** Merging datasets
merge 1:1 HHID using wealth_Ug2013.dta
drop _merge
save wealth_Ug2013.dta, replace


*** 4) LIVESTOCK - Small animals   (AGSEC6B)

*** Questions:
**  a6bq3a	 A6BQ3A:How many of [...] are owned by your household now?(present at your farm o
**  a6bq14b	 A6BQ13B: Average value of each sold

use AGSEC6B.dta, clear

tab a6bq3a
tab a6bq14b
** 2205 animals are owned by people (in the dataset), but we only have sold prices for 438 of them ----->
**		We then have to impute the prices, for the remaining ones.

tab ALiveStock_Small_ID a6bq3a, nol
tab ALiveStock_Small_ID a6bq14b, nol
** There are prices (for sold animals) for each type of animal; so I will use this variable, in order to impute
**		the missing prices

forvalues i=13/22 {
egen mean_price_`i'=mean(a6bq14b) if ALiveStock_Small_ID==`i'
}

gen price_animal=.
forvalues i=13/22 {
replace price_animal=mean_price_`i' if ALiveStock_Small_ID==`i'
}


** bysort ALiveStock_Small_ID: egen price_animals_02=mean(a6bq14b)

** We actually don't have the price for the exotic male sheep (category 15). So we try to infer it, using the relationship
**		between the prices of the indigenous male sheep and the indigenous female sheep, and then applying this relationship
**		to the price of the exotic female sheep. 
**		That is: p_exot_male = (p_indig_male/p_indig_fem) * exot_fem 
**		[All the prices refers to sheeps]

**		p_indig_male=62500    ;    p_indig_fem=84615.38       ;     exot_fem=70000
 
replace price_animal=(62500/84615.38)*70000 if ALiveStock_Small_ID==15

** Now that we have all the prices, we calculate the value of the group of animals:
gen value_small_animals= price_animal*a6bq3a
tab value_small_animals
** Same count of tab a6bq3a [...Great!]

collapse (sum) value_small_animals, by(hh)
rename hh HHID

** Merging datasets
merge 1:1 HHID using wealth_Ug2013.dta
drop _merge
save wealth_Ug2013.dta, replace




*** 4) LIVESTOCK - Poultry and others  (AGSEC6C)
*** Questions:
**  a6cq3a	 A6CQ3A: How many [..] are owned by your household now (present at your farm or a
**  a6cq14b	 A6CQ14B: Average value of each one sold

use AGSEC6C.dta, clear

tab APCode a6cq14b, nol
** We have prices (of animals sold) for each type of animal. So we proceed in the usual way (to infer prices for observations
**		that do not have prices).

tab a6cq3a
tab a6cq14b
** We need to infer prices

** Calculation of average price, per type of animal
forvalues i=23/27 {
egen mean_price_`i'=mean(a6cq14b) if APCode==`i'
}

gen price_animal=.

forvalues i=23/27 {
replace price_animal=mean_price_`i' if APCode==`i'
}



** Now that we have each price for each animal, we calculate the value of each group of animal
**		(that is: quantity * price)
gen value_poultry= price_animal*a6cq3a
sum value_poultry

collapse (sum) value_poultry, by(hh)
rename hh HHID

** Merging datasets
merge 1:1 HHID using wealth_Ug2013.dta
drop _merge
save wealth_Ug2013.dta, replace


**************************************
*** 5)  LIVESTOCK -  Farm Implements, and Machinery    (AGSEC10)
**a10q2	A10Q2:What is the total estimated value of all [ITEM] owned by your household?


use AGSEC10.dta, clear
rename a10q2 value_machineries
collapse (sum) value_machineries, by(hh)
rename hh HHID

** Merging datasets
merge 1:1 HHID using wealth_Ug2013.dta
drop _merge
save wealth_Ug2013.dta, replace


** Now, we just substitute the missing value with values of 0 (so that, the sums with components
**		that are missing do not become missing ----> If we have only an unique information to
**		describe the wealth of a person (that can be not eligible for a certain type of modules - i.e.
**		the cattle one) we would like to use that information

foreach i in value_machineries value_poultry value_small_animals value_cattle ///
		land_value value_housing_assets {
replace `i'=0 if `i'==.
}


** Now, we can calculate Total Wealth!

gen wealth_tot= value_machineries + value_poultry + value_small_animals + value_cattle + land_value + value_housing_assets
save wealth_Ug2013.dta, replace




**** In the end, I replace equal zero the value that are missing in a module, (so that the total sum in the end
***   do not seems missing).











*** I compute Wealth:
**  Wealth: houses + other durables (A.3.1) + land (A.3.2) + agric. equip. and structures (A.3.3), fishery equip. (A.3.4) +
**     + livestock (A.3.5) - debt (A.3.6).

*** Where we miss price: we average prices of those that have prices

** h14q5  (GSEC14A)	What is the total estimated value of all the assets own by your household? ? 
*** [There is also housing, inside] ----> [And also, other durables]


*-------- [Probably, I will not put these things, together....... :D;P;P;P;P;P]
**GSEC15C: (Durables)
**h15cq5	How much came from purchases in the past [RECALL]? VALUE	
**h15cq7	How much came from own-production in the past [RECALL]? VALUE	
**h15cq9	How much came from gifts\in-kind sources in the past [RECALL]? VALUE


** GSEC15D: (Semi durables)
**h15dq3	How much came from purchases in the past [RECALL]? VALUE	
**h15dq4	How much came from own-production in the past [RECALL]? VALUE	
**h15dq5	How much came from gifts\in-kind sources in the past [RECALL]? VALUE
** [Sum of the following three]
*-----------------------------------------------------

*** AGSEC2A: [Land    ]
** a2aq4	A2BQ4: Size of the Parcel in Acres
** a2aq14	A2BQ16:How much rent did you or will you receive (if sharecropped -out give the
**   [To compute the value ----> I should multiply together these two things]

** AGSEC6A [Cattle, and pack animals]
** a6aq2	A6AQ2:During the last 12 months, has any member of your household raised or owne
** a6aq3a	A6AQ3A:How many of [...] are owned by your household now (present at your farm o
** a6aq14b	A6AQ14B: What was, on aveage, the value of each sold?
**     [The final value is obtained multiplying the quantity, times the value of each sold..........................:D;P;P;P;P]

** AGSEC6B [Small animals]:
** a6bq3a	A6BQ3A:How many of [...] are owned by your household now?(present at your farm o
** a6bq14b	A6BQ13B: Average value of each sold

** AGSEC6C [Poultry and others]:
** a6cq3a	A6CQ3A: How many [..] are owned by your household now (present at your farm or a
** a6cq14b	A6CQ14B: Average value of each one sold


** AGSEC10 (Farm Implements, and Machinery)
**a10q2	A10Q2:What is the total estimated value of all [ITEM] owned by your household?




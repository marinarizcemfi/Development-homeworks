*** Income Calculations

***								Marina Rizzi
***								20th January, 2019



global path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/Data/UGA_2013_UNPS_v01_M_STATA8"
global dofiles_path "/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/HW1"
cd "$path"



****** INCOME CONSTRUCTION ***********

*** Note, that we put all the variables in an annualized terms.

* [A.2.1] Agricultural net production 
** Nonpermanent crop. and Tree/Permanent crop

use "AGSEC5A.dta", clear // first visit
append using "AGSEC3A.dta"
append using "AGSEC4A.dta"
append using "AGSEC2B.dta" 
append using "AGSEC5B.dta", generate(visit2) // second visit
append using "AGSEC3B.dta", generate(visit2_2)
append using "AGSEC4B.dta", generate(visit2_3)


*We want to obtain, firstly, the produced amount
* a5aq6a - Quantity of the crop harvested in 2013
* a5aq6d - Corvension factor into kgs per crop
gen prodQuant = a5aq6a*a5aq6d 		// Production in kg
gen prodQuant2 = a5bq6a*a5bq6d 		// Production in kg (visit 2)


* First of all, - get the median price sold
* a5aq7a - Quantity of the crop sold
* a5aq7d - Record conversion factor into KG of quantity/unit sold.
* a5aq8	 - What was the value?

* First visit
gen prodQuantSold = a5aq7a*a5aq7d 		// Quantity sold
gen prodValueSold = a5aq8				// Value of quantity sold
gen pricePerKg = a5aq8/prodQuantSold	// Price per kg for hh that sold it
bysort cropID: egen medPricePerKg = median(pricePerKg)

* Second visit
gen prodQuantSold2 = a5bq7a*a5bq7d 		// Quantity sold
gen prodValueSold2 = a5bq8				// Value of quantity sold
gen pricePerKg2 = a5bq8/prodQuantSold2	// Price per kg for hh that sold it
bysort cropID: egen medPricePerKg2 = median(pricePerKg2)


* Now, we want to get value of unsold production
* a5aq21 - How much of the crop harvested during the first season of 2013 is still b

* First visit
gen prodQuantUnsold = a5aq21
replace prodQuantUnsold=0 if prodQuantUnsold==.	// Replace missing by zero for computations
replace prodQuant=0 if prodQuant==.	// Replace missing by zero for computations
replace prodQuantSold=0 if prodQuantSold==.	// Replace missing by zero for computations
gen prodValueUnsold = medPricePerKg * prodQuantUnsold

* Second visit
gen prodQuantUnsold2 = a5bq21
replace prodQuantUnsold2=0 if prodQuantUnsold2==.	// Replace missing by zero for computations
replace prodQuant2=0 if prodQuant2==.	// Replace missing by zero for computations
replace prodQuantSold2=0 if prodQuantSold2==.	// Replace missing by zero for computations
gen prodValueUnsold2 = medPricePerKg2 * prodQuantUnsold2


* We now calculate the costs, that are associated with the production
* Transport cost
* a5aq10 - How much was spent on transport?

* First visit
gen costTransport = cond(missing(a5aq10), 0, a5aq10) // Replace missing with zero

* Second visit
gen costTransport2 = cond(missing(a5bq10), 0, a5bq10) // Replace missing with zero


* Labor cost
* AGSEC3A
* a3aq34  - Did you hire any labour to work on this plot during the first season of 2
* a3aq35a - For this plot how many days did you hire in? (Men)	
* a3aq35b - For this plot how many days did you hire in? (Women)
* a3aq35c - For this plot how many days did you hire in? (Children)
* a3aq36 - How much did you pay including the value in-kind payments for these days

* First visit
gen costLabor = cond(missing(a3aq36), 0, a3aq36) // Replace missing with zero

* Second visit
gen costLabor2 = cond(missing(a3bq36), 0, a3bq36) // Replace missing with zero


* Fertilizer cost
* Organic
* a3aq5	- What was the quantity used?
* a3aq6	- Was any of this purchased?
* a3aq7	- How much was purchased?
* a3aq8	- What was the value of the purchase?
* Inorganic
* a3aq15 - What was the quantity used?	
* a3aq17 - How much was purchased?
* a3aq16 - Was any of this purchased?
* a3aq18 - What was the value of the purchases?
* Pesticide
* a3aq24a - What was the quantity used?	
* a3aq25 - Was any of this purchased?
* a3aq26 - What quantity was purchased?	
* a3aq27 - What was the value of the purchase?

* [NB: !!!!I only use purchased fertilizer for the calculation	]

* First visit
gen costFertilizer = cond(missing(a3aq8), 0, a3aq8) + /// replace missing values by 0 when summing
				     cond(missing(a3aq18), 0, a3aq18) + ///
					 cond(missing(a3aq27), 0, a3aq27)

* Second visit
gen costFertilizer2 = cond(missing(a3bq8), 0, a3bq8) + /// replace missing values by 0 when summing
				     cond(missing(a3bq18), 0, a3bq18) + ///
					 cond(missing(a3bq27), 0, a3bq27)


* Seed cost
* a4aq15 - How much did you pay for all purchased seeds/seedlings used on this crop

* First visit
gen costSeed = cond(missing(a4aq15), 0, a4aq15) // Replace missing with zero

* Second visit
gen costSeed2 = cond(missing(a4bq15), 0, a4bq15) // Replace missing with zero


* Land cost
* a2bq9 - How much rent did you or will you pay to the land owner during the two cropping seasons 
*				   (a2bq8 has to be 1, agreement with landowner)
gen costLand = cond(missing(a2bq9), 0, a2bq9) // First and second visit together

* Sum variables per housholds
collapse (sum) prodValueSold prodValueUnsold costTransport costLabor costFertilizer costSeed costLand ///
			   prodValueSold2 prodValueUnsold2 costTransport2 costLabor2 costFertilizer2 costSeed2, by(hh)

* Keep only variables that are required for the computation of the income measure
keep prodValueSold prodValueUnsold costTransport costLabor costFertilizer costSeed costLand hh ///
     prodValueSold2 prodValueUnsold2 costTransport2 costLabor2 costFertilizer2 costSeed2 hh

* Compute the costs
gen costTotal =  costLand + costLabor + costFertilizer + costSeed + costLabor2 + costFertilizer2 + costSeed2

* Compute net crop production
gen netCropProd = prodValueSold + prodValueSold2 + prodValueUnsold + prodValueUnsold2 - costTotal

* Save constructed data
save "$path/income_Ug2013.dta", replace


** Livestock sales
use "AGSEC6A.dta", clear
append using "AGSEC6B.dta"
append using "AGSEC6C.dta"
append using "AGSEC7.dta"

* Cattle and Pack Animals (AGSEC6A)
* a6aq14a - How many <b>[LiveStockID]</b> did you sell during the last 12 months?
* a6aq14b - What was, on aveage, the value of each sold?
* a6aq5c -  How much did you pay to the paid labour for keeping / herding <b>Cattle
* Small animals (AGSEC6B)
* a6bq14a - How many livestock did you sell alive during the last 12 months	
* a6bq14b - Average value of each sold
* a6bq5c - How much did you pay for keeping/herding <b>Small Animals</b> in the las
* Poultry and others (AGSEC6C)
* a6cq14a - How many <b>[APCode]</b> did you sell alive during the last 3 months?
* a6cq14b - Average value of each one sold
* a6cq5c - How much did you pay for keeping / herding in the last 3 months?

* Compute revenue from livestock sales
gen cattleRev   = a6aq14a*a6aq14b
gen smallAniRev = a6bq14a*a6bq14b
gen poultryRev   = a6cq14a*a6cq14b*4 // Times 4 becaues question only asks for last 3 months

replace cattleRev=0 if cattleRev==.	// Replace missing by zero for computations
replace smallAniRev=0 if smallAniRev==.	// Replace missing by zero for computations
replace poultryRev=0 if poultryRev==.	// Replace missing by zero for computations

* Compute labor costs for live stokc
gen livestockLaborCost = cond(missing(a6aq5c), 0, a6aq5c) + /// replace missing values by 0 when summing
						 cond(missing(a6bq5c), 0, a6bq5c) + ///
						 cond(missing(a6cq5c), 0, a6cq5c)

* Other costs for livestock
* a7bq2e - How much has this household paid to feed the [AGroup_ID] in the past 12
* a7bq3f - How much has this household paid to access the main water sources for th
* a7bq5d - What was the total cost of vaccination, including vaccine and profession
* a7bq6c - What was the total cost for deworming, including cost of dewormer and pr
* a7bq7c - What was the total cost of the treatment of the [AGroup_ID] against tick
* a7bq8c - What was the total cost of the curative treatment for the [AGroup_ID], i
gen livestockOtherCost = cond(missing(a7bq2e), 0, a7bq2e) + /// replace missing values by 0 when summing
						 cond(missing(a7bq3f), 0, a7bq3f) + ///
						 cond(missing(a7bq5d), 0, a7bq5d) + ///
						 cond(missing(a7bq6c), 0, a7bq6c) + ///
						 cond(missing(a7bq7c), 0, a7bq7c) + ///
						 cond(missing(a7bq8c), 0, a7bq8c) 

* Sum variables per housholds
collapse (sum) cattleRev smallAniRev poultryRev livestockLaborCost livestockOtherCost, by(hh)

* Compute net livestock sales
gen livestockSales = cattleRev + smallAniRev + poultryRev - livestockLaborCost - livestockOtherCost

* Merge with existing dataset
merge 1:1 hh using "$path/income_Ug2013.dta"
drop _merge
save "$path/income_Ug2013.dta", replace
						  

** Livestock product
use "AGSEC11.dta", clear
append using "AGSEC8A.dta"
append using "AGSEC8B.dta"
append using "AGSEC8C.dta"

* Animal Power (AGSEC11)
* a11q1c - What was the total value from the sales of dung from this livestock type
* a11q5 - How much has this household earned in cash / kind by providing draught po
gen animalPower = cond(missing(a11q1c), 0, a11q1c) + cond(missing(a11q5), 0, a11q5) 

* Meat, Milk and Eggs (AGSEC8A, AGSEC8B, AGSEC8C)
* a8aq5 - How much has this household earned by selling [AGroup_ID] meat in the pas
* a8bq9 - How much has this household earned by selling [AGroup_ID] milk AND DAIRY
* a8cq5 - How much has this household earned by selling [AGroup_ID] eggs in the pas
gen revMeat = cond(missing(a8aq5), 0, a8aq5)
gen revMilk = cond(missing(a8bq9), 0, a8bq9)
gen revEggs = cond(missing(a8cq5), 0, a8cq5)*4 // Only asks for the last 3 months


* Also need to know unsold production
* Meat
* a8aq1	- How many [AGroup_ID] were slaughtered for meat in the last 12 months?	
* a8aq2	- What was the live weight, on average, of this livestock that the househol	
* a8aq3	- How much of the meat of the [AGroup_ID] produced did you sell in the past
* Milk
* a8bq1	- How many of the following livestock types were milked in the last 12 mont	
* a8bq2	- How many MONTHS on average, were [AGoup_ID] milked for?	
* a8bq3	- What was the average [AGroup_ID] milk production per day per milking anim
* a8bq5	- How much of the milk produced by [AGroup_ID] was consumed by your househo	
* a8bq5_1 - How many litres of [AGroup_ID] liquid milk did you sell per day?	
* a8bq6	- How much of the milk produced by [AGroup_ID] did you convert EACH DAY int
* Eggs
* a8cq1	- How many [AGroup_ID] laid eggs in the last 3 months?	
* a8cq2	- How many[AGroup_ID] eggs did you produce in the last 3 months?	
* a8cq3	- How many [AGroup_ID] eggs did you sell in the last 3 months?

* Meat
bysort AGroup_ID: egen priceMeatPerKg = median(a8aq5/a8aq3)
gen unsoldMeatQuant = a8aq1*a8aq2 - cond(missing(a8aq3), 0, a8aq3)
gen unsoldMeatValue = priceMeatPerKg * unsoldMeatQuant

* Milk 
gen milkProdQuant    = a8bq1 * a8bq2 * a8bq3 * 30 	// Liters of milk per year produced
gen milkOwnUseQuant  = a8bq1 * a8bq2 * a8bq5 * 30 	// Liters of milk per year produced for own use
gen milkSoldQuant  	 = a8bq1 * a8bq2 * a8bq5_1 * 30 // Liters of milk per year produced for sale
gen milkToDairyQuant = a8bq1 * a8bq2 * a8bq6 * 30 	// Liters of milk per year produced for dairy products
gen milkSoldQuantDiary = a8bq1 * a8bq2 * a8bq7 * 30 // Liters of dairy products sold per year 
													// (part of milkToDairyQuant)

replace milkProdQuant=0 if milkProdQuant==.			// Replace missing by zero for computations
replace milkOwnUseQuant=0 if milkOwnUseQuant==.		// Replace missing by zero for computations
replace milkSoldQuant=0 if milkSoldQuant==.			// Replace missing by zero for computations
replace milkToDairyQuant=0 if milkToDairyQuant==.	// Replace missing by zero for computations
replace milkSoldQuantDiary=0 if milkSoldQuantDiary==. // Replace missing by zero for computations													
													
* Check if production sums up
gen milkRemainQuant = milkProdQuant - milkOwnUseQuant - milkSoldQuant - milkToDairyQuant

* Compute the milk prices per liter
gen milkPrices = revMilk/(milkSoldQuant+milkSoldQuantDiary)
bysort AGroup_ID: egen priceMilkPerLiter = median(milkPrices) if milkRemainQuant >= 0 & revMilk>0

* Compute value of unsold production
gen milkUnsoldProdValue = (milkRemainQuant+milkOwnUseQuant) * priceMilkPerLiter

* Eggs
bysort AGroup_ID: egen priceEggs = median(a8cq5/a8cq3)
gen unsoldEggsQuant = cond(missing(a8cq2), 0, a8cq2) - cond(missing(a8cq3), 0, a8cq3)
gen unsoldEggsValue = priceEggs * unsoldEggsQuant

* Sum variables per housholds
collapse (sum) animalPower revMeat revMilk revEggs ///
			   unsoldMeatValue milkUnsoldProdValue unsoldEggsValue, by(hh)

* Compute net livestock sales
gen livestockProducts = animalPower + revMeat + revMilk + revEggs + ///
						unsoldMeatValue + milkUnsoldProdValue + unsoldEggsValue

* Merge with existing dataset
merge 1:1 hh using "$path/income_Ug2013.dta"
drop _merge
save "$path/income_Ug2013.dta", replace
	

** Renting-in agricultural equipment and structure capital
use "AGSEC10.dta", clear

* a10q6 - Did your household rent or borrow any [ITEM] during the last 12 months?
* a10q7	- How many [ITEM] did your household rent or borrow during the last 12 month
* a10q8	- How much did your household pay to rent or borrow [ITEM] during the last 1
gen machineryRent = cond(missing(a10q8), 0, a10q8)

* Sum variables per housholds
collapse (sum) machineryRent, by(hh)

* Drop all variables except machinery rent and hh
keep machineryRent hh

* Merge with existing dataset
merge 1:1 hh using "$path/income_Ug2013.dta"
drop _merge
save "$path/income_Ug2013.dta", replace
	

****** A.2.2] Labor market income [Calculations]

use "GSEC8_1.dta", clear

* Calculations for the main job
* h8q31a - How much was [Name]'s last cash payment for the main job ?	
* h8q31b - How much did [NAME] receive in kind for the main job during the last week?	
* h8q31c - What period of time did this payment cover?
* h8q30a - During the last 12 months, for how many months did [NAME] work in this job?	
* h8q30b - During the 12 months, on average how many weeks per month did [NAME] work in thi
* h8q36a - During the last 7 days, how many hours did [NAME] work on each day?	
* h8q36b - During the last 7 days, how many hours did [NAME] work on each day?	
* h8q36c - During the last 7 days, how many hours did [NAME] work on each day?	
* h8q36d - During the last 7 days, how many hours did [NAME] work on each day?	
* h8q36e - During the last 7 days, how many hours did [NAME] work on each day?	
* h8q36f - During the last 7 days, how many hours did [NAME] work on each day?	
* h8q36g - During the last 7 days, how many hours did [NAME] work on each day?

gen hoursWorkedLastWeek = cond(missing(h8q36a), 0, h8q36a) + /// replace missing values by 0 when summing
						  cond(missing(h8q36b), 0, h8q36b) + ///
						  cond(missing(h8q36c), 0, h8q36c) + ///
						  cond(missing(h8q36d), 0, h8q36d) + ///
						  cond(missing(h8q36e), 0, h8q36e) + ///
						  cond(missing(h8q36f), 0, h8q36f) + ///
						  cond(missing(h8q36g), 0, h8q36g)

gen hoursPerYear = hoursWorkedLastWeek * h8q30b * h8q30a

gen wagePerHour = .
replace wagePerHour=(h8q31a+h8q31b)  		if h8q31c==1	
replace wagePerHour=(h8q31a+h8q31b)/9  		if h8q31c==2   	// Assuming work day means 9 hours
replace wagePerHour=(h8q31a+h8q31b)/45  	if h8q31c==3  	// Assuming week means 45 hours	
replace wagePerHour=(h8q31a+h8q31b)/(4*45)  if h8q31c==4	// Assuming month means 4*45 work hours
replace wagePerHour=.  						if h8q31c==5	// Ignore ones that didn't specify a time (53 of 14751)

* Compute the main annual labor income
gen laborIncomeMain = wagePerHour * hoursPerYear
replace laborIncomeMain=0 if laborIncomeMain==.	// Replace missing by zero for computations

* Secondary Job
* h8q45a - How much was [Name]'s last cash payment for the second job?	
* h8q45b - How much was [NAME]’s last cash payment and the estimated value of what [NAME] l	
* h8q45c - What period of time did this payment cover?
* h8q43	- IN THE LAST 7 DAYS, how many hours did [NAME] actually work at the second income	
* h8q44	- During the last 12 months, for how many months did [NAME] work in this job?	
* h8q44b - During the last month, how many weeks per month did [NAME] work in this job?
gen hoursWorkedLastWeek2 = h8q43

gen hoursPerYear2 = hoursWorkedLastWeek2 * h8q44 * h8q44b

gen wagePerHour2 = .
replace wagePerHour2=(h8q45a+h8q45b)  		if h8q45c==1	
replace wagePerHour2=(h8q45a+h8q45b)/9  	if h8q45c==2   	// Assuming work day means 9 hours
replace wagePerHour2=(h8q45a+h8q45b)/45  	if h8q45c==3  	// Assuming week means 45 hours	
replace wagePerHour2=(h8q45a+h8q45b)/(4*45) if h8q45c==4	// Assuming month means 4*45 work hours
replace wagePerHour2=.  					if h8q45c==5	// Ignore ones that didn't specify a time (28 of 14751)

* Compute the main annual labor income
gen laborIncomeSecondary = wagePerHour2 * hoursPerYear2
replace laborIncomeSecondary=0 if laborIncomeSecondary==.	// Replace missing by zero for computations

* There is also a usual activity section

* Compute total labor income 
gen laborIncome = laborIncomeMain + laborIncomeSecondary

* Sum variables per housholds
collapse (sum) laborIncome laborIncomeMain laborIncomeSecondary ///
			   hoursWorkedLastWeek hoursWorkedLastWeek2 ///
			   hoursPerYear hoursPerYear2, by(HHID)

* Drop all variables except constructed ones and HHID 
keep laborIncome laborIncomeMain laborIncomeSecondary ///
     hoursWorkedLastWeek hoursWorkedLastWeek2 ///
	 hoursPerYear hoursPerYear2 ///
	 HHID
rename HHID hh // Rename HHID to make it compatible with the agriculture housheold identifier hh

* Merge with existing dataset
merge 1:1 hh using "$path/income_Ug2013.dta"
drop _merge
save "$path/income_Ug2013.dta", replace
	

****** A.2.3 Business Income] 

use "gsec12.dta", clear

* For the calculations, we need to multiply each category by number of months in operation.
* h12q12 - In the past 12 months, how many months did the enterprise operate?

* Revenue
* h12q13 - What is/was the average monthly gross revenues during the months of operation?
gen revBusiness = h12q13*h12q12
replace revBusiness=0 if revBusiness==.	// Replace missing by zero for computations

* Labor cost
* h12q15 - What is/was the average expenditure on wages during a typical month of operation
gen costBusinessLabor = h12q15*h12q12
replace costBusinessLabor=0 if costBusinessLabor==.	// Replace missing by zero for computations

* Material cost
* h12q16 - Avg expenditure on raw materials/stock during a typical month of operation?
* h12q17 - Other operating expenses such as fuel, kerosene, electricity etc. during typical
gen costBusinessMaterial = h12q16*h12q12
replace costBusinessMaterial=0 if costBusinessMaterial==.	// Replace missing by zero for computations
gen costBusinessOther = h12q17*h12q12
replace costBusinessOther=0 if costBusinessOther==.	// Replace missing by zero for computations

* Compute total business income 
gen businessIncome = revBusiness - costBusinessLabor - costBusinessMaterial - costBusinessOther

* Sum variables per housholds
collapse (sum) businessIncome, by(hh)

* Drop all variables except constructed ones and HHID 
keep businessIncome hhid
rename hhid hh // Rename HHID to make it compatible with the agriculture housheold identifier hh

* Merge with existing dataset
merge 1:1 hh using "$path/income_Ug2013.dta"
drop _merge
save "$path/income_Ug2013.dta", replace
	

****** A.2.4] Fishery net production 
* [.....???] We probably don't have any useful category here] ---- No matching category?

******* A.2.5 Capital Income] 

use "GSEC11A.dta", clear

* Other Household Income
* h11q5 - Amount received during the past 12 months.[SHILLINGS]	
* h11q6 - Amount received [IN-KIND]during the past 12 months.[SHILLINGS]
gen otherIncome = cond(missing(h11q5), 0, h11q5) + cond(missing(h11q6), 0, h11q6)

* Drop all variables except constructed ones and HHID 
keep otherIncome HHID
rename HHID hh // Rename HHID to make it compatible with the agriculture housheold identifier hh

* Merge with existing dataset
merge 1:1 hh using "$path/income_Ug2013.dta"
drop _merge
save "$path/income_Ug2013.dta", replace
	

****** A.2.6] Net Transfers 

use "GSEC15B.dta", clear
append using "GSEC15C.dta"
append using "GSEC15D.dta"

* In kind payments
* h15bq11 - How much came from gifts\in-kind sources in the past [RECALL]? VALUE
* h15cq9 - How much came from gifts\in-kind sources in the past [RECALL]? VALUE
* h15dq5 - How much came from gifts\in-kind sources in the past [RECALL]? VALUE

gen inKindFood = cond(missing(h15bq11), 0, h15bq11) * 52 // question asks for value per week
gen inKindNonDurable = cond(missing(h15cq9), 0, h15cq9) * 12  // question asks for value in last 30 days
gen inKindSemiDurable = cond(missing(h15dq5), 0, h15dq5)  // question asks for value in last 365 days

gen netTransfer = inKindFood + inKindNonDurable + inKindSemiDurable

* Sum variables per housholds
collapse (sum) netTransfer inKindFood inKindNonDurable inKindSemiDurable, by(HHID)

* Drop all variables except constructed ones and HHID 
keep netTransfer inKindFood inKindNonDurable inKindSemiDurable HHID
rename HHID hh // Rename HHID to make it compatible with the agriculture housheold identifier hh

* Merge with existing dataset
merge 1:1 hh using "$path/income_Ug2013.dta"
drop _merge
save "$path/income_Ug2013.dta", replace
	

****** Final cleanup  --------- *********

* Set missing values to zero for all series for easier computations
quietly describe, varlist
local vars `r(varlist)'
local omit hh
local want : list vars - omit
foreach x of local want {
  replace `x' = 0 if `x' == .
}

* Generate the income measure
gen income = netCropProd + livestockSales + livestockProducts - machineryRent + ///
			 laborIncome + businessIncome + otherIncome + netTransfer
* There are 408 hh with negative income



******** Renaming, and other management of dataset
* Rename houshold identifier		 
rename hh HHID
rename income income_tot

* Save dataset
cd "$path"
save income_Ug2013.dta, replace

*** Organazing Datasets
save income_alldetails_Ug2013.dta, replace
erase income_Ug2013.dta

drop machineryRent-netCropProd
save income_tot_Ug2013.dta, replace

****"$path/income_Ug2013.dta"

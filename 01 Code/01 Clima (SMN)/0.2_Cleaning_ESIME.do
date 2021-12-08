/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Clean and put together ESIME databases.
		- Data source: ESIMEs
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear all 
set more off

*HSRs globals (Home)
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"
*Everyone's globals (DO NOT ERASE)
global excel1 "$root\01 Raw DATA\03 Clima (ESIME)"
global excel2 "$root\01 Raw DATA\04 Clima (ESIME2)\18"
global excel3 "$root\01 Raw DATA\04 Clima (ESIME2)\25"
global DTA "$root/03 DTA"

*I create a blank database to put everything in
gen hora=.
save "$DTA/tempESIME.dta", replace

***********************
***********1***********
***********************

filelist , dir($excel1)  pattern() 
keep filename dirname
tempfile files
save "`files'"
local obs = _N

forvalues i=1/`obs' {  ///
	
	use "`files'" in `i', clear
	local f = dirname +"/"+ filename
	local name = filename
	import delimited  using "`f'", clear varnames(nonames)
	rename v2 fechatiempo
	g nombre= "`name'"
	order nombre
	
	forval j = 3/23  {
		 rename v`j' `=strtoname(v`j'[1])'
	}
	rename v1 Estacion
	drop in 1

	split fechatiempo, p("/") 
	split fechatiempo3, p(" ")
	split fechatiempo32, p(":")
	renvars fechatiempo1 fechatiempo2 fechatiempo31 fechatiempo321 /  dia mes year hora
	drop fechatiempo*
	foreach var of varlist _all{
		destring `var', replace 
	}
	*We Identify the A.M. hours
	gen am = 0
	replace am =1 if dia!=dia[_n-1] & hora == 12 
	replace am =1 if hora==12 & am[_n-1]==1
	forvalues i=1/11 {
		replace am = 1 if hora==`i' & am[_n-1]==1
	}
	*We replace hora with the 24-hour numbers
	replace hora = hora + 12 if am==0 & hora <12
	replace hora = 0 if hora == 12 & am == 1 
		
	collapse (firstnm) nombre (mean) SR_W_m_2_-BP_mbar_ , by(mes dia year hora)
	append using "$DTA\tempESIME.dta", force
	save "$DTA\tempESIME.dta", replace
}
			***********************
			***********2***********
			***********************
			clear
			*I create a blank database to put everything in
			gen hora=.
			save "$DTA/tempESIME2.dta", replace

			filelist , dir($excel2)  pattern() 
			keep filename dirname
			tempfile files
			save "`files'"
			local obs = _N


			forvalues i=1/`obs' {  ///
				
				use "`files'" in `i', clear
				local f = dirname +"/"+ filename
				local name = filename
				import delimited  using "`f'", clear varnames(nonames)
				rename v2 fechatiempo
				g nombre= "`name'"
				order nombre
				
				
				forval j = 3/18  {
					 rename v`j' `=strtoname(v`j'[1])'
				}
				rename v1 Estacion
				drop in 1/2

				split fechatiempo, p("/") 
				split fechatiempo3, p(" ")
				split fechatiempo32, p(":")
				renvars fechatiempo1 fechatiempo2 fechatiempo31 fechatiempo321 /  dia mes year hora
				drop fechatiempo*
				foreach var of varlist _all{
					destring `var', replace 
				}
				*We Identify the A.M. hours
				gen am = 0
				replace am =1 if dia!=dia[_n-1] & hora == 12 
				replace am =1 if hora==12 & am[_n-1]==1
				forvalues i=1/11 {
					replace am = 1 if hora==`i' & am[_n-1]==1
				}
				*We replace hora with the 24-hour numbers
				replace hora = hora + 12 if am==0 & hora <12
				replace hora = 0 if hora == 12 & am == 1 
					
				collapse (firstnm) nombre (mean) Rh-WPError , by(mes dia year hora)
				append using "$DTA\tempESIME2.dta", force
				save "$DTA\tempESIME2.dta", replace
			}

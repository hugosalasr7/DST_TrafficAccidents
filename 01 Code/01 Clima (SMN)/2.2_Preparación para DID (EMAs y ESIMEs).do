/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Prepare EMAs and ESIMEs database for the Dif-n-Dif estimations 
		- Data source: EMAs and ESIMEs
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear all 
set more off

*HSRs globals (Home)
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigacion y Docencia Economicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"
*Everyone's globals (DO NOT ERASE)
global excel "$root/01 Raw DATA"
global DTA "$root/03 DTA/Clima (SMN)"
global fig "$root/04 Figures"
global esc "C:\Users\Hrodriguez\Desktop"

*Begin
u "$DTA\EMAs (2010-2015).dta", clear
drop if year<2014 //The experiment begins in 2015. 
drop if year == 2016 //We could take the data from a year earlier (2014) only 
*We keep the names of the stations we need only
keep  if nombre_EMA=="Calakmul" | nombre_EMA=="Cancun" | nombre_EMA=="Celestun" | nombre_EMA=="Cozumel" |nombre_EMA=="Dzilam" | nombre_EMA=="Jose Maria Morelos" | nombre_EMA=="Los Petenes" | nombre_EMA=="Monclova" | nombre_EMA=="Oxkutzcab" | nombre_EMA=="P. de Centla" | nombre_EMA=="Palenque" | nombre_EMA=="Paraiso" | nombre_EMA=="Rio Lagartos" | nombre_EMA=="Tantakin" | nombre_EMA=="Tizimin" 
save "$DTA/temp00.dta", replace

	*We create a temp file with only one variable
	clear 
	gen cve = "."
	save "$esc/temp01.dta", replace

*We import a document that contains all the municipalities that are relevant to the peninsula
*and also contains the names of the EMAs and ESIMEs that should be matched to each of them
import excel "$excel\Peninsula (DID).xlsx",  firstrow clear
tostring cve, replace
replace cve = "0" + cve if cve_edo==4 //This is so all codes have the same number of digits
levelsof cve if nombre_EMA != "" //Get all the municipalitites that don't have an EMA assigned to them
//For each of these municipalities, merge it with the EMA file and append it to another file
foreach lev in `r(levels)' {
	quietly: import excel "$excel\Peninsula (DID).xlsx",  firstrow clear
	quietly: tostring cve, replace
	quietly: replace cve = "0" + cve if cve_edo==4
	keep cve nombre*
	quietly: keep if cve=="`lev'" //Keep only the municipality that we are currently looping on
	quietly: merge 1:m nombre_EMA using "$DTA\temp00.dta"  //Merge all temperature data to it
	quietly: keep if _merge==3 //Keep only if it was merged
	quietly: count
	if (r(N) == 0){
	  display "`lev' did not merge" //Palenque is the only EMA that did not merge. We do not have data for that year.
	}
	quietly: append using "$esc\temp01.dta", force //Append and put it together with all other obs
	quietly: save "$esc/temp01.dta", replace 
}
renvars HumRelativa TempAire RadSolar PresBarometric RapViento Precipitacion/ Rh ATC SR BP AvgWSV Rain
keep Rh ATC SR BP AvgWSV Rain cve nombre mes dia year hora nombre_EMA
replace nombre = nombre_EMA 
drop nombre_EMA
save "$esc/temp01.dta", replace

	u "$DTA/tempESIME.dta", clear
	renvars RH_ ATC_C_ SR_W_m_2_ BP_mbar_ WS_m_s_ Rain_mm__1Hr/ Rh ATC SR BP AvgWSV Rain
	append using "$DTA\tempESIME2.dta", force
	keep dia mes year hora nombre Rh ATC SR BP AvgWSV Rain
	*Get names back
	replace nombre= subinstr(nombre,"ESIME ","",.)
	split nombre, p(" 20")
	replace nombre=nombre1
	drop nombre1 nombre2
	drop if year<2014
	drop if year == 2016
	save "$DTA/temp00.dta", replace

	import excel "$excel\Peninsula (DID).xlsx",  firstrow clear
	tostring cve, replace
	replace cve = "0" + cve if cve_edo==4
	levelsof cve if nombre != ""
	foreach lev in `r(levels)' {
		quietly: import excel "$excel\Peninsula (DID).xlsx",  firstrow clear
		quietly: tostring cve, replace
		quietly: replace cve = "0" + cve if cve_edo==4
		keep cve nombre*
		quietly: keep if cve=="`lev'"
		merge 1:m nombre using "$DTA\temp00.dta" 
		quietly: keep if _merge==3
		quietly: count
		if (r(N) == 0){
		display "`lev' did not merge" //All ESIMEs merged
		}
		quietly: append using "$esc\temp01.dta", force
		save "$esc/temp01.dta", replace 
	}
	
	//Drop duplicates
	duplicates tag dia mes year hora cve, g(a)
	bysort cve hora dia mes year  a: gen aa = _n
	drop if aa==2 & a==1
	drop a aa _merge nombre_EMA

label var SR "Solar Radiation"
label var Rh "Relative Humidity"
label var ATC "Average Temperature (Celsius)"
label var Rain "MM of rain in that hour"
label var AvgWSV "Average Wind Speed"
label var BP "Barometric Pressure"
label var nombre "Nombre de la estación (EMA o ESIME)"

save "$DTA/Temperatura 2014-2015 (DID)", replace

/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Prepare EMAs and ESIMEs database for the RD estimations 
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

******************************************************************************
*******************************************
************First chunk of data************
*******************************************
*For some good reason I do not remember, we subset the data in 
*two chunks of data (two chunks of metropolitan areas)
*We take the metropolitan areas' database and subset it to the first chunk of data
import excel "$excel\ZonasMetro (RD).xlsx",  firstrow clear
renvars NúmeroderegistroenelSistema Nombredelaciudadparajuntar I/ cve_metro nombre nombre_EMA
keep cve_metro nombre*
drop if cve_metro==.
drop if cve_metro==58 | cve_metro==52 | cve_metro==43 | cve_metro==27 | cve_metro== 14
save "$DTA/temp00.dta", replace

			*We try to merge with EMAs first. After, we keep the merged observations for later. 
			u "$DTA/EMAs (2010-2015).dta", clear
			merge m:m nombre_EMA using "$DTA\temp00.dta"
			keep if _merge==3
			renvars HumRelativa TempAire RadSolar PresBarometric RapViento Precipitacion/ Rh ATC SR BP AvgWSV Rain
			keep Rh ATC SR BP AvgWSV Rain cve_metro nombre mes dia year hora nombre_EMA
			replace nombre = nombre_EMA 
			drop nombre_EMA
			save "$DTA/temp01.dta", replace

			*Now we try to merge it with ESIME's. We keep those that merged. 
			u "$DTA/tempESIME.dta", clear
			renvars RH_ ATC_C_ SR_W_m_2_ BP_mbar_ WS_m_s_ Rain_mm__1Hr/ Rh ATC SR BP AvgWSV Rain
			append using "$DTA\tempESIME2.dta", force
			keep dia mes year hora nombre Rh ATC SR BP AvgWSV Rain
			*Get names back
			replace nombre= subinstr(nombre,"ESIME ","",.)
			split nombre, p(" 20")
			replace nombre=nombre1
			drop nombre1 nombre2
			*Change names so merge is successful
			replace nombre= "Aguascalientes" if nombre=="Aguascalientes Enero-Junio"
			replace nombre= "Tuxtla Gutiérrez" if nombre=="Tuxla Gutiérrez"
			replace nombre= "Santa Rosalia" if nombre=="Santa Rosalía"
			replace nombre= "Orizaba" if nombre=="Orizaba _ Enero - Mayo"
			replace nombre= "Huajuapan de León" if nombre=="Huajuapan de León _ Enero - Mayo" | nombre=="Huajuapán de León" | nombre=="Huajuapan" 
			replace nombre= "Colotlán" if nombre=="Colotán"
			*Merge with metropolitan codes
			merge m:m nombre using "$DTA\temp00.dta", keep(3) nogen
			gen esime=1
			append using "$DTA\temp01.dta", force //Append those that merged with ESIME
			replace esime=0 if esime==.
			drop nombre_EMA
			save "$DTA/temp03.dta", replace

*******************************************
************Second chunk of data***********
*******************************************
*We take the metropolitan areas' database and subset it to the second chunk of data
import excel "$excel\ZonasMetro (RD).xlsx",  firstrow clear
renvars NúmeroderegistroenelSistema Nombredelaciudadparajuntar I/ cve_metro nombre nombre_EMA
keep cve_metro nombre*
drop if cve_metro==.
keep if cve_metro==58 | cve_metro==52 | cve_metro==43 | cve_metro==27 | cve_metro== 14
save "$DTA/temp00.dta", replace

*Now we try to merge it with ESIME's. We keep those that merged. 
u "$DTA/EMAs (2010-2015).dta", clear
merge m:m nombre_EMA using "$DTA\temp00.dta"
keep if _merge==3
renvars HumRelativa TempAire RadSolar PresBarometric RapViento Precipitacion/ Rh ATC SR BP AvgWSV Rain
keep Rh ATC SR BP AvgWSV Rain cve_metro nombre mes dia year hora nombre_EMA
replace nombre = nombre_EMA 
drop nombre_EMA
save "$DTA/temp01.dta", replace

			*Now we try to merge it with ESIME's. We keep those that merged. 
			u "$DTA/tempESIME.dta", clear
			renvars RH_ ATC_C_ SR_W_m_2_ BP_mbar_ WS_m_s_ Rain_mm__1Hr/ Rh ATC SR BP AvgWSV Rain
			append using "$DTA\tempESIME2.dta", force
			keep dia mes year hora nombre Rh ATC SR BP AvgWSV Rain
			*Get names back
			replace nombre= subinstr(nombre,"ESIME ","",.)
			split nombre, p(" 20")
			replace nombre=nombre1
			*Specifics
			replace nombre= "Aguascalientes" if nombre=="Aguascalientes Enero-Junio"
			replace nombre= "Tuxtla Gutiérrez" if nombre=="Tuxla Gutiérrez"
			replace nombre= "Santa Rosalia" if nombre=="Santa Rosalía"
			replace nombre= "Orizaba" if nombre=="Orizaba _ Enero - Mayo"
			replace nombre= "Huajuapan de León" if nombre=="Huajuapan de León _ Enero - Mayo" | nombre=="Huajuapán de León" | nombre=="Huajuapan" 
			replace nombre= "Colotlán" if nombre=="Colotán"
			*Merge with metropolitan codes
			merge m:m nombre using "$DTA\temp00.dta"
			keep if _merge==3
			append using "$DTA\temp01.dta", force //Append with EMAs of the second chunk
			append using "$DTA\temp03.dta", force //Append with first chunk of data

*Delete duplicates ()
duplicates tag dia mes year hora cve_metro, g(a)
bysort hora dia mes year nombre a: gen aa = _n
drop if aa>1 & a==1
drop a aa nombre_EMA _merge nombre1 nombre2

*Dias are sometimes years and viceversa
gen change = dia if dia>31
replace dia=year if dia>31
replace year = change if year<2009
*Labels
label var SR "Solar Radiation"
label var Rh "Relative Humidity"
label var ATC "Average Temperature (Celsius)"
label var Rain "MM of rain in that hour"
label var AvgWSV "Average Wind Speed"
label var BP "Barometric Pressure"
label var nombre "Nombre de la estación (EMA o ESIME)"

save "$DTA/Temperatura 2010-2015 (RD)", replace

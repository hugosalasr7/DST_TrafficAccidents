/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Prepare ATUS database for the Differences in Differences estimations 
		- Data source: Accidentes de Tránsito Urbanos y Suburbanos (1997-2015)
		- Windows version
		- Worked on Stata 14
*******************************************************************************/

clear all
set more off 

*HSRs globals (Home)
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigacion y Docencia Economicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"

*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA"
global dta "$root/03 DTA"
global final "$root/03 DTA/00 Final DB"

***********************************************************************************
*********************************************************************************** This one is to only do reduce the tsfill and do it only to my subset of municipalities
**********I only keep the municipalities in the peninsula.*************************
***********************************************************************************
***********************************************************************************
*Metropolitan areas identifiers
import excel "$raw\ZonasMetropolitanas.xlsx", sheet("ZM socio") firstrow clear
keep D // Only keep municipality's code
drop in 1/5 // It is until the 6th observation that we have interesting info
rename D cve
gen metro=1 //All the municipalities from this database are from a metropolitan area
drop if cve== ""
save  "$dta/temp.dta", replace

		u "$dta/ATUS_PF.dta", clear
		keep if year >2013 & year<2016
		append using "$dta\mun_codes.dta"
		keep if cve_edo=="23" |cve_edo=="27" |cve_edo=="31" |cve_edo=="04" //I only keep municipalities in the Yucatán peninsula
		replace hora = 0 if year ==.
		replace dia = 1 if year ==.
		replace mes = 1 if year ==.
		replace diasemana =4  if year ==.
		replace year =2015  if year ==.
		*Collapse to count how many accidents happened in every municipality per day
		collapse (sum) accid heridos muertos atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos, by(cve mun edo year hora dia diasemana mes cve_edo DST)
		*Formatting date and time
		gen date = mdy(mes,dia,year)  
		format date %tdNN/DD/CCYY  
		gen time = hms(hora,00,00)  
		format time %tcHH:MM:SS  
		gen double datetime = date*24*60*60*1000 + time  
		format datetime %tcNN/DD/CCYY_HH:MM:SS  

***********************************************************************************
***********************************************************************************
*************Filling blanks and getting back a nice and clean database*************
***********************************************************************************
***********************************************************************************
*Fill blanks
drop if datetime ==.
encode cve, gen(cve2)
duplicates tag datetime cve2, g(a)
drop if a
xtset cve2 datetime, delta(1 hours)
tsfill, full

	*Fix what tsfill messed up
	foreach var of varlist accid heridos muertos atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos{
		replace `var'= 0 if `var'==. //replace missings with zeros
	}
	foreach var of varlist pf_accid pf_heridos pf_muertos{
		replace `var'= . if year==2014 //in 2014, we do not have data of accidents in highways (PF) - therefore, they are all missings.
	}
	decode cve2, g(aa)
	replace cve = aa
	drop a aa mun edo DST cve_edo
	merge m:1 cve using "$dta\mun_codes.dta", nogen keep(3)

*Getting back hours
gen hour = hhC(datetime)
replace hour = hour + 1 
replace hour = 0 if hour == 24
replace hora = hour
*Getting back days/years/months
gen mes2 = month(dofc(datetime))
gen year2 = year(dofc(datetime))
gen dia2 = day(dofc(datetime))
replace dia = dia2
replace year = year2
replace mes = mes2
*Agrego dia de la semana
drop diasemana
merge m:1 dia mes year using "$dta\Días de la semana.dta"
keep if _merge==3
drop _merge mes2 year2 dia2 hour G date time

*Metropolitan areas
merge m:1 cve using "$dta/temp.dta"
replace metro = 0 if metro==.
drop if _merge==2
drop _merge
*Population
merge m:1 year cve using "$dta/pobINEGImun2.dta"
keep if _merge==3

			*******************************************************************
			*******************************************************************
			*************For Differences-in-Differences estimation*************
			*******************************************************************
			*******************************************************************
			rename DST DST_zone
			gen treated = (DST_zone == 3) //Dummy for our treated group (2 Quintana Roo)
			gen Feb2015 = 0 if year != 2015 //Dummy for  the time when our treated group is treated (2 Quintana Roo)
			replace Feb2015= 0 if year ==2015 & mes == 1
			replace Feb2015= 1 if year == 2015 & Feb2015== .
			//Borramos todo antes del 25 de Octubre (antes de esto hay cambio de horario otra vez)
			drop if year == 2014 & mes<10
			drop if year==2014 & mes==10 & dia<24
			*Borramos todo después del 4 de abril (empieza el HDV en todo menos Quintana Roo)
			drop if year == 2015 & mes>4
			drop if year == 2015 & mes==4 & dia >4
					*Pegar con variables meteorologicas
					drop _merge
					merge 1:1 year hora dia mes cve using "$dta\Clima (SMN)\Temperatura 2014-2015 (DID).dta"
					drop if _merge==2
					sort cve datetime
					*Intrapolate the data
					foreach var of varlist SR Rain Rh ATC AvgWSV BP{
						bysort cve: ipolate `var' datetime, g(`var'_ipo)
						replace `var' = `var'_ipo
						drop `var'_ipo
					}
*Labels
label var DST_zone "Zona del Horario de Verano"
label var pf_accid "(SOLO PF) # de accidentes"
label var pf_heridos "(SOLO PF) # de heridos"
label var pf_muertos "(SOLO PF) # de muertos"
label var atus_accid "(SOLO ATUS) # de accidentes"
label var atus_heridos "(SOLO ATUS) # de heridos"
label var atus_muertos "(SOLO ATUS) # de muertos"
label var muertos "# de muertos totales"
label var heridos "# de heridos totales"
label var accid "# de accidentes totales"
label var DST "1 = Horario de Verano , 0 = Horario estandar" 
label var date "Date"
label var datetime "Date and Time"
label var datetime "Fecha y hora"
label var edo "Entidad federativa"
label var cve_mun "Clave de municipio"
label var mun "Municipio"
label var cve_edo "Clave de Entidad Federativa"
label var metro "Pertenece o no a una zona metropolitana"
label var treated "1 para el grupo tratado (Quintana Roo)"
label var Feb2015 "1 para cualquier momento despues de implementacion de ley (postFebrero)"
label var diasemana "Dia de la semana (Lunes - Viernes)"

drop count big2 big _merge count
order cve cve2 cve_mun cve_edo mun edo year mes dia hora datetime

save "$FINAL/ATUS_DID1_QRoo.dta", replace

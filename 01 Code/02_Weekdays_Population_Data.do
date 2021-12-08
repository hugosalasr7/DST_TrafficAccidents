/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Clean and prepare two databases: SEMANA (identifies each day of 
		  with its correspondent day of the week) and pobINEGI (has information 
		  of population per municipality)
		- Data source: SEMANA.XLSX and pobINEGImun.dta
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear
set more off 

*HSRs globals (Home)
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"

*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA"
global dta "$root/03 DTA"

********************************************************************************/
import excel "$raw/Días de la semana.xlsx", allstring clear
split A, p("/")
rename A1 mes 
rename A2 dia
rename A3 year
rename C count
replace B = "sabado" if B=="sábado"
replace B = "miercoles" if B=="miércoles"

foreach var of varlist dia mes year count{
destring `var' , replace
}
encode B, g(diasemana)
drop A B
label var mes "Mes del año"
label var dia "Día del mes"
label var diasemana "Día de la semana (lunes-viernes)"
label var year "Año" 
label var count "Contador"
save "$dta/Días de la semana.dta", replace

			u "$dta/pobINEGImun.dta", clear
			drop if year > 2015
			collapse (sum) pob, by(cvegeo year)
			rename cvegeo cve
			bysort cve: egen big = mean(pob)
			gen big2 = (big>50000)
			label var year "Año"
			label var cve "Clave Única Municipal y Estatal"
			label var big "Media poblacional 2010-2015"
			label var big2 "Media poblacional>50,000"
			label var pob "Población por año"
			save "$dta/pobINEGImun2.dta", replace

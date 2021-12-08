/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Systematically imports and gathers Policía Federal's data 
		- Data source: Accidentes de Tránsito Urbanos y Suburbanos (1997-2015)
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear all
set more off 

*HSRs globals (Home)
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"

*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA\05 Accidentes (Policía Federal)"
global dta "$root/03 DTA"

********************************************************************************/
import delimited "$raw/Accidentes 2015_PF.csv", clear
drop in 1/3
rename (datosgenerales v3 v4 v5 v6 v9 victimas v11 v12) (edo mun time fecha diasemana carretera victimas muertos heridos)
drop id v13-v215 v7 v8
gen year=2015
save "$dta/temp.dta", replace

import delimited "$raw/Accidentes 2016_PF.csv", clear
drop in 1/22
drop v1 v14-v234 v8 v9 v6
rename (datosgenerales v3 v4 v5 v7 v10 v11 v12 v13) (edo mun time fecha diasemana carretera victimas muertos heridos)
gen year=2016
append using "$dta/temp.dta"
save "$dta/temp.dta", replace

		split time, p(":")
		split fecha, p("/")
		split time3, p(" ")
		rename (time1 time2 fecha1 fecha2 time32) (hora minutos dia mes ampm)
		destring hora , replace
		destring minutos, replace
		destring mes, replace
		destring dia, replace
		replace hora = hora + 12 if ampm=="p.m."
		replace hora=0 if hora==12
		replace hora= 12 if hora==24 
		replace mun = subinstr(mun, "  ", "",.)
		
		drop time fecha fecha3 time3 time31 victimas

		label var mes "Mes de la informacion"
		label var year "Año del accidente"
		label var hora "Hora del accidente"
		label var minutos "Minuto del accidente"
		label var dia "Dia del mes del accidente"
		label var diasemana "Dia de la semana en que ocurrio el accidente (Lunes a viernes)"
		label var muertos "# total de muertos"
		label var heridos "# total de heridos"
		label var ampm "¿Sucedió en la mañana o tarde?"
		label var carretera "Carretera donde sucedió el accidente"
		label var edo "Entidad Federativa"
		label var mun "Municipio" 
		compress
		save "$dta/temp.dta", replace
		
*****************************************************************************
*Generate state codes so it could merge with other databases*****************
*****************************************************************************
collapse (sum) dia, by(edo)	
gen cve_edo = ""
replace cve_edo="01" if edo=="AGUASCALIENTES"
replace cve_edo="02" if edo=="BAJA CALIFORNIA"
replace cve_edo="03" if edo=="BAJA CALIFORNIA SUR"
replace cve_edo="04" if edo=="CAMPECHE"
replace cve_edo="07" if edo=="CHIAPAS"
replace cve_edo="08" if edo=="CHIHUAHUA"
replace cve_edo="09" if edo=="CIUDAD DE MEXICO"
replace cve_edo="05" if edo=="COAHUILA"
replace cve_edo="05" if edo=="COAHUILA "
replace cve_edo="06" if edo=="COLIMA"
replace cve_edo="06" if edo=="COLIMA "
replace cve_edo="09" if edo=="DISTRITO FEDERAL"
replace cve_edo="10" if edo=="DURANGO"
replace cve_edo="15" if edo=="ESTADO DE MEXICO"
replace cve_edo="11" if edo=="GUANAJUATO"
replace cve_edo="12" if edo=="GUERRERO"
replace cve_edo="13" if edo=="HIDALGO"
replace cve_edo="14" if edo=="JALISCO"
replace cve_edo="16" if edo=="MICHOACAN"
replace cve_edo="17" if edo=="MORELOS"
replace cve_edo="18" if edo=="NAYARIT"
replace cve_edo="19" if edo=="NUEVO LEON"
replace cve_edo="20" if edo=="OAXACA"
replace cve_edo="21" if edo=="PUEBLA"
replace cve_edo="21" if edo=="PUEBLA "
replace cve_edo="22" if edo=="QUERETARO"
replace cve_edo="23" if edo=="QUINTANA ROO"
replace cve_edo="24" if edo=="SAN LUIS POTOSI"
replace cve_edo="25" if edo=="SINALOA"
replace cve_edo="26" if edo=="SONORA"
replace cve_edo="27" if edo=="TABASCO"
replace cve_edo="28" if edo=="TAMAULIPAS"
replace cve_edo="29" if edo=="TLAXCALA"
replace cve_edo="30" if edo=="VERACRUZ"
replace cve_edo="31" if edo=="YUCATAN"
replace cve_edo="31" if edo=="YUCATAN "
replace cve_edo="32" if edo=="ZACATECAS"
replace cve_edo="32" if edo=="zacatecas"
label var cve_edo "Código Único Estatal"
drop dia

merge 1:m edo using "$dta/temp.dta", nogen
		drop if mun == "SD" | mun == "S/D" | mun == "BAJACALIFORNIA" | mun == "ESTADODEMEXICO" //We can't identify these crashes
		replace cve_edo = "32" if mun=="ELTEULDEGONZALEZORTEGA"
		replace cve_edo = "14" if mun=="HUEJUCAR(ZAC)"
		replace cve_edo = "32" if mun=="TEULDEGONZALEZORTEGA"
		replace cve_edo = "15" if mun=="TLALNEPANTLADEBAZ"
		replace cve_edo = "32" if mun=="TLALTENANGO"
		replace cve_edo = "32" if mun=="TLALTENANGODESANCHEZROMAN(ZAC)"
		replace cve_edo = "32" if mun=="TRINIDADGARCIADELACADENA"
		replace cve_edo = "13" if mun=="TULA" & cve_edo=="15"
		replace cve_edo = "" if mun=="SONORA"
		replace cve_edo = "" if mun=="QUINTANAROO"
		replace cve_edo = "" if mun=="NUEVOMORELOS"
		replace cve_edo = "15" if mun=="ECATEPEC"
		replace cve_edo = "15" if mun=="NAUCALPANDEJUAREZ"
		replace cve_edo = "15" if mun=="TECAMAC"
		replace cve_edo = "15" if mun=="TEOTIHUACAN"
		replace cve_edo = "15" if mun=="TEXCOCO"
		replace cve_edo = "15" if mun=="OMITLANDEJUAREZ"
		replace cve_edo = "15" if mun=="HUEYPOXTLA"
		replace cve_edo = "32" if mun=="TLALTENANGODESANCHEZROMAN"
replace mun = subinstr(mun, " ", "", .) //Remove all spaces from mun variable
save "$dta/temp.dta", replace

			*****************************************************************************
			*Generate mun codes so it could merge with other databases*******************
			*****************************************************************************
			import excel "$raw/CVE_MUN_PF.xlsx", clear firstrow sheet("Sheet2")
			replace mun = subinstr(mun, " ", "", .)  //Remove all spaces from mun variable
			gen cve_edo = substr(cve, 1,2)
			bysort cve_edo mun: drop if _n!=1
			save "$dta/temp2.dta", replace //This is the document that was generated manually to assign one code to each municipality

			u "$dta/temp.dta", clear
			replace mun = subinstr(mun, " ", "", .) //Remove all spaces from mun variable
			gen n =1 
			collapse (sum) n, by(mun cve_edo)
			bysort cve_edo mun: drop if _n!=1 // Remove all repeated obs
			
			merge 1:1 mun cve_edo using "$dta/temp2.dta"
			drop if cve == ""
			keep if _merge==3
			
			merge 1:m mun cve_edo using "$dta/temp.dta", keep(3) nogen
			drop mun n _merge edo
			drop if hora==. | mes==. | dia==. | hora==.   //Eliminamos las obs sin datos de fecha o hora
			merge m:1 cve using "$dta/mun_codes.dta", gen(_merge2)
			gen accid = (_merge == 3) // Gen 1 for each accident
			drop _merge _merge2 G
				label var cve "Código único Municipal y Estatal"
				label var mun "Municipio"
				label var cve_mun "Código Único Municipal"
				label var accid "1 si hubo un accidente en ese municipio en ese momento"
			
*****************************************************************************
*Format**********************************************************************
*****************************************************************************
replace diasemana = "1" if diasemana=="LUNES"
replace diasemana = "2" if diasemana=="MARTES"| diasemana=="MARTES "
replace diasemana = "3" if diasemana=="MIERCOLES" 
replace diasemana = "4" if diasemana=="JUEVES" | diasemana=="JUEVES "
replace diasemana = "5" if diasemana=="VIERNES" | diasemana=="viernes"
replace diasemana = "6" if diasemana=="SABADO"
replace diasemana = "7" if diasemana=="DOMINGO"
destring diasemana, replace
label define label3 1 "Lunes" 2 "Martes" 3 "Miercoles" 4 "Jueves" 5 "Viernes" 6 "Sabado" 7 "Domingo"
label values diasemana label3

order cve cve_mun cve_edo mun edo year hora minutos dia diasemana mes
sort cve year
			
compress
save "$dta/PF_Accidentes.dta", replace

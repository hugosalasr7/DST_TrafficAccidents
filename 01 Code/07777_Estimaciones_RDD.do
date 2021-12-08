/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Estimates the three regression models
		- Data source: Cleaned ATUS, cleaned PF
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear all
set more off 

*HSRs globals (Home)
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"
*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA"
global dta "$root/03 DTA"
global fig "$root/04 Figures"

****************************************************
****************************************************
***********Transition towards DST*******************
****************************************************
****************************************************
u "$dta/ATUS_PF_RD", clear
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime
global control "SR Rain Rh ATC AvgWSV BP"

**********************ATUS
foreach var of varlist atus_accid atus_heridos atus_muertos{
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control, fe cluster(cve2) robust
	est store `var'
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control if year==2011 & DST_zone==1 , fe cluster(cve2) robust
	est store `var'_2011
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control if year==2014 & DST_zone==1 , fe cluster(cve2) robust
	est store `var'_2014
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control if year==2016 & DST_zone==1 , fe cluster(cve2) robust
	est store `var'_2016
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control if DST_zone==2 , fe cluster(cve2) robust
	est store `var'_2
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control if DST_zone==1 , fe cluster(cve2) robust
	est store `var'_1	
}

*HDV y HDV fronterizo en todos los años
esttab atus_accid atus_heridos atus_muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p scalars()
*Sólo HDV en todos los años
esttab atus_accid_1 atus_heridos_1 atus_muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
*Sólo HDV Fronterizo en todos los años
esttab atus_accid_2 atus_heridos_2 atus_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
*Sólo HDV separando 2011, 2014 y 2016
esttab atus_accid_2011 atus_heridos_2011 atus_muertos_2011 atus_accid_2014 atus_heridos_2014 atus_muertos_2014 atus_accid_2016 atus_heridos_2016 atus_muertos_2016, star(* 0.10 ** 0.05 *** 0.01) se
*Export all regressions
esttab atus_accid atus_heridos atus_muertos atus_accid_1 atus_heridos_1 atus_muertos_1 atus_accid_2 atus_heridos_2 atus_muertos_2 atus_accid_2011 atus_heridos_2011 atus_muertos_2011 atus_accid_2014 atus_heridos_2014 atus_muertos_2014 atus_accid_2016 atus_heridos_2016 atus_muertos_2016 using "$fig/RDD_ATUS_hora.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)
		
		**********************ATUS
		foreach var of varlist pf_accid pf_heridos pf_muertos{
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if year == 2016, fe cluster(cve2) robust
			est store `var'
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==2 & year==2016 , fe cluster(cve2) robust
			est store `var'_2
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==1 & year==2016, fe cluster(cve2) robust
			est store `var'_1	
		}
		**********************PF
		*HDV y HDV fronterizo en todos los años
		esttab pf_accid pf_heridos pf_muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p scalars()
		*Sólo HDV en todos los años
		esttab pf_accid_1 pf_heridos_1 pf_muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Sólo HDV Fronterizo en todos los años
		esttab pf_accid_2 pf_heridos_2 pf_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Export all regressions
		esttab pf_accid pf_heridos pf_muertos pf_accid_1 pf_heridos_1 pf_muertos_1 pf_accid_2 pf_heridos_2 pf_muertos_2 using "$fig/RDD_PF_hora.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)
		
****************************************************
***********Collapse to obtain daily data************
****************************************************
sort cve2 datetime
replace DST = 1 if hora<3 & diasemana==1 & DST[_n+4]==1 //We'll count the first day of DST although there are three hours in which we still had Normal time
collapse (mean) SR Rh ATC AvgWSV BP (sum) Rain atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos, by(diasemana DST_zone year cve mes dia DST cve2)
sort cve year mes dia
	by cve year:gen runningv = _n
	replace runningv = runningv - 8
	replace runningv= runningv+1 if runningv>=0 // No 0 for this model, it skips from -1 to 1.
	drop if runningv==8 //We drop the 8th day
gen date = mdy(mes, dia, year)
xtset cve2 date
gen interaction = DST*runningv

foreach var of varlist atus_accid atus_heridos atus_muertos{
	quietly xtreg `var' DST runningv interaction i.diasemana i.year $control, fe cluster(cve2) robust
	est store `var'
	quietly xtreg `var' DST runningv interaction i.diasemana i.year $control if year==2011 & DST_zone==1, fe cluster(cve2) robust
	est store `var'_2011
	quietly xtreg `var' DST runningv interaction i.diasemana i.year $control if year==2014 & DST_zone==1, fe cluster(cve2) robust
	est store `var'_2014
	quietly xtreg `var' DST runningv interaction i.diasemana i.year $control if year==2016 & DST_zone==1, fe cluster(cve2) robust
	est store `var'_2016
	quietly xtreg `var' DST runningv interaction i.diasemana i.year $control if DST_zone==2, fe cluster(cve2) robust
	est store `var'_2
	quietly xtreg `var' DST runningv interaction i.diasemana i.year $control if DST_zone==1, fe cluster(cve2) robust
	est store `var'_1
}

*HDV y HDV fronterizo en todos los años
esttab atus_accid atus_heridos atus_muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
*Sólo HDV en todos los años
esttab atus_accid_1 atus_heridos_1 atus_muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
*Sólo HDV Fronterizo en todos los años
esttab atus_accid_2  atus_heridos_2 atus_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
*Sólo HDV separando 2011, 2014 and 2016
esttab atus_accid_2011 atus_heridos_2011 atus_muertos_2011 atus_accid_2014 atus_heridos_2014 atus_muertos_2014 atus_accid_2016 atus_heridos_2016 atus_muertos_2016, star(* 0.10 ** 0.05 *** 0.01) 

		foreach var of varlist pf_accid pf_heridos pf_muertos {
			quietly xtreg `var' DST runningv interaction i.diasemana $control if year==2016, fe cluster(cve2) robust
			est store `var'
			quietly xtreg `var' DST runningv interaction i.diasemana $control if DST_zone==2 & year==2016, fe cluster(cve2) robust
			est store `var'_2
			quietly xtreg `var' DST runningv interaction i.diasemana $control if DST_zone==1 & year==2016, fe cluster(cve2) robust
			est store `var'_1
		}
		
		*HDV y HDV fronterizo en todos los años
		esttab pf_accid pf_heridos pf_muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Sólo HDV en todos los años
		esttab pf_accid_1 pf_heridos_1 pf_muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Sólo HDV Fronterizo en todos los años
		esttab pf_accid_2 pf_heridos_2 pf_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p

****************************************************
****************************************************
***********Transition out of DST********************
****************************************************
****************************************************		
u "$dta/ATUS_PF_RD2.dta", clear
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime
global control "SR Rain Rh ATC AvgWSV BP"	
gen ddm2 = (mes==11) & (dia==2)
gen ddm = (mes==11) & (dia==1)	
		
**********************ATUS
foreach var of varlist atus_accid atus_heridos atus_muertos{
	quietly xtreg `var' DST runningv interaction ddm ddm2 i.hora i.diasemana i.year $control, fe cluster(cve2) robust
	est store `var'
	quietly xtreg `var' DST runningv interaction ddm ddm2 i.hora i.diasemana i.year $control if DST_zone==2 , fe cluster(cve2) robust
	est store `var'_2
	quietly xtreg `var' DST runningv interaction ddm ddm2 i.hora i.diasemana i.year $control if DST_zone==1 , fe cluster(cve2) robust
	est store `var'_1	
}

*HDV y HDV fronterizo en todos los años
esttab atus_accid atus_heridos atus_muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p scalars()
*Sólo HDV en todos los años
esttab atus_accid_1 atus_heridos_1 atus_muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
*Sólo HDV Fronterizo en todos los años
esttab atus_accid_2 atus_heridos_2 atus_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
*Export all regressions
esttab atus_accid atus_heridos atus_muertos atus_accid_1 atus_heridos_1 atus_muertos_1 atus_accid_2 atus_heridos_2 atus_muertos_2 atus_accid_2011 atus_heridos_2011 atus_muertos_2011 atus_accid_2014 atus_heridos_2014 atus_muertos_2014 atus_accid_2016 atus_heridos_2016 atus_muertos_2016 using "$fig/RDD_ATUS_hora.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)
		
		**********************ATUS
		foreach var of varlist pf_accid pf_heridos pf_muertos{
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if year == 2016, fe cluster(cve2) robust
			est store `var'
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==2 & year==2016 , fe cluster(cve2) robust
			est store `var'_2
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==1 & year==2016, fe cluster(cve2) robust
			est store `var'_1	
		}
		**********************PF
		*HDV y HDV fronterizo en todos los años
		esttab pf_accid pf_heridos pf_muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p scalars()
		*Sólo HDV en todos los años
		esttab pf_accid_1 pf_heridos_1 pf_muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Sólo HDV Fronterizo en todos los años
		esttab pf_accid_2 pf_heridos_2 pf_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Export all regressions
		esttab pf_accid pf_heridos pf_muertos pf_accid_1 pf_heridos_1 pf_muertos_1 pf_accid_2 pf_heridos_2 pf_muertos_2 using "$fig/RDD_PF_hora.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)
		
		
		

		
		asddddddddddddddddddddddddddddddddddddd
		
		
		
		
		
		
		
		
		
		
		
***************Efectos por hora***********************
xtreg atus_accid DST#hora runningv interaction i.diasemana i.year i.hora $control, fe cluster(cve2) robust
mat acc = r(table)'
mat acc = acc[25..48,1],acc[25..48,2]
xtreg muertos DST#hora runningv interaction i.diasemana i.year i.hora $control, fe cluster(cve2) robust
mat muer = r(table)'
mat muer = muer[25..48,1],muer[25..48,2]

gen ae =.
gen ase = . 
gen me = .
gen mse = .
gen count = .
forvalues x= 1/24{
	replace ae = acc[`x',1] in `x'
	replace ase = acc[`x',2] in `x'
	replace me = muer[`x',1] in `x'
	replace mse = muer[`x',2] in `x'
	replace count = `x'-1 in `x'
}

gen ahigh = ase*1.96+ ae
gen alow =  ae - ase*1.96
gen mhigh = mse*1.96+ me
gen mlow = me-mse*1.96

set scheme s1color
graph drop _all
twoway (bar ae count, barwidth(0.8) col(edkblue)) (rcap ahigh alow count, col(gs5)), xlab(0(2)23) ///
xtitle("") subtitle("") ytitle("Accidentes totales") ///
legend(order(2) label(2 "IC de 95%") position(4) ring(0)) name(s2)
twoway (bar me count, barwidth(0.8) col(black)) (rcap mhigh mlow count, col(gs5)), xlab(0(2)23) ///
xtitle("") subtitle("") ytitle("Muertos") ///
legend(order(2) label(2 "IC de 95%") position(4) ring(0)) name(s1)
graph combine s2 s1, subtitle("Regresión Discontinua") title("Efecto del HDV por hora del día")
graph display, xsize(20) ysize(10)
graph export "$fig/efectosph.png", width(4000) replace


****************************************************
**************Robustez******************************
****************************************************
u "$dta/ATUS_RD", clear
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime
global control "SR Rain Rh ATC AvgWSV BP"

mat CS=J(100,5,0)

gen chosen = .

local h=167
while `h'>=69 {
	replace chosen = 0
	replace chosen = 1 if runningv < `h' & runningv >-`h'
	xtreg accidTOT DST runningv interaction i.hora i.diasemana i.year $control if chosen, fe cluster(cve2) robust
	mat temp = r(table)'
	mat CS[-`h'+168,1]= `h'
	mat CS[-`h'+168,2]= temp[1,1]
	mat CS[-`h'+168,3]= temp[1,4]
	xtreg muerTOT DST runningv interaction i.hora i.diasemana i.year $control if chosen, fe cluster(cve2) robust
	mat temp = r(table)'
	mat CS[-`h'+168,4]= temp[1,1]
	mat CS[-`h'+168,5]= temp[1,4]
	local h=`h'-1
}


putexcel A1=matrix(CS) using "$fig/robust.xls" , replace


****************************************************
****************************************************
****************************************************
***********Differences-in-Differences***************
****************************************************
****************************************************
****************************************************

u "$dta/ATUS_DID", clear
set more off
gen interaction = treated*Feb2015
gen firstweek_int = (mes==2) & (dia<8) & (cve_edo=="23")
gen firstweek = (mes==2) & (dia<8) 

global control "SR Rain Rh ATC AvgWSV BP"
*Formatting date and time
gen date = mdy(mes,dia,year)  

gen dtime = string(date) +"_" +string(hora)
encode dtime, gen(dtime2)
xtset cve2 datetime

foreach var of varlist accidTOT muerTOT {
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora i.cve2 $control, robust cluster(cve2)
	est store `var'
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora i.cve2 $control if metro ,  robust cluster(cve2)
	est store `var'_met
}
****************************************************
**************Con datos por hora********************
****************************************************
*Todos los municipios
esttab accidTOT muerTOT,  star(* 0.10 ** 0.05 *** 0.01) p
*Sólo zonas metropolitanas
esttab accidTOT muerTOT accidTOT_met muerTOT_met,  star(* 0.10 ** 0.05 *** 0.01) p
esttab accidTOT muerTOT accidTOT_met muerTOT_met using "$fig/DDh.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)

*************************************************************************
*Efectos por hora
**************************************************************************
set more off
reg accidTOT Feb2015 treated interaction#hora firstweek firstweek_int i.date i.hora i.cve2 $control, robust cluster(cve2)
mat acc = r(table)'
mat acc = acc[27..50,1],acc[27..50,2]
reg muerTOT Feb2015 treated interaction#hora firstweek firstweek_int i.date i.hora i.cve2 $control, robust cluster(cve2)
mat muer = r(table)'
mat muer = muer[27..50,1],muer[27..50,2]

gen ae =.
gen ase = . 
gen me = .
gen mse = .
gen count = .
forvalues x= 1/24{
	replace ae = acc[`x',1] in `x'
	replace ase = acc[`x',2] in `x'
	replace me = muer[`x',1] in `x'
	replace mse = muer[`x',2] in `x'
	replace count = `x'-1 in `x'
}

gen ahigh = ase*1.96+ ae
gen alow =  ae - ase*1.96
gen mhigh = mse*1.96+ me
gen mlow = me-mse*1.96

set scheme s1color
graph drop _all
twoway (bar ae count, barwidth(0.8) col(cranberry)) (rcap ahigh alow count, col(gs5)), xlab(0(2)23) ///
xtitle("") subtitle("") ytitle("Accidentes totales") ///
legend(order(2) label(2 "IC de 95%") position(4) ring(0)) name(s2)
twoway (bar me count, barwidth(0.8) col(black)) (rcap mhigh mlow count, col(gs5)), xlab(0(2)23) ///
xtitle("") subtitle("") ytitle("Muertos") ///
legend(order(2) label(2 "IC de 95%") position(4) ring(0)) name(s1)
graph combine s2 s1, subtitle("Diferencias en Diferencias para todo el periodo") title("Efecto del HDV por hora del día")
graph display, xsize(20) ysize(10)
graph export "$fig/efectosphDD.png", width(4000) replace


drop ae ase me mse ahigh alow mhigh mlow count
set more off
reg accidTOT Feb2015 treated interaction firstweek firstweek_int#hora i.date i.hora i.cve2 $control, robust cluster(cve2)
mat acc = r(table)'
mat acc = acc[29..52,1],acc[29..52,2]
reg muerTOT Feb2015 treated interaction firstweek firstweek_int#hora i.date i.hora i.cve2 $control, robust cluster(cve2)
mat muer = r(table)'
mat muer = muer[29..52,1],muer[29..52,2]

gen ae =.
gen ase = . 
gen me = .
gen mse = .
gen count = .
forvalues x= 1/24{
	replace ae = acc[`x',1] in `x'
	replace ase = acc[`x',2] in `x'
	replace me = muer[`x',1] in `x'
	replace mse = muer[`x',2] in `x'
	replace count = `x'-1 in `x'
}

gen ahigh = ase*1.96+ ae
gen alow =  ae - ase*1.96
gen mhigh = mse*1.96+ me
gen mlow = me-mse*1.96

set scheme s1color
graph drop _all
twoway (bar ae count, barwidth(0.8) col(maroon)) (rcap ahigh alow count, col(gs5)), xlab(0(2)23) ///
xtitle("") subtitle("") ytitle("Accidentes totales") ///
legend(order(2) label(2 "IC de 95%") position(4) ring(0)) name(s2)
twoway (bar me count if me<0, barwidth(0.8) col(black)) (rcap mhigh mlow count if me<0, col(gs5)), xlab(0(2)23) ///
xtitle("") subtitle("") ytitle("Muertos") yscale(r(-0.003 0)) ///
legend(order(2) label(2 "IC de 95%") position(4) ring(0)) name(s1)
graph combine s2 s1, subtitle("Diferencias en Diferencias para la primera semana") title("Efecto del HDV por hora del día")
graph display, xsize(20) ysize(10)
graph export "$fig/efectosphDD2.png", width(4000) replace

*****************************


drop if year==2014
drop if mes==1 & dia<16
drop if mes==4
drop if mes==3 & dia>20
foreach var of varlist accidTOT muerTOT {
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora $control, robust cluster(cve2)
	est store `var'
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora $control if metro, robust cluster(cve2)
	est store `var'_met
}
esttab accidTOT muerTOT accidTOT_met muerTOT_met using "$fig/DDh_rob.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)

u "$dta/ATUS_DID", clear
set more off
gen interaction = treated*Feb2015
gen firstweek_int = (mes==2) & (dia<8) & (cve_edo=="23")
gen firstweek = (mes==2) & (dia<8) 

collapse (sum) Rain accidTOT herTOT muerTOT (mean)firstweek firstweek_int SR Rh ATC AvgWSV BP , by(diasemana dia metro mes Feb2015 interaction dia cve2 treated year)
gen date = mdy(mes, dia, year)
xtset cve2 date


foreach var of varlist accidTOT muerTOT {
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.cve2 $control , cluster(cve2) robust
	est store `var'
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.cve2 $control  if metro, cluster(cve2) robust
	est store `var'_met
}

****************************************************
**************Con datos por dia*********************
****************************************************
*Todos los municipios
esttab accidTOT muerTOT,  star(* 0.10 ** 0.05 *** 0.01)
*Sólo zonas metropolitanas
esttab accidTOT_met  muerTOT_met,  star(* 0.10 ** 0.05 *** 0.01) p

esttab accidTOT muerTOT accidTOT_met muerTOT_met using "$fig/DDd.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)

/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Estimates the Differences in Differences Model
		- Data source: Cleaned ATUS, cleaned PF
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear all
set more off 

*HSRs globals (Home)
global root "C:\Users\hugo3\OneDrive - Centro de Investigacion y Docencia Economicas CIDE\03 DST on Road Traffic Accidents\02 Data"
*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA"
global dta "$root/03 DTA"
global fig "$root/04 Figures"

****************************************************
***********Differences-in-Differences by hour*******
****************************************************
*From Oct/24/2014 to April/4/2015
u "$dta/ATUS_DID1_QRoo.dta", clear
set more off
gen interaction = treated*Feb2015
gen firstweek_int = (mes==2) & (dia<8) & (cve_edo=="23")
gen firstweek = (mes==2) & (dia<8) 

global control "SR Rain Rh ATC AvgWSV BP"

gen date = mdy(mes,dia,year)  //Formatting date and time
gen dtime = string(date) +"_" +string(hora)
encode dtime, gen(dtime2)
xtset cve2 datetime

foreach var of varlist atus_accid atus_heridos atus_muertos {
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora i.cve2 $control, robust cluster(cve2)
	est store `var'
	quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora i.cve2 $control if metro, robust cluster(cve2)
	est store `var'_met
}

*All municipalities
esttab atus_accid atus_heridos atus_muertos,  star(* 0.10 ** 0.05 *** 0.01) p
*Only metropolitan municipalities
esttab atus_accid_met atus_heridos_met atus_muertos_met,  star(* 0.10 ** 0.05 *** 0.01) p
esttab atus_accid atus_heridos atus_muertos atus_accid_met atus_heridos_met atus_muertos_met using "$fig/DnD_hora.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)
		
		*Only one week before and after - From Jan/25/2015 to February/7/2015
		gen oneweek = 1 if date<=20126 & date>=20113
		replace oneweek = 0 if oneweek==.
		
		foreach var of varlist atus_accid atus_heridos atus_muertos {
			quietly reg `var' Feb2015 treated interaction i.date i.hora i.cve2 $control  if oneweek==1, robust cluster(cve2)
			est store `var'
			quietly reg `var' Feb2015 treated interaction i.date i.hora i.cve2 $control if metro==1 & oneweek==1 ,  robust cluster(cve2) 
			est store `var'_met
		}

		*All municipalities
		esttab atus_accid atus_heridos atus_muertos,  star(* 0.10 ** 0.05 *** 0.01) p
		*Only metropolitan municipalities
		esttab atus_accid_met atus_heridos_met atus_muertos_met,  star(* 0.10 ** 0.05 *** 0.01) p
		esttab atus_accid atus_heridos atus_muertos atus_accid_met atus_heridos_met atus_muertos_met using "$fig/DnD_hora_1week.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)

				*Shorter period - From Jan/16/2015 to March/20/2015
				drop if year==2014
				drop if mes==1 & dia<16
				drop if mes==4
				drop if mes==3 & dia>20
				foreach var of varlist atus_accid atus_heridos atus_muertos {
					quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora i.cve2 $control, robust cluster(cve2) 
					est store `var'
					quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.hora i.cve2 $control if metro ,  robust cluster(cve2)
					est store `var'_met
				}
				*All municipalities
				esttab atus_accid atus_heridos atus_muertos,  star(* 0.10 ** 0.05 *** 0.01) p
				*Only metropolitan municipalities
				esttab atus_accid_met atus_heridos_met atus_muertos_met,  star(* 0.10 ** 0.05 *** 0.01) p
				esttab atus_accid atus_heridos atus_muertos atus_accid_met atus_heridos_met atus_muertos_met using "$fig/DnD_hora_short.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)

******************************
*Efectos por hora*************
******************************
set more off
xtreg atus_accid Feb2015 treated interaction#hora firstweek firstweek_int i.date i.hora $control, fe robust cluster(cve2)
mat acc = r(table)'
xtreg atus_muertos Feb2015 treated interaction#hora firstweek firstweek_int i.date i.hora $control, fe robust cluster(cve2)
mat muer = r(table)'
xtreg atus_accid Feb2015 treated interaction firstweek firstweek_int#hora  i.date i.hora $control, fe robust cluster(cve2)
mat acc_first = r(table)'
xtreg atus_muertos Feb2015 treated interaction#hora firstweek firstweek_int#hora  i.date i.hora $control, fe robust cluster(cve2)
mat muer_first = r(table)'

mat CS=J(24,9,0) // This is the matrix where we will output our data

forvalues x= 1/24{
	quietly mat CS[`x',1]= `x' 
	quietly mat CS[`x',2]= acc[`x'+26,1] //Store our coefficient of interest
	quietly mat CS[`x',3]= acc[`x'+26,4] //Store our coefficient of interest
	quietly mat CS[`x',4]= acc[`x'+26,5] //Store our coefficient of interest
	quietly mat CS[`x',5]= acc[`x'+26,6] //Store our coefficient of interest
	quietly mat CS[`x',6]= muer[`x'+26,1] //Store our coefficient of interest
	quietly mat CS[`x',7]= muer[`x'+26,4] //Store our coefficient of interest
	quietly mat CS[`x',8]= muer[`x'+26,5] //Store our coefficient of interest
	quietly mat CS[`x',9]= muer[`x'+26,6] //Store our coefficient of interest
}
matrix colnames CS = hour beta_a pv_a ci1_a ci2_a beta_m pv_m ci1_m ci2_m 
svmat CS, names(col) 

twoway (rbar ci1_a ci2_a hour, lcolor(white) fcolor(gs7)) ///
(scatter beta_a hour, mcolor(gs3) msymbol(s) msize(small))  ///
, xlabel(0(2)24) ylabel(-0.10(0.02)0.16) yline(0, lcol(red)) ///
xtitle("Hour of the day") ytitle("Estimated DST impact on accidents by hour") /// 
legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0)) 
graph export "$fig/DND_hour_accid.png", width(4000) replace
			
twoway (rbar ci1_m ci2_m hour, lcolor(white) fcolor(gs3)) ///
(scatter beta_m hour, mcolor(gs11) msymbol(s) msize(vsmall))  ///
, xlabel(0(2)24) ylabel(-0.012(0.004)0.016) yline(0, lcol(red)) ///
xtitle("Hour of the day") ytitle("Estimated DST impact on deaths by hour") /// 
legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0)) 
graph export "$fig/DND_hour_muert.png", width(4000) replace

		****************************************************
		***********Differences-in-Differences by day********
		****************************************************
		u "$dta/ATUS_DID1_QRoo.dta", clear
		set more off
		gen interaction = treated*Feb2015
		gen firstweek_int = (mes==2) & (dia<8) & (cve_edo=="23")
		gen firstweek = (mes==2) & (dia<8) 

		collapse (sum) Rain atus_accid atus_heridos atus_muertos (mean) firstweek firstweek_int SR Rh ATC AvgWSV BP , by(diasemana dia metro mes Feb2015 interaction dia cve2 treated year)

		gen date = mdy(mes, dia, year)
		xtset cve2 date

		foreach var of varlist atus_accid atus_heridos atus_muertos{
			quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.date i.cve2 $control , cluster(cve2) robust 
			est store `var'
			quietly reg `var' Feb2015 treated interaction firstweek firstweek_int i.cve2 i.date $control  if metro, cluster(cve2) robust
			est store `var'_met
		}

		*All municipalities
		esttab atus_accid atus_heridos atus_muertos,  star(* 0.10 ** 0.05 *** 0.01) p
		*Only metropolitan municipalities
		esttab atus_accid_met atus_heridos_met atus_muertos_met,  star(* 0.10 ** 0.05 *** 0.01) p
		esttab atus_accid atus_heridos atus_muertos atus_accid_met atus_heridos_met atus_muertos_met using "$fig/DnD_dia.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)

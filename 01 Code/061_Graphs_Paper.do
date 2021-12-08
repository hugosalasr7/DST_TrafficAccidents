/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Makes Figures out of all the databases.
		- Data source: All databases in these subfolders
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear 
set more off 
set scheme plotplainblind

*HSRs globals (Home)
global root "C:\Users\hugo3\OneDrive - Centro de Investigacion y Docencia Economicas CIDE\03 DST on Road Traffic Accidents\02 Data"

*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA"
global dta "$root/03 DTA"
global graph "$root/04 Figures"
global do "$root/02 Do Files"
global inegi "Fuente: Elaboración propia con datos de INEGI"

*******************************************************************************
*Figura 2: Accidentes por cada 100,000 habitantes entre países de la OCDE
import excel "$raw\Accidents in the world (WHO).xlsx", clear firstrow
graph drop _all

	gen total = subinstr(total_rtdr_2016, " ", "",.)
	destring total, replace
	tabstat total if OECD==1, stats(sum) // 102,974 deaths for OECD countries
	su rtdr_2016 if OECD==1 //min = 2.7; max = 13.1
	
graph bar rtdr_2016 if OECD== 1, ///
over(name2, sort(1) label(angle(45)))  bargap(50) ///
ytitle("Road traffic death rate (per 100,000)") ///
note("Source: Global Health Observatory Data Repository, World Health Organization (WHO)", size(small)) ///
legend(off) bar(1, lcolor(white)) ylabel(,grid gstyle(minor))
graph display, xsize(20) ysize(10)
graph export "$graph/bar_OECD.png", width(1000) replace

*******************************************************************************
*Figura 3: Accidentes y muertos por año en México - X axis = año
use "$dta/ATUS_old.dta", clear

collapse (sum) accid muertos, by(year)
drop if year == .
replace accid = accid/1000
replace muertos = muertos/1000

twoway (connect muertos year, yaxis(2) msymbol(O) msize(large))(connected accid year, yaxis(1) msymbol(S) msize(medlarge)) , ///
xlabel(1997(3)2018) ytitle("", axis(2)) ytitle("", axis(1))   ///
note("Source: National Institute of Statistics and Geography (INEGI)", size(small)) ///
legend(label(1 "Deaths (left axis)") label(2 "Accidents (right axis)") pos(6)) ///
title("") subtitle("") xtitle("") 
graph export "$graph/bar_ts_acc9716.png", width(4000) replace

*******************************************************************************
*Figura 4-5: Accidentes y muertos hora y tipo de horario - X axis = hora
use "$dta/ATUS_PF.dta", clear
keep if year==2015 //Keep 2015 only  
encode cve, gen(cve2) //Gen a string mun id
collapse (sum) accid muertos heridos , by(datetime date cve2 DST) // Keep only one obs per mun per hour
xtset cve2 datetime, delta(1 hours) //Prepare for tsfill
tsfill, full
		//Replace all missins with zeroes
		foreach var of varlist accid heridos muertos {
			replace `var'= 0 if `var'==. //All missings become 0
			gen `var'_dum = (`var'>0) // We create a dummy = 1 if an accident/death happened
		}
		//Get month, day, year variables back
		replace date = dofc(datetime)
		gen year = year(date)
		gen mes = month(date)
		gen dia = day(date)
		gen hora = hh(datetime)
		//Get DST zone back
		decode cve2, gen(cve)
		drop DST
		merge m:1 cve using "$dta/mun_codes.dta", keepusing(DST) keep(3)
		do "$do/Additional do-files/DST identifiers (for Graphs).do" //Generate a variable that indicates if we are in DST or not
		collapse (mean) accid muertos heridos accid_dum heridos_dum muertos_dum , by(DST hora)

*Accidentes promedio
twoway (connect accid hora if DST == 1, msymbol(D) msize(medium) lpattern(dash)) ///
(connect accid hora if DST == 0, msymbol(X) msize(medium)) , ///
ytitle("Average accidents by hour") xtitle("Time of the day") xlabel(0(3)24) ///
ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Daylight Saving Time") /// 
label(2 "Standard Time")) note("$inegi")  ///
note("Source: National Institute of Statistics and Geography (INEGI)", size(small)) 
graph export "$graph/ts_acc.png", width(4000) replace 

*Accidentes promedio
twoway (connect muertos hora if DST == 1, msymbol(D) msize(medium) lpattern(dash)) ///
(connect muertos hora if DST == 0, msymbol(X) msize(medium)) , ///
ytitle("Average deaths by hour") xtitle("Time of the day") xlabel(0(3)24) ///
ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Daylight Saving Time") /// 
label(2 "Standard Time")) note("$inegi")  ///
note("Source: National Institute of Statistics and Geography (INEGI)", size(small)) 
graph export "$graph/ts_muer.png", width(4000) replace 

*******************************************************************************
*Tabla 1: Balance between DST nad Standard Time
u "$dta/ATUS_PF_RD", clear
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
drop if cve_edo=="23" & year==2016 //QRoo in 2016 did not shift DST

orth_out SR Rain Rh ATC AvgWSV BP using "$graph/RDD_Balance_DST", by(DST) compare test vcount se replace

*This is just a suggestion that differences are still important even when controlling by all types of fixed effects.
*reg DST SR Rain Rh ATC AvgWSV BP i.hora i.diasemana i.year i.cve2,  cluster(cve2) robust

*********************************
*********************************
*************Figura RD***********
*********************************
*********************************
u "$dta/ATUS_PF_RD", clear
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime
global control "SR Rain Rh ATC AvgWSV BP"
drop if cve_edo=="23" & year==2016 //QRoo in 2016 did not shift DST

tab hora, gen(hora_dum)
tab diasemana, gen(diasemana_dum)
tab year, gen(year_dum)  

cmogram atus_accid runningv, controls(hora_dum* diasemana_dum* year_dum* $control) ///
cutpoint(0) scatter lfitci graphopts(msymbol(O) xlabel(-168(42)168)  ///
ytitle("Mean residual of road traffic deaths by municipality") ///
xtitle("Hours after the shift to DST") legend(label(3 "95% CI") ///
order(3 4) ring(0) position(5))) legend lineat(0) lfitopts(lcolor(gs7))
graph export "$graph/RDD_accid.png", width(4000) replace 

cmogram atus_muert runningv, controls(hora_dum* diasemana_dum* year_dum* $control) ///
cutpoint(0) scatter lfitci graphopts(msymbol(S) xlabel(-168(42)168)  ///
ytitle("Mean residual of road traffic deaths by municipality") ///
xtitle("Hours after the shift to DST") legend(label(3 "95% CI") ///
order(3 4) ring(0) position(5))) legend lineat(0) lfitopts(lcolor(gs7))
graph export "$graph/RDD_muer.png", width(4000) replace 

*********************************
****Continuity in covariates*****
*********************************
u "$dta/ATUS_PF_RD", clear
drop if cve_edo=="23" & year==2016 //QRoo in 2016 did not shift DST
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
*set scheme s1color
collapse (mean) SR Rh ATC AvgWSV BP Rain , by(runningv)
graph drop _all

twoway bar SR runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T1") ///
subtitle("Solar Radiation") ylabel(#3) xline(0, lcol(red)) col(gs1)

twoway bar Rh runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T2") ///
subtitle("Relative humidity") ylabel(#3) col(gs3) xline(0, lcol(red)) 

twoway bar ATC runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T3") ///
subtitle("Temperatura (C°)") ylabel(#3) xline(0, lcol(red)) col(gray) col(gs5)

twoway bar AvgWSV runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T4") ///
subtitle("Wind speed") ylabel(#3) xline(0, lcol(red)) col(gs7)

twoway bar BP runningv, xlabel(-168 -80 0 80 168) ytitle("")  name("T5") ///
subtitle("Barometric Pressure") ylabel(#3) xline(0, lcol(red)) col(gs9) xtitle("Hours after the shift to DST")

twoway bar Rain runningv if Rain < 0.5, xlabel(-168 -80 0 80 168) ytitle("") name("T6") ///
subtitle("Rainfall (mm)") ylabel(#3) col(gs1) xline(0, lcol(red)) xtitle("Hours after the shift to DST")

gr combine T1 T2 T3 T4 T5 T6, rows(3) title("") 
graph export "$graph/controls_RD.png", width(4000) replace

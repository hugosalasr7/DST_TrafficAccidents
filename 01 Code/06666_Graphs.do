/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Makes Figures out of all the databases.
		- Data source: All databases in these subfolders
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear 
set more off 
set scheme plottig

*HSRs globals (Home)
global root "C:\Users\hugo3\OneDrive - Centro de Investigacion y Docencia Economicas CIDE\03 DST on Road Traffic Accidents\02 Data"

*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA"
global dta "$root/03 DTA"
global graph "$root/04 Figures"
global do "$root/02 Do Files"
global inegi "Fuente: Elaboración propia con datos de INEGI"

*******************************************************************************
*Figura 1: Mortalidad por tipo de accidente
use "$dta/ATUS_PF.dta", clear
keep if year==2015
	*To generate the prob of having deaths in an accident - ATUS
	gen atus_accid_dum = 1 if atus_muertos>0
	replace atus_accid_dum = 0 if atus_muertos==0 & atus_accid!=0 
	*To generate the prob of having deaths in an accident - PF
	gen pf_accid_dum = 1 if pf_muertos>0
	replace pf_accid_dum = 0 if pf_muertos==0 & pf_accid!=0 
su atus_accid_dum
gen a = r(mean)*100 in 1
gen b = 100-r(mean)*100 in 1
su pf_accid_dum
replace a = r(mean)*100 in 2
replace b = 100-r(mean)*100 in 2
gen c = "Urbanos y suburbanos" in 1
replace c = "Carreteras" in 2
gen d = 0 in 1/2
label var a "% que causó muertes"
label var b "% que NO causó muertes"

graph bar (mean) b d a, over(c) stack ytitle("%") legend(order(1 3) ///
label(1 "% que causó muertes") label(3 "% que no causó muertes") pos(6)) ///
subtitle("2015") 
graph export "$graph/bar_mortality.png", width(4000) replace
*******************************************************************************
*Figura 2: Accidentes por cada 100,000 habitantes entre países de la OCDE
import excel "$raw\Accidents in the world (WHO).xlsx", clear firstrow
graph drop _all

graph bar rtdr if OECD== 1, ///
over(name2, sort(1) label(angle(45)))  bargap(50) ///
ytitle("Road traffic death rate (per 100,000 population)") ///
note("Source: Global Health Observatory Data Repository, World Health Organization (WHO)") ///
legend(off) bar(1, lcolor(white)) ylabel(,grid gstyle(minor))
graph display, xsize(20) ysize(10)
graph export "$graph/bar_OECD.png", width(4000) replace

*******************************************************************************
*Figura 3: Accidentes y muertos por año
use "$dta/ATUS.dta", clear

collapse (sum) accid muertos, by(year)
drop if year == .
replace accid = accid/1000
replace muertos = muertos/1000

twoway (bar muertos year, yaxis(2) )(connected accid year, yaxis(1) msize(large)) , ///
xlabel(1997(2)2016) ytitle("", axis(2)) ytitle("", axis(1))  note("$inegi")  ///
legend(label(1 "Muertos (eje izq.)") label(2 "Accidentes (eje der.)") pos(6)) ///
title("") subtitle("") xtitle("") 
graph export "$graph/bar_ts_acc9716.png", width(4000) replace

*******************************************************************************
*Figura 4: Accidentes y muertos hora y tipo de horario
use "$dta/ATUS_PF.dta", clear
keep if year==2015 //Keep 2015 only  
encode cve, gen(cve2) //Gen a string mun id
collapse (sum) accid muertos heridos atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos, by(datetime date cve2 DST) // Keep only one obs per mun per hour
xtset cve2 datetime, delta(1 hours) //Prepare for tsfill
tsfill, full
		//Replace all missins with zeroes
		foreach var of varlist accid heridos muertos atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos{
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
		collapse (mean) accid muertos heridos accid_dum heridos_dum muertos_dum pf_accid pf_heridos pf_muertos atus_accid atus_heridos atus_muertos atus_accid_dum atus_heridos_dum atus_muertos_dum pf_accid_dum pf_heridos_dum pf_muertos_dum, by(DST hora)

*Accidentes promedio
twoway (connect atus_accid hora if DST == 1, msymbol(D) lpattern(dash)) (connect atus_accid hora if DST == 0) , ///
ytitle("# de accidentes promedio") xtitle("Hora del día") xlabel(0(3)24) ///
ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Horario de Verano") /// 
label(2 "Horario Estándar")) note("$inegi") title("ATUS")
graph export "$graph/ts_acc.png", width(4000) replace 
		*Accidentes promedio (CARRETERA)
		twoway (connect pf_accid hora if DST == 1, msymbol(D) lpattern(dash)) (connect pf_accid hora if DST == 0) , ///
		ytitle("# de accidentes promedio") xtitle("Hora del día") xlabel(0(3)24) ///
		ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Horario de Verano") /// 
		label(2 "Horario Estándar")) note("$inegi") title("Carreteras")
		graph export "$graph/ts_acc_pf.png", width(4000) replace
*Probabilidad de un accidente
twoway (connect atus_accid_dum hora if DST == 1, msymbol(D) lpattern(dash)) (connect atus_accid_dum hora if DST == 0) , ///
ytitle("Probabilidad de que suceda un accidente") xtitle("Hora del día") xlabel(0(3)24) ///
ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Horario de Verano") /// 
label(2 "Horario Estándar")) note("$inegi") title("ATUS")
graph export "$graph/ts_prob_acc.png", width(4000) replace 
*Muertes promedio
twoway (connect atus_muertos hora if DST == 1, msymbol(D) lpattern(dash)) (connect atus_muertos hora if DST == 0) , ///
ytitle("# de muertos promedio") xtitle("Hora del día") xlabel(0(3)24) ///
ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Horario de Verano") /// 
label(2 "Horario Estándar")) note("$inegi") title("ATUS")
graph export "$graph/ts_muer.png", width(4000) replace 
		*Muertes promedio (CARRETERAS)
		twoway (connect pf_muertos hora if DST == 1, msymbol(D) lpattern(dash)) (connect pf_muertos hora if DST == 0) , ///
		ytitle("# de muertos promedio") xtitle("Hora del día") xlabel(0(3)24) ///
		ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Horario de Verano") /// 
		label(2 "Horario Estándar")) note("$inegi") title("Carreteras")
		graph export "$graph/ts_muer_pf.png", width(4000) replace 
*Probabilidad de un accidente
twoway (connect atus_muertos_dum hora if DST == 1, msymbol(D) lpattern(dash)) (connect atus_muertos_dum hora if DST == 0) , ///
ytitle("Probabilidad de que haya un muerto") xtitle("Hora del día") xlabel(0(3)24) ///
ylabel(, ) legend(bmargin(medium) ring(0) pos(11) label(1 "Horario de Verano") /// 
label(2 "Horario Estándar")) note("$inegi") title("ATUS")
graph export "$graph/ts_prob_muer.png", width(4000) replace 

*******************************************************************************
*Figura 5: Comparación de ciudades en frontera y sur
		*Metropolitan areas identifiers
		import excel "$raw\ZonasMetropolitanas.xlsx", sheet("ZM socio") firstrow clear
		drop in 1/5 //These are blanks
		rename (SUNIn D) (cve_metro cve)
		keep cve cve_metro
			gen metro=1
			label define metro 0 "NO es área metropolitana" 1 "Parte de alguna área metropolitana"
			label values metro metro
			label var cve_metro "Código único por zona metropolitana"
		drop if cve== "" //Drop blanks
		save  "$dta/temp.dta", replace

u "$dta/pobINEGImun2.dta", clear
merge m:1 cve using "$dta/mun_codes.dta", keep(3) nogen
merge m:1 cve using "$dta/temp.dta",  nogen keep(3 1)
keep if year==2015 //Only keep 2015
save  "$dta/temp.dta", replace
		
		*Solo estados del norte
		keep if edo=="Baja California" | edo=="Chihuahua" | edo=="Tamaulipas" | cve_edo=="19" |cve_edo=="05"
		orth_out pob, by(DST) compare test
		orth_out pob if metro==1, by(DST) compare test
		*Todos los estados
		u "$dta/temp.dta",clear
		drop if DST==4
		replace DST = 1 if DST!=2
		orth_out pob, by(DST) compare test
		orth_out pob if metro==1, by(DST) compare test
		
*********************************
*********************************
*************Figura RD***********
*********************************
*********************************
u "$dta/ATUS_RD", clear
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime

global control "SR Rain Rh ATC AvgWSV BP"
*Transición hacia el HDV
foreach var of varlist accidTOT muerTOT {
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control, fe cluster(cve2) robust
	predict u_`var'	
	mat b_`var' = r(table)'
}

drop if runningv> 168 | runningv<-168
keep if cve_edo == "09"

gen DST_ = b_accidTOT[1,1]
gen DSTsd_ = b_accidTOT[1,2]
gen rv_ = b_accidTOT[2,1]
gen rvsd_ = b_accidTOT[2,2]
gen int_ = b_accidTOT[3,1]
gen intsd_ = b_accidTOT[3,2]
gen cons_ = b_accidTOT[47,1]
gen conssd_ = b_accidTOT[47,2]

set seed 6
replace DST_= rnormal(DST_[1],DSTsd_[1])
replace rv_= rnormal(rv_[1],rvsd_[1])
replace int_= rnormal(int_[1],intsd_[1])
replace cons_= rnormal(cons_[1],conssd_[1])

gen first= runningv*rv_ + cons_ + .45 -.155
gen second= runningv*rv_ + cons_ +DST_+ runningv*int_ +.45 -.155

twoway (lfitci  first  runningv if runningv<0, lpattern(dash) color(gs11) )  ///
(lfitci  second  runningv if runningv>0, lpattern(dash) color(gs11)) ///
(lfit  first  runningv if runningv<0, lpattern(dash) color(navy) )  ///
(lfit  second  runningv if runningv>0, lpattern(dash) color(navy)) ///
(scatter u_accidTOT runningv if runningv<0  , color(cranberry)) ///
(scatter u_accidTOT runningv if runningv>0 , color(dkorange) ) ///
, xlabel(-168(56)168)  legend(off) subtitle("Distrito Federal 2011, 2014") /// 
xline(0,lcolor(black) lpattern(dash)) ytitle("Accidentes predichos") graphregion(color(white))  ///
xtitle("Horas después de la transición") note("Predicciones del Modelo 1 de la Tabla 2" "Áreas grises son intervalos de confianza de 95%") ///
text(.145 -80 "Horario Estándar", box fcolor(white)) text(.145 80 "Horario de Verano", box fcolor(white))
graph export "$graph/discA.png", width(4000) replace


replace DST_ = DST_*-51408
twoway (hist DST_ , gap(20) col(pink) percent) (hist DST_ , gap(25) col(pink) percent), /// 
ytitle("%") xtitle("Accidentes") legend(order(1) label(1 "Intervalo de Confianza de 95%")) ///
note("Predicciones del Modelo 1 de la Tabla 2")
graph export "$graph/predic.png", width(4000) replace

drop DST* rv* int* cons* first second

gen DST_ = b_muerTOT[1,1]
gen DSTsd_ = b_muerTOT[1,2]
gen rv_ = b_muerTOT[2,1]
gen rvsd_ = b_muerTOT[2,2]
gen int_ = b_muerTOT[3,1]
gen intsd_ = b_muerTOT[3,2]
gen cons_ = b_muerTOT[47,1]
gen conssd_ = b_muerTOT[47,2]

set seed 6
replace DST_= rnormal(DST_[1],DSTsd_[1])
replace rv_= rnormal(rv_[1],rvsd_[1])
replace int_= rnormal(int_[1],intsd_[1])
replace cons_= rnormal(cons_[1],conssd_[1])

gen first= runningv*rv_ + cons_ +.002-0.01-0.0002
gen second= runningv*rv_ + cons_ +DST_+ runningv*int_ +.002-0.01-0.0002

twoway (lfitci   first runningv if runningv<0, lpattern(dash) color(gs11) )  ///
(lfitci   second runningv if runningv>0, lpattern(dash) color(gs11) ) ///
(lfit   first runningv if runningv<0, lpattern(dash) color(navy) )  ///
(lfit   second runningv if runningv>0, lpattern(dash) color(navy) ) ///
(scatter u_muerTOT runningv if runningv<0 , color(emerald)) ///
(scatter u_muerTOT runningv if runningv>0 , color(sienna) ) ///
, xlabel(-168(56)168)  legend(off) subtitle("Distrito Federal 2011, 2014") /// 
xline(0,lcolor(black) lpattern(dash)) ytitle("Muertos predichos") ///
xtitle("Horas después de la transición") note("Predicciones de la estimación 2 de la Tabla 2" "Áreas grises son intervalos de confianza de 95%") ///
text(.0029 -80 "Horario Estándar", box fcolor(white)) text(.0029 80 "Horario de Verano", box fcolor(white))
graph export "$graph/discM.png", width(4000) replace


*********************************
*********************************
********Figura CONT RD***********
*********************************
*********************************
u "$dta/ATUS_RD", clear

set scheme s1color
kdensity runningv, xline(0, lpattern(dash) ) ytitle("Densidad") title("") ///
xtitle("Horas después de la transición") note("Ancho de banda = 7.36") 
graph export "$graph/densidad.png", width(4000) replace

collapse (mean) SR Rh ATC AvgWSV BP Rain , by(runningv)
graph drop _all

twoway bar SR runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T1") ///
subtitle("Radiación Solar") ylabel(#3) xline(0, lcol(red)) col(dkorange)

twoway bar Rh runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T2") ///
subtitle("Humedad Relativa") ylabel(#3) col(ebblue) xline(0, lcol(red)) 

twoway bar ATC runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T3") ///
subtitle("Temperatura") ylabel(#3) xline(0, lcol(red)) col(gray)

twoway bar AvgWSV runningv, xlabel(-168 -80 0 80 168) ytitle("") xtitle("") name("T4") ///
subtitle("Velocidad del viento") ylabel(#3) xline(0, lcol(red)) col(brown)

twoway bar BP runningv, xlabel(-168 -80 0 80 168) ytitle("")  name("T5") ///
subtitle("Presión Barométrica") ylabel(#3) xline(0, lcol(red)) col(forest_green) xtitle("Horas después de la transición")

twoway bar Rain runningv if Rain < 0.5, xlabel(-168 -80 0 80 168) ytitle("") name("T6") ///
subtitle("Milímetros de Lluvia") ylabel(#3) col(navy) xline(0, lcol(red)) xtitle("Horas después de la transición")

gr combine T1 T2 T3 T4 T5 T6, rows(3) title("") note("Fuente: Elaboración propia con datos del Sistema Meteorológico Nacional")
graph export "$graph/continuRD.png", width(4000) replace

*********************************
*********************************
********Tend. Paralelas**********
*********************************
*********************************
u "$dta/ATUS_DID.dta", clear

gen date = mdy(mes, dia, year)
format date %d

collapse (sum) herTOT muerTOT accidTOT, by(date treated mes dia year)
gen date2 = mdy(mes, dia, year)
graph drop _all

twoway (connect accidTOT date if date2<20120 & treated == 1, col(midgreen)) ///
(connect accidTOT date if date2<20120 & treated == 0, col(ebblue))  ///
(lfit accidTOT date if date2<20120 & treated == 1, col(gs4) lpattern(dash))  ///
(lfit accidTOT date if date2<20120 & treated == 0, col(gs4) lpattern(dash))  ///
,  xline(20120, lwidth(thick)) legend(off) ytitle("Accidentes") name("TP1")

twoway (connect muerTOT date if date2<20120 & treated == 1, col(midgreen)) ///
(connect muerTOT date if date2<20120 & treated == 0, col(ebblue))  ///
(lfit muerTOT date if date2<20120 & treated == 1, col(gs4) lpattern(dash))  ///
(lfit muerTOT date if date2<20120 & treated == 0, col(gs4) lpattern(dash))  ///
,  xline(20120, lwidth(thick)) legend(label(1 "Tratamiento") label(2 "Control") ///
label(3 "Tendencia") order(1 2 3)) xtitle("Fecha") ytitle("Muertos") name("TP2")

gr combine TP1 TP2, rows(2) note("Fuente: Elaboración propia con datos de INEGI")
graph display, xsize(15) ysize(20)
graph export "$graph/TPDID.png", width(4000) replace

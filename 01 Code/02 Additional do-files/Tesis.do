clear all
set more off 

/*Work
global dta "C:\Users\Usuario\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Tesis\Datos\DTA"
*/
*Home
global dta "C:\Users\Hugo\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Tesis\Datos\DTA"
*/
/*Rerun only if necessary
u "$dta/ATUS.dta", clear

gen accid = (_merge == 3)
drop if year<2010
sort cve year mes dia hora 
collapse (sum) accid heridos muertos, by(cve mun edo year hora dia diasemana mes cve_edo DST)
merge m:1 year cve using "$dta/Pob por Mun.dta"
keep if _merge==3
drop if big2==0

*Format date and time
gen date = mdy(mes,dia,year)
format date %tdNN/DD/CCYY
gen time = hms(hora,00,00)
format time %tcHH:MM:SS
gen double datetime = date*24*60*60*1000 + time
format datetime %tcNN/DD/CCYY_HH:MM:SS
order cve mun edo datetime

*Fill blanks
drop if datetime ==.
encode cve, gen(cve2)
duplicates tag datetime cve2, g(a)
drop if a
xtset cve2 datetime, delta(1 hours)
drop a _merge
tsfill

*Fix what tsfill messed up
foreach var of varlist accid heridos muertos{
replace `var'= 0 if `var'==.
}

decode cve2, g(a)
replace cve = a
drop a mun edo DST cve_edo
merge m:1 cve using "$dta\mun_codes.dta"
keep if _merge==3

*getting back hours
gen hour = hhC(datetime)
replace hour = hour + 1 
replace hour = 0 if hour == 24
replace hora = hour
*getting back days/years/months
gen mes2 = month(dofc(datetime))
gen year2 = year(dofc(datetime))
gen dia2 = day(dofc(datetime))
replace dia = dia2
replace year = year2
replace mes = mes2
drop mes2 year2 dia2 hour G _merge date time diasemana

merge m:1 dia mes year using "$dta\semana.dta"
keep if _merge==3
drop _merge
sort cve datetime
order mun datetime accid muertos heridos

save "$dta/temp.dta", replace
*/


u "$dta/temp.dta", clear
drop pob
merge m:1 year cve using "$dta/Pob por Mun.dta"
keep if _merge ==3 
***********************
****DST Identifiers****
***********************
rename DST DST_zone
gen DST = 0 

************Normal DST zone
replace DST = 1 if mes>4 & mes<10 & DST_zone == 1
*2010
replace DST = 1 if mes ==4 & year ==2010 & dia > 3  & DST_zone == 1
replace DST = 1 if mes ==10 & year ==2010 & dia < 31  & DST_zone == 1
*2011
replace DST = 1 if mes ==4 & year ==2011 & dia > 2  & DST_zone == 1
replace DST = 1 if mes ==10 & year ==2011 & dia < 30  & DST_zone == 1
*2012
replace DST = 1 if mes ==4 & year ==2012   & DST_zone == 1
replace DST = 1 if mes ==10 & year ==2012 & dia < 29  & DST_zone == 1
*2013
replace DST = 1 if mes ==4 & year ==2013 & dia>6  & DST_zone == 1
replace DST = 1 if mes ==10 & year ==2013 & dia < 27  & DST_zone == 1
*2014 
replace DST = 1 if mes ==4 & year ==2014 & dia>5  & DST_zone == 1
replace DST = 1 if mes ==10 & year ==2014 & dia < 26  & DST_zone == 1
*2015
replace DST = 1 if mes ==4 & year ==2015 & dia>4  & DST_zone == 1
replace DST = 1 if mes ==10 & year ==2015 & dia < 25  & DST_zone == 1

************Quintana Roo Zone
replace DST = 1 if mes>4 & mes<10 & DST_zone == 3 & year<2015
*2010
replace DST = 1 if mes ==4 & year ==2010 & dia > 3  & DST_zone == 3
replace DST = 1 if mes ==10 & year ==2010 & dia < 31  & DST_zone == 3
*2011
replace DST = 1 if mes ==4 & year ==2011 & dia > 2  & DST_zone == 3
replace DST = 1 if mes ==10 & year ==2011 & dia < 30  & DST_zone == 3
*2012
replace DST = 1 if mes ==4 & year ==2012   & DST_zone == 3
replace DST = 1 if mes ==10 & year ==2012 & dia < 29  & DST_zone == 3
*2013
replace DST = 1 if mes ==4 & year ==2013 & dia>6  & DST_zone == 3
replace DST = 1 if mes ==10 & year ==2013 & dia < 27  & DST_zone == 3
*2014 
replace DST = 1 if mes ==4 & year ==2014 & dia>5  & DST_zone == 3
replace DST = 1 if mes ==10 & year ==2014 & dia < 26  & DST_zone == 3
*2015
replace DST = 1 if mes >1 & year ==2015 & DST_zone == 3

************DST for border municipalities
replace DST = 1 if mes>3 & mes<11 & DST_zone == 2
*2010
replace DST = 1 if mes ==3 & year ==2010 & dia > 13  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2010 & dia < 7  & DST_zone == 2
*2011
replace DST = 1 if mes ==3 & year ==2011 & dia > 12  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2011 & dia < 6  & DST_zone == 2
*2012
replace DST = 1 if mes ==3 & year ==2012  & dia >11 & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2012 & dia < 4  & DST_zone == 2
*2013
replace DST = 1 if mes ==3 & year ==2013 & dia>9  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2013 & dia < 3  & DST_zone == 2
*2014 
replace DST = 1 if mes ==3 & year ==2014 & dia>8  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2014 & dia < 2  & DST_zone == 2
*2015
replace DST = 1 if mes ==3 & year ==2015 & dia>7  & DST_zone == 2
*No need for a second line for 2015


*********************************************
*********************************************
********For regression discontinuity*********
*********************************************
*********************************************
sort cve datetime
gen runningv = 0 if DST[_n-1]== 0 & DST== 1
replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & runningv[_n-1]!=. & runningv[_n-1]<4000
replace runningv = -4000 if runningv==. & runningv[_n+4000]==0
replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & running[_n-1]<0
replace runningv = -1 if runningv[_n+1] ==0 & runningv==.
gen before = 0 if runningv > 0 & runningv != .
replace before = 1 if runningv < 0 & runningv != .

sort cve datetime
gen runningv2 = 0 if DST[_n-1]== 1 & DST== 0
replace runningv2 = runningv2[_n-1]+1 if runningv2[_n+1]==. & runningv2[_n-1]!=. & runningv2[_n-1]<1000
replace runningv2 = -1000 if runningv2==. & runningv2[_n+1000]==0
replace runningv2 = runningv2[_n-1]+1 if runningv2[_n+1]==. & runningv2[_n-1]<0
replace runningv2 = -1 if runningv2[_n+1] ==0 & runningv2==.
*********************************************
*********************************************
**********For dif-n-dif estimations**********
*********************************************
*********************************************

***********Dummy for our treated group (1 Border)
gen treated1 = (DST_zone == 2)

***********Dummy for  the time when our treated group is treated (1 Border)
gen time1 = 1 if year == 2015 & mes == 3 & dia >=8 
replace time1 = 1 if year == 2015 & mes == 4 & dia <5
replace time1 = 1 if year == 2014 & mes == 3 & dia >=9
replace time1 = 1 if year == 2014 & mes == 4 & dia <6
replace time1 = 1 if year == 2013 & mes == 3 & dia >=14
replace time1 = 1 if year == 2013 & mes == 4 & dia <5
replace time1 = 1 if year == 2012 & mes == 3 & dia >=11
replace time1 = 1 if year == 2012 & mes == 4 & dia <1
replace time1 = 1 if year == 2011 & mes == 3 & dia >=13
replace time1 = 1 if year == 2011 & mes == 4 & dia <3
replace time1 = 1 if year == 2010 & mes == 3 & dia >=14
replace time1 = 1 if year == 2010 & mes == 4 & dia <4
replace time1= 0 if time1 == .


***********Dummy for our treated group (2 Quintana Roo)
gen treated2 = (DST_zone == 3)

***********Dummy for  the time when our treated group is treated (2 Quintana Roo)
gen time2 = 0 if year != 2015
replace time2 = 0 if year ==2015 & mes == 1
replace time2 = 1 if year == 2015 & time2 == .
*Demean vars by hour, municipality, dayofweek and year

replace heridos = heridos/pob*100000
replace muertos = muertos/pob*100000
replace accid = accid/pob*100000
gen herTOT = heridos*pob/100000
gen muerTOT = muertos*pob/100000
gen accidTOT = accid*pob/100000

foreach var of varlist accid heridos muertos{
	bysort cve hora diasemana year : egen mean_`var'= mean(`var')
	gen demean_`var' = mean_`var' - `var'
}

label var DST_zone "Zona del Horario de Verano"
label var DST "1 En Horario de Verano 0 Horario Estandar"
label var accid "# de Accidentes Ocurridos/ 100,000 hab"
label var herido "# de Heridos/ 100,000 hab"
label var muertos "# de Muertos/ 100,000 hab"
label var treated1 "Treated group (border municipalities) (first dnd)"
label var time1 "Time where the treated group is treated (first dnd)"
label var treated2 "Treated group (Quintana Roo) (second dnd)"
label var time2 "Time where the treated group is treated (second dnd)"
label var date "Date"
label var datetime "Date and Time"
label var runningv "Running variable for reg disc (transition to DST)"
label var diasemana "Dia de la semana"
label var datetime "Fecha y hora"
label var before "1 Horas antes del cambio 0 Horas despues"
label var herTOT "Heridos totales"
label var muerTOT "Muertos totales"
label var accidTOT "Accidentes totales"
label var runningv2 "Running variable for reg disc (out of DST transition)"

drop count big2 big _merge 

save "$dta/ATUS_tesis.dta", replace

u "$dta/ATUS_tesis.dta", clear

preserve
drop if year == 2010 & DST_zone ==1 & runningv2==.
drop if year == 2012 & DST_zone ==1 & runningv2==.
drop if year == 2013 & DST_zone ==1 & runningv2==.
drop if year == 2015 & DST_zone ==1 & runningv2==.
drop if DST_zone == 3 | DST_zone == 4 
drop if runningv == . & runningv2 == .
save "$dta/ATUS_disc.dta", replace
restore


preserve 
collapse (sum) accid muertos heridos herTOT muerTOT accidTOT (mean) treated* time* DST_zone DST, by(dia mes cve2 year cve_edo edo cve_mun diasemana mun)
label var DST_zone "Zona del Horario de Verano"
label var DST "1 En Horario de Verano 0 Horario Estandar"
label var accid "# de Accidentes Ocurridos/ 100,000 hab"
label var herido "# de Heridos/ 100,000 hab"
label var muertos "# de Muertos/ 100,000 hab"
label var treated1 "Treated group (border municipalities) (first dnd)"
label var time1 "Time where the treated group is treated (first dnd)"
label var treated2 "Treated group (Quintana Roo) (second dnd)"
label var time2 "Time where the treated group is treated (second dnd)"
label var diasemana "Dia de la semana"
label var herTOT "Heridos totales"
label var muerTOT "Muertos totales"
label var accidTOT "Accidentes totales"
save "$dta/ATUS_dnd.dta", replace
restore

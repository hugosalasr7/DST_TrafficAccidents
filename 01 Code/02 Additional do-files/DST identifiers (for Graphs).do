/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: This is used in 3_Graphs.do to generate the DST variable
		- Data source: NONE
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
drop if year<2010
rename DST DST_zone

***********************
****DST Identifiers****
***********************
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

************DST Fronterizo
replace DST = 1 if mes>3 & mes<11 & DST_zone == 2
*2010
replace DST = 1 if mes ==4 & year ==2010 & dia > 13  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2010 & dia < 7  & DST_zone == 2
*2011
replace DST = 1 if mes ==4 & year ==2011 & dia > 12  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2011 & dia < 6  & DST_zone == 2
*2012
replace DST = 1 if mes ==4 & year ==2012  & dia >11 & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2012 & dia < 4  & DST_zone == 2
*2013
replace DST = 1 if mes ==4 & year ==2013 & dia>9  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2013 & dia < 3  & DST_zone == 2
*2014 
replace DST = 1 if mes ==4 & year ==2014 & dia>8  & DST_zone == 2
replace DST = 1 if mes ==11 & year ==2014 & dia < 2  & DST_zone == 2
*2015
replace DST = 1 if mes ==4 & year ==2015 & dia>7  & DST_zone == 2
*No hace falta un segundo enunciado

label var DST_zone "Zona del Horario de Verano"
label var DST "1 En Horario de Verano 0 Horario Estandar"

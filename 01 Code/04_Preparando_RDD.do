/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Modifies ATUS_PF so it could be used to estimate the RD model :
		  creates new variables, fills up blanks (tsfill), merges with weather 
		  and population variables, among others.
		- Data source: Cleaned ATUS, cleaned 
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

************************************************************************************
*Fill blanks
u "$dta/ATUS_PF.dta", clear
keep if year>2009 //We are interested in years after 2010 only 
drop if DST==4 //Sonora does not implement DST, so we don't use it
encode cve, gen(cve2)
replace datetime = 1577923200000 if datetime==.
duplicates tag datetime cve2, g(a) //See if we have any repeated obs
drop if a //Drop if the obs is repeated
drop a
keep if metro==1
xtset cve2 datetime, delta(1 hours)
tsfill, full

			************************************************************************************
			******************TSFill left a lot of missings*************************************
			************************************************************************************
			*All the accidents that are in missings are transformed to 0
			foreach var of varlist accid heridos muertos atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos{
				replace `var'= 0 if `var'==.
			}
			*Get back all the municipalities information
			decode cve2, g(a)
			replace cve = a
			drop a mun edo DST cve_edo
			merge m:1 cve using "$dta\mun_codes.dta", keep(3)
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
			drop mes2 year2 dia2 hour G _merge date time diasemana
			*Agrego dia de la semana
			merge m:1 dia mes year using "$dta\Días de la semana.dta", keep(3) nogen
			*Agrego codigo de zona metro
			drop metro cve_metro
			merge m:1 cve using "$dta/temp.dta", keep(3)
			destring cve_metro, replace
			replace metro=0 if metro==.
			drop _merge
				*Labels
				label var cve_edo "Código Único Estatal"
				label var edo "Entidad Federativa"
				label var cve_mun "Código Único Municipal"
				label var mun "Municipio"
				label var DST "Tipo de DST que implementa"
				label define DST1 1 "DST Normal" 2 "DST Fronterizo" 3 "No aplica DST desde 2015" 4 "No aplica DST desde 1998"
				label values DST DST1
			save "$dta/temp2.dta", replace		
			
***********************************************************************************
********************************Towards DST****************************************
***********************************************************************************
***********************************************************************************			
*I only keep the sample I need for the regression discontinuity. 
*This one is to keep my relevant time subset

u "$dta/temp2.dta", clear

**************************From Normal Time to Daylight Saving time*****************
*For those who apply Normal DST (and Quintana Roo), we could only use 2011 and 2014. 
g valido= .  //We generate a var = 1 for the days that are within TWO weeks of the schedule change
replace valido = 1 if mes==4 & dia<17 & year==2016
replace valido = 1 if mes==3 & dia>19 & year==2016
replace valido = 1 if mes==4 & dia<21 & year==2014
replace valido = 1 if mes==3 & dia>23 & year==2014
replace valido = 1 if mes==4 & dia<17 & year==2011
replace valido = 1 if mes==3 & dia>20 & year==2011
drop if valido!=1 & DST==1
drop if valido!=1 & DST==3

**************************From Normal Time to Daylight Saving time*****************
*For those who apply Border DST, we can estimate the impact from 2010-2015. 
replace valido=. //We generate a var = 1 for the days that are within TWO weeks of the schedule change
replace valido = 1 if mes==3 & year==2010
replace valido = 1 if mes==2 & dia>27 & year==2010
replace valido = 1 if mes==3 & year==2011
replace valido = 1 if mes==2 & dia>26 & year==2011
replace valido = 1 if mes==3 & year==2012
replace valido = 1 if mes==2 & dia>25 & year==2012
replace valido = 1 if mes==3 & year==2013
replace valido = 1 if mes==2 & dia>23 & year==2013
replace valido = 1 if mes==3 & year==2014
replace valido = 1 if mes==2 & dia>22 & year==2014
replace valido = 1 if mes==3 & year==2015
replace valido = 1 if mes==2 & dia>21 & year==2015
replace valido = 1 if mes==3 & year==2016
replace valido = 1 if mes==2 & dia>27 & year==2016
drop if valido!=1 & DST==2

merge m:1 year cve using "$dta/pobINEGImun2.dta", nogen keep(3 1) //Add population data
save "$dta/temp.dta", replace

			*********************************************************************
			****Gen a var to identify DST days compared to Normal time days******
			*********************************************************************
			u "$dta/temp.dta", clear
			rename DST DST_zone
			replace DST_zone = 1 if DST_zone==3 //All we care about now are two different type of DST: Border and Normal
				
			************Normal DST zone
			gen DST = 0 
			replace DST = 1 if mes>4 & mes<10 & DST_zone == 1 //For all years on Normal DST, on May-September we had DST
			replace DST = 1 if mes ==4 & year ==2010 & dia> 3  & DST_zone == 1 //2010
			replace DST = 1 if mes ==10 & year ==2010 & dia< 31  & DST_zone == 1
			replace DST = 1 if mes ==4 & year ==2011 & dia > 2  & DST_zone == 1 //2011
			replace DST = 1 if mes ==10 & year ==2011 & dia < 30  & DST_zone == 1
			replace DST = 1 if mes ==4 & year ==2012   & DST_zone == 1 //2012
			replace DST = 1 if mes ==10 & year ==2012 & dia < 29  & DST_zone == 1
			replace DST = 1 if mes ==4 & year ==2013 & dia>6  & DST_zone == 1 //2013
			replace DST = 1 if mes ==10 & year ==2013 & dia < 27  & DST_zone == 1
			replace DST = 1 if mes ==4 & year ==2014 & dia>5  & DST_zone == 1 //2014
			replace DST = 1 if mes ==10 & year ==2014 & dia < 26  & DST_zone == 1
			replace DST = 1 if mes ==4 & year ==2015 & dia>4  & DST_zone == 1 //2015
			replace DST = 1 if mes ==10 & year ==2015 & dia < 25  & DST_zone == 1
			replace DST = 1 if mes ==4 & year ==2016 & dia>2  & DST_zone == 1 //2016
			replace DST = 1 if mes ==10 & year ==2016 & dia < 23  & DST_zone == 1
			************DST for border municipalities
			replace DST = 1 if mes>3 & mes<11 & DST_zone == 2 //For all years on Border DST, on April-October we had DST
			replace DST = 1 if mes ==3 & year ==2010 & dia > 13  & DST_zone == 2 //2010
			replace DST = 1 if mes ==11 & year ==2010 & dia < 7  & DST_zone == 2
			replace DST = 1 if mes ==3 & year ==2011 & dia > 12  & DST_zone == 2 //2011
			replace DST = 1 if mes ==11 & year ==2011 & dia < 6  & DST_zone == 2
			replace DST = 1 if mes ==3 & year ==2012  & dia >10 & DST_zone == 2 //2012
			replace DST = 1 if mes ==11 & year ==2012 & dia < 4  & DST_zone == 2
			replace DST = 1 if mes ==3 & year ==2013 & dia>9  & DST_zone == 2 //2013
			replace DST = 1 if mes ==11 & year ==2013 & dia < 3  & DST_zone == 2
			replace DST = 1 if mes ==3 & year ==2014 & dia>8  & DST_zone == 2 //2014
			replace DST = 1 if mes ==11 & year ==2014 & dia < 2  & DST_zone == 2
			replace DST = 1 if mes ==3 & year ==2015 & dia>7  & DST_zone == 2 //2015
			replace DST = 1 if mes ==3 & year ==2016 & dia>12  & DST_zone == 2 //2016
			*DST goes on until 3:00 am ()
			sort cve datetime
			replace DST = 0 if DST[_n-1]==0 & DST==1 & hora==0
			replace DST = 0 if DST[_n-2]==0 & DST==1 & hora==1
			replace DST = 0 if DST[_n-3]==0 & DST==1 & hora==2
			*DST goes off until 1:00 am
			replace DST = 1 if DST[_n-1]==1 & DST==0 & hora==0
			save "$dta/temp.dta", replace

********Merge with weather variables
u "$dta/temp.dta", clear
merge m:1 year hora dia mes cve_metro using "$dta\Clima (SMN)\Temperatura 2010-2015 (RD).dta"
drop if _merge==2
sort cve datetime
foreach var of varlist SR Rain Rh ATC AvgWSV BP{ //Some variables have missings. We intrapolate with linear trends
	bysort cve: ipolate `var' datetime, g(`var'_ipo)
	replace `var' = `var'_ipo
	drop `var'_ipo
}
************************************************************************************
********Generate a variable that counts each hour after the schedule change*********
************************************************************************************
sort cve datetime
gen runningv = 0 if DST[_n-1]== 0 & DST== 1 & year==2011 //2011: Runningv set to 0 at the first hour of DST - Normal DST
replace runningv = 0 if DST[_n-1]== 0 & DST== 1 & year==2014 //2014: Runningv set to 0 at the first hour of DST - Normal DST
replace runningv = 0 if DST[_n-1]== 0 & DST== 1 & year==2016 //2016: Runningv set to 0 at the first hour of DST - Normal DST
replace runningv = 0 if DST[_n-1]== 0 & DST== 1 & DST_zone==2 //2010-2015: Runningv set to 0 at the first hour of DST - Border DST
replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & runningv[_n-1]!=. & runningv[_n-1]<315 //After DST has begun, it adds 1 to the counter until we reach 2 weeks
replace runningv = -315 if runningv==. & runningv[_n+315]==0 //This is tu add the negative values to runningv
replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & runningv[_n-1]<0 //This is tu add the negative values to runningv
replace runningv = -1 if runningv[_n+1] ==0 & runningv==. //This is tu add the negative values to runningv
drop if runningv ==. //Eliminar todos los missings

label var runningv "Number of hours away from transition to DST (=0 on first hour after transition)"
label var DST "1 = Horario de Verano , 0 = Horario estandar" 
drop count big2 big _merge valido metro
order cve cve2 cve_mun cve_edo mun edo cve_metro year mes dia hora datetime
save "$dta/ATUS_PF_RD.dta", replace

			*This is only for PF data for 2016
			***********************************************************************************
			********************************To DST******************************************
			***********************************************************************************
			***********************************************************************************			

			************************************************************************************
			*Fill blanks
			u "$dta/ATUS_PF.dta", clear
			keep if year==2016  //We are interested in years after 2010 only 
			drop if DST==4 //Sonora does not implement DST, so we don't use it
			encode cve, gen(cve2)
			replace datetime = 1577923200000 if datetime==.
			duplicates tag datetime cve2, g(a) //See if we have any repeated obs
			drop if a //Drop if the obs is repeated
			drop a
			xtset cve2 datetime, delta(1 hours)
			tsfill, full

						************************************************************************************
						******************TSFill left a lot of missings*************************************
						************************************************************************************
						drop  accid heridos muertos atus*
						*All the accidents that are in missings are transformed to 0
						foreach var of varlist pf_accid pf_heridos pf_muertos{
							replace `var'= 0 if `var'==.
						}
						*Get back all the municipalities information
						decode cve2, g(a)
						replace cve = a
						drop a mun edo DST cve_edo
						merge m:1 cve using "$dta\mun_codes.dta", keep(3)
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
						drop mes2 year2 dia2 hour G _merge date time diasemana
						*Agrego dia de la semana
						merge m:1 dia mes year using "$dta\D�as de la semana.dta", keep(3) nogen

							*Labels
							label var cve_edo "Codigo Unico Estatal"
							label var edo "Entidad Federativa"
							label var cve_mun "Codigo Unico Municipal"
							label var mun "Municipio"
							label var DST "Tipo de DST que implementa"
							label define DST1 1 "DST Normal" 2 "DST Fronterizo" 3 "No aplica DST desde 2015" 4 "No aplica DST desde 1998"
							label values DST DST1
						save "$dta/temp2.dta", replace		
						
			***********************************************************************************
			********************************Towards DST****************************************
			***********************************************************************************
			***********************************************************************************			
			*I only keep the sample I need for the regression discontinuity. 
			*This one is to keep my relevant time subset

			u "$dta/temp2.dta", clear

			**************************From Normal Time to Daylight Saving time*****************
			*For those who apply Normal DST (and Quintana Roo), we could only use 2011 and 2014. 
			g valido= .  //We generate a var = 1 for the days that are within TWO weeks of the schedule change
			replace valido = 1 if mes==4 & dia<17 & year==2016
			replace valido = 1 if mes==3 & dia>19 & year==2016
			replace valido = 1 if mes==4 & dia<21 & year==2014
			drop if valido!=1 & DST==1
			drop if valido!=1 & DST==3

			*For those who apply Border DST, we can estimate the impact from 2010-2015. 
			replace valido=. //We generate a var = 1 for the days that are within TWO weeks of the schedule change
			replace valido = 1 if mes==3 & year==2016
			replace valido = 1 if mes==2 & dia>27 & year==2016
			drop if valido!=1 & DST==2
			save "$dta/temp.dta", replace

						*********************************************************************
						****Gen a var to identify DST days compared to Normal time days******
						*********************************************************************
						u "$dta/temp.dta", clear
						rename DST DST_zone
						replace DST_zone = 1 if DST_zone==3 //All we care about now are two different type of DST: Border and Normal
							
						************Normal DST zone
						gen DST = 0 
						replace DST = 1 if mes>4 & mes<10 & DST_zone == 1 //For all years on Normal DST, on May-September we had DST
						replace DST = 1 if mes ==4 & year ==2016 & dia>2  & DST_zone == 1 //2016
						replace DST = 1 if mes ==10 & year ==2016 & dia < 23  & DST_zone == 1
						************DST for border municipalities
						replace DST = 1 if mes ==3 & year ==2016 & dia>12  & DST_zone == 2 //2016
						*DST goes on until 3:00 am ()
						sort cve datetime
						replace DST = 0 if DST[_n-1]==0 & DST==1 & hora==0
						replace DST = 0 if DST[_n-2]==0 & DST==1 & hora==1
						replace DST = 0 if DST[_n-3]==0 & DST==1 & hora==2
						*DST goes off until 1:00 am
						replace DST = 1 if DST[_n-1]==1 & DST==0 & hora==0
						save "$dta/temp.dta", replace

			********Merge with weather variables
			u "$dta/temp.dta", clear
			destring cve_metro, replace
			merge m:1 year hora dia mes cve_metro using "$dta\Clima (SMN)\Temperatura 2010-2015 (RD).dta"
			drop if _merge==2
			sort cve datetime
			foreach var of varlist SR Rain Rh ATC AvgWSV BP{ //Some variables have missings. We intrapolate with linear trends
				bysort cve: ipolate `var' datetime, g(`var'_ipo)
				replace `var' = `var'_ipo
				drop `var'_ipo
			}
			************************************************************************************
			********Generate a variable that counts each hour after the schedule change*********
			************************************************************************************
			sort cve datetime
			gen runningv = 0 if DST[_n-1]== 0 & DST== 1 & year==2011 //2011: Runningv set to 0 at the first hour of DST - Normal DST
			replace runningv = 0 if DST[_n-1]== 0 & DST== 1 & year==2016 //2016: Runningv set to 0 at the first hour of DST - Normal DST
			replace runningv = 0 if DST[_n-1]== 0 & DST== 1 & DST_zone==2 //2010-2015: Runningv set to 0 at the first hour of DST - Border DST
			replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & runningv[_n-1]!=. & runningv[_n-1]<315 //After DST has begun, it adds 1 to the counter until we reach 2 weeks
			replace runningv = -315 if runningv==. & runningv[_n+315]==0 //This is tu add the negative values to runningv
			replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & runningv[_n-1]<0 //This is tu add the negative values to runningv
			replace runningv = -1 if runningv[_n+1] ==0 & runningv==. //This is tu add the negative values to runningv
			drop if runningv ==. //Eliminar todos los missings

			label var runningv "Number of hours away from transition to DST (=0 on first hour after transition)"
			label var DST "1 = Horario de Verano , 0 = Horario estandar" 
			drop count big2 big _merge valido metro
			order cve cve2 cve_mun cve_edo mun edo cve_metro year mes dia hora datetime
			save "$dta/ATUS_PF_RD.dta", replace
					











								***********************************************************************************
								********************************Outta DST******************************************
								***********************************************************************************
								***********************************************************************************			
								*I only keep the sample I need for the regression discontinuity. 
								*This one is to keep my relevant time subset

								u "$dta/temp2.dta", clear

								**************************From Daylight Saving Time to Standard time***************** 
								*All years for transition out of DST (Normal DST)
								g valido= .  //We generate a var = 1 for the days that are within TWO weeks of the schedule change
								replace valido = 1 if mes==11 & dia<15 & year==2010
								replace valido = 1 if mes==10 & dia>17 & year==2010
								replace valido = 1 if mes==11 & dia<13 & year==2011
								replace valido = 1 if mes==10 & dia>15 & year==2011
								replace valido = 1 if mes==11 & dia<11 & year==2012
								replace valido = 1 if mes==10 & dia>13 & year==2012
								replace valido = 1 if mes==11 & dia<10 & year==2013
								replace valido = 1 if mes==10 & dia>12 & year==2013
								replace valido = 1 if mes==11 & dia<9 & year==2014
								replace valido = 1 if mes==10 & dia>11 & year==2014
								replace valido = 1 if mes==11 & dia<8 & year==2015
								replace valido = 1 if mes==10 & dia>10 & year==2015
								replace valido = 1 if mes==11 & dia<13 & year==2016
								replace valido = 1 if mes==10 & dia>15 & year==2016	
								drop if valido!=1 & DST==1
								drop if valido!=1 & DST==3
								**************************From Daylight Saving Time to Standard time*****************
								*All years for transition out of DST (Border DST)
								replace valido = 1 if mes==11 & dia<19 & year==2010
								replace valido = 1 if mes==10 & dia>21 & year==2010
								replace valido = 1 if mes==11 & dia<20 & year==2011
								replace valido = 1 if mes==10 & dia>22 & year==2011
								replace valido = 1 if mes==11 & dia<18 & year==2012
								replace valido = 1 if mes==10 & dia>20 & year==2012
								replace valido = 1 if mes==11 & dia<17 & year==2013
								replace valido = 1 if mes==10 & dia>19 & year==2013
								replace valido = 1 if mes==11 & dia<16 & year==2014
								replace valido = 1 if mes==10 & dia>18 & year==2014
								replace valido = 1 if mes==11 & dia<15 & year==2015
								replace valido = 1 if mes==10 & dia>17 & year==2015
								replace valido = 1 if mes==11 & dia<17 & year==2016
								replace valido = 1 if mes==10 & dia>25 & year==2016
								drop if valido!=1 & DST==2
								
								merge m:1 year cve using "$dta/pobINEGImun2.dta", nogen keep(3 1) //Add population data
								save "$dta/temp.dta", replace
								
											*********************************************************************
											****Gen a var to identify DST days compared to Normal time days******
											*********************************************************************
											u "$dta/temp.dta", clear
											rename DST DST_zone
											replace DST_zone = 1 if DST_zone==3 //All we care about now are two different type of DST: Border and Normal
												
											************Normal DST zone
											gen DST = 0 
											replace DST = 1 if mes ==10 & year ==2010 & dia< 31  & DST_zone == 1
											replace DST = 1 if mes ==10 & year ==2011 & dia < 30  & DST_zone == 1
											replace DST = 1 if mes ==10 & year ==2012 & dia < 29  & DST_zone == 1
											replace DST = 1 if mes ==10 & year ==2013 & dia < 27  & DST_zone == 1
											replace DST = 1 if mes ==10 & year ==2014 & dia < 26  & DST_zone == 1
											replace DST = 1 if mes ==10 & year ==2015 & dia < 25  & DST_zone == 1
											replace DST = 1 if mes ==10 & year ==2016 & dia<30  & DST_zone == 1
											************DST for border municipalities
											replace DST = 1 if mes ==11 & year ==2010 & dia < 7  & DST_zone == 2
											replace DST = 1 if mes ==11 & year ==2011 & dia < 6  & DST_zone == 2
											replace DST = 1 if mes ==11 & year ==2012 & dia < 4  & DST_zone == 2
											replace DST = 1 if mes ==11 & year ==2013 & dia < 3  & DST_zone == 2
											replace DST = 1 if mes ==11 & year ==2014 & dia < 2  & DST_zone == 2
											replace DST = 1 if mes ==11 & year ==2016 & dia < 6  & DST_zone == 2
											replace DST = 1 if mes ==10 & DST_zone == 2
											*DST goes off until 1:00 am
											sort cve datetime
											replace DST = 1 if DST[_n-1]==1 & DST==0 & hora==0
											save "$dta/temp.dta", replace

								********Merge with weather variables
								u "$dta/temp.dta", clear
								merge m:1 year hora dia mes cve_metro using "$dta\Clima (SMN)\Temperatura 2010-2015 (RD).dta"
								drop if _merge==2
								sort cve datetime
								foreach var of varlist SR Rain Rh ATC AvgWSV BP{ //Some variables have missings. We intrapolate with linear trends
									bysort cve: ipolate `var' datetime, g(`var'_ipo)
									replace `var' = `var'_ipo
									drop `var'_ipo
								}
								************************************************************************************
								********Generate a variable that counts each hour after the schedule change*********
								************************************************************************************
								gsort cve -datetime //Since we are going out of DST, we need to sort the database upside down for this to work
								gen runningv = 0 if DST[_n-1]== 0 & DST== 1 & DST_zone==1  //2010-2016: Runningv set to 0 at the first hour of DST - Normal DST
								replace runningv = 0 if DST[_n-1]== 0 & DST== 1 & DST_zone==2 //2010-2016: Runningv set to 0 at the first hour of DST - Border DST
								replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & runningv[_n-1]!=. & runningv[_n-1]<315 //After DST has begun, it adds 1 to the counter until we reach 2 weeks
								replace runningv = -100 if runningv==. & runningv[_n+100]==0 //This is tu add the negative values to runningv
								replace runningv = runningv[_n-1]+1 if runningv[_n+1]==. & runningv[_n-1]<0 //This is to add the negative values to runningv
								replace runningv = -1 if runningv[_n+1] ==0 & runningv==. //This is tu add the negative values to runningv
								drop if runningv ==. //Eliminar todos los missings

								label var runningv "Number of hours away from transition out of DST (=0 on first hour after transition)"
								label var DST "1 = Horario de Verano , 0 = Horario estandar" 
								drop count big2 big _merge valido metro

								save "$dta/ATUS_PF_RD2.dta", replace



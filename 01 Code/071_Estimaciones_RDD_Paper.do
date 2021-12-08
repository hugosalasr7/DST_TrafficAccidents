/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Estimates Regression Discontinuity Models 
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

*********************************
***********RDD*******************
*********************************
u "$dta/ATUS_PF_RD", clear
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime
global control "SR Rain Rh ATC AvgWSV BP"
drop if cve_edo=="23" & year==2016 //QRoo in 2016 did not shift DST

*We run the main regression, subsets for each year and subset for type of DST that is implemented(Border DST or Common DST)
**********************ATUS INEGI
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
		
		**********************Policia federal
		foreach var of varlist pf_accid pf_heridos pf_muertos{
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if year == 2016, fe cluster(cve2) robust
			est store `var'
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==2 & year==2016 , fe cluster(cve2) robust
			est store `var'_2
			quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==1 & year==2016, fe cluster(cve2) robust
			est store `var'_1	
		}

		*HDV y HDV fronterizo en todos los años
		esttab pf_accid pf_heridos pf_muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p scalars()
		*Sólo HDV en todos los años
		esttab pf_accid_1 pf_heridos_1 pf_muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Sólo HDV Fronterizo en todos los años
		esttab pf_accid_2 pf_heridos_2 pf_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
		*Export all regressions
		esttab pf_accid pf_heridos pf_muertos pf_accid_1 pf_heridos_1 pf_muertos_1 pf_accid_2 pf_heridos_2 pf_muertos_2 using "$fig/RDD_PF_hora.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)
			
				**********************ATUS + Policia federal
				foreach var of varlist accid heridos muertos{
					quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if year == 2016, fe cluster(cve2) robust
					est store `var'
					quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==2 & year==2016 , fe cluster(cve2) robust
					est store `var'_2
					quietly xtreg `var' DST runningv interaction i.hora i.diasemana $control if DST_zone==1 & year==2016, fe cluster(cve2) robust
					est store `var'_1	
				}

				*HDV y HDV fronterizo en todos los años
				esttab accid heridos muertos, star(* 0.10 ** 0.05 *** 0.01) b(a2) p scalars()
				*Sólo HDV en todos los años
				esttab accid_1 heridos_1 muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
				*Sólo HDV Fronterizo en todos los años
				esttab accid_2 heridos_2 muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
				*Export all regressions
				esttab accid heridos muertos accid_1 heridos_1 muertos_1 accid_2 heridos_2 muertos_2 using "$fig/RDD_ATUSPF_hora.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g)
							
*************************************************************************************************************
***********Sensibility: RDD models are robust to estimating it with daily data instead of hourly************
*************************************************************************************************************
sort cve2 datetime
replace DST = 1 if hora<3 & diasemana==1 & DST[_n+4]==1 //We'll count the first day of DST although there are three hours in which we still had Normal time
collapse (mean) SR Rh ATC AvgWSV BP (sum) accid heridos muertos Rain atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos, by(diasemana DST_zone year cve mes dia DST cve2)
sort cve year mes dia
	by cve year:gen runningv = _n
	replace runningv = runningv - 8
	replace runningv= runningv+1 if runningv>=0 // No 0 for this model, it skips from -1 to 1.
	drop if runningv==8 //We drop the 8th day
gen date = mdy(mes, dia, year)
xtset cve2 date
gen interaction = DST*runningv

**********************************ATUS
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
esttab atus_accid_2  atus_heridos_2 atus_muertos_2,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p scalar(N N_g)
*Sólo HDV separando 2011, 2014 and 2016
esttab atus_accid atus_heridos atus_muertos atus_accid_1 atus_heridos_1 atus_muertos_1 atus_accid_2  atus_heridos_2 atus_muertos_2 using "$fig/RDD_ATUS_dia.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N N_g)

		**********************************Policia Federal
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
		esttab pf_accid pf_heridos pf_muertos pf_accid_1 pf_heridos_1 pf_muertos_1 pf_accid_2 pf_heridos_2 pf_muertos_2 using "$fig/RDD_PF_dia.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N N_g) 

					********************************** ATUS + Policia Federal 
					foreach var of varlist accid heridos muertos {
						quietly xtreg `var' DST runningv interaction i.diasemana $control if year==2016, fe cluster(cve2) robust
						est store `var'
						quietly xtreg `var' DST runningv interaction i.diasemana $control if DST_zone==2 & year==2016, fe cluster(cve2) robust
						est store `var'_2
						quietly xtreg `var' DST runningv interaction i.diasemana $control if DST_zone==1 & year==2016, fe cluster(cve2) robust
						est store `var'_1
					}
					
					*HDV y HDV fronterizo en todos los años
					esttab accid heridos muertos,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
					*Sólo HDV en todos los años
					esttab accid_1 heridos_1 muertos_1,  star(* 0.10 ** 0.05 *** 0.01) b(a2) p
					*Sólo HDV Fronterizo en todos los años
					esttab accid heridos muertos accid_1 heridos_1 muertos_1 accid_2 heridos_2 muertos_2 using "$fig/RDD_ATUSPF_dia.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N_g N) 

********************************************************************************************
**Sensibility: we change the amount of hours we use before and after the shift towards DST**
********************************************************************************************
*In the main specification, we use a window of 167 hours before 
*and after the change (which is = to 1 week). To make sure this 
*is not model dependent, we will run some variants p to 69 hours
u "$dta/ATUS_PF_RD", clear
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime
global control "SR Rain Rh ATC AvgWSV BP"
drop if cve_edo=="23" & year==2016

mat CS=J(100,17,0) // This is the matrix where we will output our data
gen chosen = . // This is the chosen window of data

local h=167
while `h'>=72 {
	quietly replace chosen = 0 
	quietly replace chosen = 1 if runningv < `h' & runningv >-`h' //Only those in this window will be used to estimate the effect
	*Run regression on the # accidents
	quietly xtreg atus_accid DST runningv interaction i.hora i.diasemana i.year $control if chosen, fe cluster(cve2) robust
	quietly mat temp = r(table)' //Store regression table in a temporary matrix
	quietly mat CS[-`h'+168,1]= `h' //Store the number of hours we used before and after the change
	quietly mat CS[-`h'+168,2]= temp[1,1] //Store our coefficient of interest
	quietly mat CS[-`h'+168,3]= temp[1,4] //Store its p-value
	quietly mat CS[-`h'+168,4]= temp[1,5] //Store its 95% lower bound CI
	quietly mat CS[-`h'+168,5]= temp[1,6] //Store its 95% upper bound CI
	quietly mat CS[-`h'+168,6]= temp[3,1] //INTERACTION: Store our coefficient of interest
	quietly mat CS[-`h'+168,7]= temp[3,4] //INTERACTION: Store its p-value
	quietly mat CS[-`h'+168,8]= temp[3,5] //INTERACTION: Store its 95% lower bound CI
	quietly mat CS[-`h'+168,9]= temp[3,6] //INTERACTION: Store its 95% upper bound CI
	*Run regression on the # deaths
	quietly xtreg atus_muertos DST runningv interaction i.hora i.diasemana i.year $control if chosen, fe cluster(cve2) robust
	quietly mat temp = r(table)' //Store regression table in a temporary matrix
	quietly mat CS[-`h'+168,10]= temp[1,1] //Store our coefficient of interest
	quietly mat CS[-`h'+168,11]= temp[1,4] //Store its p-value
	quietly mat CS[-`h'+168,12]= temp[1,5] //Store its 95% lower bound CI
	quietly mat CS[-`h'+168,13]= temp[1,6] //Store its 95% upper bound CI
	quietly mat CS[-`h'+168,14]= temp[3,1] //Store our coefficient of interest
	quietly mat CS[-`h'+168,15]= temp[3,4] //Store its p-value
	quietly mat CS[-`h'+168,16]= temp[3,5] //Store its 95% lower bound CI
	quietly mat CS[-`h'+168,17]= temp[3,6] //Store its 95% upper bound CI
	display "Data window of +-`h' hours: coefficients were stored" 
	local h=`h'-1
}
matrix colnames CS = n beta_a pv_a ci1_a ci2_a beta_inter_a pv_inter_a ci1_inter_a ci2_inter_a beta_m pv_m ci1_m ci2_m beta_inter_m pv_inter_m ci1_inter_m ci2_inter_m 
putexcel A1=matrix(CS) using "$fig/RDD_Sensibilidad.xls" , replace					

svmat CS, names(col) 	
drop if n==0	//We only keep those obs that have coefficients			
gen a = mod(n,2) //Let's only display even numbers. If not each bar becomes too thin.

*Bar graph for the estimated change on the intercept (β2) - ACCIDENTS
twoway (rbar ci1_a ci2_a n if a==1, lcolor(gs7) fcolor(gs7)) ///
(scatter beta_a n if a==1, mcolor(gs3) msymbol(s) msize(vsmall))  ///
, xlabel(72(15)167) ylabel(-0.0(0.01)-0.08) yline(0, lcol(red)) ///
xtitle("Hours before and after the shift towards DST") /// 
ytitle("Estimated DST impact on accidents (β2)")  ///
legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0))  ///
note("Note: each bar represents the coefficient of one regression based on equation 1.", size(small))
graph export "$fig/RDD_Sens_accid.png", width(4000) replace

*Bar graph for the estimated change on the intercept (β2) - Deaths
twoway (rbar ci1_m ci2_m n if a==1, lcolor(gs3) fcolor(gs3)) ///
(scatter beta_m n if a==1, mcolor(gs11) msymbol(s) msize(vsmall))  ///
, xlabel(72(15)167) ylabel(-0.004(0.001)0.004) yline(0, lcol(red)) ///
xtitle("Hours before and after the shift towards DST") /// 
ytitle("Estimated DST impact on deaths (β2)")  ///
legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0)) ///
note("Note: each bar represents the coefficient of one regression based on equation 1.", size(small))
graph export "$fig/RDD_Sens_muert.png", width(4000) replace

	*Bar graph for the estimated change on the slope (β3) - ACCIDENTS
	twoway (rbar ci1_inter_a ci2_inter_a n if a==1, lcolor(gs7) fcolor(gs7)) ///
	(scatter beta_inter_a n if a==1, mcolor(gs3) msymbol(s) msize(vsmall))  ///
	, xlabel(72(15)167) ylabel(-0.0008(0.0002)0.0010) yline(0, lcol(red)) ///
	xtitle("Hours before and after the shift towards DST") /// 
	ytitle("Estimated change in the slope post-DST (β3)")  ///
	legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0))  ///
	note("Note: each bar represents the coefficient of one regression based on equation 1.", size(small))
	graph export "$fig/RDD_Sens_accid_inter.png", width(4000) replace

	*Bar graph for the estimated change on the slope (β3) - Deaths
	twoway (rbar ci1_inter_m ci2_inter_m n if a==1, lcolor(gs3) fcolor(gs3)) ///
	(scatter beta_inter_m n if a==1, mcolor(gs11) msymbol(s) msize(vsmall))  ///
	, xlabel(72(15)167) ylabel(-0.00012(0.00002)0.00010) yline(0, lcol(red)) ///
	xtitle("Hours before and after the shift towards DST") /// 
	ytitle("Estimated change in the slope post-DST (β3)")  ///
	legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0)) ///
	note("Note: each bar represents the coefficient of one regression based on equation 1.", size(small))
	graph export "$fig/RDD_Sens_muert_inter.png", width(4000) replace

			********************************************************************************************
			**Heterogeneous effect by hour of the day: We now try to estimate effects for each hour**
			********************************************************************************************
			u "$dta/ATUS_PF_RD", clear
			drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
			gen interaction = DST*runningv
			encode edo, g(edo2)
			xtset cve2 datetime
			global control "SR Rain Rh ATC AvgWSV BP"
			drop if cve_edo=="23" & year==2016

			xtreg atus_accid DST#hora runningv interaction i.diasemana i.year i.hora $control, fe cluster(cve2) robust
			mat acc = r(table)'
			xtreg muertos DST#hora runningv interaction i.diasemana i.year i.hora $control, fe cluster(cve2) robust
			mat muer = r(table)'

			mat CS=J(24,9,0) // This is the matrix where we will output our data

			forvalues x= 1/24{
				quietly mat CS[`x',1]= `x' 
				quietly mat CS[`x',2]= acc[`x'+24,1] //Store our coefficient of interest
				quietly mat CS[`x',3]= acc[`x'+24,4] //Store our coefficient of interest
				quietly mat CS[`x',4]= acc[`x'+24,5] //Store our coefficient of interest
				quietly mat CS[`x',5]= acc[`x'+24,6] //Store our coefficient of interest
				quietly mat CS[`x',6]= muer[`x'+24,1] //Store our coefficient of interest
				quietly mat CS[`x',7]= muer[`x'+24,4] //Store our coefficient of interest
				quietly mat CS[`x',8]= muer[`x'+24,5] //Store our coefficient of interest
				quietly mat CS[`x',9]= muer[`x'+24,6] //Store our coefficient of interest
			}
			matrix colnames CS = hour beta_a pv_a ci1_a ci2_a beta_m pv_m ci1_m ci2_m 
			svmat CS, names(col) 
	
			twoway (rbar ci1_a ci2_a hour, lcolor(white) fcolor(gs7)) ///
			(scatter beta_a hour, mcolor(gs3) msymbol(s) msize(small))  ///
			, xlabel(0(2)24) ylabel(-0.10(0.01)0) yline(0, lcol(red)) ///
			xtitle("Hour of the day") ytitle("Estimated DST impact on accidents by hour") /// 
			legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0)) 
			graph export "$fig/RDD_hour_accid.png", width(4000) replace
			
			twoway (rbar ci1_m ci2_m hour, lcolor(white) fcolor(gs3)) ///
			(scatter beta_m hour, mcolor(gs11) msymbol(s) msize(vsmall))  ///
			, xlabel(0(2)24) ylabel(-0.008(0.001)0.003) yline(0, lcol(red)) ///
			xtitle("Hour of the day") ytitle("Estimated DST impact on deaths by hour") /// 
			legend(label(1 "95% Confidence Interval") label(2 "Point estimate") position(7) ring(0)) 
			graph export "$fig/RDD_hour_muert.png", width(4000) replace
		
*************************************************************************
***********Run regression with the state of Quintana Roo only************
*************************************************************************
u "$dta/ATUS_PF_RD", clear
drop if runningv > 168 | runningv <-168 //We only keep 1 week before and after the schedule change
gen interaction = DST*runningv
encode edo, g(edo2)
xtset cve2 datetime
global control "SR Rain Rh ATC AvgWSV BP"
keep if cve_edo=="23"
drop if cve_edo=="23" & year==2016

**********************************ATUS
foreach var of varlist atus_accid atus_heridos atus_muertos{
	quietly xtreg `var' DST runningv interaction i.hora i.diasemana i.year $control, fe cluster(cve2) robust
	est store `var'
}

*HDV y HDV fronterizo en todos los años
esttab atus_accid atus_heridos atus_muertos using "$fig/RDD_ATUS_hora_QROO.csv", replace star(* 0.10 ** 0.05 *** 0.01) b(a2) se scalar(N N_g)

/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Clean and put together EMA databases
		- Data source: EMAs
		- Windows version
		- Worked on Stata 14
*******************************************************************************/

clear all 
set more off

*HSRs globals (Home)
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"
*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA/02 Clima (EMA)"
global dta "$root/03 DTA\Clima (SMN)"
global fig "$root/04 Figures"

*I create a blank database to put everything in
gen hora=.
save "$dta/temp1.dta", replace

***********************
***********1***********
***********************

filelist , dir($raw/1) pattern(*.xls) norecur
keep filename
tempfile files
save "`files'"
local obs = _N

forvalues i=1/`obs' {  ///
	use "`files'" in `i', clear
	local f = "$raw/1" + "/" + filename
	local name = filename
	import excel  using "`f'", clear firstrow allstring
	split fecha, p("/") 
	split fecha3, p(" ")
	split fecha32, p(":")
	renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
	drop fecha3 fecha32 fecha

	foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
		replace `var' = subinstr(`var',",",".",1)
		destring `var', replace 
	}
	*We Identify the A.M. hours
	gen am = 0
	replace am =1 if dia!=dia[_n-1] & hora == 12 
	replace am =1 if hora==12 & am[_n-1]==1
	forvalues i=1/11 {
		replace am = 1 if hora==`i' & am[_n-1]==1
	}
	*We replace hora with the 24-hour numbers
	replace hora = hora + 12 if am==0 & hora <12
	replace hora = 0 if hora == 12 & am == 1 
	
	*Filename
	g nombre= "`name'"
	
	*Collapse with hour means
	collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
	bro
	append using "$DTA\temp1.dta", force
	save "$DTA\temp1.dta", replace
	}
	
		***********************
		***********2***********
		***********************
		*I create a blank database to put everything in
		clear
		gen hora=.
		save "$DTA/temp2.dta", replace

		filelist , dir($excel/2) pattern(*.xls) norecur
		keep filename
		tempfile files
		save "`files'"
		local obs = _N


		forvalues i=1/`obs' {  ///
			
			use "`files'" in `i', clear
			local f = "$excel/2" + "/" + filename
			local name = filename
			import excel  using "`f'", clear firstrow allstring
			split fecha, p("/") 
			split fecha3, p(" ")
			split fecha32, p(":")
			renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
			drop fecha3 fecha32 fecha

			foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
				replace `var' = subinstr(`var',",",".",1)
				destring `var', replace 
			}
			*We Identify the A.M. hours
			gen am = 0
			replace am =1 if dia!=dia[_n-1] & hora == 12 
			replace am =1 if hora==12 & am[_n-1]==1
			forvalues i=1/11 {
				replace am = 1 if hora==`i' & am[_n-1]==1
			}
			*We replace hora with the 24-hour numbers
			replace hora = hora + 12 if am==0 & hora <12
			replace hora = 0 if hora == 12 & am == 1 
			
			*Filename
			g nombre= "`name'"
			
			*Collapse with hour means
			collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
			bro
			append using "$DTA\temp2.dta", force
			save "$DTA\temp2.dta", replace
			}

***********************
***********3***********
***********************
*I create a blank database to put everything in
clear
gen hora=.
save "$DTA/temp3.dta", replace

filelist , dir($excel/3) pattern(*.xls) norecur
keep filename
tempfile files
save "`files'"
local obs = _N


forvalues i=1/`obs' {  ///
	
	use "`files'" in `i', clear
	local f = "$excel/3" + "/" + filename
	local name = filename
	import excel  using "`f'", clear firstrow allstring
	split fecha, p("/") 
	split fecha3, p(" ")
	split fecha32, p(":")
	renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
	drop fecha3 fecha32 fecha

	foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
		replace `var' = subinstr(`var',",",".",1)
		destring `var', replace 
	}
	*We Identify the A.M. hours
	gen am = 0
	replace am =1 if dia!=dia[_n-1] & hora == 12 
	replace am =1 if hora==12 & am[_n-1]==1
	forvalues i=1/11 {
		replace am = 1 if hora==`i' & am[_n-1]==1
	}
	*We replace hora with the 24-hour numbers
	replace hora = hora + 12 if am==0 & hora <12
	replace hora = 0 if hora == 12 & am == 1 
	
	*Filename
	g nombre= "`name'"
	
	*Collapse with hour means
	collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
	bro
	append using "$DTA\temp3.dta", force
	save "$DTA\temp3.dta", replace
	}
				
			***********************
			***********4***********
			***********************

			*I create a blank database to put everything in
			clear
			gen hora=.
			save "$DTA/temp4.dta", replace

			filelist , dir($excel/4) pattern(*.xls) norecur
			keep filename
			tempfile files
			save "`files'"
			local obs = _N


			forvalues i=1/`obs' {  ///
				
				use "`files'" in `i', clear
				local f = "$excel/4" + "/" + filename
				local name = filename
				import excel  using "`f'", clear firstrow allstring
				split fecha, p("/") 
				split fecha3, p(" ")
				split fecha32, p(":")
				renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
				drop fecha3 fecha32 fecha

				foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
					replace `var' = subinstr(`var',",",".",1)
					destring `var', replace 
				}
				*We Identify the A.M. hours
				gen am = 0
				replace am =1 if dia!=dia[_n-1] & hora == 12 
				replace am =1 if hora==12 & am[_n-1]==1
				forvalues i=1/11 {
					replace am = 1 if hora==`i' & am[_n-1]==1
				}
				*We replace hora with the 24-hour numbers
				replace hora = hora + 12 if am==0 & hora <12
				replace hora = 0 if hora == 12 & am == 1 
				
				*Filename
				g nombre= "`name'"
				
				*Collapse with hour means
				collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
				bro
				append using "$DTA\temp4.dta", force
				save "$DTA\temp4.dta", replace
				}
***********************
***********5***********
***********************
*I create a blank database to put everything in
clear
gen hora=.
save "$DTA/temp5.dta", replace

filelist , dir($excel/5) pattern(*.xls) norecur
keep filename
tempfile files
save "`files'"
local obs = _N


forvalues i=1/`obs' {  ///
	
	use "`files'" in `i', clear
	local f = "$excel/5" + "/" + filename
	local name = filename
	import excel  using "`f'", clear firstrow allstring
	split fecha, p("/") 
	split fecha3, p(" ")
	split fecha32, p(":")
	renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
	drop fecha3 fecha32 fecha

	foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
		replace `var' = subinstr(`var',",",".",1)
		destring `var', replace 
	}
	*We Identify the A.M. hours
	gen am = 0
	replace am =1 if dia!=dia[_n-1] & hora == 12 
	replace am =1 if hora==12 & am[_n-1]==1
	forvalues i=1/11 {
		replace am = 1 if hora==`i' & am[_n-1]==1
	}
	*We replace hora with the 24-hour numbers
	replace hora = hora + 12 if am==0 & hora <12
	replace hora = 0 if hora == 12 & am == 1 
	
	*Filename
	g nombre= "`name'"
	
	*Collapse with hour means
	collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
	bro
	append using "$DTA\temp5.dta", force
	save "$DTA\temp5.dta", replace
	}
	
			***********************
			***********6***********
			***********************
			*I create a blank database to put everything in
			clear
			gen hora=.
			save "$DTA/temp6.dta", replace

			filelist , dir($excel/6) pattern(*.xls) norecur
			keep filename
			tempfile files
			save "`files'"
			local obs = _N

			forvalues i=1/`obs' {  ///
				
				use "`files'" in `i', clear
				local f = "$excel/6" + "/" + filename
				local name = filename
				import excel  using "`f'", clear firstrow allstring
				split fecha, p("/") 
				split fecha3, p(" ")
				split fecha32, p(":")
				renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
				drop fecha3 fecha32 fecha

				foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion  mes dia year hora {
					replace `var' = subinstr(`var',",",".",1)
					destring `var', replace 
				}
				*We Identify the A.M. hours
				gen am = 0
				replace am =1 if dia!=dia[_n-1] & hora == 12 
				replace am =1 if hora==12 & am[_n-1]==1
				forvalues i=1/11 {
					replace am = 1 if hora==`i' & am[_n-1]==1
				}
				*We replace hora with the 24-hour numbers
				replace hora = hora + 12 if am==0 & hora <12
				replace hora = 0 if hora == 12 & am == 1 
				
				*Filename
				g nombre= "`name'"
				
				*Collapse with hour means
				collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion, by(mes dia year hora)
				bro
				append using "$DTA\temp6.dta", force
				save "$DTA\temp6.dta", replace
				}
***********************
***********7***********
***********************
*I create a blank database to put everything in
clear
gen hora=.
save "$DTA/temp7.dta", replace

filelist , dir($excel/7) pattern(*.xls) norecur
keep filename
tempfile files
save "`files'"
local obs = _N

forvalues i=1/`obs' {  ///
	
	use "`files'" in `i', clear
	local f = "$excel/7" + "/" + filename
	local name = filename
	import excel  using "`f'", clear firstrow allstring
	split fecha, p("/") 
	split fecha3, p(" ")
	split fecha32, p(":")
	renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
	drop fecha3 fecha32 fecha

	foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
		replace `var' = subinstr(`var',",",".",1)
		destring `var', replace 
	}
	*We Identify the A.M. hours
	gen am = 0
	replace am =1 if dia!=dia[_n-1] & hora == 12 
	replace am =1 if hora==12 & am[_n-1]==1
	forvalues i=1/11 {
		replace am = 1 if hora==`i' & am[_n-1]==1
	}
	*We replace hora with the 24-hour numbers
	replace hora = hora + 12 if am==0 & hora <12
	replace hora = 0 if hora == 12 & am == 1 
	
	*Filename
	g nombre= "`name'"
	
	*Collapse with hour means
	collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
	bro
	append using "$DTA\temp7.dta", force
	save "$DTA\temp7.dta", replace
	}

		***********************
		***********8***********
		***********************
		*I create a blank database to put everything in
		clear
		gen hora=.
		save "$DTA/temp8.dta", replace

		filelist , dir($excel/8) pattern(*.xls) norecur
		keep filename
		tempfile files
		save "`files'"
		local obs = _N


		forvalues i=1/`obs' {  ///
			
			use "`files'" in `i', clear
			local f = "$excel/8" + "/" + filename
			local name = filename
			import excel  using "`f'", clear firstrow allstring
			split fecha, p("/") 
			split fecha3, p(" ")
			split fecha32, p(":")
			renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
			drop fecha3 fecha32 fecha

			foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
				replace `var' = subinstr(`var',",",".",1)
				destring `var', replace 
			}
			*We Identify the A.M. hours
			gen am = 0
			replace am =1 if dia!=dia[_n-1] & hora == 12 
			replace am =1 if hora==12 & am[_n-1]==1
			forvalues i=1/11 {
				replace am = 1 if hora==`i' & am[_n-1]==1
			}
			*We replace hora with the 24-hour numbers
			replace hora = hora + 12 if am==0 & hora <12
			replace hora = 0 if hora == 12 & am == 1 
			
			*Filename
			g nombre= "`name'"
			
			*Collapse with hour means
			collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
			bro
			append using "$DTA\temp8.dta", force
			save "$DTA\temp8.dta", replace
			}

***********************
***********9***********
***********************
*I create a blank database to put everything in
clear
gen hora=.
save "$DTA/temp9.dta", replace

filelist , dir($excel/9) pattern(*.xls) norecur
keep filename
tempfile files
save "`files'"
local obs = _N

forvalues i=1/`obs' {  ///
	
	use "`files'" in `i', clear
	local f = "$excel/9" + "/" + filename
	local name = filename
	import excel  using "`f'", clear firstrow allstring
	split fecha, p("/") 
	split fecha3, p(" ")
	split fecha32, p(":")
	renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
	drop fecha3 fecha32 fecha

	foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
		replace `var' = subinstr(`var',",",".",1)
		destring `var', replace 
	}
	*We Identify the A.M. hours
	gen am = 0
	replace am =1 if dia!=dia[_n-1] & hora == 12 
	replace am =1 if hora==12 & am[_n-1]==1
	forvalues i=1/11 {
		replace am = 1 if hora==`i' & am[_n-1]==1
	}
	*We replace hora with the 24-hour numbers
	replace hora = hora + 12 if am==0 & hora <12
	replace hora = 0 if hora == 12 & am == 1 
	
	*Filename
	g nombre= "`name'"
	
	*Collapse with hour means
	collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
	bro
	append using "$DTA\temp9.dta", force
	save "$DTA\temp9.dta", replace
	}
	
			***********************
			***********10**********
			***********************

			*I create a blank database to put everything in
			clear
			gen hora=.
			save "$DTA/temp10.dta", replace

			filelist , dir($excel/10) pattern(*.xls) norecur
			keep filename
			tempfile files
			save "`files'"
			local obs = _N


			forvalues i=1/`obs' {  ///
				
				use "`files'" in `i', clear
				local f = "$excel/10" + "/" + filename
				local name = filename
				import excel  using "`f'", clear firstrow allstring
				split fecha, p("/") 
				split fecha3, p(" ")
				split fecha32, p(":")
				renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
				drop fecha3 fecha32 fecha

				foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
					replace `var' = subinstr(`var',",",".",1)
					destring `var', replace 
				}
				*We Identify the A.M. hours
				gen am = 0
				replace am =1 if dia!=dia[_n-1] & hora == 12 
				replace am =1 if hora==12 & am[_n-1]==1
				forvalues i=1/11 {
					replace am = 1 if hora==`i' & am[_n-1]==1
				}
				*We replace hora with the 24-hour numbers
				replace hora = hora + 12 if am==0 & hora <12
				replace hora = 0 if hora == 12 & am == 1 
				
				*Filename
				g nombre= "`name'"
				
				*Collapse with hour means
				collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
				bro
				append using "$DTA\temp10.dta", force
				save "$DTA\temp10.dta", replace
				}

***********************
**********11***********
***********************
*I create a blank database to put everything in
clear
gen hora=.
save "$DTA/temp11.dta", replace

filelist , dir($excel/11) pattern(*.xls) norecur
keep filename
tempfile files
save "`files'"
local obs = _N

forvalues i=1/`obs' {  ///
	
	use "`files'" in `i', clear
	local f = "$excel/11" + "/" + filename
	local name = filename
	import excel  using "`f'", clear firstrow allstring
	split fecha, p("/") 
	split fecha3, p(" ")
	split fecha32, p(":")
	renvars fecha1 fecha2 fecha31 fecha321 / mes dia year hora
	drop fecha3 fecha32 fecha

	foreach var of varlist DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar mes dia year hora {
		replace `var' = subinstr(`var',",",".",1)
		destring `var', replace 
	}
	*We Identify the A.M. hours
	gen am = 0
	replace am =1 if dia!=dia[_n-1] & hora == 12 
	replace am =1 if hora==12 & am[_n-1]==1
	forvalues i=1/11 {
		replace am = 1 if hora==`i' & am[_n-1]==1
	}
	*We replace hora with the 24-hour numbers
	replace hora = hora + 12 if am==0 & hora <12
	replace hora = 0 if hora == 12 & am == 1 
	
	*Filename
	g nombre= "`name'"
	
	*Collapse with hour means
	collapse (firstnm) nombre (mean) DirViento DirRafaga RapViento RapRafaga TempAire HumRelativa PresBarometric Precipitacion RadSolar, by(mes dia year hora)
	bro
	append using "$DTA\temp11.dta", force
	save "$DTA\temp11.dta", replace
	}
	
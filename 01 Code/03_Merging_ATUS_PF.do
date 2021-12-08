/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Puts ATUS and PF together. Additionally, it identifies the municipalities
		that are part of a metropolitan area in MX.
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

************************************************************************************
*Metropolitan areas identifiers
import delimited "$raw\ZonasMetropolitanas.csv",  clear
drop in 1/5 //These are blanks
rename (v1 v4) (cve_metro cve)
keep cve cve_metro
	gen metro=1
	label define metro 0 "NO es área metropolitana" 1 "Parte de alguna área metropolitana"
	label values metro metro
	label var cve_metro "Código único por zona metropolitana"
drop if cve== "" //Drop blanks
save  "$dta/temp.dta", replace

			*Combine ATUS and PF
			u "$dta/ATUS.dta", clear
				gen origen = 1 
				label define origen 1 "ATUS" 2 "Polic�a Federal"
				label values origen origen
			rename (urb	suburb	tipaccid	automovil	campasaj	microbus	pascamion	omnibus	tranvia	camioneta	camion	tractor	ferrocarri	motociclet	bicicleta	otrovehic	causaacci	caparod	sexo	aliento	cinturon	edad	condmuerto	condherido	pasamuerto	pasaherido	peatmuerto	peatherido	ciclmuerto	ciclherido	otromuerto	otroherido	nemuerto	neherido	urb_dum	trans	moto) (atus_urb	atus_suburb	atus_tipaccid	atus_automovil	atus_campasaj	atus_microbus	atus_pascamion	atus_omnibus	atus_tranvia	atus_camioneta	atus_camion	atus_tractor	atus_ferrocarri	atus_motociclet	atus_bicicleta	atus_otrovehic	atus_causaacci	atus_caparod	atus_sexo	atus_aliento	atus_cinturon	atus_edad	atus_condmuerto	atus_condherido	atus_pasamuerto	atus_pasaherido	atus_peatmuerto	atus_peatherido	atus_ciclmuerto	atus_ciclherido	atus_otromuerto	atus_otroherido	atus_nemuerto	atus_neherido	atus_urb_dum	atus_trans	atus_moto)
			append using "$dta\PF_Accidentes.dta"  //Add accidents from PF
				replace origen = 2 if origen==.
			merge m:1 cve using "$dta/temp.dta"
			replace metro = (_merge==3)
				
*Formatting date and time
replace dia = 1 if dia==0
gen date = mdy(mes,dia,year)  
format date %tdNN/DD/CCYY  
gen time = hms(hora,00,00)  
format time %tcHH:MM:SS  
gen double datetime = date*24*60*60*1000 + time  
format datetime %tcNN/DD/CCYY_HH:MM:SS  

*Generating dummies for accidents
*ATUS: Accidents in suburban and urban areas
gen atus_accid = accid if origen==1
replace atus_accid = 0 if origen==2
gen atus_heridos = heridos if origen==1
replace atus_heridos = 0 if origen==2
gen atus_muertos = muertos if origen==1
replace atus_muertos = 0 if origen==2
	*PF: Accidents in highways (captured by policía Federal)
	gen pf_accid = accid if origen==2
	replace pf_accid = 0 if origen==1
	gen pf_heridos = heridos if origen==2
	replace pf_heridos = 0 if origen==1
	gen pf_muertos = muertos if origen==2
	replace pf_muertos = 0 if origen==1

label var date "Fecha"
label var time "Hora"
label var datetime "Fecha y hora"
label var metro "�Este municipio es parte de una zona metropolitana?"
label var origen "1==ATUS, 2==PF"

//Collapse so we only have one observation per day with the number of accidents that happened that day
sort cve datetime
collapse (sum) accid heridos muertos atus_accid atus_heridos atus_muertos pf_accid pf_heridos pf_muertos , by(datetime cve_metro time date cve mun edo year hora dia diasemana mes cve_edo DST metro)

label var pf_accid "(SOLO PF) # de accidentes"
label var pf_heridos "(SOLO PF) # de heridos"
label var pf_muertos "(SOLO PF) # de muertos"
label var atus_accid "(SOLO ATUS) # de accidentes"
label var atus_heridos "(SOLO ATUS) # de heridos"
label var atus_muertos "(SOLO ATUS) # de muertos"
label var muertos "# de muertos totales"
label var heridos "# de heridos totales"
label var accid "# de accidentes totales"

save "$dta/ATUS_PF.dta", replace

/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Systematically imports and cleans ATUS data 
		- Data source: ATUS - Accidentes de TrÃ¡nsito Urbanos y Suburbanos (1997-2015)
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear all
set more off 

*HSRs globals (Home)
global root "C:\Users\hugo3\OneDrive - Centro de Investigacion y Docencia Economicas CIDE\03 DST on Road Traffic Accidents\02 Data"

*Everyone's globals (DO NOT ERASE)
global raw "$root/01 Raw DATA\01 ATUS 97-2015 (INEGI)"
global dta "$root/03 DTA"
********************************************************************************/
import delimited "$raw/ATUS_00.csv", clear
save "$dta/temp.dta", replace

foreach i in ATUS_15.csv ATUS_16.csv  ATUS_17.csv  ATUS_18.csv ATUS_01.csv	ATUS_02.csv	ATUS_03.csv	ATUS_04.csv	ATUS_05.csv	ATUS_06.csv	ATUS_07.csv	ATUS_08.csv	ATUS_09.csv	ATUS_10.csv	ATUS_11.csv	ATUS_12.csv	ATUS_13.csv	ATUS_14.csv	ATUS_97.csv	ATUS_98.csv	ATUS_99.csv{
	import delimited "$raw/`i'", clear // Imports
	append using "$dta/temp.dta", force
	save "$dta/temp.dta", replace
}

rename (edo anio mpio urbana suburbana) (cve_edo year cve_mun urb suburb)
*Etiquetas a todas las variables
label var cve_edo "Clave de la Entidad Federativa"
label var mes "Mes del accidente"
label var year "Año del accidente"
label var cve_mun "Clave del Municipio"
label var hora "Hora en que ocurrio el accidente"
label var minutos "Minuto en el que ocurrio el accidente"
label var dia "Dia del mes en que ocurrio el accidente"
label var diasemana "Dia de la semana en que ocurrio el accidente (Lunes a viernes)"
label var automovil "# de automoviles involucrados"
label var campasaj "# de camioneta para pasajeros involucrados"
label var microbus "# de microbuses involucrados"
label var pascamion "# de camiones urbanos de pasajeros involucrados"
label var omnibus "# de omnibuses involucrados"
label var tranvia "# de tranvias involucrados"
label var camioneta "# de camionetas involucrados"
label var camion "# de camiones involucrados"
label var tractor "# de tractores involucrados"
label var ferrocarri "# de ferrocarriles involucrados"
label var motociclet "# de motocicletas involucrados"
label var bicicleta "# de bicicletas involucrados"
label var otrovehic "# de otros vehiculos involucrados"
label var causaacci "Causa probable o presunta del accidente"
label var edad "Edad del conductor presunto responsable"
label var condmuerto "# de conductores muertos"
label var condherido "# de conductores heridos"
label var pasamuerto "# de pasajeros muertos"
label var pasaherido "# de pasajeros heridos"
label var peatmuerto "# de peatones muertos"
label var peatherido "# de peatones heridos"
label var ciclmuerto "# de ciclistas muertos"
label var ciclherido "# de ciclistas heridos"
label var otroherido "# de otras personas heridas"
label var otromuerto "# de otras personas muertas"
label var neherido "# de NO ESPECIFICADOS heridas"
label var nemuerto "# de NO ESPECIFICADOS muertas"
label var urb "Â¿Sucedio en Zona Urbana?"
label var suburb "Â¿Sucedio en Zona SUBurbana?"
label var sexo "Sexo del conductor presunto responsable"
label var aliento "Â¿Aliento alcoholico?"
label var caparod "Capa de rodamiento: 1=Pavimentada, 2=No Pavimentada"
label var cinturon "Uso de cinturon de seguridad"
label var tipaccid "Tipo de accidente"

		*Etiquetas a los valores de las variables e identificar missings
		replace hora = . if hora == 99 
		replace minutos = . if minutos == 99 | minutos == -5| minutos == -4
		replace dia = . if dia==32
		replace diasemana = . if diasemana ==8
		replace edad=. if edad==99 | edad==0

		label define label3 1 "Lunes" 2 "Martes" 3 "Miercoles" 4 "Jueves" 5 "Viernes" 6 "Sabado" 7 "Domingo"
		label values diasemana label3
		
		label define label4 0 "No" 1 "Accidente en Interseccion" 2 "Accidente en no interseccion"
		label values urb label4
		
		label define label5 0 "No" 1 "Accidente en camino rural" 2 "Accidente en carretera estatal" 3 "Accidentes en otro camino"
		label values suburb label5
		
		label define label6 1 "Colision con vehiculo automotor" 2 "Colision con peaton (atropellamiento)" 3 "Colision con Animal" 4 "Colision con objeto fijo" 5 "Volcadura" 6 "Caida de pasajero" 7 "Salida de camino" 8 "Incendio" 9 "Colision con Ferrocarril" 10 "Colision con motocicleta" 11 "Colision con ciclista" 12 "Otro"
		label values tipaccid label6
		
		label define label7 1 "Conductor" 2 "Peaton o pasajero" 3 "Falla del vehiculo" 4 "Mala condicion del camino" 5 "Otra" 
		label values causaacci label7

		label define label8 1 "Pavimentada" 2 "No pavimentada"
		label values caparod label8
		
		label define label9 1 "Se fugo" 2 "Hombre" 3 "Mujer"
		label values sexo label9
		
		replace aliento = 6 if aliento==7
		label define label10 4 "Si" 5 "No" 6 "Se ignora"
		label values aliento label10 
		
		label define label11 0 "Se ignora porque se fugo" 99 "No especificado"
		label values edad label11
		
		replace cinturon = 9 if cinturon == 6
		label define label12 7 "Si" 8 "No" 9 "Se ignora"
		label values cinturon label12 

*Total de muertos y heridos por accidente	
foreach i in nemuerto otromuerto ciclmuerto peatmuerto pasamuerto condmuerto neherido otroherido ciclherido peatherido pasaherido condherido{
	replace `i' = 0 if `i'== -6 | `i'==-1 | `i'==. //Reemplazamos con 0 las observaciones que no son positivas
}
	
gen muertos = nemuerto +otromuerto +ciclmuerto +peatmuerto +pasamuerto +condmuerto
gen heridos = neherido +otroherido +ciclherido +peatherido +pasaherido +condherido
label var muertos "# de muertos totales"
label var heridos "# de heridos totales"

*Generar un cÃ³digo Ãºnico por cada municipio y estado
gen a=cve_edo
tostring a, replace
replace a= "0"+a if cve_edo<10
gen b= cve_mun
tostring b, replace
replace b= "00"+b if cve_mun<10
replace b= "0"+b if cve_mun>9 & cve_mun<100
gen cve=a+b
drop cve_edo cve_mun
rename (a b) (cve_edo cve_mun)
label var cve "Codigo Unico Municipal y Estatal"
label var cve_edo "Codigo Ãšnico Estatal"
label var cve_mun "Codigo Ãšnico Municipal"

drop if hora==. | mes==. | dia==.   //Eliminamos las obs sin datos de fecha o hora
*From 2016 and on there is a weird thing with codes. This fixes it
replace cve = subinstr(cve, ".", "", .)

merge m:1 cve using "$dta/mun_codes.dta"
drop if _merge == 1 //We drop obs that do not identify their municipality. ATUS does not identify it.
		*Labels for variables in mun_codes.dta
		gen accid = (_merge == 3) // Gen 1 for each accident
		label var accid "1 si hubo un accidente en ese municipio en ese momento"
		label var mun "Municipio"
		label var edo "Entidad federativa"
		label define DST 1 "DST Normal" 2 "DST Fronterizo" 3 "No aplica DST desde 2015" 4 "No aplica DST desde 1998"
		label values DST DST
		label var DST "Tipo de cambio de horario que aplica (DST = Daylight Saving Time)"
		drop G _merge
order cve cve_mun cve_edo mun edo year hora minutos dia diasemana 
sort cve year

*Dummificamos urb
gen urb_dum = (urb>0) & (urb!=.)
label define label01 1 "Si" 0 "No"
label values urb label01
label var urb_dum "¿El accidente sucedia en un area urbana?"

*Numero de medios de transporte involucrados
gen trans = automovil +campasaj +microbus +pascamion+ omnibus +tranvia +camioneta +camion +tractor +ferrocarri +motociclet+ bicicleta +otrovehic
label var trans "# de automoviles involucrados"

*Motos 
gen moto = 1 if tipaccid== 10
replace moto = 0 if moto == .
label var moto "Accidentes causados por colision con moto"

compress
save "$dta/ATUS.dta", replace
save "$dta/ATUS_old.dta", replace

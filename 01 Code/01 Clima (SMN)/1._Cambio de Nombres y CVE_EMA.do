/*******************************************************************************
		- Author: Hugo Salas
		- Purpose: Harmonize the names of most EMAs and put them together in one database
		- Data source: EMAs
		- Windows version
		- Worked on Stata 14
*******************************************************************************/
clear all 
set more off

*Everyone's global
global root "C:\Users\Hrodriguez\OneDrive - Centro de Investigacion y Docencia Economicas CIDE\Impact of DST on Road Traffic Accidents\02 Data"
*HSR global (Home)

global excel "C:\Users\Hugo\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Tesis\Datos Clima (SMN)\Excel"
global DTA "$root/03 DTA"
global clima "$DTA/Clima (SMN)"
global S "C:\Users\Hugo\OneDrive - Centro de Investigación y Docencia Económicas CIDE\Tesis\Datos Clima (SMN)\S"
*/

**************************
**************************
*Re-run only if necessary*
**************************
**************************
/*
g hora=.
save "$DTA/temp.dta", replace

forvalues i=1/6 {  
	use "$DTA/temp`i'", clear
	append using "$DTA\temp.dta", force
	save "$DTA/temp.dta", replace
}

clear
g hora=.
save "$DTA/temp0.dta", replace

forvalues i=7/11 {  
	use "$DTA/temp`i'", clear
	append using "$DTA\temp0.dta", force
	save "$DTA/temp0.dta", replace
}

append using "$DTA\temp.dta", force

*Homologar nombres
replace nombre = subinstr(nombre,".xls","",1)
foreach i in " ab" " s" " o" " mz" " my" " d" " jn" " ag" " e" " f" " jl" " n" " mr" " nd"{ 
	forvalues num=10/16 {  
		replace nombre = subinstr(nombre,"`i'`num'","",1)
	}
}

save "$DTA\Temp por hora (2010-2015).dta", replace
*/


u "$clima\EMAs (2010-2015).dta", clear
**************************
*********Renaming*********
**************************
replace nombre = "Calvillo" if nombre == "calv"| nombre == "calvi"
replace nombre = "Escuela Nacional de Ciencias Biológicas" if nombre == "encb1" 
replace nombre = "La Primavera" if nombre == "la prima"
replace nombre = "Cumbres de Monterrey I" if nombre == "cum mtry1" | nombre == "cum mty1"
replace nombre = "La Malinche II" if nombre == "la malin2"
replace nombre = "La Malinche I" if nombre == "la malin1"
replace nombre = "Valle de Bravo" if nombre == "va bra" | nombre == "va brav"
replace nombre = "Presa Abelardo L. Rodríguez" if nombre == "psa abel"
replace nombre = "Córdoba" if nombre == "cordo"
replace nombre = "Alvarado" if nombre == "alvar"
replace nombre = "Perote" if nombre == "pero" | nombre == "perot"
replace nombre = "Matamoros" if nombre == "matam" | nombre == "mata"
replace nombre = "Acayucan" if nombre == "acayu" | nombre == "acay"
replace nombre = "Hermosillo - Bahia del Kino" if nombre == "herm"| nombre == "hermo"| nombre == "hermos"| nombre == "hermos "
replace nombre = "Nogales" if nombre == "nogal"
replace nombre = "Cozumel" if nombre == "cozu" | nombre == "cozu " | nombre == "cozum"
replace nombre = "Cancun" if nombre == "canc"
replace nombre = "Agustín Melgar" if nombre == "agus" | nombre== "agust"
replace nombre = "Celestun" if nombre == "celes"
replace nombre = "Mexicali" if nombre == "mexic" | nombre== "mexi"
replace nombre = "Instituto Mexicano de Tecnología del Agua" if nombre == "imta" | nombre== "imta mr5"
replace nombre = "Ciudad Cuauhtemoc" if nombre == "cd cuauh" | nombre == "cd cuauht"
replace nombre = "Angamacutiro" if nombre == "anga" | nombre == "angam" | nombre == "angam " | nombre == "angama"  
replace nombre = "La Cangrejera" if nombre == "psa cang" | nombre == "psa cangr" | nombre == "psa cangre"
replace nombre = "Iguala" if nombre == "igua"| nombre == "igual"
replace nombre = "Zihuatanejo" if nombre == "zihua" | nombre == "zihuat"
replace nombre = "Benito Juarez" if nombre == "beni"
replace nombre = "Puerto Escondido" if nombre == "pto esco" | nombre == "pto escon"
replace nombre = "El Veladero" if nombre == "el vela" | nombre == "el velad"
replace nombre = "San Luis Río Colorado" if nombre == "s luis"| nombre == "s luis "
replace nombre = "Presa Emilio Lopez Zamora" if nombre == "psa emil"
replace nombre = "Cabo San Lucas" if nombre == "cab luc" | nombre == "cab lucs"
replace nombre = "Ojinaga" if nombre == "ojina"
replace nombre = "Nueva Rosita" if nombre == "nva rosi" | nombre == "nva rosit"
replace nombre = "San Fernando" if nombre == "s fer" | nombre == "s fern" | nombre == "s ferna" | nombre == "s fernan"
replace nombre = "Ciudad Mante" if nombre == "cd  mant" | nombre == "cd man" | nombre == "cd mant"
replace nombre = "Ciudad Valles" if nombre == "cd vall" | nombre == "cd valle" | nombre == "cd valles"
replace nombre = "Presa Allende" if nombre == "psa alle" | nombre == "psa allen"
replace nombre = "Zacualtipan" if nombre == "zacua" | nombre == "zacual"
replace nombre = "Huauchinango" if nombre == "huauchi"| nombre == "huauchin"
replace nombre = "Huichapan" if nombre == "huicha"
replace nombre = "Zacatecas" if nombre == "zacat"
replace nombre = "Villagran" if nombre == "villag" | nombre == "villagr" | nombre == "villagra"
replace nombre = "Villa Ahumada" if nombre == "v ahum" | nombre == "v ahuma" | nombre == "v ahuam"
replace nombre = "Universidad Tecnologica de Tecamachalco" if nombre == "utt"
replace nombre = "Uruapan" if nombre == "urua"|  nombre == "uruap" 
replace nombre = "Teziutlan" if nombre == "teziu"| nombre == "teziut" 
replace nombre = "Tehuacan" if nombre == "tehua"
replace nombre = "Tizapan" if nombre == "tiza"| nombre == "tizap" 
replace nombre = "Rio Tomatlan" if nombre == "r tomat"| nombre == "r toma" 
replace nombre = "Jose Maria Morelos" if nombre == "jo ma morel"| nombre == "jo ma mor" 
replace nombre = "P. de Centla" if nombre == "p centla"| nombre == "p cent" 
replace nombre = "Los Petenes" if nombre == "los pete"| nombre == "los peten" 
replace nombre = "Monclova" if nombre == "monclo" 
replace nombre = "Calakmul" if nombre == "calak" 
replace nombre = "Palenque" if nombre == "palen" 
replace nombre = "Paraiso" if nombre == "paraís"| nombre == "paraí"| nombre == "paraì"  
replace nombre = "Oxkutzcab" if nombre == "oxku"| nombre == "oxkut"
replace nombre = "Dzilam" if nombre == "dzila" 
replace nombre = "Tizimin" if nombre == "tizim"| nombre == "tizi"
replace nombre = "Tantakin" if nombre == "tantak"
replace nombre = "Rio Lagartos" if nombre == "r laga"| nombre == "r lagar"
	
	**************************************
	************Assigning code************
	**************************************
	replace cve = "01003" if nombre == "Calvillo"
	replace cve = "19039" if nombre == "Cumbres de Monterrey I"
	replace cve = "29042" if nombre == "La Malinche I" 
	*replace cve = "30039" if nombre == "La Cangrejera" /// Mun de Coatza, pero podría haber uno más cerca
	*replace cve = "12001" if nombre == "El Veladero" /// Mun de Acapulco, pero podría haber uno más cerca
	*replace cve = "21114" if nombre == "La Malinche II" /// Mun de Puebla, pero podría haber uno más cerca
	*replace cve = "14039" if nombre == "La Primavera" /// Mun de GLJ, pero podría haber uno más cerca
	replace cve = "20293" if nombre == "Benito Juarez"
	replace cve = "15110" if nombre == "Valle de Bravo"
	replace cve= "02004" if nombre == "Presa Abelardo L. Rodríguez"
	replace cve= "30011" if nombre == "Alvarado"
	replace cve= "30044" if nombre == "Córdoba"
	replace cve= "30128" if nombre == "Perote"
	replace cve= "28022" if nombre == "Matamoros"
	replace cve= "30003" if nombre == "Acayucan"
	replace cve = "26030" if nombre == "Hermosillo - Bahia del Kino"
	replace cve= "26043" if nombre == "Nogales"
	replace cve  = "23001" if nombre == "Cozumel"
	replace cve  = "23005" if nombre == "Cancun"
	replace cve  = "10015" if nombre == "Agustín Melgar"
	replace cve  = "31011" if nombre == "Celestun"
	replace cve  = "02002" if nombre == "Mexicali"
	replace cve  = "17011" if nombre == "Instituto Mexicano de Tecnología del Agua"
	replace cve  = "08017" if nombre == "Ciudad Cuauhtemoc"
	replace cve  = "16004" if nombre == "Angamacutiro"
	replace cve = "12035" if nombre == "Iguala"
	replace cve = "12038" if nombre == "Zihuatanejo"
	replace cve = "20318" if nombre == "Puerto Escondido"
	replace cve = "26055" if nombre == "San Luis Río Colorado"
	replace cve = "02001" if nombre == "Presa Emilio Lopez Zamora"
	replace cve = "03008" if nombre == "Cabo San Lucas"
	replace cve = "08052" if nombre== "Ojinaga"
	replace cve ="05032" if nombre == "Nueva Rosita"
	replace cve ="28035" if nombre == "San Fernando"
	replace cve ="28021" if nombre == "Ciudad Mante"
	replace cve = "24013" if nombre == "Ciudad Valles"
	replace cve = "11003" if nombre == "Presa Allende"
	replace cve = "13081" if nombre == "Zacualtipan"
	replace cve = "21071" if nombre == "Huauchinango"
	replace cve = "13029" if nombre == "Huichapan"
	replace cve = "32017" if nombre == "Zacatecas"
	replace cve = "28042" if nombre == "Villagran"
	replace cve = "08001" if nombre == "Villa Ahumada"
	replace cve = "21154" if nombre == "Universidad Tecnologica de Tecamachalco"
	replace cve = "16102" if nombre == "Uruapan"
	replace cve_edo = "09" if nombre == "Escuela Nacional de Ciencias Biológicas"

	save "$DTA\EMAs (2010-2015).dta", replace 

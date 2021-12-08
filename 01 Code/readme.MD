### 00_Cleaning_ATUS.do

- Author: Hugo Salas
- Purpose: Systematically imports and cleans ATUS data 
- Data source: ATUS - Accidentes de Tránsito Urbanos y Suburbanos (1997-2015) - INEGI
- Windows version
- Worked on Stata 14

### 01_Cleaning_PF.do

- Author: Hugo Salas
- Purpose: Systematically imports and gathers Policía Federal's data 
- Data source: Accidentes de Tránsito Urbanos y Suburbanos (1997-2015)
- Windows version
- Worked on Stata 14
    
### 02_Weekdays_Population_Data.do

- Author: Hugo Salas
- Purpose: Clean and prepare two databases: SEMANA (identifies each day of  with its correspondent day of the week) and pobINEGI (has information  of population per municipality)
- Data source: SEMANA.XLSX and pobINEGImun.dta
- Windows version
- Worked on Stata 14
    
### 03_Merging_ATUS_PF.do

- Author: Hugo Salas
- Purpose: Puts ATUS and PF together. Additionally, it identifies the municipalities that are part of a metropolitan area in MX.
- Data source: Cleaned ATUS, cleaned PF
- Windows version
- Worked on Stata 14
    
### 04_Preparando_RDD.do

- Author: Hugo Salas
- Purpose: Modifies ATUS_PF so it could be used to estimate the RD model: creates new variables, fills up blanks (tsfill), merges with weather and population variables, among others.
- Data source: Cleaned ATUS, cleaned 
- Windows version
- Worked on Stata 14

### 05_Preparando_DID1_QRoo.do

- Author: Hugo Salas
- Purpose: Prepare ATUS database for the Differences in Differences estimations 
- Data source: Accidentes de Tránsito Urbanos y Suburbanos (1997-2015)
- Windows version
- Worked on Stata 14
    
### 06_Preparando_DID2_Son.do

- Author: Hugo Salas
- Purpose: Prepare ATUS database for the Differences in Differences estimatio for the Sonora Experiment 
- Data source: Accidentes de Tránsito Urbanos y Suburbanos (1997-2015)
- Windows version
- Worked on Stata 14

### 061_Graphs_Paper.do

- Author: Hugo Salas
- Purpose: Makes Figures out of all the databases.
- Data source: All databases in these subfolders
- Windows version
- Worked on Stata 14
    
### 06666_Graphs.do

- Author: Hugo Salas
- Purpose: Makes Figures out of all the databases.
- Data source: All databases in these subfolders
- Windows version
- Worked on Stata 14

### 071_Estimaciones_RDD_Paper.do

- Author: Hugo Salas
- Purpose: Estimates Regression Discontinuity Models 
- Data source: Cleaned ATUS, cleaned PF
- Windows version
- Worked on Stata 14
  
### 072_Estimaciones_DnD_Paper.do

- Author: Hugo Salas
- Purpose: Estimates the Differences in Differences Model
- Data source: Cleaned ATUS, cleaned PF
- Windows version
- Worked on Stata 14
    
### 07777_Estimaciones_DIFF.do

- Author: Hugo Salas
- Purpose: Estimates the three regression models
- Data source: Cleaned ATUS, cleaned PF
- Windows version
- Worked on Stata 14

### 07777_Estimaciones_RDD.do

- Author: Hugo Salas
- Purpose: Estimates the three regression models
- Data source: Cleaned ATUS, cleaned PF
- Windows version
- Worked on Stata 14

/************************
	Nathaniel Cross
		PA 594
    Capstone Project
		  ---
    Data Analysis:
 Partisanship regression
************************/

cd "C:\Users\ndmcr\Desktop\MPP Capstone"
set more off
clear all

*Make directory
mkdir "Data\Other data\ACS_temp"

**# ACS DATA

**2006

*Load data
infile using "Data\Original data\ACS\ACS2006_R50135583.dct", using("Data\Original data\ACS\R50135583_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2006.dta", replace


**2007

*Load data
infile using "Data\Original data\ACS\ACS2007_R50135582.dct", using("Data\Original data\ACS\R50135582_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2007.dta", replace


**2008

*Load data
infile using "Data\Original data\ACS\ACS2008_R50135581.dct", using("Data\Original data\ACS\R50135581_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2008.dta", replace


**2009

*Load data
infile using "Data\Original data\ACS\ACS2009_R50135580.dct", using("Data\Original data\ACS\R50135580_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2009.dta", replace


**2010

*Load data
infile using "Data\Original data\ACS\ACS2010_R50135579.dct", using("Data\Original data\ACS\R50135579_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2010.dta", replace


**2011

*Load data
infile using "Data\Original data\ACS\ACS2011_R50135575.dct", using("Data\Original data\ACS\R50135575_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2011.dta", replace


**2012

*Load data
infile using "Data\Original data\ACS\ACS2012_R50135574.dct", using("Data\Original data\ACS\R50135574_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2012.dta", replace


**2013

*Load data
infile using "Data\Original data\ACS\ACS2013_R50135572.dct", using("Data\Original data\ACS\R50135572_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2013.dta", replace


**2014

*Load data
infile using "Data\Original data\ACS\ACS2014_R50135571.dct", using("Data\Original data\ACS\R50135571_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2014.dta", replace


**2015

*Load data
infile using "Data\Original data\ACS\ACS2015_R50135569.dct", using("Data\Original data\ACS\R50135569_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2015.dta", replace


**2016

*Load data
infile using "Data\Original data\ACS\ACS2016_R50135568.dct", using("Data\Original data\ACS\R50135568_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2016.dta", replace


**2017

*Load data
infile using "Data\Original data\ACS\ACS2017_R50135567.dct", using("Data\Original data\ACS\R50135567_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2017.dta", replace


**2018

*Load data
infile using "Data\Original data\ACS\ACS2018_R50135566.dct", using("Data\Original data\ACS\R50135566_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2018.dta", replace


**2019

*Load data
infile using "Data\Original data\ACS\ACS2019_R50135558.dct", using("Data\Original data\ACS\R50135558_SL040.txt") clear

*Drop unneeded vars
drop Geo__geoid_ Geo_FILEID Geo_SUMLEV Geo_GEOCOMP Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_CDCURR Geo_SLDU Geo_SLDL Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_PUMA5 Geo_BTTR Geo_BTBG Geo_qname

drop SE*

keep Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003

*Rename vars
rename (Geo_NAME Geo_STUSAB PCT_SE_A06001_003 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003) (state id p_foreign_born p_latino p_white p_unemp)

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2019.dta", replace


**Other prep

*Add year identifier to each set
forvalues t = 2006/2019 {
	use "Data\Other data\ACS_temp\acs`t'.dta", clear
	gen year = `t'
	save "Data\Other data\ACS_temp\acs`t'.dta", replace
}

*Append sets
use "Data\Other data\ACS_temp\acs2006.dta", clear

forvalues t = 2007/2019 {
	append using "Data\Other data\ACS_temp\acs`t'.dta"
	erase "Data\Other data\ACS_temp\acs`t'.dta"
}

*Accuracy check
tab year

*Remove temp wd
erase "Data\Other data\ACS_temp\acs2006.dta"
rmdir "Data\Other data\ACS_temp"

*Clean up master dataset
order state id year
tab id

replace id = strupper(id)
tab id

tab state
drop if state == "Puerto Rico"

*Save data
save "Data\Other data\Partisanship_ACS.dta", replace

**# PARTISANSHIP DATA

*Load data
import delimited "Data\Original data\Partisan_balance", varnames(1) clear

*Drop unneeded vars
keep year state sen_dem_in_sess sen_rep_in_sess hs_dem_in_sess hs_rep_in_sess govparty_c leg_cont government_cont

*Sort
sort year state
tab year
keep if year >= 2000
tab year
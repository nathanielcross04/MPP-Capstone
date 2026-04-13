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

*Create 2006 frame for imputation
preserve
keep if year == 2006
save "Data\Other data\ACS2006temp.dta", replace
restore

*Save data
save "Data\Other data\Partisanship_ACS.dta", replace

**Load 2000 census data
infile using "Data\Original data\ACS\C2000_R50135804.dct", using("Data\Original data\ACS\R50135804_SL040.txt") clear

*Drop unneeded vars
drop Geo_QName Geo_AREALAND Geo_AREAWATR Geo_SUMLEV Geo_GEOCOMP Geo_REGION Geo_DIVISION Geo_FIPS Geo_STATE

drop SE*

keep Geo_NAME PCT_SE_T015_010 PCT_SE_T201_003 PCT_SE_T014_002 PCT_SE_T073_003

*Rename vars
rename (Geo_NAME PCT_SE_T015_010 PCT_SE_T201_003 PCT_SE_T014_002 PCT_SE_T073_003) (state p_latino2000 p_foreign_born2000 p_white2000 p_unemp2000)

*Resize columns
recol

*Add year identifier
gen year = 2000

*Order data
order state year 

*Merge data
merge 1:1 state using "Data\Other data\ACS2006temp"
drop if state == "Puerto Rico"
drop _merge

*Order data
order state id year

*Impute proportions for each year 2001-2005
forvalues t = 2001/2005 {
	local steps = `t' - 2000
	gen p_latino`t' = p_latino2000 + (`steps' * ((p_latino - p_latino2000) / 6))
	gen p_foreign_born`t' = p_foreign_born2000 + (`steps' * ((p_foreign_born - p_foreign_born2000) / 6))
	gen p_unemp`t' = p_unemp2000 + (`steps' * ((p_unemp - p_unemp2000) / 6))
	gen p_white`t' = p_white2000 + (`steps' * ((p_white - p_white2000) / 6))
}

order state id year p_foreign_born* p_latino* p_white* p_unemp*
drop p_foreign_born p_latino p_white p_unemp
drop year

*Reshape data long
reshape long p_foreign_born p_latino p_white p_unemp, i(state) j(year)

*Sort data
sort year state

*Save data
save "Data\Other data\Census2000-05", replace

*Clean up wd
erase "Data\Other data\ACS2006temp.dta"

**# PARTISANSHIP DATA

*Convert data to append to .dta
import delimited "Data\Original data\Partisanship_extended", varnames(1) clear
save "Data\Original data\Partisanship_extended.dta", replace

*Load data
import delimited "Data\Original data\Partisan_balance", varnames(1) clear

*Drop unneeded vars
keep year state sen_dem_in_sess sen_rep_in_sess hs_dem_in_sess hs_rep_in_sess govparty_c leg_cont government_cont sen_tot_in_sess hs_tot_in_sess

/*
leg_cont
	Additive scale of Democratic power in the legislature.  
	1 = Democratic control of both chambers, 0 = Republican control of both chambers, .5 = Democrats control one chamber, Republicans the other, .25 = Republican control of one chamber, split control of the other, .75 = Democratic control of one chamber, split control of the other.  

government_cont
	Additive scale of Democratic control of three institutions: each chamber of the state legislature and the governor's office.  
	1 = Democratic control of all three institutions, 0 = Republican control of all three institutions, .33 = Democratic control of one institution, Republican control of the other two, etc.  
*/

*Sort
sort year state
tab year
keep if year >= 2000
tab year

*Recode splits
tab leg_cont
replace leg_cont = 0.5 if leg_cont > 0 & leg_cont < 1
tab leg_cont

*Missings
tab govparty_c, m
tab leg_cont, m
drop if govparty_c == .
tab govparty_c, m
tab leg_cont, m

*Append 2015-2019 data
append using "Data\Original data\Partisanship_extended.dta"

*Clean dataset
keep state year leg_cont govparty_c

*Calculate total state government control
tab govparty_c, m
gen govt_cont = ((leg_cont * 2) + govparty_c) / 3 if govparty_c != 0.5
tab govt_cont
replace govt_cont = 0.33333333 if govparty_c == 0.5 & leg_cont == 0
replace govt_cont = 0.66666667 if govparty_c == 0.5 & leg_cont == 1
replace govt_cont = 0.5  	   if govparty_c == 0.5 & leg_cont == 0.5
tab govt_cont, m

list state if govt_cont == . //Only Nebraska, non-partisan legislature

*Order data
order year state leg_cont govparty_c

*Save data
save "Data\Other data\partisan_balance.dta", replace



**# ALL DATA TOGETHER!!

*Load data
use "Data\Other data\Partisanship_ACS", clear

*Append missing demo data for 2000-2005
append using "Data\Other data\Census2000-05"

sort year state
tab state
tab year

erase "Data\Other data\Census2000-05.dta"

*Merge partisanship data
merge 1:1 state year using "Data\Other data\partisan_balance"

list state year if _merge == 1
drop if state == "District of Columbia"

tab _merge
drop _merge

*Save data
save "Data\Other data\Partisanship_all", replace
erase "Data\Other data\Partisanship_ACS.dta"
erase "Data\Other data\partisan_balance.dta"



**# MERGE CLUSTER IDS

*Load data
use "Data\Other data\Partisanship_all", clear

*Merge 
merge 1:1 state year using "Data\Other data\Medoids"

list state if _merge == 2
drop if state == "District of Columbia"

tab _merge
drop _merge

*Clean
drop id_no medoid_rank1 medoid_rank2

*Run probit
probit state_cluster_id p_foreign_born p_latino p_white p_unemp leg_cont

xtset 

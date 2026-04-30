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
infile using "Data\Original data\ACS\ACS2006_R50140069.dct", using("Data\Original data\ACS\R50140069_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002


*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2006.dta", replace


**2007

*Load data
infile using "Data\Original data\ACS\ACS2007_R50140068.dct", using("Data\Original data\ACS\R50140068_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2007.dta", replace


**2008

*Load data
infile using "Data\Original data\ACS\ACS2008_R50140067.dct", using("Data\Original data\ACS\R50140067_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2008.dta", replace


**2009

*Load data
infile using "Data\Original data\ACS\ACS2009_R50140066.dct", using("Data\Original data\ACS\R50140066_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2009.dta", replace


**2010

*Load data
infile using "Data\Original data\ACS\ACS2010_R50140065.dct", using("Data\Original data\ACS\R50140065_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2010.dta", replace


**2011

*Load data
infile using "Data\Original data\ACS\ACS2011_R50140064.dct", using("Data\Original data\ACS\R50140064_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2011.dta", replace


**2012

*Load data
infile using "Data\Original data\ACS\ACS2012_R50140063.dct", using("Data\Original data\ACS\R50140063_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2012.dta", replace


**2013

*Load data
infile using "Data\Original data\ACS\ACS2013_R50140062.dct", using("Data\Original data\ACS\R50140062_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2013.dta", replace


**2014

*Load data
infile using "Data\Original data\ACS\ACS2014_R50140061.dct", using("Data\Original data\ACS\R50140061_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2014.dta", replace


**2015

*Load data
infile using "Data\Original data\ACS\ACS2015_R50140060.dct", using("Data\Original data\ACS\R50140060_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2015.dta", replace


**2016

*Load data
infile using "Data\Original data\ACS\ACS2016_R50140059.dct", using("Data\Original data\ACS\R50140059_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2016.dta", replace


**2017

*Load data
infile using "Data\Original data\ACS\ACS2017_R50140058.dct", using("Data\Original data\ACS\R50140058_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2017.dta", replace


**2018

*Load data
infile using "Data\Original data\ACS\ACS2018_R50140057.dct", using("Data\Original data\ACS\R50140057_SL040.txt") clear

*Drop unneeded vars
drop Geo_FIPS Geo_GEOID Geo_QName Geo_SUMLEV Geo_GEOCOMP Geo_FILEID Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_PLACESE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_UACP Geo_CDCURR Geo_SLDU Geo_SLDL Geo_VTD Geo_ZCTA3 Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_TAZ Geo_UGA Geo_PUMA5 Geo_PUMA1

keep Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_NAME Geo_STUSAB SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003  PCT_SE_A13003B_002) (state id pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

*Resize columns
recol

*Save data
save "Data\Other data\ACS_temp\acs2018.dta", replace


**2019

*Load data
infile using "Data\Original data\ACS\ACS2019_R50139872.dct", using("Data\Original data\ACS\R50139872_SL040.txt") clear

*Drop unneeded vars
drop Geo__geoid_ Geo_FILEID Geo_SUMLEV Geo_GEOCOMP Geo_LOGRECNO Geo_US Geo_REGION Geo_DIVISION Geo_STATECE Geo_STATE Geo_COUNTY Geo_COUSUB Geo_PLACE Geo_TRACT Geo_BLKGRP Geo_CONCIT Geo_AIANHH Geo_AIANHHFP Geo_AIHHTLI Geo_AITSCE Geo_AITS Geo_ANRC Geo_CBSA Geo_CSA Geo_METDIV Geo_MACC Geo_MEMI Geo_NECTA Geo_CNECTA Geo_NECTADIV Geo_UA Geo_CDCURR Geo_SLDU Geo_SLDL Geo_ZCTA5 Geo_SUBMCD Geo_SDELM Geo_SDSEC Geo_SDUNI Geo_UR Geo_PCI Geo_PUMA5 Geo_BTTR Geo_BTBG Geo_qname

keep Geo_STUSAB Geo_NAME SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013 PCT_SE_A13003B_002

*Rename vars
rename (Geo_STUSAB Geo_NAME SE_A00001_001 PCT_SE_A04001_010 PCT_SE_A03001_002 PCT_SE_A17005_003 PCT_SE_A06001_003 PCT_SE_A13003B_002) (id state pop p_latino p_white p_unemp p_foreign_born p_poverty)

*Gen aggregate age var
gen p_old = PCT_SE_A01001_011 + PCT_SE_A01001_012 + PCT_SE_A01001_013
drop PCT_SE_A01001_011 PCT_SE_A01001_012 PCT_SE_A01001_013

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
infile using "Data\Original data\ACS\C2000_R50139873.dct", using("Data\Original data\ACS\R50139873_SL040.txt") clear

*Drop unneeded vars
drop Geo_QName Geo_AREALAND Geo_AREAWATR Geo_SUMLEV Geo_GEOCOMP Geo_REGION Geo_DIVISION Geo_FIPS Geo_STATE

keep Geo_NAME SE_T001_001 PCT_SE_T015_010 PCT_SE_T014_002 PCT_SE_T073_003 PCT_SE_T201_003 PCT_SE_T008_011 PCT_SE_T008_012 PCT_SE_T008_013 PCT_SE_T181_002

*Rename vars
rename (Geo_NAME SE_T001_001 PCT_SE_T015_010 PCT_SE_T014_002 PCT_SE_T073_003 PCT_SE_T201_003 PCT_SE_T181_002) (state pop2000 p_latino2000 p_white2000 p_unemp2000 p_foreign_born2000 p_poverty2000)

*Gen aggregate age var
gen p_old2000 = PCT_SE_T008_011 + PCT_SE_T008_012 + PCT_SE_T008_013
drop PCT_SE_T008_011 PCT_SE_T008_012 PCT_SE_T008_013

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
	gen pop`t' = pop2000 + (`steps' * ((pop - pop2000) / 6))
	gen p_poverty`t' = p_poverty2000 + (`steps' * ((p_poverty - p_poverty2000) / 6))
	gen p_old`t' = p_old2000 + (`steps' * ((p_old - p_old2000) / 6))
}

order state id year p_foreign_born* p_latino* p_white* p_unemp*
drop p_foreign_born p_latino p_white p_unemp pop p_poverty p_old
drop year

*Reshape data long
reshape long p_foreign_born p_latino p_white p_unemp pop p_poverty p_old, i(state) j(year)

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



**# UNDOCUMENTED DATA

*Load original data
import delimited "Data\Original data\CMS-data-undoc-state_2010-2019", varnames(1) clear

*Tostring
destring total, replace ignore(",")

*Save data
save "Data\Other data\undoc1.dta", replace

*Load secondary data
import delimited "Data\Original Data\undoc_extended", varnames(1) clear

*Impute for 2001-2005
keep if year == 2000 | year == 2006

*Reshape wide
reshape wide total, i(state) j(year)

forvalues t = 2001/2005 {
	local steps = `t' - 2000
	gen total`t' = total2000 + (`steps' * ((total2006 - total2000) / 6))
}

drop total2000 total2006 total2005

*Pivot long
reshape long total, i(state) j(year)

*Save data
save "Data\Other data\undoc_imp", replace

*Append all sets together
import delimited "Data\Original Data\undoc_extended", varnames(1) clear
append using "Data\Other data\undoc_imp"

*Rescale undoc
sum total
replace total = total * 1000
sum total

*Append original data
append using "Data\Other data\undoc1.dta"

*Sort
sort year state
tab year, m
tab state, m

drop if state == ""
drop if year == .

*Save final set
save "Data\Other data\undoc_final", replace

*Clean temp files
erase "Data\Other data\undoc1.dta"
erase "Data\Other data\undoc_imp.dta"
	

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

*Merge undoc data
merge 1:1 state year using "Data\Other data\undoc_final"

list state year if _merge == 2
drop if state == "District of Columbia"

tab _merge
drop _merge

*Gen prop undoc var
gen p_undoc = total / pop
drop total

*Save data
save "Data\Other data\Partisanship_all", replace
erase "Data\Other data\Partisanship_ACS.dta"
erase "Data\Other data\partisan_balance.dta"
erase "Data\Other data\undoc_final.dta"


**# MERGE CLUSTER IDS

*Load data
use "Data\Final data\state_distances (raw and deltas)", clear

*Cleaning and reshape
keep state cluster* dist_1cs* dist_own* extremity*
drop dist_1cs_delta_* dist_own_delta_* extremity_delta_*

reshape long cluster_ dist_1cs_ dist_own_ extremity_, i(state) j(year)

*Merge 
merge 1:1 state year using "Data\Other data\Partisanship_all"

list state if _merge == 1
drop if state == "District of Columbia"

tab _merge
drop _merge

*Clean
rename cluster_ cluster
rename dist_1cs_ dist_1cs
rename dist_own_ dist_own
rename extremity_ extremity

*Gen unit id
sort state
egen id_no = group(state)
order id_no state id year

*Prep for reg
xtset id_no year
replace cluster = cluster - 1



**# REGRESSIONS

*Run probit for group identification
xtlogit cluster govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old, or //VALID
xtlogit cluster govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old i.year, fe or //VALID

*Run reg for extremity (FE)
forvalues i = 0/1 {
	preserve
	keep if cluster == `i'
	xtreg dist_own govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old i.year, fe vce(cluster state) 
	xtreg extremity govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old i.year, fe vce(cluster state) 
	restore
} //Gov party strongly predicts cluster 2 distances, not cluster 1


*Visualization
eststo clear
eststo reg1: xtlogit cluster govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old, or
eststo reg2: xtlogit cluster govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old i.year, fe or
esttab reg1 reg2 using "Figures/xtlogit.rtf", se replace nogap onecell title({\b Table X.} Odds ratios for determinants of cluster membership)


forvalues i = 0/1 {
	preserve
	keep if cluster == `i'
	local c = `i' + 1
	eststo clear
	eststo reg1: xtreg dist_own govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old i.year, fe vce(cluster state) 
	eststo reg2: xtreg extremity govt_cont pop p_latino p_white p_unemp p_foreign_born p_undoc p_poverty p_old i.year, fe vce(cluster state) 
	esttab reg1 reg2 using "Figures/xtreg_clust`c'.rtf", se replace nogap onecell title({\b Table X.} Coefficients of policy determinants on two-cluster solution euclidian distances, Cluster `c')
	restore
}
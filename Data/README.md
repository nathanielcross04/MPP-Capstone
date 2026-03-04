# Data

The final dataset published in this repository is secondary data, adapted from the Urban Institute's State Immigration Policy Resource, which can be found [here](https://www.urban.org/data-tools/state-immigration-policy-resource).

The constructed set is a long panel dataset spanning 27 variables and 1,071 observations. Two variables (`state` and `year`) uniquely identify every observation in the dataset, and these identifiers span all 50 states and the District of Columbia and most years from 2000 to 2020. Some variables are only coded until 2017 or 2019 and therefore have missings due to data availability and coding timelines. Despite this, the data remains a strongly-balanced panel.

Twenty-five policy dimensions make up the majority of the dataset, spanning three overarching facets of immigration policies that vary at the state level:  enforcement, public benefits, and integration. Descriptions of all variables, as well as their potential values, can be found in the codebook.

### Data construction
This dataset was constructed by extracting 25 distinct policy frames from the original data, recoding, cleaning, and pivoting these frames to distinct .dta files before merging all frames together to create the final panel dataset. Data integrity was ensured through ronust missings investigations and other checks to ensure accurate pivoting and merging of the original spreadsheets.

### Data roadmap
<pre>
Data/
├── Final data/
    ├── State immigration policies.csv
    └── State immigration policies.dta
├── Original data/                                      
    ├── State to State ID crosswalk.csv
    ├── Updated_Enforcement_Policies_Data.xlsx          ← Original Urban Institute spreadsheet
    ├── Updated_Integration_Policies_Data.xlsx          ← Original Urban Institute spreadsheet
    └── Updated_Public_Benefits_Policies_Data.xlsx      ← Original Urban Institute spreadsheet
├── Codebook.md                                         ← Dataset codebook, outlining variable names and descriptions
└── README.md                                           ← Dataset documentation, including construction, roadmap and references
</pre>

### References
- Julia Gelatt, Hamutal Bernstein, Heather Koball, Charmaine Runes, & Eleanor Pratt. (2017). *State Immigration Policy Resource* (Version 1) \[Dataset]. UrbanInstitute/state-immigration. github.com/UrbanInstitute/state-immigration

- Hamutal Bernstein, Paola Echave, Heather Koball, Joseph Stinson, & Susi Martinez. (2022). *State Immigration Policy Resource (2022 update)* (Version 2) \[Dataset]. UrbanInstitute/state-immigration. github.com/UrbanInstitute/state-immigration

- The original Urban Institute repo can be found [here](https://github.com/UrbanInstitute/state-immigration).

REFERENCE : https://about.usps.com/who/profile/history/state-abbreviations.htm

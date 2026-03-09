/************************
	Nathaniel Cross
		PA 594
    Capstone Project
		  ---
     Data Analysis
************************/

cd "C:\Users\ndmcr\Desktop\MPP Capstone"
set more off
clear all

**#***CLEANING/VARIABLE MANIPULATION***

*Load data
use "Data\Final data\State immigration policies.dta", clear

**Standardize ternary variables

*Identify ternary variables
sum *
/*
enf_tas~287g |      1,071    .1176471    .4484412          0          2
enf_war~287g |      1,071    .0046685     .080748          0          2
enf_jai~287g |      1,071     .210084     .518563          0          2
enf_lim_co~s |      1,019    .2816487    .6470174          0          2
 enf_everify |        867     .254902    .5793469          0          2
*/

*Create macro of variables needing standarization
global standardize_vars enf_task_force_287g enf_warrant_287g enf_jail_287g enf_lim_coop_detainers enf_everify

*Run standardization loop
foreach var of varlist $standardize_vars {
	tab `var'
	replace `var' = `var' / 2
	tab `var'
}

*Save standardized data
save "Data\Other data\Standardized SIPs", replace

**Identify variables with limited unit variance (e.g. federal mandate)

*Create macro for policy variables
global policy_vars enf_warrant_287g enf_jail_287g ///
	enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify ///
	enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids ///
	pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids /// 
	pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult ///
	pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 /// 
	int_instate_tuition int_state_finaid int_uni_ban int_official_eng ///
	int_drivers_license

*Create directory
mkdir "Data\Using data"

*Collapse pilot variable by year to yield nationwide average
preserve
collapse (mean) avg_enf_task_force_287g = enf_task_force_287g, by(year)

*Save data
save "Data\Using data\avg_enf_task_force_287g", replace
restore

*Repeat for all variables
foreach var of varlist $policy_vars {
	*Collapse variable by year to yield nationwide average
	preserve
	collapse (mean) avg_`var' = `var', by(year)

	*Save data
	save "Data\Using data\avg_`var'", replace
	restore
}

*Load pilot dataset
use "Data\Using data\avg_enf_task_force_287g", clear

*Merge all other collapsed policy variables
foreach i in $policy_vars {
	merge 1:1 year using "Data\Using data\avg_`i'"
	drop _merge
}

*Clean up directory
erase "Data\Using data\avg_enf_task_force_287g.dta"

foreach i in $policy_vars {
	erase "Data\Using data\avg_`i'.dta"
}

rmdir "Data\Using data"

*Check missingness
missings report
/*
  +----------------------------------------+
  |                              # missing |
  |----------------------------------------|
  | avg_enf_lim_coop_detainers           1 |
  |            avg_enf_everify           4 |
  |      avg_enf_state_omnibus           4 |
  |         avg_pub_tanf_post5           1 |
  |    avg_pub_cashass_during5           1 |
  +----------------------------------------+
*/

*Enforcement variables

*Test correlations
corr avg_enf*
corr avg_enf_everify avg_enf_limits_everify
corr avg_enf_everify avg_enf_state_omnibus
corr avg_enf_limits_everify avg_enf_state_omnibus

corr avg_enf_task_force_287g avg_enf_warrant_287g avg_enf_jail_287g

*Plot average values visually
tsset year
tsline avg_enf*

/* Findings:
- High correlations:
	- Everify & Limits Everify: 		0.9764 
	- Everify & State omnibus:  		0.9410
	- Limits Everify & State omnibus: 	0.9084

- Limited variation:
	- 287(g) WSO model	 				20 non variable observations
	- Secure communities 				17 non variable observations
	- State omnibus 					14 non variable observations

- High missingness
	- Everify							4 years missing
	- State omnibus						4 years missing
*/

*Public benefits variables

*Test correlations
corr avg_pub*
corr avg_pub_cashass_during5 avg_pub_medicaid_lprpreg 
corr avg_pub_cashass_during5 avg_pub_medicaid_unauthpreg
corr avg_pub_foodass_lpradults avg_pub_pubins_lpradults
corr avg_pub_medicaid_lprkids avg_pub_medicaid_lprpreg
corr avg_pub_medicaid_lprpreg avg_pub_medicaid_unauthpreg

*Plot average values visually
tsset year
tsline avg_pub*

/* Findings:
- High correlations:
	- Medicaid LPR kids & Medicaid pregnant LPR:					 0.9494 
	- Cash ass. during 5 yr bar & Medicaid for pregnant unauth:  	-0.9433 
	- Cash ass. during 5 yr bar & Medicaid for pregnant LPRs: 		-0.9411 
 	- Medicaid pregnant LPR & Medicaid pregnant unauth:				 0.9390
	- Food ass. LPR adults & Pub. ins. LPR adults: 					 0.9318 

- Limited variation:
	- Pub. ins. unauth adult	 		20 non variable observations (.01960784)
	- Food ass. LPR kids 				18 non variable observations
*/

*Integration variables

*Test correlations
corr avg_int*

corr avg_int_instate_tuition avg_int_state_finaid

corr avg_int_instate_tuition avg_int_state_finaid avg_int_drivers_license

*Plot average values visually
tsset year
tsline avg_int*

/*Findings:
- Do in-state tuition and state financial aid measure the same concept?
- Are these metrics of educational integration only driven by driver's licenses?
>>> Are unauthorized immigrants residents of the state?
*/

*Investigating whether to average specific integration metrics or keep DL only
preserve
use "Data\Final data\State immigration policies.dta", clear

*Examining patterns in policy vars
keep year state int_instate_tuition int_state_finaid int_drivers_license
order state year int_drivers_license int_instate_tuition int_state_finaid

//No patterns of consistently implementing in-state tuition or state financial aid directly after or correlated to enabling unauthorized immigrants to obtain state DLs

restore

/*Conclusions:
- Drop:
	- avg_enf_warrant_287g
	- avg_pub_foodass_lprkids
	- Secure Communities (???)
	- State omnibus
- Consolidate:
	- Everify & Limits Everify
		- Invert Limits Everify --> average
	- Medicaid LPR kids & Medicaid pregnant LPR
		- Average --> Medicaid vulnerable LPRs
	- In-state tuition, state finaid, and state DL
		--> Are unauth residents?
			- Keep only DL - no
			- Average all  - yes

Total variables dropped: 7
*/

*Saving collapsed dataset
save "Data\Other data\Collapsed policies by year", replace

**Variable transformations 

*Load data
use "Data\Other data\Standardized SIPs", clear

*Drop policy variables
drop enf_warrant_287g
drop enf_state_omnibus
drop pub_foodass_lprkids

**Index variables

**Everify variables
//Everify started in 2006, limitations to Everify in 2007

list state year enf_everify enf_limits_everify if enf_limits_everify == 1 & enf_everify == 0 
/*
      +-----------------------------------------+
      |      state   year   enf_ev~y   enf_li~y |
      |-----------------------------------------|
  96. | California   2011          0          1 |
  97. | California   2012          0          1 |
  98. | California   2013          0          1 |
  99. | California   2014          0          1 |
 100. | California   2015          0          1 |
      |-----------------------------------------|
 101. | California   2016          0          1 |
 281. |   Illinois   2007          0          1 |
 282. |   Illinois   2008          0          1 |
 283. |   Illinois   2009          0          1 |
 284. |   Illinois   2010          0          1 |
      |-----------------------------------------|
 285. |   Illinois   2011          0          1 |
 286. |   Illinois   2012          0          1 |
 287. |   Illinois   2013          0          1 |
 288. |   Illinois   2014          0          1 |
 289. |   Illinois   2015          0          1 |
      |-----------------------------------------|
 290. |   Illinois   2016          0          1 |
      +-----------------------------------------+
*/

list state year enf_everify enf_limits_everify if year < 2012 & id == "CA"
//CA and IL limited Everify before any local Everify mandates were implemented

*Create inverted Limits Everify variable to identify states that could have limited Everify but did not
gen inverted_enf_limits_everify = .
replace inverted_enf_limits_everify = 0 if enf_everify != .
replace inverted_enf_limits_everify = 1 - enf_limits_everify if year >= 2007
replace inverted_enf_limits_everify = . if enf_everify == .

order state id year enf_everify enf_limits_everify inverted_enf_limits_everify

*Create Everify index
gen enf_everify_index = (enf_everify + inverted_enf_limits_everify) / 2

order state id year enf_everify enf_limits_everify inverted_enf_limits_everify enf_everify_index

*Dropping temporary and original variables
drop enf_everify enf_limits_everify inverted_enf_limits_everify

**Medicaid for vulnerable LPRs
gen pub_medicaid_vulnerablelpr = (pub_medicaid_lprkids + pub_medicaid_lprpreg) / 2
drop pub_medicaid_lprkids pub_medicaid_lprpreg

**Resident status for unauthorized immigrants
gen int_unauth_residents = (int_instate_tuition + int_state_finaid + int_drivers_license) / 3
drop int_instate_tuition int_state_finaid int_drivers_license

order state id year enf* pub* int*

**Rerun collapse to chach again for variables to drop

*Create macro for policy variables
global policy_vars enf_task_force_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers pub_tanf_post5 pub_cashass_during5 pub_foodass_lpradults pub_ssi_replacement pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_unauthpreg pub_medicaid_lpr_post5 pub_medicaid_vulnerablelpr int_uni_ban int_official_eng int_unauth_residents

*Create directory
mkdir "Data\Using data"

*Collapse pilot variable by year to yield nationwide average
preserve
collapse (mean) avg_enf_everify_index = enf_everify_index, by(year)

*Save data
save "Data\Using data\avg_enf_everify_index", replace
restore

*Repeat for all variables
foreach var of varlist $policy_vars {
	*Collapse variable by year to yield nationwide average
	preserve
	collapse (mean) avg_`var' = `var', by(year)

	*Save data
	save "Data\Using data\avg_`var'", replace
	restore
}

*Load pilot dataset
use "Data\Using data\avg_enf_everify_index", clear

*Merge all other collapsed policy variables
foreach i in $policy_vars {
	merge 1:1 year using "Data\Using data\avg_`i'"
	drop _merge
}

*Clean up directory
erase "Data\Using data\avg_enf_everify_index.dta"

foreach i in $policy_vars {
	erase "Data\Using data\avg_`i'.dta"
}

rmdir "Data\Using data"


*Test correlations

corr avg_enf*
corr avg_enf_everify_index avg_enf_jail_287g

alpha avg_enf_everify_index avg_enf_jail_287g

corr avg_pub*
corr avg_pub_foodass_lpradults avg_pub_pubins_lpradults
corr avg_pub_pubins_unauthkids avg_pub_pubins_unauthadult
corr avg_pub_cashass_during5 avg_pub_medicaid_vulnerablelpr 
corr avg_pub_cashass_during5 avg_pub_medicaid_unauthpreg

alpha avg_pub_cashass_during5 avg_pub_medicaid_unauthpreg

*Visualizations
tsset year
tsline avg_enf*
tsline avg_pub*

/*Findings:
- Drop SC
- Potentially drop pub ins. unauth adult

*/














**#***DATASET INVESTIGATION***






codebook

*Investigate missingness
missings report

*Descriptive statistics

































**#***ANALYSIS***

**Prepare for analysis




keep if year == 2000

global varlist enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_medicaid_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license

corr $varlist

*Principal-component analysis
pca $varlist
	
*Scree plots
screeplot, yline(1)

*PCA
pca $varlist, mineigen(1)
pca $varlist, comp(4)

pca $varlist, mineigen(1) blanks(0.3)

*Rotations
rotate, varimax
rotate, varimax blanks(0.3)
rotate, clear

rotate, promax
rotate, promax blanks(0.3)
rotate, clear

*Plots
loadingplot
scoreplot, mlabel(state)

*Loadings/scores of the components
estat loadings
predict pc1 pc2 pc3 pc4 pc5, score

*KMO measure of sampling adequacy
estat kmo

**#END
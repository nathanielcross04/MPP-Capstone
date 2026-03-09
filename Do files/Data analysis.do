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

**#***DATASET INVESTIGATION***


codebook

*Investigate missingness
missings report

*Descriptive statistics



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

*Plot average values visually
tsline avg_int*

/*Findings:
- 
*/


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
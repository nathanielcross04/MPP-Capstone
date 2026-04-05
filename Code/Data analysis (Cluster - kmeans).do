/************************
	Nathaniel Cross
		PA 594
    Capstone Project
		  ---
    Data Analysis:
   Cluster (k-means)
************************/

cd "C:\Users\ndmcr\Desktop\MPP Capstone"
set more off
clear all

**#***DATASET PREP
use "Data\Other data\Standardized SIPs", clear

*Clean missings
drop if year == 2020
missings report *

replace enf_lim_coop_detainers = 0.5 if enf_lim_coop_detainers == .
missings report *

replace enf_state_omnibus = 0 if enf_state_omnibus == .
missings report *

egen id_no = group(state)
sum id_no
order id_no
sort id_no year

xtset id_no year

sum enf_everify if year == 2016

sum enf_everify if year == 2017
replace enf_everify = enf_everify[_n-1] if year == 2017
sum enf_everify if year == 2017

sum enf_everify if year == 2018
replace enf_everify = enf_everify[_n-2] if year == 2018
sum enf_everify if year == 2018

sum enf_everify if year == 2019
replace enf_everify = enf_everify[_n-3] if year == 2019
sum enf_everify if year == 2019

missings report *

/*Create year frames
forvalues t = 2000(1)2019 {
	preserve
	keep if year == `t'
	save "Data\Other data\Policy vectors by year\policy_vectors_`t'", replace
	restore
} */

*Save data
save "Data\Other data\Policy vectors (std) (nomiss)", replace

*Make temporary directory for merges
mkdir "Data\Other data\Cluster solutions (temp)"

*Create vector of policy vars
vl clear
vl create policies = (enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license)

*Run loop to find cluster solutions and identify centroids of each year
forvalues t = 2000(1)2019 {

	**Two cluster solution

	*Load data
	use "Data\Other data\Policy vectors (std) (nomiss)", clear

	*Setup
	keep if year == `t'
	cluster kmeans $policies, k(2) name(state_cluster_id)

	*Within-cluster variance (lower = tighter clusters)
	foreach v of varlist $policies {
		bysort state_cluster_id: egen mean_`v' = mean(`v')
		gen sq_dev_`v' = (`v' - mean_`v')^2
	}
	egen within_ss = rowtotal(sq_dev_*)
	bysort state_cluster_id: egen cluster_wss = sum(within_ss)

	*Total variance
	foreach v of varlist $policies {
		egen gm_`v' = mean(`v')
		gen tsd_`v' = (`v' - gm_`v')^2				 // TSD = Total Squared Deviation
	}
	egen total_ss = rowtotal(tsd_*)
	egen tss = sum(total_ss)

	*Ratio: between-cluster variance explained
	gen between_ss = tss - cluster_wss
	gen r2 = between_ss / tss

	*Order important variables
	order id_no id state year state_cluster_id cluster_wss tss between_ss r2

	*Drop vars
	drop mean_* sq_dev_* gm_* tsd_*
	drop within_ss total_ss

	*Collapse
	collapse (mean) year cluster_wss tss between_ss r2 $policies, by(state_cluster_id)

	*Identify no. of clusters in the solution
	gen cluster_solutions = 2
	order year cluster_solutions state_cluster_id

	*Save 2CS
	save "Data\Other data\Cluster solutions (temp)\TwoCS_`t'", replace

	**One cluster solution

	*Load data
	use "Data\Other data\Policy vectors (std) (nomiss)", clear

	*Setup
	keep if year == `t'
	cluster kmeans $policies, k(1) name(state_cluster_id)

	*Within-cluster variance (lower = tighter clusters)
	foreach v of varlist $policies {
		bysort state_cluster_id: egen mean_`v' = mean(`v')
		gen sq_dev_`v' = (`v' - mean_`v')^2
	}
	egen within_ss = rowtotal(sq_dev_*)
	bysort state_cluster_id: egen cluster_wss = sum(within_ss)

	*Total variance
	foreach v of varlist $policies {
		egen gm_`v' = mean(`v')
		gen tsd_`v' = (`v' - gm_`v')^2				 // TSD = Total Squared Deviation
	}
	egen total_ss = rowtotal(tsd_*)
	egen tss = sum(total_ss)

	*Ratio: between-cluster variance explained
	gen between_ss = tss - cluster_wss
	gen r2 = between_ss / tss

	*Order important variables
	order id_no id state year state_cluster_id cluster_wss tss between_ss r2

	*Drop vars
	drop mean_* sq_dev_* gm_* tsd_*
	drop within_ss total_ss

	*Collapse
	collapse (mean) year state_cluster_id cluster_wss tss between_ss r2 $policies

	*Identify no. of clusters in the solution
	gen cluster_solutions = 1
	order year cluster_solutions state_cluster_id

	*Append 2CS
	append using "Data\Other data\Cluster solutions (temp)\TwoCS_`t'"
	
	*Erase 2CS
	erase "Data\Other data\Cluster solutions (temp)\TwoCS_`t'.dta"

	*Save year cluster solutions
	save "Data\Other data\Cluster solutions (temp)\CS_`t'", replace
}

*Append CS for all years
use "Data\Other data\Cluster solutions (temp)\CS_2000", clear

forvalues t = 2001(1)2019 {
	append using "Data\Other data\Cluster solutions (temp)\CS_`t'"
}

*Accuracy check
tab year
tab cluster_solutions
tab state_cluster_id if cluster_solutions == 2

*Save data
save "Data\Other data\Clusters", replace

*Clean up wd
forvalues t = 2000(1)2019 {
	erase "Data\Other data\Cluster solutions (temp)\CS_`t'.dta"
}

rmdir "Data\Other data\Cluster solutions (temp)"



*Begin analysis
use "Data\Other data\Clusters"

keep if cluster_solutions == 1

tsset year
tsline enf*
tsline pub*
tsline int*

*Identify medoids


























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
	cluster kmeans $policies, k(2) name(state_cluster_id) start(krandom(80504))

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
	cluster kmeans $policies, k(1) name(state_cluster_id) start(krandom(80504))

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
use "Data\Other data\Clusters", clear

keep if cluster_solutions == 1

tsset year

/*
tsline enf*
tsline pub*
tsline int*
*/

**Identify medoids

*One cluster solution

*Load data
use "Data\Other data\Policy vectors (std) (nomiss)", clear

*Setup
keep if year == 2000
cluster kmeans $policies, k(1) name(state_cluster_id) start(krandom(80504))
order state_cluster_id

*Gen mean of each policy as a column
foreach var of varlist $policies {
	sum `var' if state_cluster_id == 1
	gen cm_`var' = `r(mean)' if state_cluster_id == 1
}

*Take difference between each state's policies and mean policy scores
foreach var of varlist $policies {
	gen diff_`var' = abs(`var' - cm_`var')
	drop `var'
	drop cm_`var'
}

*Sum rows across to identify most central and outlier states
egen total_distance = rowtotal(diff*)

*Rank states
egen medoid_rank = rank(total_distance)
extremes medoid_rank id total_distance, n(5)

/* Suggests two cluster solution:
  +---------------------------------+
  | obs:   medoid~k   id   total_~e |
  |---------------------------------|
  |   3.        4.5   AZ   2.705882 |
  |   9.        4.5   DC   2.705882 |
  |  16.        4.5   IA   2.705882 |
  |  17.        4.5   KS   2.705882 |
  |  23.        4.5   MI   2.705882 |
  +---------------------------------+

  +---------------------------------+
  |  20.         47   ME   6.294118 |
  |  28.         48   NE   6.313726 |
  |   5.         49   CA   7.039217 |
  |  22.         50   MA   7.117648 |
  |  48.         51   WA   8.058825 |
  +---------------------------------+
*/

*Two cluster solution

*Make temp directory
mkdir "Data\Other data\Medoids temp"

forvalues t = 2000(1)2019 {
	*Load data
	use "Data\Other data\Policy vectors (std) (nomiss)", clear

	*Setup
	keep if year == `t'
	cluster kmeans $policies, k(2) name(state_cluster_id) start(krandom(80504))
	order state_cluster_id

	*Gen mean of each policy as a column
	foreach var of varlist $policies {
		gen cm_`var' = .
		sum `var' if state_cluster_id == 1
		replace cm_`var' = `r(mean)' if state_cluster_id == 1
		sum `var' if state_cluster_id == 2
		replace cm_`var' = `r(mean)' if state_cluster_id == 2
	}

	*Take difference between each state's policies and mean policy scores
	foreach var of varlist $policies {
		gen diff_`var' = abs(`var' - cm_`var')
		drop `var'
		drop cm_`var'
	}

	*Sum rows across to identify most central and outlier states
	egen total_distance = rowtotal(diff*)

	*Rank states
	egen medoid_rank1 = rank(total_distance) if state_cluster_id == 1
	egen medoid_rank2 = rank(total_distance) if state_cluster_id == 2

	*Keep needed vars
	keep state_cluster_id id_no state id year total_distance medoid_rank1 medoid_rank2

	*Save data
	save "Data\Other data\Medoids temp\medoids_`t'", replace
}

*Merge all sets together
use "Data\Other data\Medoids temp\medoids_2000", clear
	
forvalues t = 2001(1)2019 {
	append using "Data\Other data\Medoids temp\medoids_`t'"
}

*Cleaning wd
forvalues t = 2000(1)2019 {
	erase "Data\Other data\Medoids temp\medoids_`t'.dta"
}

rmdir "Data\Other data\Medoids temp"

**Align clusters

tab state_cluster_id year

*Generate lagged cluster id
bysort state (year): gen lag_cluster = state_cluster_id[_n-1]
order state_cluster_id lag_cluster

*Generate switch indicator
bysort year: gen noswitch = cond(state_cluster_id == lag_cluster, 1, 0)
bysort year: gen switched = cond(state_cluster_id != lag_cluster, 1, 0)
replace noswitch = 1 if year == 2000
replace switched = 0 if year == 2000

bysort year: egen n_noswitch = total(noswitch)
bysort year: egen n_switched = total(switched)

sort year state

bysort year: gen flag = cond(n_switched > n_noswitch, 1, 0)
tab flag

foreach t of numlist 2012 2013 {
	display `t'
	display "Cluster 1"
	list state if state_cluster_id == 1 & year == `t'
	display "Cluster 2"
	list state if state_cluster_id == 2 & year == `t'
}

tab state_cluster_id year

*Clean dataset
drop lag_cluster noswitch switched n_noswitch n_switched flag

*Export data
save "Data\Other data\Medoids", replace

**Visualization prep

*Load data
use "Data\Other data\Medoids", clear

*Identifing medoids
gen mrank1_temp = medoid_rank1
gen mrank2_temp = medoid_rank2

**Medoid 1

*Iteration 1
bysort year: egen min_rank1 = min(mrank1_temp)

bysort year: egen count_minrank1 = total(mrank1_temp == min_rank1)

sum count_minrank1 

gen include1 = .
replace include1 = 1 if mrank1_temp == min_rank1

tab include1 (year)

bysort year: egen total_included = total(include1)

gen continue = 1 if 5 - total_included > 0

tab continue (year), m

replace mrank1_temp = . if mrank1_temp == min_rank1


*Iteration 2
drop min_rank1 count_minrank1 total_included

bysort year: egen min_rank1 = min(mrank1_temp) if continue == 1

bysort year: egen count_minrank1 = total(mrank1_temp == min_rank1) if continue == 1

sum count_minrank1

replace include1 = 1 if mrank1_temp == min_rank1 & continue == 1

tab include1 (year)

drop continue
bysort year: egen total_included = total(include1)
gen continue = 1 if 5 - total_included > 0
tab continue (year), m

replace mrank1_temp = . if mrank1_temp == min_rank1

*Iteration 3
drop min_rank1 count_minrank1 total_included

bysort year: egen min_rank1 = min(mrank1_temp) if continue == 1

bysort year: egen count_minrank1 = total(mrank1_temp == min_rank1) if continue == 1

sum count_minrank1

replace include1 = 1 if mrank1_temp == min_rank1 & continue == 1

tab include1 (year)

drop continue
bysort year: egen total_included = total(include1)
gen continue = 1 if 5 - total_included > 0
tab continue (year), m

replace mrank1_temp = . if mrank1_temp == min_rank1

*Iteration 4
drop min_rank1 count_minrank1 total_included

bysort year: egen min_rank1 = min(mrank1_temp) if continue == 1

bysort year: egen count_minrank1 = total(mrank1_temp == min_rank1) if continue == 1

sum count_minrank1

replace include1 = 1 if mrank1_temp == min_rank1 & continue == 1

tab include1 (year)

drop continue min_rank1 count_minrank1 mrank1_temp

**Medoid 2

*Iteration 1
bysort year: egen min_rank2 = min(mrank2_temp)

bysort year: egen count_minrank2 = total(mrank2_temp == min_rank2)

sum count_minrank2

gen include2 = .
replace include2 = 1 if mrank2_temp == min_rank2

tab include2 (year)

bysort year: egen total_included = total(include2)

gen continue = 1 if 5 - total_included > 0

tab continue (year), m

replace mrank2_temp = . if mrank2_temp == min_rank2

*Iteration 2
drop min_rank2 count_minrank2 total_included

bysort year: egen min_rank2 = min(mrank2_temp) if continue == 1

bysort year: egen count_minrank2 = total(mrank2_temp == min_rank2) if continue == 1

sum count_minrank2

replace include2 = 1 if mrank2_temp == min_rank2 & continue == 1

tab include2 (year)

drop continue
bysort year: egen total_included = total(include2)
gen continue = 1 if 5 - total_included > 0
tab continue (year), m

replace mrank2_temp = . if mrank2_temp == min_rank2

*Iteration 3
drop min_rank2 count_minrank2 total_included

bysort year: egen min_rank2 = min(mrank2_temp) if continue == 1

bysort year: egen count_minrank2 = total(mrank2_temp == min_rank2) if continue == 1

sum count_minrank2

replace include2 = 1 if mrank2_temp == min_rank2 & continue == 1

tab include2 (year)

drop continue
bysort year: egen total_included = total(include2)
gen continue = 1 if 5 - total_included > 0
tab continue (year), m

replace mrank2_temp = . if mrank2_temp == min_rank2

*Iteration 4
drop min_rank2 count_minrank2 total_included

bysort year: egen min_rank2 = min(mrank2_temp) if continue == 1

bysort year: egen count_minrank2 = total(mrank2_temp == min_rank2) if continue == 1

sum count_minrank2

replace include2 = 1 if mrank2_temp == min_rank2 & continue == 1

tab include2 (year)

drop continue
bysort year: egen total_included = total(include2)
gen continue = 1 if 5 - total_included > 0
tab continue (year), m

replace mrank2_temp = . if mrank2_temp == min_rank2

*Iteration 5
drop min_rank2 count_minrank2 total_included

bysort year: egen min_rank2 = min(mrank2_temp) if continue == 1

bysort year: egen count_minrank2 = total(mrank2_temp == min_rank2) if continue == 1

sum count_minrank2

replace include2 = 1 if mrank2_temp == min_rank2 & continue == 1

tab include2 (year)

drop continue
bysort year: egen total_included = total(include2)
gen continue = 1 if 5 - total_included > 0
tab continue (year), m

replace mrank2_temp = . if mrank2_temp == min_rank2

*Clean up data
drop mrank2_temp min_rank2 count_minrank2 total_included continue

*Prep for visualization
gen distance1 = total_distance if include1 == 1
gen distance2 = total_distance if include2 == 1

*Clean up vars
gen include = 1 if include1 == 1 | include2 == 1
gen distance_map = .
replace distance_map = distance1 if distance1 != .
replace distance_map = distance2 if distance2 != .

*Save and export data
save "Data\Other data\Medoids (prep for viz)", replace
export delimited "Data\Other data\Medoids (prep for viz).csv", replace
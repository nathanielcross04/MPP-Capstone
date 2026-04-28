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

**# Identify clusters

*Make temporary directory for merges
mkdir "Data\Other data\Cluster solutions (temp)"

*Run loop to find cluster solutions and identify centroids of each year
forvalues t = 2000(1)2019 {

	**Two cluster solution

	*Load data
	use "Data\Final data\Policy vectors (std) (nomiss)", clear
	
	*Create vector of policy vars
	vl clear
	vl create policies = (enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license)

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
	use "Data\Final data\Policy vectors (std) (nomiss)", clear

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

**# Describe 1CS policies
mkdir "Data\Other data\Cluster_mean_sd"

forvalues t = 2000/2019 {

	**Two cluster solution

	*Load data
	use "Data\Final data\Policy vectors (std) (nomiss)", clear
	
	*Create vector of policy vars
	vl clear
	vl create policies = (enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license)

	*Setup
	keep if year == `t'

	*Calculate mean and SD of each policy collapse
	preserve
		collapse (mean) $policies
		rename ($policies) (=_mean)
		gen year = `t'
		tempfile means
		save `means'
	restore

	collapse (sd) $policies
	rename ($policies) (=_sd)
	gen year = `t'

	merge 1:1 year using `means', nogen

	*Save data
	save "Data\Other data\Cluster_mean_sd\centroids`t'.dta"

}

*Append all sets
use "Data\Other data\Cluster_mean_sd\centroids2000"

forvalues t = 2001/2019 {
	append using "Data\Other data\Cluster_mean_sd\centroids`t'"
	erase "Data\Other data\Cluster_mean_sd\centroids`t'.dta"
}

*Clean wd
erase "Data\Other data\Cluster_mean_sd\centroids2000.dta"
rmdir "Data\Other data\Cluster_mean_sd"

*Clean dataset
order year

*Reshape
reshape long enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license, i(year) j(stat) string

replace stat = subinstr(stat, "_", "", 1)

*Add missings
local policies "enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license"

foreach var in `policies' {
	bysort year (stat): gen byte zero_flag = ///
		(`var'[1] == 0 & `var'[2] == 0)

	replace `var' = . if zero_flag
	drop zero_flag
}

reshape wide

*Identify least SD each year
local sd_policies "enf_task_force_287gsd enf_warrant_287gsd enf_jail_287gsd enf_secure_commssd enf_lim_coop_detainerssd enf_everifysd enf_limits_everifysd enf_state_omnibussd pub_tanf_post5sd pub_cashass_during5sd pub_foodass_lprkidssd pub_foodass_lpradultssd pub_ssi_replacementsd pub_medicaid_lprkidssd pub_pubins_unauthkidssd pub_pubins_lpradultssd pub_pubins_unauthadultsd pub_medicaid_lprpregsd pub_medicaid_unauthpregsd pub_medicaid_lpr_post5sd int_instate_tuitionsd int_state_finaidsd int_uni_bansd int_official_engsd int_drivers_licensesd"
egen min_sd = rowmin(`sd_policies')

foreach var in `sd_policies' {
	gen temp_`var' = `var'
}

foreach var in `sd_policies' {
	replace temp_`var' = . if temp_`var' == min_sd
}

egen min_sd2 = rowmin(temp*)

foreach var in `sd_policies' {
	replace temp_`var' = . if temp_`var' == min_sd2
}

egen min_sd3 = rowmin(temp*)

drop temp*

*Blank out SDs
local policies "enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license"

foreach var in `policies' {
	gen mean_`var' = .
	replace mean_`var' = `var'mean if `var'sd == min_sd
	replace mean_`var' = `var'mean if `var'sd == min_sd2
	replace mean_`var' = `var'mean if `var'sd == min_sd3
}

*Clean up dataset
drop *mean *sd min*
foreach var of varlist _all {
    quietly count if !missing(`var')
    if r(N) == 0 {
        drop `var'
    }
}

*Export
export delimited "Data\Other data\Global_policies.csv", replace



**# Describe cluster policies

mkdir "Data\Other data\Cluster_mean_sd"

forvalues t = 2000/2019 {

	**Two cluster solution

	*Load data
	use "Data\Final data\Policy vectors (std) (nomiss)", clear
	
	*Create vector of policy vars
	vl clear
	vl create policies = (enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license)

	*Setup
	keep if year == `t'
	cluster kmeans $policies, k(2) name(state_cluster_id) start(krandom(80504))

	*Calculate mean and SD of each policy collapse
	preserve
		collapse (mean) $policies, by(state_cluster_id)
		rename ($policies) (mean_=)
		tempfile means
		save `means'
	restore

	collapse (sd) $policies, by(state_cluster_id)
	rename ($policies) (sd_=)

	merge 1:1 state_cluster_id using `means', nogen

	*Gen year id
	gen year = `t'

	*Save data
	save "Data\Other data\Cluster_mean_sd\centroids`t'.dta"

}

*Append all sets
use "Data\Other data\Cluster_mean_sd\centroids2000"

forvalues t = 2001/2019 {
	append using "Data\Other data\Cluster_mean_sd\centroids`t'"
	erase "Data\Other data\Cluster_mean_sd\centroids`t'.dta"
}

*Clean wd
erase "Data\Other data\Cluster_mean_sd\centroids2000.dta"
rmdir "Data\Other data\Cluster_mean_sd"

*Clean set
order state_cluster_id year mean* sd*
sort state_cluster_id year

*Identify null year/policy combos
vl clear
vl create policies = (mean_enf_task_force_287g mean_enf_warrant_287g mean_enf_jail_287g mean_enf_secure_comms mean_enf_lim_coop_detainers mean_enf_everify mean_enf_limits_everify mean_enf_state_omnibus mean_pub_tanf_post5 mean_pub_cashass_during5 mean_pub_foodass_lprkids mean_pub_foodass_lpradults mean_pub_ssi_replacement mean_pub_medicaid_lprkids mean_pub_pubins_unauthkids mean_pub_pubins_lpradults mean_pub_pubins_unauthadult mean_pub_medicaid_lprpreg mean_pub_medicaid_unauthpreg mean_pub_medicaid_lpr_post5 mean_int_instate_tuition mean_int_state_finaid mean_int_uni_ban mean_int_official_eng mean_int_drivers_license)

foreach v of varlist $policies {
	gen i`v' = .
}

forvalues t = 2000/2019 {
	
	foreach v of varlist $policies {
		
		*Check if policy == 0 in year t for BOTH clusters
		quietly count if `v' == 0 & year == `t' & state_cluster_id == 1
		local cond1 = r(N) > 0
		
		quietly count if `v' == 0 & year == `t' & state_cluster_id == 2
		local cond2 = r(N) > 0
		
		*Only flag if BOTH conditions are met
		if `cond1' & `cond2' {
			replace i`v' = 1 if year == `t' & inlist(state_cluster_id, 1, 2)
		}
	}
}

foreach v of varlist $policies {
	replace `v' = . if i`v' == 1
}

local policies "enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license"

foreach v in `policies' {
	replace sd_`v' = . if imean_`v' == 1
}

drop i*

*Identify vars with least SDs
vl clear
vl create policies = (sd_enf_task_force_287g sd_enf_warrant_287g sd_enf_jail_287g sd_enf_secure_comms sd_enf_lim_coop_detainers sd_enf_everify sd_enf_limits_everify sd_enf_state_omnibus sd_pub_tanf_post5 sd_pub_cashass_during5 sd_pub_foodass_lprkids sd_pub_foodass_lpradults sd_pub_ssi_replacement sd_pub_medicaid_lprkids sd_pub_pubins_unauthkids sd_pub_pubins_lpradults sd_pub_pubins_unauthadult sd_pub_medicaid_lprpreg sd_pub_medicaid_unauthpreg sd_pub_medicaid_lpr_post5 sd_int_instate_tuition sd_int_state_finaid sd_int_uni_ban sd_int_official_eng sd_int_drivers_license)

egen min_sd = rowmin($policies)
order min_sd

foreach var of varlist $policies {
	gen temp`var' = `var'
}

foreach var of varlist $policies {
	replace temp`var' = . if temp`var' == min_sd
}

vl create temppol = (tempsd_enf_task_force_287g tempsd_enf_warrant_287g tempsd_enf_jail_287g tempsd_enf_secure_comms tempsd_enf_lim_coop_detainers tempsd_enf_everify tempsd_enf_limits_everify tempsd_enf_state_omnibus tempsd_pub_tanf_post5 tempsd_pub_cashass_during5 tempsd_pub_foodass_lprkids tempsd_pub_foodass_lpradults tempsd_pub_ssi_replacement tempsd_pub_medicaid_lprkids tempsd_pub_pubins_unauthkids tempsd_pub_pubins_lpradults tempsd_pub_pubins_unauthadult tempsd_pub_medicaid_lprpreg tempsd_pub_medicaid_unauthpreg tempsd_pub_medicaid_lpr_post5 tempsd_int_instate_tuition tempsd_int_state_finaid tempsd_int_uni_ban tempsd_int_official_eng tempsd_int_drivers_license)

egen min_sd2 = rowmin($temppol)
order min_sd2

foreach var of varlist $policies {
	replace temp`var' = . if temp`var' == min_sd2
}

egen min_sd3 = rowmin($temppol)
order min_sd3

drop temp*

*Identifying greatest influence policies
local policies "enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license"

foreach var in `policies' {
	gen dupmean_`var' = .
}

foreach var in `policies' {
	replace dupmean_`var' = 1 if sd_`var' == min_sd
//	replace dupmean_`var' = 2 if sd_`var' == min_sd2
//	replace dupmean_`var' = 3 if sd_`var' == min_sd3
}

*Gen ranks and raw
foreach var in `policies' {
	rename dupmean_`var' rk_`var'
}

*Blank out SDs and means of unimportant vars
foreach var in `policies' {
	replace mean_`var' = . if rk_`var' == .
	replace sd_`var' = . if rk_`var' == .
}

*Drop any vars with all .
foreach var of varlist _all {
    capture assert missing(`var')
    if !_rc drop `var'
}

*Drop unneeded vars
drop sd*
drop min*
drop rk*

*Frame dataset by cluster
preserve
keep if state_cluster_id == 1

*Drop any vars with all .
foreach var of varlist _all {
    capture assert missing(`var')
    if !_rc drop `var'
}

*Save data-- Top 1 SDs
export delimited "Data\Other data\Cluster1_policies.csv", replace
restore

keep if state_cluster_id == 2

*Drop any vars with all .
foreach var of varlist _all {
    capture assert missing(`var')
    if !_rc drop `var'
}

*Save data
export delimited "Data\Other data\Cluster2_policies.csv", replace


**Differentiator policies
use "Data\Other data\Clusters", clear

keep if cluster_solutions == 2

drop cluster_solutions cluster_wss tss between_ss r2

*Generating year/state_cluster_id single string var
tostring year, replace
forvalues t = 2000/2019 {
	replace year = "y_`t'" if year == "`t'"
}
gen year_scid = year + "_" + string(state_cluster_id)
order year_scid
drop year state_cluster_id

local policies enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license

*Rename all policy vars to a common stub
local i = 1
foreach var of local policies {
    rename `var' pol`i'
    local polname`i' "`var'"
    local i = `i' + 1
}

*Reshape long with stub
reshape long pol, i(year_scid) j(pol_num)

*Restore original policy names as a string variable
gen policy = ""
local i = 1
foreach var of local policies {
    replace policy = "`var'" if pol_num == `i'
    local i = `i' + 1
}

drop pol_num
rename pol value

*Reshape wide
reshape wide value, i(policy) j(year_scid) string

*Take difference in cluster scores
forvalues t = 2000/2019 {
	gen diff_`t' = abs(valuey_`t'_1 - valuey_`t'_2)
	drop valuey_`t'_1 valuey_`t'_2
}

*Reshape long again
reshape long diff_, i(policy) j(year)

*Reshape wide again
reshape wide diff_, i(year) j(policy) string

*Identify top 3 most influential cluster differentiators per year
vl clear
vl create policies = (diff_enf_everify diff_enf_jail_287g diff_enf_lim_coop_detainers diff_enf_limits_everify diff_enf_secure_comms diff_enf_state_omnibus diff_enf_task_force_287g diff_enf_warrant_287g diff_int_drivers_license diff_int_instate_tuition diff_int_official_eng diff_int_state_finaid diff_int_uni_ban diff_pub_cashass_during5 diff_pub_foodass_lpradults diff_pub_foodass_lprkids diff_pub_medicaid_lpr_post5 diff_pub_medicaid_lprkids diff_pub_medicaid_lprpreg diff_pub_medicaid_unauthpreg diff_pub_pubins_lpradults diff_pub_pubins_unauthadult diff_pub_pubins_unauthkids diff_pub_ssi_replacement diff_pub_tanf_post5)

egen max_diff = rowmax($policies)
order max_diff

foreach var of varlist $policies {
	gen temp`var' = `var'
}

foreach var of varlist $policies {
	replace temp`var' = . if temp`var' == max_diff
}

vl create temppol = (tempdiff_enf_everify tempdiff_enf_jail_287g tempdiff_enf_lim_coop_detainers tempdiff_enf_limits_everify tempdiff_enf_secure_comms tempdiff_enf_state_omnibus tempdiff_enf_task_force_287g tempdiff_enf_warrant_287g tempdiff_int_drivers_license tempdiff_int_instate_tuition tempdiff_int_official_eng tempdiff_int_state_finaid tempdiff_int_uni_ban tempdiff_pub_cashass_during5 tempdiff_pub_foodass_lpradults tempdiff_pub_foodass_lprkids tempdiff_pub_medicaid_lpr_post5 tempdiff_pub_medicaid_lprkids tempdiff_pub_medicaid_lprpreg tempdiff_pub_medicaid_unauthpreg tempdiff_pub_pubins_lpradults tempdiff_pub_pubins_unauthadult tempdiff_pub_pubins_unauthkids tempdiff_pub_ssi_replacement tempdiff_pub_tanf_post5)

egen max_diff2 = rowmax($temppol)
order max_diff2

foreach var of varlist $policies {
	replace temp`var' = . if temp`var' == max_diff2
}

egen max_diff3 = rowmax($temppol)
order max_diff3

drop temp*

*Identifying greatest influence policies
sum $policies

foreach var of varlist $policies {
	replace `var' = 1 if `var' == max_diff
	replace `var' = 2 if `var' == max_diff2
	replace `var' = 3 if `var' == max_diff3
	replace `var' = . if `var' < 1
}

*Drop any vars with all .
foreach var of varlist _all {
    capture assert missing(`var')
    if !_rc drop `var'
}

*Gen ranks and raw
foreach var of varlist diff* {
	gen rk`var' = `var'
}

foreach var of varlist diff*{
	replace `var' = max_diff if `var' == 1
	replace `var' = max_diff2 if `var' == 2
	replace `var' = max_diff3 if `var' == 3
}

drop max*

*Export data
export delimited "Data\Other data\Imp policies ranked.csv", replace



**# Identify medoids

*One cluster solution

*Make temp dir
mkdir "Data\Other data\OneCSmed_temp"

forvalues t = 2000/2019 {
	*Load data
	use "Data\Final data\Policy vectors (std) (nomiss)", clear

	*Define policy vector
	vl clear
	vl create policies = (enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license)

	*Setup
	keep if year == `t'
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

	*Keep medoid and outliers of the year
	egen min_dist = min(total_distance)
	egen max_dist = max(total_distance)
	keep if total_distance == min_dist | total_distance == max_dist
	gen medoid_type = 1 if total_distance == min_dist
	replace medoid_type = 2 if total_distance == max_dist

	*Save data
	save "Data\Other data\OneCSmed_temp\medoids_`t'", replace
}

*Append all sets together
use "Data\Other data\OneCSmed_temp\medoids_2000", clear

forvalues t = 2001/2019 {
	append using "Data\Other data\OneCSmed_temp\medoids_`t'"
}

*Clean wd
forvalues t = 2000/2019 {
	erase "Data\Other data\OneCSmed_temp\medoids_`t'.dta"
}

rmdir "Data\Other data\OneCSmed_temp"

*Save data
save "Data\Other data\Medoids_1CS", replace

**Two cluster solution

*Make temp directory
mkdir "Data\Other data\Medoids temp"

forvalues t = 2000(1)2019 {
	*Load data
	use "Data\Final data\Policy vectors (std) (nomiss)", clear

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



**# Tables (i = state)


**Distance to global centroid

*Load data
use "Data\Final data\Policy vectors (std) (nomiss)", clear

*Create policy vector
vl clear
vl create policies = (enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license)

*Create output shell (one row per state)
preserve
    bysort state (year): keep if _n == 1
    keep state
    forvalues t = 2000/2019 {
        gen dist_`t' = .
    }
    tempfile output_shell
    save `output_shell'
restore

*Loop over years
forvalues t = 2000/2019 {
    preserve
        keep if year == `t'
        
        *Calculate centroid
        gen _sq_dist = 0
        foreach v of varlist $policies {
            quietly summarize `v'
            gen _diff = (`v' - r(mean))^2
            replace _sq_dist = _sq_dist + _diff
            drop _diff
        }
        gen dist_`t' = sqrt(_sq_dist)
        drop _sq_dist
        
        keep state dist_`t'
        tempfile dist_`t'
        save `dist_`t''
    restore
}

*Merge all years into output shell
use `output_shell', clear
forvalues t = 2000/2019 {
    merge 1:1 state using `dist_`t'', nogenerate update
}

*Label and save
forvalues t = 2000/2019 {
    label variable dist_`t' "Euclidean distance from centroid, `t'"
}

sort state
save "Data\Other data\distances_1CS", replace


**Distance to respective centroids, 2CS

*Load data
use "Data\Final data\Policy vectors (std) (nomiss)", clear

*Loop over years
forvalues t = 2000/2019 {
    preserve
        keep if year == `t'
        
        *Run kmeans with fixed seed
        cluster kmeans $policies, k(2) name(state_cluster_id) start(krandom(80504))
        
        *Compute distance to each cluster's centroid for every state
        forvalues c = 1/2 {
            gen _sq_dist_`c' = 0
            foreach v of varlist $policies {
                quietly summarize `v' if state_cluster_id == `c'
                gen _diff = (`v' - r(mean))^2
                replace _sq_dist_`c' = _sq_dist_`c' + _diff
                drop _diff
            }
            gen dist_centroid_`c' = sqrt(_sq_dist_`c')
            drop _sq_dist_`c'
        }
        
        *Assign distance to own and other centroid based on cluster membership
        gen dist_`t' = .
        gen dist_other_`t' = .
        replace dist_`t'       = dist_centroid_1 if state_cluster_id == 1
        replace dist_`t'       = dist_centroid_2 if state_cluster_id == 2
        replace dist_other_`t' = dist_centroid_2 if state_cluster_id == 1
        replace dist_other_`t' = dist_centroid_1 if state_cluster_id == 2
        drop dist_centroid_1 dist_centroid_2
        
        *Extremity score: product of distance to own and other centroid
        gen extremity_`t' = dist_`t' * dist_other_`t'
        
        rename state_cluster_id cluster_`t'
        keep state dist_`t' dist_other_`t' extremity_`t' cluster_`t'
        
        tempfile year_`t'
        save `year_`t''
    restore
}

*Merge all years
use `year_2000', clear
forvalues t = 2001/2019 {
    merge 1:1 state using `year_`t'', nogenerate
}

*Label and save
forvalues t = 2000/2019 {
    label variable cluster_`t'    "Cluster membership (1 or 2), `t'"
    label variable dist_`t'       "Distance to own cluster centroid, `t'"
    label variable dist_other_`t' "Distance to other cluster centroid, `t'"
    label variable extremity_`t'  "Extremity score (own x other centroid distance), `t'"
}

*Rename own-cluster distance for merging
forvalues t = 2000/2019 {
	rename dist_`t' dist_own_`t'
}

sort state
save "Data\Other data\distances_2CS", replace

**Merge all distances together
use "Data\Other data\distances_1CS", clear

forvalues t = 2000/2019 {
	rename dist_`t' dist_1cs_`t'
}

merge 1:1 state using "Data\Other data\distances_2CS"
drop _merge

forvalues t = 2000/2019 {
    order cluster_`t' dist_1cs_`t' dist_own_`t' dist_other_`t' extremity_`t', last
}

*Clean up
drop dist_other*

*Save data
save "Data\Other data\state_distances", replace

**Calculate year over year deltas
forvalues t = 2001/2019 {
	local past_year = `t' - 1
	gen dist_1cs_delta_`t' = dist_1cs_`t' - dist_1cs_`past_year'
	gen dist_own_delta_`t' = dist_own_`t' - dist_own_`past_year'
	gen extremity_delta_`t' = extremity_`t' - extremity_`past_year'
}

forvalues t = 2000/2019 {
	drop dist_1cs_`t' dist_own_`t' extremity_`t'
}

forvalues t = 2001/2019 {
	order cluster_`t' dist_1cs_delta_`t' dist_own_delta_`t' extremity_delta_`t', last
}
order state cluster_2000, first

*Merge all together
merge 1:1 state using "Data\Other data\state_distances"

*Order
forvalues t = 2001/2019 {
	order cluster_`t' dist_1cs_`t' dist_own_`t' extremity_`t' dist_1cs_delta_`t' dist_own_delta_`t' extremity_delta_`t', last
}
order state cluster_2000 dist_1cs_2000 dist_own_2000 extremity_2000, first
drop _merge

**Create ranks
forvalues t = 2000/2019 {
	egen rank_1cs_`t' = rank(dist_1cs_`t')
	egen rank_own_`t' = rank(dist_own_`t'), by(cluster_`t')
	egen rank_extremity_`t' = rank(extremity_`t')
}

**Create year over year deltas
forvalues t = 2001/2019 {
	local past_year = `t' - 1
	gen rank_1cs_delta_`t' = rank_1cs_`t' - rank_1cs_`past_year'
	gen rank_extremity_delta_`t' = rank_extremity_`t' - rank_extremity_`past_year'
}

forvalues t = 2001/2019 {
	order cluster_`t' dist_1cs_`t' dist_1cs_delta_`t' rank_1cs_`t' rank_1cs_delta_`t' dist_own_`t' dist_own_delta_`t' rank_own_`t' extremity_`t' extremity_delta_`t' rank_extremity_`t' rank_extremity_delta_`t', last
}
order state cluster_2000 dist_1cs_2000 rank_1cs_2000 dist_own_2000 rank_own_2000 extremity_2000 rank_extremity_2000, first

*Change District of Columbia to DC
replace state = "D.C." if state == "District of Columbia"

*Save final dataset
save "Data\Final data\state_distances (raw and deltas)", replace
export delimited "Data\Final data\state_distances (raw and deltas).csv", replace

*Clean wd
erase "Data\Other data\state_distances.dta"
erase "Data\Other data\distances_2CS.dta"
erase "Data\Other data\distances_1CS.dta"



**# Visualizations

**Network map -- 3D
use "Data\Final data\Policy vectors (std) (nomiss)", clear

forvalues t = 2000/2019 {
	preserve
		vl clear
		vl create policies = (enf_task_force_287g enf_warrant_287g enf_jail_287g enf_secure_comms enf_lim_coop_detainers enf_everify enf_limits_everify enf_state_omnibus pub_tanf_post5 pub_cashass_during5 pub_foodass_lprkids pub_foodass_lpradults pub_ssi_replacement pub_medicaid_lprkids pub_pubins_unauthkids pub_pubins_lpradults pub_pubins_unauthadult pub_medicaid_lprpreg pub_medicaid_unauthpreg pub_medicaid_lpr_post5 int_instate_tuition int_state_finaid int_uni_ban int_official_eng int_drivers_license)

		keep if year == `t'
		cluster kmeans $policies, k(2) name(state_cluster_id) start(krandom(80504))	

		tempfile clust_`t'
		save `clust_`t''
	restore
}

use `clust_2000', clear
forvalues t = 2001/2019 {
	append using `clust_`t''
}

tab state_cluster_id, m

*Export
export delimited "Data\Other data\network_map.csv", replace


**Radar plot - 1CS
use "Data\Other data\Clusters", clear


keep if cluster_solutions == 1

*Clean dataset
drop cluster_solutions state_cluster_id cluster_wss tss between_ss r2

*Create index vars
gen index_enf_anti = (enf_task_force_287g + enf_warrant_287g + enf_jail_287g + enf_secure_comms + enf_everify + enf_state_omnibus) / 6
gen index_enf_pro = (enf_lim_coop_detainers + enf_limits_everify) / 2

gen index_pub_pro = (pub_tanf_post5 + pub_cashass_during5 + pub_foodass_lprkids + pub_foodass_lpradults + pub_ssi_replacement + pub_medicaid_lprkids + pub_pubins_unauthkids + pub_pubins_lpradults + pub_pubins_unauthadult + pub_medicaid_lprpreg + pub_medicaid_unauthpreg + pub_medicaid_lpr_post5) / 12

gen index_int_pro = (int_instate_tuition + int_state_finaid + int_drivers_license) / 3
gen index_int_anti = (int_uni_ban + int_official_eng) / 2

*Clean 
drop enf* pub* int*

*Export data
export delimited "Data\Other data\Radar plot centroids.csv", replace

**Radar plot - 2CS
use "Data\Other data\Clusters", clear

keep if cluster_solutions == 2

*Clean dataset
drop cluster_solutions cluster_wss tss between_ss r2

*Create index vars
gen index_enf_anti = (enf_task_force_287g + enf_warrant_287g + enf_jail_287g + enf_secure_comms + enf_everify + enf_state_omnibus) / 6
gen index_enf_pro = (enf_lim_coop_detainers + enf_limits_everify) / 2

gen index_pub_pro = (pub_tanf_post5 + pub_cashass_during5 + pub_foodass_lprkids + pub_foodass_lpradults + pub_ssi_replacement + pub_medicaid_lprkids + pub_pubins_unauthkids + pub_pubins_lpradults + pub_pubins_unauthadult + pub_medicaid_lprpreg + pub_medicaid_unauthpreg + pub_medicaid_lpr_post5) / 12

gen index_int_pro = (int_instate_tuition + int_state_finaid + int_drivers_license) / 3
gen index_int_anti = (int_uni_ban + int_official_eng) / 2

*Clean 
drop enf* pub* int*

*Export data
export delimited "Data\Other data\Radar plot centroids - 2CS.csv", replace


**Map prep

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
export delimited "Data\Other data\Medoids (prep for viz).csv", replace


**Plotting policy profile individualization over time

*Load data
use "Data\Other data\Medoids_1CS", clear

keep if medoid_type == 1

tab year

bysort year: egen n_medoids = sum(medoid_type)

collapse (mean) n_medoids min_dist, by(year)

tsset year
//tsline n_medoids
//tsline min_dist //Distance of medoid to centroid inc. over time

*Export data for graphing
export delimited "Data\Other data\line_indiv.csv", replace
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

**#***DATASET INVESTIGATION***

*Load data
use "Data\Final data\State immigration policies.dta", clear

codebook

*Investigating missingness
missings report









**#***ANALYSIS***

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
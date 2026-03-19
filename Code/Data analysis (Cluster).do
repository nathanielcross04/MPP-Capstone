/************************
	Nathaniel Cross
		PA 594
    Capstone Project
		  ---
    Data Analysis:
       Cluster
************************/

cd "C:\Users\ndmcr\Desktop\MPP Capstone"
set more off
clear all

*Load data
use "Data\Final data\State immigration policies"

*Summarize data
sum *

keep if year == 2020

/*
*Standardize policy variables
foreach var of varlist enf* pub* int* {
    egen z_`var' = std(`var')
}

sum z*

drop enf* pub* int*

rename z_* *
*/ *OR: STANDARDIZE TERNARY VARS TO 0-1


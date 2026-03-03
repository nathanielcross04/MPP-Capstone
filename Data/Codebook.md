# Codebook

### Unique identifiers
| Variable | Name | Description | Value type |
|---|---|---|---|
|state|State|Unit identifier|string|Fifty-one unique values: all 50 states plus the District of Columbia.|
|year|Year|Time identifier|integer|Ranges from 2000 to 2020, with up to 21 observations per each state-policy.|

### Dimensions of immigration enforcement policy
| Variable | Name | Description | Value type |
|---|---|---|---|
|enf_task_force_287g|287(g) agreement (task force model)|The 287(g) task force model, which ended in 2012, allowed officials to act in the community.\*|ternary byte^|
|enf_warrant_287g|287(g) agreement (Warrant Service Officer model)|The 287(g) WSO model allows local officials to serve and execute administrative arrest warrants on individuals already in their jail custody.\*|ternary byte^|
|enf_jail_287g|287(g) agreement (jail model)|The 287(g) jail model allows officials to perform immigration enforcement functions in jails.\*|ternary byte^|
|enf_secure_comms|Secure Communities (SC)|Through Secure Communities, the FBI shares fingerprints it receives from local law enforcement agencies with immigration enforcement agencies for checks against immigration databases.\**|binary byte|
|enf_lim_coop_detainers|Limited cooperation with ICE detainer requests|ICE detainers are  requests to local jails and law enforcement agencies asking that they hold individuals for an additional 48 hours after their release date to give ICE time to process the case and decide whether to take the individual into federal custody for deportation.|ternary byte^|
enf_everify|E-Verify mandate|State has a policy to mandate that some or all employers use E-Verify.\***|ternary byte^|
|enf_limits_everify|Prohibition of local E-Verify mandates|State has a policy to block cities, counties, or other jurisdictions from requiring employers to use E-Verify.\***|binary byte| |
|enf_state_omnibus|State omnibus immigration bill|State has multiple enforcement-related measures on the books as a result of passing an omnibus immigration bill, such as Arizona's SB1070 and copycat bills in several states.|binary byte|

>\* 287(g) programs are agreements between local jurisdictions and Immigration and Cusoms Enforcement which deputize local law enforcement to perform certain functions of federal immigration officials.
>
>\** Secure Communities is a federal data-sharing program that ran from 2008 to 2014 and was reinstated in January 2017. Between 2014 and 2017, a different program, the Priority Enforcement Program, was in place. Participation in Secure Communities was initially voluntary but became mandatory and was active in all states by 2012.
>
>\*** E-Verify is an electronic verification system that confirms the employment eligibility of workers. Most states with this mandate require either public employers and state contractors, or all employers with at least a certain number of employees, to use E-Verify.
>
>^ Ternary values are recorded through a three-part coding mechanism: 0 (none of the counties in the state had this policy), 1 (some of the counties had this policy), 2 (all of the counties, or a statewide agency, had this policy.

### Dimensions of immigrant public benefits policy
| Variable | Name | Description | Value type |
|---|---|---|---|
|pub_tanf_post5|TANF for LPRs after the five-year bar|State provides TANF to LPRs after their first five years with this status. Although federal funding is available, a few states deny TANF to LPRs even after the five-year waiting period.\*|binary byte| |
|pub_cashass_during5|Cash assistance for LPRs during the five-year bar|State funds TANF-like cash assistance for LPRs during their first five years with this status.\*|binary byte| |
|pub_foodass_lprkids|Food assistance for LPR children during the five-year bar|State provides food stamps or SNAP benefits for low-income LPR children during their first five years with this status.\**|binary byte| |
|pub_foodass_lpradults|Food assistance for LPR adults during the five-year bar|State funds food stamps or SNAP-like food assistance for low-income LPRs during their first five years with this status.|binary byte| |
|pub_ssi_replacement|SSI replacement for LPRs|State offers cash assistance at levels close to those received under SSI (Supplemental Security Income) to LPRs who are ineligible for SSI even after five years with this status.\***|binary byte| |
|pub_medicaid_lprkids|Medicaid/CHIP for LPR children during the five-year bar|State provides public health insurance to LPR children during their first five years with this status.^|binary byte| |
|pub_pubins_unauthkids|Public health insurance to some unauthorized immigrant children|State funds public health insurance for children regardless of immigration status. Some of these programs offer more comprehensive health insurance coverage than others.|binary byte | |
|pub_pubins_lpradults|Public health insurance to LPR adults during the five-year bar|State funds public health insurance for LPR adults during their first five years with this status.|binary byte| |
|pub_pubins_unauthadult|Public health insurance to some unauthorized immigrant adults|State funds public health insurance for adults regardless of immigration status.|binary byte| |
|pub_medicaid_lprpreg|Medicaid for pregnant LPRs duing the five-year bar|State provides prenatal care to LPR pregnant women during their first five years with this status.^^|binary byte| |
|pub_medicaid_unauthpreg|Medicaid for pregnant unauthorized immigrants|State provides prenatal care regardless of a woman's immigration status, through either a state-funded program or through a 2002 CHIP option.|binary byte| |
|pub_medicaid_lpr_post5|Medicaid for LPRs after the five-year bar|State provides Medicaid and CHIP to LPRs after their first five years with this status. States have the option to provide Medicaid/CHIP to LPRs after five years with this status.|binary byte| |

>\* TANF (Temporary Assistance for Needy Families) provides cash assistance and supportive services for a limited period to low-income families with children to pay for living expenses.
>
>\** Food ass kids Before 2003, several states offered food stamps to LPR children without a waiting period. A 2002 bill restored food stamp eligibility to LPR children during their first five years with this status, effective in April 2003.
>
>\*** SSI supports seniors and people with disabilities, including children, who have very little or no income.
>
>^ A 2009 law allowed states to use federal matching funds to provide Medicaid or CHIP to LPR children during their first five years with this status.
>
>^^ Until 2002, this care was provided with state funds. Regulations issued in 2002 allowed states to fund limited prenatal care for new LPRs through a CHIP option; a 2009 law allowed states to fund some more-comprehensive health coverage to LPR pregnant women through Medicaid/CHIP.
>
>Notes:
>- LPR = Legal Permanent Resident
>- The five-year bar restricts most LPRs from accessing federal means-tested benefits during the first five years of their residency.

### Dimensions of immigrant integration policy
| Variable | Name | Description | Value type |
|---|---|---|---|
|int_instate_tuition|In-state tuition for unauthorized immigrant students|State allows students who meet certain requirements to pay in-state tuition rates at its public colleges and universities regardless of their immigration status.|binary byte| |
|int_state_finaid|State financial aid for unauthorized immigrant students|State allows students who meet certain requirements to access state financial aid regardless of their immigration status.|binary byte| |
|int_uni_ban|Ban on university enrollment for unauthorized immigrant students|State denies enrollment at its public colleges and universities to unauthorized immigrant students.|binary byte| |
|int_official_eng|English as the official state language|State formally recognizes English as its official language.|binary byte| |
|int_drivers_license|State driver's license for unauthorized immigrants|State allows unauthorized immigrants to apply for driver's licenses and state ID cards.|binary byte| |

---

> Note: Some definitions were originally drafted as part of the Urban Institute dataset publication found [here](https://www.urban.org/data-tools/state-immigration-policy-resource)

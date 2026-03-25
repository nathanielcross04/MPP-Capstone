# Nathaniel Cross
# PA 594
# Capstone Project
# 
# Data analysis:
# Cluster analysis


#=======#
# Setup #
#=======#

# Set working directory
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")
getwd()
file.exists("Data/Final data/State immigration policies.dta")

# Load packages
library(tidyverse)
library(janitor)
library(haven)

# Load data
sip_unabridged <- read_csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Final%20data/State%20immigration%20policies.csv")

## Explore dataset

# Dimensions
dim(sip_unabridged)

# First 6 rows
head(sip_unabridged)

# Structure and data types
str(sip_unabridged)

# Summary statistics
summary(sip_unabridged)


#=====================#
# Matrix construction #
#=====================#

## Rescale ternary vars to 0-1

# Detect unique values per column to classify variable type
unique_vals <- sapply(sip_unabridged, function(x) sort(unique(na.omit(x))))

# Identify binary vars
binary_vars <- names(unique_vals)[sapply(unique_vals, function(v) setequal(v, c(0, 1)))]

# Identify ternary vars
ternary_vars <- names(unique_vals)[sapply(unique_vals, function(v) setequal(v, c(0, 1, 2)))]

# Inspect classifications
cat("Binary variables (", length(binary_vars), "):\n"); print(binary_vars)
cat("\nTernary variables (", length(ternary_vars), "):\n"); print(ternary_vars)

# Flag any variables that are neither binary nor ternary
other_vars <- setdiff(names(sip_unabridged), c(binary_vars, ternary_vars))
cat("\nUnclassified variables (", length(other_vars), "):\n"); print(other_vars)

# Scale ternary vars
sip_scaled <- sip_unabridged |>
  mutate(across(
    all_of(ternary_vars),
    ~ . / 2,                                # Maps 0 > 0, 1 > 0.5, 2 > 1
    .names = "{.col}"                       # Overwrites in place
  ))

# Verify scaling — each ternary var should now only contain 0, 0.5, 1
sapply(sip_scaled[ternary_vars], function(x) sort(unique(na.omit(x))))

# Verify binary vars are untouched — should still only contain 0, 1
sapply(sip_scaled[binary_vars], function(x) sort(unique(na.omit(x))))

# Clean environment
rm(unique_vals)
rm(binary_vars)
rm(other_vars)
rm(ternary_vars)

## Other dataset cleaning

# Filtering to year == 2000 and renaming rows to state IDs
sip00_scaled <- sip_scaled |>
  filter(year == "2000") |>                 # Filter by year (keep 2000 obs)
  column_to_rownames(var = "id") |>         # Move state names to row names
  select(-c(state, year)) |>                # Drop state and year vars
  clean_names()                             # Standardize column names

# Ensure retention of only numeric policy variables
sip00_scaled <- sip00_scaled |>
  select(where(is.numeric))

# Check dimensions
dim(sip00_scaled)

# Check for missings
colSums(is.na(sip00_scaled))                # No missings for year == 2000

## Create matrix

# Create distance vectors using Euclidean distance calculations
vectors_00 <- dist(sip00_scaled, method = "euclidean")
matrix_00 <- as.matrix(vectors_00)

# Clean up
rm(vectors_00)

# Verify structure
dim(matrix_00)                              # 51 x 51
matrix_00[1:5, 1:5]
all(diag(matrix_00) == 0)                   # TRUE
isSymmetric(matrix_00)                      # TRUE

# Inspect matrix
distinct_values <- matrix_00[upper.tri(matrix_00)]
summary(distinct_values)

diag(matrix_00) <- NA
min_dist <- which(matrix_00 == min(matrix_00, na.rm = TRUE), arr.ind = TRUE)
cat("Most similar states:\n"); print(rownames(matrix_00)[min_dist[1, ]])

max_dist <- which(matrix_00 == max(matrix_00, na.rm = TRUE), arr.ind = TRUE)
cat("Most dissimilar states:\n"); print(rownames(matrix_00)[max_dist[1, ]])

diag(matrix_00) <- 0

# Clean up environment
rm(max_dist)
rm(min_dist)
rm(distinct_values)

# Export matrix
write.csv(
  matrix_00, 
  file = "Data/Other data/SIP distance matrix 2000.csv", 
  row.names = TRUE)

## Create frames for each year

# Clean environment
rm(sip00_scaled)

# Create vector of all years
years <- 2000:2020

# Run loop to create df for each year
sip_list <- lapply(years, function(yr) {
  sip_scaled |>
    filter(year == as.character(yr)) |>
    column_to_rownames(var = "id") |>
    select(-c(state, year)) |>
    clean_names()
})

# Rename dataframes
names(sip_list) <- paste0("sip", substr(years, 3, 4), "_scaled")

# Check dimensions
lapply(sip_list, dim)
sapply(sip_list, dim)

# Check for missingness
lapply(sip_list, function(df) sum(is.na(df)))
lapply(sip_list, function(df) colSums(is.na(df)))

sapply(sip_list, function(df) colSums(is.na(df)))

sapply(sip_list, function(df) {
  na_counts <- colSums(is.na(df))
  na_counts[na_counts > 0]
})

# Findings:
# - No missings from 2000 to 2016
# - 2 variables missing 2017-2020
# - enf_lim_coop_detainers missing for DE 2019 and ALL states 2020
# - In total, 5 variables missing in 2020

# Options for missingness:
# - Drop years
# - Impute values
# - Code 2017+ values with LLM
# - Some combination of the above options

































































## Henry code

# Set working directory and verify file location
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")
getwd()
file.exists("Code/hru_v2024_12_27.RData")

# Load packages
load("Code/hru_v2024_12_27.RData" )
library(sna)

# Create function to pull state and year policy vectors

GetPolicy <- function(state, year)
{
  # Get all rows (as TRUE versus FALSE) for the chosen state and year
  rows_state <- sip_scaled[,"id"] == state
  rows_year <- sip_scaled[,"year"] == year
  
  # Get all row for which both are TRUE. There should be one and only one.
  target_row <- NULL
  BreakQ <- FALSE
  i <- 1
  while((i < length(rows_state)) && (BreakQ == FALSE))
  {
    # Might be tempting to vectorize this, but this loop is very clear on what is          being done here.
    if((rows_state[i] == TRUE) && (rows_year[i] == TRUE))
    {
      # Then we have a match! Just go ahead and break.
      target_row <- i
      BreakQ <- TRUE
    } #if
    i <- i + 1
  } #while
  
  result <- NULL
  if(BreakQ == TRUE)
  {
    # Then we found a match!
    result <- as.vector(sip_scaled[target_row , ])
    
    # Remove data irrelevant for distance metrics:
    result <- result[4:length(result)]
  } #if
  else
  {
    message("No data matching the specified state and year was found. Are you using the state abbreviation versus full name? Is the specified year valid for the data range?")
  } #else
  
  return(result)
} #end GetPolicy

# Test created function
GetPolicy("AZ", 2010)
GetPolicy("AZ", 2015)
GetPolicy("AZ", 2020)
GetPolicy("AZ", 2050)
  
# Comparison of Arizona and California
PolicyCA <- GetPolicy("CA", 2000)
PolicyAZ <- GetPolicy("AZ", 2000)

PolicyCA <- as.numeric(PolicyCA)
PolicyAZ <- as.numeric(PolicyAZ)

Euclidean_Distance(PolicyCA, PolicyAZ)

# Clean environment
rm(PolicyCA)
rm(PolicyAZ)

# Create distance matrix
GetDistanceMatrix <- function(year, states)
{
  # Create data shell:
  dist_net <- matrix(0, nrow=length(states), ncol=length(states))
  rownames(dist_net) <- states
  colnames(dist_net) <- states
  i <- 1
  while(i <= dim(dist_net)[1])
  {
    j <- i + 1
    while(j <= dim(dist_net)[2])
    {
      # Get the distance between the current pair:
      PolicyA <- GetPolicy(states[i], year)
      PolicyB <- GetPolicy(states[j], year)
      
      if((is.null(PolicyA) == FALSE) && (is.null(PolicyB) == FALSE))
      {
        PolicyA <- as.numeric(PolicyA)
        PolicyB <- as.numeric(PolicyB)
        
        current_dist <- Euclidean_Distance(PolicyA, PolicyB)
        
        dist_net[i,j] <- current_dist
        dist_net[j,i] <- current_dist
      } #if
      else
      {
        dist_net[i,j] <- NA
        dist_net[j,i] <- NA
      } #else
      
      dist_net
      j <- j + 1
    } #while
    i <- i + 1
  } #while
  
  return(dist_net)
} #end GetDistanceMatrix

# Test matrix construction
TargetYear <- 2019
TargetStates <- c("CA","NY","MA","DC","WA")
GetDistanceMatrix(TargetYear, TargetStates)

# Get vector of all states
AllStates <- sip_unabridged |> distinct(id) |> pull(id)

# Visualize
net <- GetDistanceMatrix(TargetYear, AllStates)
identical(matrix_00, net)
Visualize_Network(net, FALSE) ## Would still need to show scaling according to the distance.









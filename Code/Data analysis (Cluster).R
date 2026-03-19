# Nathaniel Cross
# PA 594
# Capstone Project
# 
# Data analysis:
# Cluster analysis

## Setup

# Set working directory
knitr::opts_knit$set(root.dir = "C:/Users/ndmcr/Desktop/MPP Capstone")
getwd()
file.exists("../Data/Final data/State immigration policies.dta")

# Load packages
library(tidyverse)
library(janitor)
library(haven)

# Load data
sip_unabridged <- read_stata("../Data/Final data/State immigration policies.dta")

## Explore dataset

# Dimensions
dim(sip_unabridged)

# First 6 rows
head(sip_unabridged)

# Structure and data types
str(sip_unabridged)

# Summary statistics
summary(sip_unabridged)

## Matrix construction

# Dataset prep
sip00 <- sip_unabridged |>
  filter(year == "2000") |>             # Filter by year (keep 2000 obs)
  column_to_rownames(var = "id") |>     # Move state names to row names
  select(-c(state, year)) |>            # Drop state and year vars
  clean_names() |>                      # Standardize column names
  glimpse()

# Ensure retention of only numeric policy variables
sip00 <- sip00 |>
  select(where(is.numeric))

# Check dimensions
dim(sip00)

# Check for missings
colSums(is.na(sip00))                   # No missings for year == 2000


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
sip_scaled <- sip_unabridged %>%
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

## Calculate distances between vectors
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






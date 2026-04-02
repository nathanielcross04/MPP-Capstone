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


## Create frames for each year

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


## Deal with missingness

# Drop year == 2020 (too 5 vars. missing)
sip_list$sip20_scaled <- NULL

# Sustain E-Verify values from 2016 through 2019
everify16 <- sip_list$sip16_scaled$enf_everify

sip_list$sip17_scaled$enf_everify <- everify16

sip_list$sip18_scaled$enf_everify <- everify16
sip_list$sip19_scaled$enf_everify <- everify16

sapply(sip_list, function(df) {
  df <- as.data.frame(df)
  na_counts <- colSums(is.na(df))
  na_counts[na_counts > 0]
})

rm(everify16)

# Set all omnibus values 2017-2019 to 0
sip_list$sip16_scaled |>
  select(enf_state_omnibus) |>
  rownames_to_column()

sip_list$sip17_scaled <- sip_list$sip17_scaled |>
  mutate(enf_state_omnibus = 0)
sip_list$sip18_scaled <- sip_list$sip18_scaled |>
  mutate(enf_state_omnibus = 0)
sip_list$sip19_scaled <- sip_list$sip19_scaled |>
  mutate(enf_state_omnibus = 0)

sapply(sip_list, function(df) {
  df <- as.data.frame(df)
  na_counts <- colSums(is.na(df))
  na_counts[na_counts > 0]
})

# Investigating last missing value
sip_list$sip19_scaled |>
  filter(is.na(enf_lim_coop_detainers)) |>
  select(enf_lim_coop_detainers) |>
  rownames_to_column()                      # Delaware

sip_list$sip19_scaled <- sip_list$sip19_scaled |>
  filter(is.na(enf_lim_coop_detainers)) |>
  mutate(enf_lim_coop_detainers = 0.5) |>
  rownames_to_column()

sapply(sip_list, function(df) {
  df <- as.data.frame(df)
  na_counts <- colSums(is.na(df))
  na_counts[na_counts > 0]
})


## Create distance matrices 

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

# Create function to create distance matrices
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

# Prep for matrix construction
AllStates <- sip_unabridged |> distinct(id) |> pull(id)
sip_matrix <- list()

# Run loop to create distance matrices
for (t in 2000:2019) {
  print(t)
  sip_matrix[[paste0("sip_matrix_", t)]] <- GetDistanceMatrix(t, AllStates)
}

#for (t in 2000:2019) {
#  print(t)
#  df <- as.data.frame(GetDistanceMatrix(t, AllStates))
#  sip_matrix[[paste0("sip_matrix_", t)]] <- df
#  rm(df)
#}

# Verify structure
for (t in seq_along(sip_matrix)) {
  cat(names(sip_matrix)[t], ":", dim(sip_matrix[[t]]), ":", isSymmetric(sip_matrix[[t]]), ":", all(diag(sip_matrix[[t]]) == 0), "\n")
} 

#==================#
# Cluster analysis #
#==================#

# Year == 2000
matrix_2000 <- sip_matrix$sip_matrix_2000

distances_2000 <- as.dist(matrix_2000)

cluster_2000 <- hclust(distances_2000, method = "ward.D2")

par(mar = c(4, 4, 3, 1))  # tighten margins
plot(cluster_2000,
     main  = "Hierarchical Clustering of State Policy Distances (2000)",
     xlab  = "State",
     ylab  = "Ward Distance",
     sub   = "",
     cex   = 0.75,       # shrink state labels so they don't overlap
     hang  = -1)         # hang = -1 drops all leaves to the same baseline

# Cut tree
k <- 4
clusters_2000 <- cutree(cluster_2000, k = k)

rect.hclust(cluster_2000, k = k, border = 2:(k + 1))
rect.hclust(cluster_2000, k = 6, border = 2:(k + 1))


# Inspect clusters
print(sort(clusters_2000))

table(clusters_2000)

# Silhouette scores
library(cluster)

sil_scores <- sapply(2:10, function(k) {
  cut   <- cutree(cluster_2000, k = k)
  s     <- silhouette(cut, distances_2000)
  mean(s[, "sil_width"])
})

# Plot silhouette scores across candidate k values
plot(2:10, sil_scores,
     type  = "b",
     pch   = 19,
     xlab  = "Number of clusters (k)",
     ylab  = "Mean silhouette width",
     main  = "Silhouette scores — 2000")
abline(v = which.max(sil_scores) + 1, lty = 2, col = "firebrick")






## Compare all years

# Create faceted dendrograms
years <- 2000:2019

# Set 4x5 grid
par(mfrow = c(5, 4),
    mar   = c(3, 2, 2, 1),
    oma   = c(1, 1, 3, 1))

# Run loop to create dendros
for (yr in years) {
  mat  <- sip_matrix[[paste0("sip_matrix_", yr)]]
  dist <- as.dist(mat)
  hc   <- hclust(dist, method = "ward.D2")
  
  plot(hc,
       main  = as.character(yr),
       xlab  = "",
       ylab  = "",
       sub   = "",
       cex   = 0.4,    # state label size — reduce if labels overlap
       hang  = -1)
}

# Shared outer title
mtext("Hierarchical Clustering of State Policy Distances (2000–2019)",
      outer = TRUE,
      cex   = 1.1,
      font  = 2,       # bold
      line  = 1)

# Reset graphics parameters after
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2), oma = c(0, 0, 0, 0))

# Save plot
png("C:/Users/ndmcr/Desktop/MPP Capstone/Figures/dendrograms_2000_2019.png", 
    width = 2550, 
    height = 3300, 
    res = 300)

par(mfrow = c(5, 4),
    mar   = c(3, 2, 2, 1),
    oma   = c(1, 1, 3, 1))

for (yr in years) {
  mat  <- sip_matrix[[paste0("sip_matrix_", yr)]]
  hc   <- hclust(as.dist(mat), method = "ward.D2")
  plot(hc, main = as.character(yr), xlab = "", ylab = "",
       sub = "", cex = 0.4, hang = -1)
}

mtext("Hierarchical Clustering of State Policy Distances (2000–2019)",
      outer = TRUE, cex = 1.1, font = 2, line = 1)

dev.off()


## Create faceted silhouette plots

# Find the global min and max across all years before plotting
all_scores <- sapply(years, function(yr) {
  mat  <- sip_matrix[[paste0("sip_matrix_", yr)]]
  dist <- as.dist(mat)
  hc   <- hclust(dist, method = "ward.D2")
  sapply(2:10, function(k) {
    s <- silhouette(cutree(hc, k = k), dist)
    mean(s[, "sil_width"])
  })
})

global_min <- floor(min(all_scores) * 20) / 20    # round down to nearest 0.05
global_max <- ceiling(max(all_scores) * 20) / 20  # round up to nearest 0.05

cat("Suggested ylim: c(",global_min, ",", global_max,")\n")

# Plot
library(cluster)

years <- 2000:2019

png("C:/Users/ndmcr/Desktop/MPP Capstone/Figures/silhouette_scores_2000_2019.png",
    width  = 2550,   # 8.5 * 300
    height = 3300,   # 11 * 300
    res    = 300)

par(mfrow = c(5, 4),
    mar   = c(4, 4, 3, 1),
    oma   = c(1, 1, 3, 1))

for (yr in years) {
  mat  <- sip_matrix[[paste0("sip_matrix_", yr)]]
  dist <- as.dist(mat)
  hc   <- hclust(dist, method = "ward.D2")
  
  # Compute mean silhouette width for k = 2 to 10
  sil_scores <- sapply(2:10, function(k) {
    cut <- cutree(hc, k = k)
    s   <- silhouette(cut, dist)
    mean(s[, "sil_width"])
  })
  
  # Find optimal k
  best_k <- which.max(sil_scores) + 1  # +1 because index 1 = k=2
  
  plot(2:10, sil_scores,
       type  = "b",
       pch   = 19,
       cex   = 0.6,
       xlab  = "Number of clusters (k)",
       ylab  = "Mean silhouette width",
       main  = as.character(yr),
       ylim  = c(0.1 , 0.45),   # fixed y axis so panels are comparable across years
       cex.main = 0.9,
       cex.lab  = 0.7,
       cex.axis = 0.65)
  
  # Mark the optimal k with a dashed vertical line
  abline(v = best_k, lty = 2, col = "firebrick", lwd = 0.8)
  
  # Annotate optimal k value in the panel
  text(x      = best_k,
       y      = max(sil_scores) - 0.02,
       labels = paste0("k=", best_k),
       cex    = 0.6,
       col    = "firebrick",
       pos    = 4)   # pos=4 places text to the right of the point
}

mtext("Silhouette Scores by Year (2000–2019)",
      outer = TRUE,
      cex   = 1.1,
      font  = 2,
      line  = 1)

dev.off()

# Reset graphics parameters
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2), oma = c(0, 0, 0, 0))





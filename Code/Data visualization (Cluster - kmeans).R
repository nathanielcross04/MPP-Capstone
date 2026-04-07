# Nathaniel Cross
# PA 594
# Capstone Project
# 
# Data analysis:
# Cluster analysis - visualization


#=======#
# Setup #
#=======#

# Set working directory
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")
getwd()
file.exists("Data/Other data/Medoids.csv")

# Load packages
library(tidyverse)
library(janitor)
library(haven)

# Load data

# ============================================================
# State Cluster Map — animation-ready
#
# Usage:
#   Single frame:  render_map(year = 2000)
#   All frames:    render_all_years()
#   GIF animation: render_animation()   # needs gganimate + gifski
# ============================================================

library(ggplot2)
library(dplyr)
library(maps)
library(mapproj)
library(grid)
library(scales)

# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Medoids%20(prep%20for%20viz).csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# Cluster color palettes: rich (close to medoid) to pale (far from medoid)
CLUSTER_COLORS <- list(
  "1" = list(rich = "#1A7A6E", pale = "#C2EBE6"),  # teal
  "2" = list(rich = "#C46B00", pale = "#FAE0BB")   # amber
)
NEUTRAL_COLOR <- "#D0D0D0"

# ── 1. LOAD & PREP DATA ──────────────────────────────────────
raw <- DATA_PATH

prepped <- raw %>%
  group_by(year, state_cluster_id) %>%
  mutate(
    dist_min  = min(distance_map, na.rm = TRUE),
    dist_max  = max(distance_map, na.rm = TRUE),
    dist_norm = ifelse(
      !is.na(distance_map) & !is.na(include) & include == 1,
      (distance_map - dist_min) / pmax(dist_max - dist_min, 1e-9),
      NA_real_
    )
  ) %>%
  ungroup() %>%
  mutate(state_lower = tolower(state))

# ── 2. COLOR HELPERS ─────────────────────────────────────────
blend_hex <- function(hex1, hex2, t) {
  c1 <- col2rgb(hex1)
  c2 <- col2rgb(hex2)
  r  <- round(c1 + t * (c2 - c1))
  rgb(r[1], r[2], r[3], maxColorValue = 255)
}

compute_fills <- function(cluster_id, dist_norm, include_flag) {
  n   <- length(cluster_id)
  out <- rep(NEUTRAL_COLOR, n)
  for (i in seq_len(n)) {
    if (!is.na(include_flag[i]) && include_flag[i] == 1) {
      pal <- CLUSTER_COLORS[[as.character(cluster_id[i])]]
      if (!is.null(pal)) {
        t_val  <- if (is.na(dist_norm[i])) 0 else dist_norm[i]
        out[i] <- blend_hex(pal$rich, pal$pale, t_val)
      }
    }
  }
  out
}

# ── 3. MAP GEOMETRIES ────────────────────────────────────────
cont48 <- map_data("state")

# Alaska: clip Aleutians at -180 before transforming to eliminate stretch.
# After clipping, bbox is roughly long [-180, -130], lat [51, 72].
# Inset target (bottom-left of plot): long [-124, -112], lat [23, 31].
# Use rescale() on each axis independently — shapes stay true because the
# source and target boxes share the same aspect ratio (10:8 lon x lat degrees
# vs 12:21 source, so a small amount of distortion remains but is minimal
# compared to the original fold-and-scale approach).
ak_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Alaska") %>%
  mutate(long = ifelse(long > 0, long - 360, long)) %>%
  filter(long >= -180) %>%
  mutate(
    long = rescale(long, to = c(-124, -113.5), from = c(-180, -130)),
    lat  = rescale(lat,  to = c(23,   31),   from = c(51,   72))
  )

# Hawaii: source bbox long [-160.5, -154.5], lat [18.9, 22.2].
# Inset target: long [-112, -105], lat [23, 27].
hi_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Hawaii") %>%
  mutate(
    long = rescale(long, to = c(-112, -105), from = c(-160.5, -154.5)),
    lat  = rescale(lat,  to = c(23,   27),   from = c(18.9,   22.2))
  )

# ── 4. ATTACH FILLS FOR ONE YEAR ─────────────────────────────
attach_fills <- function(geom_df, region_col, yr_data) {
  geom_df %>%
    left_join(
      yr_data %>% select(state_lower, state_cluster_id, include, dist_norm),
      by = setNames("state_lower", region_col)
    ) %>%
    mutate(fill_col = compute_fills(state_cluster_id, dist_norm, include))
}

# ── 5. SINGLE-YEAR RENDER ────────────────────────────────────
render_map <- function(year_val,
                       save    = TRUE,
                       outfile = file.path(OUTPUT_DIR,
                                           sprintf("cluster_map_%d.png", year_val))) {
  
  yr   <- prepped %>% filter(year == year_val)
  df48 <- attach_fills(cont48,                               "region", yr)
  dfak <- attach_fills(ak_raw %>% mutate(region = "alaska"), "region", yr)
  dfhi <- attach_fills(hi_raw %>% mutate(region = "hawaii"), "region", yr)
  
  p <- ggplot() +
    geom_polygon(data = df48,
                 aes(x = long, y = lat, group = group, fill = fill_col),
                 color = "white", linewidth = 0.25) +
    geom_polygon(data = dfak,
                 aes(x = long, y = lat, group = group, fill = fill_col),
                 color = "white", linewidth = 0.2) +
    geom_polygon(data = dfhi,
                 aes(x = long, y = lat, group = group, fill = fill_col),
                 color = "white", linewidth = 0.2) +
    scale_fill_identity() +
    coord_map("albers", lat0 = 29.5, lat1 = 45.5,
              xlim = c(-124, -66), ylim = c(23, 50)) +
    labs(
      title    = sprintf("State Cluster Membership, %d", year_val),
      subtitle = "Highlighted states: include = 1  \u00b7  Darker = closer to medoid"
    ) +
    theme_void(base_family = "sans") +
    theme(
      plot.title      = element_text(size = 15, face = "bold",  hjust = 0.5,
                                     margin = margin(b = 3)),
      plot.subtitle   = element_text(size =  8, color = "#555555", hjust = 0.5,
                                     margin = margin(b = 5)),
      plot.caption    = element_text(size =  7, color = "#777777", hjust = 0.5,
                                     margin = margin(t = 5)),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin     = margin(10, 10, 10, 10)
    )
  
  if (save) {
    ggsave(outfile, plot = p, width = 10, height = 4.5, dpi = 180, bg = "white")
    message("Saved: ", outfile)
  }
  
  p
}

p <- render_map(2000)
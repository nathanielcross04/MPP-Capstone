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



# ============================================================
# State Cluster Map — Animated GIF (2000–2019)
# Requires: gganimate, gifski (in addition to existing packages)
# ============================================================

library(ggplot2)
library(dplyr)
library(maps)
library(mapproj)
library(scales)
library(gganimate)
library(gifski)

# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Medoids%20(prep%20for%20viz).csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

CLUSTER_COLORS <- list(
  "1" = list(rich = "#1A7A6E", pale = "#C2EBE6"),
  "2" = list(rich = "#C46B00", pale = "#FAE0BB")
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
# Convert cluster + dist_norm to an RGB triplet (3-element numeric vector)
state_to_rgb <- function(cluster_id, dist_norm, include_flag) {
  neutral <- col2rgb(NEUTRAL_COLOR)
  if (is.na(include_flag) || include_flag != 1) return(neutral)
  pal <- CLUSTER_COLORS[[as.character(cluster_id)]]
  if (is.null(pal)) return(neutral)
  t_val <- if (is.na(dist_norm)) 0 else dist_norm
  c1 <- col2rgb(pal$rich)
  c2 <- col2rgb(pal$pale)
  round(c1 + t_val * (c2 - c1))
}

# ── 3. BUILD INTERPOLATED COLOR TABLE ────────────────────────
# For smooth transitions, generate N interpolated frames between each year pair.
# We work in RGB space so color blending is linear and flicker-free.

YEARS       <- 2000:2019
FRAMES_PER_YEAR <- 24   # intermediate steps between each year; increase for smoother GIF

# For each state × year, compute the RGB triplet
state_year_rgb <- prepped %>%
  filter(year %in% YEARS) %>%
  group_by(state_lower, year) %>%
  slice(1) %>%   # one row per state × year
  ungroup() %>%
  rowwise() %>%
  mutate(
    rgb = list(state_to_rgb(state_cluster_id, dist_norm, include))
  ) %>%
  ungroup() %>%
  mutate(
    r = sapply(rgb, `[`, 1),
    g = sapply(rgb, `[`, 2),
    b = sapply(rgb, `[`, 3)
  ) %>%
  select(state_lower, year, r, g, b)

# Generate interpolated frames
interp_frames <- lapply(seq_along(YEARS), function(i) {
  yr_a <- YEARS[i]
  yr_b <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
  
  rgb_a <- state_year_rgb %>% filter(year == yr_a) %>% select(state_lower, r, g, b)
  rgb_b <- state_year_rgb %>% filter(year == yr_b) %>% select(state_lower, r, g, b) %>%
    rename(r2 = r, g2 = g, b2 = b)
  
  joined <- left_join(rgb_a, rgb_b, by = "state_lower")
  
  steps <- if (i < length(YEARS)) seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)] else 0
  
  lapply(steps, function(t) {
    joined %>%
      mutate(
        ri = round(r + t * (r2 - r)),
        gi = round(g + t * (g2 - g)),
        bi = round(b + t * (b2 - b)),
        fill_col   = rgb(ri, gi, bi, maxColorValue = 255),
        frame_year = yr_a,
        frame_t    = t,
        frame_label = sprintf(
          "%d%s",
          yr_a,
          if (t > 0) sprintf(" → %d", yr_b) else ""
        ),
        # Numeric frame ID for gganimate ordering
        frame_id = (i - 1) * FRAMES_PER_YEAR + which(steps == t)
      ) %>%
      select(state_lower, fill_col, frame_year, frame_t, frame_label, frame_id)
  })
}) %>%
  unlist(recursive = FALSE) %>%
  bind_rows()

# ── 4. MAP GEOMETRIES ────────────────────────────────────────
cont48 <- map_data("state")

ak_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Alaska") %>%
  mutate(long = ifelse(long > 0, long - 360, long)) %>%
  filter(long >= -180) %>%
  mutate(
    long = rescale(long, to = c(-124, -113.5), from = c(-180, -130)),
    lat  = rescale(lat,  to = c(23,   31),     from = c(51,   72))
  )

hi_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Hawaii") %>%
  mutate(
    long = rescale(long, to = c(-112, -105), from = c(-160.5, -154.5)),
    lat  = rescale(lat,  to = c(23,   27),   from = c(18.9,   22.2))
  )

# ── 5. JOIN FILLS ONTO MAP GEOMETRIES FOR ALL FRAMES ─────────
join_fills <- function(geom_df, region_col, group_offset = 0) {
  geom_df %>%
    mutate(group = group + group_offset) %>%   # ensure globally unique group IDs
    left_join(
      interp_frames,
      by           = setNames("state_lower", region_col),
      relationship = "many-to-many"
    ) %>%
    mutate(fill_col = ifelse(is.na(fill_col), NEUTRAL_COLOR, fill_col))
}

# Use large offsets so group IDs never overlap across the three geometries
df48 <- join_fills(cont48,                               "region", group_offset = 0)
dfak <- join_fills(ak_raw %>% mutate(region = "alaska"), "region", group_offset = 100000)
dfhi <- join_fills(hi_raw %>% mutate(region = "hawaii"), "region", group_offset = 200000)

map_data_all <- bind_rows(df48, dfak, dfhi)

# ── 6. BUILD ANIMATED PLOT ───────────────────────────────────
# Pull one label per frame_id for the title
frame_labels <- interp_frames %>%
  distinct(frame_id, frame_year) %>%
  arrange(frame_id)

p_anim <- ggplot(map_data_all,
                 aes(x = long, y = lat, group = group, fill = fill_col)) +
  geom_polygon(color = "white", linewidth = 0.25) +
  scale_fill_identity() +
  coord_map("albers", lat0 = 29.5, lat1 = 45.5,
            xlim = c(-124, -66), ylim = c(23, 50)) +
  labs(
    title    = "State Cluster Membership, {frame_labels$frame_year[frame_labels$frame_id == as.integer(closest_state)][1]}",
    subtitle = "Darker = closer to cluster medoid"
  ) +
  theme_void(base_family = "sans") +
  theme(
    plot.title      = element_text(size = 15, face = "bold",  hjust = 0.5,
                                   margin = margin(b = 3)),
    plot.subtitle   = element_text(size =  8, color = "#555555", hjust = 0.5,
                                   margin = margin(b = 5)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(10, 10, 10, 10)
  ) +
  transition_states(
    states          = frame_id,
    transition_length = 0,   # all time is "state" time; interpolation handled manually
    state_length      = 1,
    wrap              = FALSE
  )

# ── 7. RENDER & SAVE GIF ─────────────────────────────────────
total_frames <- max(interp_frames$frame_id)

anim_obj <- animate(
  p_anim,
  nframes   = total_frames,
  fps       = FRAMES_PER_YEAR / 2,   # 1 second per year
  width     = 1000,
  height    = 450,
  renderer  = gifski_renderer(file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif")),
  bg        = "white"
)

message("GIF saved to: ", file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif"))

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



# ============================================================
# State Cluster Map — Animated GIF (2000–2019)
# Requires: gganimate, gifski (in addition to existing packages)
# ============================================================

library(ggplot2)
library(dplyr)
library(maps)
library(mapproj)
library(scales)
library(gganimate)
library(gifski)

# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Medoids%20(prep%20for%20viz).csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

CLUSTER_COLORS <- list(
  "1" = list(rich = "#1A7A6E", pale = "#C2EBE6"),
  "2" = list(rich = "#C46B00", pale = "#FAE0BB")
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
# Convert cluster + dist_norm to an RGB triplet (3-element numeric vector)
state_to_rgb <- function(cluster_id, dist_norm, include_flag) {
  neutral <- col2rgb(NEUTRAL_COLOR)
  if (is.na(include_flag) || include_flag != 1) return(neutral)
  pal <- CLUSTER_COLORS[[as.character(cluster_id)]]
  if (is.null(pal)) return(neutral)
  t_val <- if (is.na(dist_norm)) 0 else dist_norm
  c1 <- col2rgb(pal$rich)
  c2 <- col2rgb(pal$pale)
  round(c1 + t_val * (c2 - c1))
}

# ── 3. BUILD INTERPOLATED COLOR TABLE ────────────────────────
# For smooth transitions, generate N interpolated frames between each year pair.
# We work in RGB space so color blending is linear and flicker-free.

YEARS       <- 2000:2019
FRAMES_PER_YEAR <- 24   # intermediate steps between each year; increase for smoother GIF

# For each state × year, compute the RGB triplet
state_year_rgb <- prepped %>%
  filter(year %in% YEARS) %>%
  group_by(state_lower, year) %>%
  slice(1) %>%   # one row per state × year
  ungroup() %>%
  rowwise() %>%
  mutate(
    rgb = list(state_to_rgb(state_cluster_id, dist_norm, include))
  ) %>%
  ungroup() %>%
  mutate(
    r = sapply(rgb, `[`, 1),
    g = sapply(rgb, `[`, 2),
    b = sapply(rgb, `[`, 3)
  ) %>%
  select(state_lower, year, r, g, b)

# Generate interpolated frames
interp_frames <- lapply(seq_along(YEARS), function(i) {
  yr_a <- YEARS[i]
  yr_b <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
  
  rgb_a <- state_year_rgb %>% filter(year == yr_a) %>% select(state_lower, r, g, b)
  rgb_b <- state_year_rgb %>% filter(year == yr_b) %>% select(state_lower, r, g, b) %>%
    rename(r2 = r, g2 = g, b2 = b)
  
  joined <- left_join(rgb_a, rgb_b, by = "state_lower")
  
  steps <- if (i < length(YEARS)) seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)] else 0
  
  lapply(steps, function(t) {
    joined %>%
      mutate(
        ri = round(r + t * (r2 - r)),
        gi = round(g + t * (g2 - g)),
        bi = round(b + t * (b2 - b)),
        fill_col   = rgb(ri, gi, bi, maxColorValue = 255),
        frame_year = yr_a,
        frame_t    = t,
        frame_label = sprintf(
          "%d%s",
          yr_a,
          if (t > 0) sprintf(" → %d", yr_b) else ""
        ),
        # Numeric frame ID for gganimate ordering
        frame_id = (i - 1) * FRAMES_PER_YEAR + which(steps == t)
      ) %>%
      select(state_lower, fill_col, frame_year, frame_t, frame_label, frame_id)
  })
}) %>%
  unlist(recursive = FALSE) %>%
  bind_rows()

# ── 4. MAP GEOMETRIES ────────────────────────────────────────
cont48 <- map_data("state")

ak_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Alaska") %>%
  mutate(long = ifelse(long > 0, long - 360, long)) %>%
  filter(long >= -180) %>%
  mutate(
    long = rescale(long, to = c(-124, -113.5), from = c(-180, -130)),
    lat  = rescale(lat,  to = c(23,   31),     from = c(51,   72))
  )

hi_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Hawaii") %>%
  mutate(
    long = rescale(long, to = c(-112, -105), from = c(-160.5, -154.5)),
    lat  = rescale(lat,  to = c(23,   27),   from = c(18.9,   22.2))
  )

# ── 5. JOIN FILLS ONTO MAP GEOMETRIES FOR ALL FRAMES ─────────
join_fills <- function(geom_df, region_col, group_offset = 0) {
  geom_df %>%
    mutate(group = group + group_offset) %>%   # ensure globally unique group IDs
    left_join(
      interp_frames,
      by           = setNames("state_lower", region_col),
      relationship = "many-to-many"
    ) %>%
    mutate(fill_col = ifelse(is.na(fill_col), NEUTRAL_COLOR, fill_col))
}

# Use large offsets so group IDs never overlap across the three geometries
df48 <- join_fills(cont48,                               "region", group_offset = 0)
dfak <- join_fills(ak_raw %>% mutate(region = "alaska"), "region", group_offset = 100000)
dfhi <- join_fills(hi_raw %>% mutate(region = "hawaii"), "region", group_offset = 200000)

map_data_all <- bind_rows(df48, dfak, dfhi)

# ── 6. BUILD ANIMATED PLOT ───────────────────────────────────
# Pull one label per frame_id for the title
frame_labels <- interp_frames %>%
  distinct(frame_id, frame_year) %>%
  arrange(frame_id)

p_anim <- ggplot(map_data_all,
                 aes(x = long, y = lat, group = group, fill = fill_col)) +
  geom_polygon(color = "white", linewidth = 0.25) +
  scale_fill_identity() +
  coord_map("albers", lat0 = 29.5, lat1 = 45.5,
            xlim = c(-124, -66), ylim = c(23, 50)) +
  labs(
    title    = "State Cluster Membership, {frame_labels$frame_year[frame_labels$frame_id == as.integer(closest_state)][1]}",
    subtitle = "Darker = closer to cluster medoid"
  ) +
  theme_void(base_family = "sans") +
  theme(
    plot.title      = element_text(size = 15, face = "bold",  hjust = 0.5,
                                   margin = margin(b = 3)),
    plot.subtitle   = element_text(size =  8, color = "#555555", hjust = 0.5,
                                   margin = margin(b = 5)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(10, 10, 10, 10)
  ) +
  transition_states(
    states          = frame_id,
    transition_length = 0,   # all time is "state" time; interpolation handled manually
    state_length      = 1,
    wrap              = FALSE
  )

# ── 7. RENDER & SAVE GIF ─────────────────────────────────────
total_frames <- max(interp_frames$frame_id)

anim_obj <- animate(
  p_anim,
  nframes   = total_frames,
  fps       = FRAMES_PER_YEAR / 2,   # 1 second per year
  width     = 1000,
  height    = 450,
  renderer  = gifski_renderer(file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif")),
  bg        = "white"
)

message("GIF saved to: ", file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif"))


#=======#
# Just cluster 1
#=======#

# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Medoids%20(prep%20for%20viz).csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

CLUSTER_COLORS <- list(
  "1" = list(rich = "#1A7A6E", pale = "#C2EBE6"),
  "2" = list(rich = "#D0D0D0", pale = "#D0D0D0")
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
# Convert cluster + dist_norm to an RGB triplet (3-element numeric vector)
state_to_rgb <- function(cluster_id, dist_norm, include_flag) {
  neutral <- col2rgb(NEUTRAL_COLOR)
  if (is.na(include_flag) || include_flag != 1) return(neutral)
  pal <- CLUSTER_COLORS[[as.character(cluster_id)]]
  if (is.null(pal)) return(neutral)
  t_val <- if (is.na(dist_norm)) 0 else dist_norm
  c1 <- col2rgb(pal$rich)
  c2 <- col2rgb(pal$pale)
  round(c1 + t_val * (c2 - c1))
}

# ── 3. BUILD INTERPOLATED COLOR TABLE ────────────────────────
# For smooth transitions, generate N interpolated frames between each year pair.
# We work in RGB space so color blending is linear and flicker-free.

YEARS       <- 2000:2019
FRAMES_PER_YEAR <- 24   # intermediate steps between each year; increase for smoother GIF

# For each state × year, compute the RGB triplet
state_year_rgb <- prepped %>%
  filter(year %in% YEARS) %>%
  group_by(state_lower, year) %>%
  slice(1) %>%   # one row per state × year
  ungroup() %>%
  rowwise() %>%
  mutate(
    rgb = list(state_to_rgb(state_cluster_id, dist_norm, include))
  ) %>%
  ungroup() %>%
  mutate(
    r = sapply(rgb, `[`, 1),
    g = sapply(rgb, `[`, 2),
    b = sapply(rgb, `[`, 3)
  ) %>%
  select(state_lower, year, r, g, b)

# Generate interpolated frames
interp_frames <- lapply(seq_along(YEARS), function(i) {
  yr_a <- YEARS[i]
  yr_b <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
  
  rgb_a <- state_year_rgb %>% filter(year == yr_a) %>% select(state_lower, r, g, b)
  rgb_b <- state_year_rgb %>% filter(year == yr_b) %>% select(state_lower, r, g, b) %>%
    rename(r2 = r, g2 = g, b2 = b)
  
  joined <- left_join(rgb_a, rgb_b, by = "state_lower")
  
  steps <- if (i < length(YEARS)) seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)] else 0
  
  lapply(steps, function(t) {
    joined %>%
      mutate(
        ri = round(r + t * (r2 - r)),
        gi = round(g + t * (g2 - g)),
        bi = round(b + t * (b2 - b)),
        fill_col   = rgb(ri, gi, bi, maxColorValue = 255),
        frame_year = yr_a,
        frame_t    = t,
        frame_label = sprintf(
          "%d%s",
          yr_a,
          if (t > 0) sprintf(" → %d", yr_b) else ""
        ),
        # Numeric frame ID for gganimate ordering
        frame_id = (i - 1) * FRAMES_PER_YEAR + which(steps == t)
      ) %>%
      select(state_lower, fill_col, frame_year, frame_t, frame_label, frame_id)
  })
}) %>%
  unlist(recursive = FALSE) %>%
  bind_rows()

# ── 4. MAP GEOMETRIES ────────────────────────────────────────
cont48 <- map_data("state")

ak_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Alaska") %>%
  mutate(long = ifelse(long > 0, long - 360, long)) %>%
  filter(long >= -180) %>%
  mutate(
    long = rescale(long, to = c(-124, -113.5), from = c(-180, -130)),
    lat  = rescale(lat,  to = c(23,   31),     from = c(51,   72))
  )

hi_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Hawaii") %>%
  mutate(
    long = rescale(long, to = c(-112, -105), from = c(-160.5, -154.5)),
    lat  = rescale(lat,  to = c(23,   27),   from = c(18.9,   22.2))
  )

# ── 5. JOIN FILLS ONTO MAP GEOMETRIES FOR ALL FRAMES ─────────
join_fills <- function(geom_df, region_col, group_offset = 0) {
  geom_df %>%
    mutate(group = group + group_offset) %>%   # ensure globally unique group IDs
    left_join(
      interp_frames,
      by           = setNames("state_lower", region_col),
      relationship = "many-to-many"
    ) %>%
    mutate(fill_col = ifelse(is.na(fill_col), NEUTRAL_COLOR, fill_col))
}

# Use large offsets so group IDs never overlap across the three geometries
df48 <- join_fills(cont48,                               "region", group_offset = 0)
dfak <- join_fills(ak_raw %>% mutate(region = "alaska"), "region", group_offset = 100000)
dfhi <- join_fills(hi_raw %>% mutate(region = "hawaii"), "region", group_offset = 200000)

map_data_all <- bind_rows(df48, dfak, dfhi)

# ── 6. BUILD ANIMATED PLOT ───────────────────────────────────
# Pull one label per frame_id for the title
frame_labels <- interp_frames %>%
  distinct(frame_id, frame_year) %>%
  arrange(frame_id)

p_anim <- ggplot(map_data_all,
                 aes(x = long, y = lat, group = group, fill = fill_col)) +
  geom_polygon(color = "white", linewidth = 0.25) +
  scale_fill_identity() +
  coord_map("albers", lat0 = 29.5, lat1 = 45.5,
            xlim = c(-124, -66), ylim = c(23, 50)) +
  labs(
    title    = "State Cluster Membership, {frame_labels$frame_year[frame_labels$frame_id == as.integer(closest_state)][1]}",
    subtitle = "Darker = closer to cluster medoid"
  ) +
  theme_void(base_family = "sans") +
  theme(
    plot.title      = element_text(size = 15, face = "bold",  hjust = 0.5,
                                   margin = margin(b = 3)),
    plot.subtitle   = element_text(size =  8, color = "#555555", hjust = 0.5,
                                   margin = margin(b = 5)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(10, 10, 10, 10)
  ) +
  transition_states(
    states          = frame_id,
    transition_length = 0,   # all time is "state" time; interpolation handled manually
    state_length      = 1,
    wrap              = FALSE
  )

# ── 7. RENDER & SAVE GIF ─────────────────────────────────────
total_frames <- max(interp_frames$frame_id)

anim_obj <- animate(
  p_anim,
  nframes   = total_frames,
  fps       = FRAMES_PER_YEAR / 2,   # 1 second per year
  width     = 1000,
  height    = 450,
  renderer  = gifski_renderer(file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif")),
  bg        = "white"
)

message("GIF saved to: ", file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif"))


#=======
# Just cluster 2
#=======

# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Medoids%20(prep%20for%20viz).csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

CLUSTER_COLORS <- list(
  "1" = list(rich = "#D0D0D0", pale = "#D0D0D0"),
  "2" = list(rich = "#C46B00", pale = "#FAE0BB")
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
# Convert cluster + dist_norm to an RGB triplet (3-element numeric vector)
state_to_rgb <- function(cluster_id, dist_norm, include_flag) {
  neutral <- col2rgb(NEUTRAL_COLOR)
  if (is.na(include_flag) || include_flag != 1) return(neutral)
  pal <- CLUSTER_COLORS[[as.character(cluster_id)]]
  if (is.null(pal)) return(neutral)
  t_val <- if (is.na(dist_norm)) 0 else dist_norm
  c1 <- col2rgb(pal$rich)
  c2 <- col2rgb(pal$pale)
  round(c1 + t_val * (c2 - c1))
}

# ── 3. BUILD INTERPOLATED COLOR TABLE ────────────────────────
# For smooth transitions, generate N interpolated frames between each year pair.
# We work in RGB space so color blending is linear and flicker-free.

YEARS       <- 2000:2019
FRAMES_PER_YEAR <- 24   # intermediate steps between each year; increase for smoother GIF

# For each state × year, compute the RGB triplet
state_year_rgb <- prepped %>%
  filter(year %in% YEARS) %>%
  group_by(state_lower, year) %>%
  slice(1) %>%   # one row per state × year
  ungroup() %>%
  rowwise() %>%
  mutate(
    rgb = list(state_to_rgb(state_cluster_id, dist_norm, include))
  ) %>%
  ungroup() %>%
  mutate(
    r = sapply(rgb, `[`, 1),
    g = sapply(rgb, `[`, 2),
    b = sapply(rgb, `[`, 3)
  ) %>%
  select(state_lower, year, r, g, b)

# Generate interpolated frames
interp_frames <- lapply(seq_along(YEARS), function(i) {
  yr_a <- YEARS[i]
  yr_b <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
  
  rgb_a <- state_year_rgb %>% filter(year == yr_a) %>% select(state_lower, r, g, b)
  rgb_b <- state_year_rgb %>% filter(year == yr_b) %>% select(state_lower, r, g, b) %>%
    rename(r2 = r, g2 = g, b2 = b)
  
  joined <- left_join(rgb_a, rgb_b, by = "state_lower")
  
  steps <- if (i < length(YEARS)) seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)] else 0
  
  lapply(steps, function(t) {
    joined %>%
      mutate(
        ri = round(r + t * (r2 - r)),
        gi = round(g + t * (g2 - g)),
        bi = round(b + t * (b2 - b)),
        fill_col   = rgb(ri, gi, bi, maxColorValue = 255),
        frame_year = yr_a,
        frame_t    = t,
        frame_label = sprintf(
          "%d%s",
          yr_a,
          if (t > 0) sprintf(" → %d", yr_b) else ""
        ),
        # Numeric frame ID for gganimate ordering
        frame_id = (i - 1) * FRAMES_PER_YEAR + which(steps == t)
      ) %>%
      select(state_lower, fill_col, frame_year, frame_t, frame_label, frame_id)
  })
}) %>%
  unlist(recursive = FALSE) %>%
  bind_rows()

# ── 4. MAP GEOMETRIES ────────────────────────────────────────
cont48 <- map_data("state")

ak_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Alaska") %>%
  mutate(long = ifelse(long > 0, long - 360, long)) %>%
  filter(long >= -180) %>%
  mutate(
    long = rescale(long, to = c(-124, -113.5), from = c(-180, -130)),
    lat  = rescale(lat,  to = c(23,   31),     from = c(51,   72))
  )

hi_raw <- map_data("world", region = "USA") %>%
  filter(subregion == "Hawaii") %>%
  mutate(
    long = rescale(long, to = c(-112, -105), from = c(-160.5, -154.5)),
    lat  = rescale(lat,  to = c(23,   27),   from = c(18.9,   22.2))
  )

# ── 5. JOIN FILLS ONTO MAP GEOMETRIES FOR ALL FRAMES ─────────
join_fills <- function(geom_df, region_col, group_offset = 0) {
  geom_df %>%
    mutate(group = group + group_offset) %>%   # ensure globally unique group IDs
    left_join(
      interp_frames,
      by           = setNames("state_lower", region_col),
      relationship = "many-to-many"
    ) %>%
    mutate(fill_col = ifelse(is.na(fill_col), NEUTRAL_COLOR, fill_col))
}

# Use large offsets so group IDs never overlap across the three geometries
df48 <- join_fills(cont48,                               "region", group_offset = 0)
dfak <- join_fills(ak_raw %>% mutate(region = "alaska"), "region", group_offset = 100000)
dfhi <- join_fills(hi_raw %>% mutate(region = "hawaii"), "region", group_offset = 200000)

map_data_all <- bind_rows(df48, dfak, dfhi)

# ── 6. BUILD ANIMATED PLOT ───────────────────────────────────
# Pull one label per frame_id for the title
frame_labels <- interp_frames %>%
  distinct(frame_id, frame_year) %>%
  arrange(frame_id)

p_anim <- ggplot(map_data_all,
                 aes(x = long, y = lat, group = group, fill = fill_col)) +
  geom_polygon(color = "white", linewidth = 0.25) +
  scale_fill_identity() +
  coord_map("albers", lat0 = 29.5, lat1 = 45.5,
            xlim = c(-124, -66), ylim = c(23, 50)) +
  labs(
    title    = "State Cluster Membership, {frame_labels$frame_year[frame_labels$frame_id == as.integer(closest_state)][1]}",
    subtitle = "Darker = closer to cluster medoid"
  ) +
  theme_void(base_family = "sans") +
  theme(
    plot.title      = element_text(size = 15, face = "bold",  hjust = 0.5,
                                   margin = margin(b = 3)),
    plot.subtitle   = element_text(size =  8, color = "#555555", hjust = 0.5,
                                   margin = margin(b = 5)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(10, 10, 10, 10)
  ) +
  transition_states(
    states          = frame_id,
    transition_length = 0,   # all time is "state" time; interpolation handled manually
    state_length      = 1,
    wrap              = FALSE
  )

# ── 7. RENDER & SAVE GIF ─────────────────────────────────────
total_frames <- max(interp_frames$frame_id)

anim_obj <- animate(
  p_anim,
  nframes   = total_frames,
  fps       = FRAMES_PER_YEAR / 2,   # 1 second per year
  width     = 1000,
  height    = 450,
  renderer  = gifski_renderer(file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif")),
  bg        = "white"
)

message("GIF saved to: ", file.path(OUTPUT_DIR, "cluster_map_2000_2019.gif"))


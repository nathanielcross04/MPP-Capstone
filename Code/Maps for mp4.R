# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Cluster analysis - animated medoid map (1CS)


#==============================================================================#
# 1CS MEDOID MAP                                                               #
#==============================================================================#


# ── 0. CONFIG ────────────────────────────────────────────────

setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Final%20data/state_distances%20(raw%20and%20deltas).csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

library(ggplot2)
library(dplyr)
library(tidyr)
library(maps)
library(gganimate)
library(gifski)
library(showtext)
library(av)

font_add_google("Lato", "lato")
showtext_auto()

# Resolution & scale
# Map is landscape so we use a non-square output
OUTPUT_WIDTH  <- 1800
OUTPUT_HEIGHT <- 1100
SCALE         <- OUTPUT_WIDTH / 900   # = 2; matches original ggsave width of 900px

MEDOID_COLOR    <- "#009E73"
BASE_MAP_FILL   <- "#D9D9D9"
BASE_MAP_BORDER <- "#FFFFFF"

YEARS           <- 2000:2019
FRAMES_PER_YEAR <- 64
FADE_FRAMES     <- round(FRAMES_PER_YEAR * 0.25)


# ── 1. LOAD & PREP DISTANCE DATA ─────────────────────────────
raw <- DATA_PATH %>%
  filter(state != "District of Columbia")

dist_cols <- paste0("dist_1cs_", YEARS)

dist_long <- raw %>%
  select(state, all_of(dist_cols)) %>%
  pivot_longer(
    cols         = all_of(dist_cols),
    names_to     = "year",
    names_prefix = "dist_1cs_",
    values_to    = "dist_1cs"
  ) %>%
  mutate(year = as.integer(year))

medoid_by_year <- dist_long %>%
  group_by(year) %>%
  arrange(dist_1cs, .by_group = TRUE) %>%
  mutate(rank_1cs = min_rank(dist_1cs)) %>%
  group_modify(function(df, key) {
    for (max_rank in sort(unique(df$rank_1cs))) {
      candidates <- df %>% filter(rank_1cs <= max_rank)
      if (nrow(candidates) >= 4) return(candidates)
    }
    return(df)
  }) %>%
  ungroup() %>%
  select(state, year) %>%
  mutate(is_medoid = TRUE)


# ── 2. BUILD MAP GEOMETRIES ───────────────────────────────────
conus_df <- map_data("state") %>%
  mutate(
    state_name = tools::toTitleCase(region),
    group      = paste0("conus_", group)
  ) %>%
  filter(!state_name %in% c("District Of Columbia")) %>%
  select(long, lat, group, order, state_name)

ak_raw <- map_data("world", region = "USA") %>%
  filter(!is.na(subregion) & subregion == "Alaska") %>%
  mutate(long = ifelse(long > 0, long - 360, long))

ak_cx <- mean(range(ak_raw$long))
ak_cy <- mean(range(ak_raw$lat))

ak_df <- ak_raw %>%
  mutate(
    long       = (long - ak_cx) * 0.23 + (-120),
    lat        = (lat  - ak_cy) * 0.35 + 26,
    state_name = "Alaska",
    group      = paste0("ak_", group)
  ) %>%
  select(long, lat, group, order, state_name)

hi_raw <- map_data("world", region = "USA") %>%
  filter(!is.na(subregion) & subregion == "Hawaii")

if (nrow(hi_raw) == 0) {
  hi_raw <- map_data("world", region = "Hawaii")
}

hi_cx <- mean(range(hi_raw$long))
hi_cy <- mean(range(hi_raw$lat))

hi_df <- hi_raw %>%
  mutate(
    long       = (long - hi_cx) * 1.2 + (-109),
    lat        = (lat  - hi_cy) * 1.2 + 26,
    state_name = "Hawaii",
    group      = paste0("hi_", group)
  ) %>%
  select(long, lat, group, order, state_name)

all_states_df <- bind_rows(conus_df, ak_df, hi_df)


# ── 3. BUILD PER-FRAME DATA ───────────────────────────────────
medoid_continuity <- medoid_by_year %>%
  arrange(state, year) %>%
  group_by(state) %>%
  mutate(
    medoid_prev = lag(year)  == year - 1,
    medoid_next = lead(year) == year + 1
  ) %>%
  ungroup() %>%
  mutate(
    medoid_prev = replace_na(medoid_prev, FALSE),
    medoid_next = replace_na(medoid_next, FALSE),
    do_fade_in  = !medoid_prev,
    do_fade_out = !medoid_next
  )

frame_lookup <- data.frame(
  frame_id     = seq_len(length(YEARS) * FRAMES_PER_YEAR),
  year         = rep(YEARS, each = FRAMES_PER_YEAR),
  frame_within = rep(seq_len(FRAMES_PER_YEAR), times = length(YEARS))
) %>%
  mutate(year_label = as.character(year))

medoid_frames <- frame_lookup %>%
  left_join(medoid_continuity, by = "year") %>%
  mutate(
    hold_end     = FRAMES_PER_YEAR - FADE_FRAMES,
    medoid_alpha = case_when(
      do_fade_in  & frame_within <= FADE_FRAMES ~ frame_within / FADE_FRAMES,
      do_fade_out & frame_within >  hold_end    ~ (FRAMES_PER_YEAR - frame_within + 1) / (FADE_FRAMES + 1),
      TRUE                                      ~ 1
    )
  ) %>%
  select(-hold_end) %>%
  left_join(
    all_states_df,
    by           = c("state" = "state_name"),
    relationship = "many-to-many"
  ) %>%
  mutate(group = paste0(group, "_f", frame_id)) %>%
  select(frame_id, year_label, medoid_alpha, state, long, lat, group, order)

message("medoid_frames rows: ", nrow(medoid_frames))


# ── 4. RENDER FRAMES & STITCH MP4 ────────────────────────────
frame_dir <- file.path(OUTPUT_DIR, "frames_tmp")
dir.create(frame_dir, showWarnings = FALSE)

base_plot <- ggplot() +
  geom_polygon(
    data      = all_states_df,
    aes(x = long, y = lat, group = group),
    fill      = BASE_MAP_FILL,
    color     = BASE_MAP_BORDER,
    linewidth = 0.25 * SCALE
  ) +
  coord_fixed(
    ratio  = 1.3,
    xlim   = c(-128, -65),
    ylim   = c(22,   50),
    expand = FALSE
  ) +
  theme_void(base_family = "lato") +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(t = 20 * SCALE, r = 20 * SCALE,
                             b = 10 * SCALE, l = 20 * SCALE)
  )

total_frames <- max(frame_lookup$frame_id)

for (fid in seq_len(total_frames)) {
  
  yr_label   <- frame_lookup$year_label[frame_lookup$frame_id == fid]
  frame_data <- medoid_frames %>% filter(frame_id == fid)
  
  p <- base_plot +
    
    geom_polygon(
      data        = frame_data,
      aes(x = long, y = lat, group = group, alpha = medoid_alpha),
      fill        = MEDOID_COLOR,
      color       = BASE_MAP_BORDER,
      linewidth   = 0.25 * SCALE,
      show.legend = FALSE
    ) +
    scale_alpha_identity() +
    
    labs(
      title    = "Medoid states remain mostly consistent over\ntime, many are entrenched red states",
      subtitle = paste0("States closest to the policy vector centroid, in ", yr_label)
    ) +
    
    theme(
      plot.title.position = "plot",
      plot.title    = element_text(size   = 25 * SCALE,
                                   face   = "bold",
                                   family = "lato",
                                   hjust  = 0,
                                   margin = margin(t = 20 * SCALE, b = 8 * SCALE)),
      plot.subtitle = element_text(size   = 14 * SCALE,
                                   color  = "#555555",
                                   family = "lato",
                                   hjust  = 0,
                                   margin = margin(b = 8 * SCALE)),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin     = margin(t = 10 * SCALE, r = 20 * SCALE,
                               b = 10 * SCALE, l = 20 * SCALE)
    )
  
  ggsave(
    filename = file.path(frame_dir, sprintf("frame_%04d.png", fid)),
    plot     = p,
    width    = OUTPUT_WIDTH,
    height   = OUTPUT_HEIGHT,
    units    = "px",
    dpi      = 150,
    bg       = "white"
  )
  
  if (fid %% 10 == 0) message("Rendered frame ", fid, " of ", total_frames)
}


# ── 5. STITCH FRAMES INTO MP4 ────────────────────────────────
png_files <- list.files(frame_dir, pattern = "\\.png$",
                        full.names = TRUE) %>% sort()

av::av_encode_video(
  input   = png_files,
  output  = file.path(OUTPUT_DIR, "medoid_map_1cs.mp4"),
  framerate = FRAMES_PER_YEAR,
  vfilter = "scale=trunc(iw/2)*2:trunc(ih/2)*2"
)

unlink(frame_dir, recursive = TRUE)

message("MP4 saved to: ", file.path(OUTPUT_DIR, "medoid_map_1cs.mp4"))

rm(list = ls())


#==============================================================================#
# 2CS MEDOID MAP                                                               #
#==============================================================================#


# ── 0. CONFIG ────────────────────────────────────────────────

setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Final%20data/state_distances%20(raw%20and%20deltas).csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

library(ggplot2)
library(dplyr)
library(tidyr)
library(maps)
library(gganimate)
library(gifski)
library(showtext)
library(av)

font_add_google("Lato", "lato")
showtext_auto()

# Resolution & scale
OUTPUT_WIDTH  <- 1800
OUTPUT_HEIGHT <- 1100
SCALE         <- OUTPUT_WIDTH / 900   # = 2

CLUSTER_COLORS  <- c("1" = "#B5463A", "2" = "#2E86B5")
BASE_MAP_FILL   <- "#D9D9D9"
BASE_MAP_BORDER <- "#FFFFFF"

YEARS           <- 2000:2019
FRAMES_PER_YEAR <- 64
FADE_FRAMES     <- round(FRAMES_PER_YEAR * 0.25)


# ── 1. LOAD & PREP DISTANCE DATA ─────────────────────────────
raw <- DATA_PATH %>%
  filter(state != "District of Columbia")

cluster_cols  <- paste0("cluster_",  YEARS)
dist_own_cols <- paste0("dist_own_", YEARS)

cluster_long <- raw %>%
  select(state, all_of(cluster_cols)) %>%
  pivot_longer(
    cols         = all_of(cluster_cols),
    names_to     = "year",
    names_prefix = "cluster_",
    values_to    = "cluster"
  ) %>%
  mutate(year = as.integer(year), cluster = as.character(cluster))

dist_own_long <- raw %>%
  select(state, all_of(dist_own_cols)) %>%
  pivot_longer(
    cols         = all_of(dist_own_cols),
    names_to     = "year",
    names_prefix = "dist_own_",
    values_to    = "dist_own"
  ) %>%
  mutate(year = as.integer(year), dist_own = as.numeric(dist_own))

state_year <- cluster_long %>%
  left_join(dist_own_long, by = c("state", "year"))

medoid_by_year <- state_year %>%
  group_by(year, cluster) %>%
  arrange(dist_own, .by_group = TRUE) %>%
  mutate(rank_own = min_rank(dist_own)) %>%
  group_modify(function(df, key) {
    for (max_rank in sort(unique(df$rank_own))) {
      candidates <- df %>% filter(rank_own <= max_rank)
      if (nrow(candidates) >= 3) return(candidates)
    }
    return(df)
  }) %>%
  ungroup() %>%
  select(state, year, cluster)


# ── 2. BUILD MAP GEOMETRIES ───────────────────────────────────
conus_df <- map_data("state") %>%
  mutate(
    state_name = tools::toTitleCase(region),
    group      = paste0("conus_", group)
  ) %>%
  filter(!state_name %in% c("District Of Columbia")) %>%
  select(long, lat, group, order, state_name)

ak_raw <- map_data("world", region = "USA") %>%
  filter(!is.na(subregion) & subregion == "Alaska") %>%
  mutate(long = ifelse(long > 0, long - 360, long))

ak_cx <- mean(range(ak_raw$long))
ak_cy <- mean(range(ak_raw$lat))

ak_df <- ak_raw %>%
  mutate(
    long       = (long - ak_cx) * 0.23 + (-120),
    lat        = (lat  - ak_cy) * 0.35 + 26,
    state_name = "Alaska",
    group      = paste0("ak_", group)
  ) %>%
  select(long, lat, group, order, state_name)

hi_raw <- map_data("world", region = "USA") %>%
  filter(!is.na(subregion) & subregion == "Hawaii")

if (nrow(hi_raw) == 0) {
  hi_raw <- map_data("world", region = "Hawaii")
}

hi_cx <- mean(range(hi_raw$long))
hi_cy <- mean(range(hi_raw$lat))

hi_df <- hi_raw %>%
  mutate(
    long       = (long - hi_cx) * 1.2 + (-109),
    lat        = (lat  - hi_cy) * 1.2 + 26,
    state_name = "Hawaii",
    group      = paste0("hi_", group)
  ) %>%
  select(long, lat, group, order, state_name)

all_states_df <- bind_rows(conus_df, ak_df, hi_df)


# ── 3. BUILD PER-FRAME DATA ───────────────────────────────────
medoid_continuity <- medoid_by_year %>%
  arrange(state, cluster, year) %>%
  group_by(state, cluster) %>%
  mutate(
    medoid_prev = lag(year)  == year - 1,
    medoid_next = lead(year) == year + 1
  ) %>%
  ungroup() %>%
  mutate(
    medoid_prev = replace_na(medoid_prev, FALSE),
    medoid_next = replace_na(medoid_next, FALSE),
    do_fade_in  = !medoid_prev,
    do_fade_out = !medoid_next
  )

frame_lookup <- data.frame(
  frame_id     = seq_len(length(YEARS) * FRAMES_PER_YEAR),
  year         = rep(YEARS, each = FRAMES_PER_YEAR),
  frame_within = rep(seq_len(FRAMES_PER_YEAR), times = length(YEARS))
) %>%
  mutate(year_label = as.character(year))

medoid_frames <- frame_lookup %>%
  left_join(medoid_continuity, by = "year") %>%
  mutate(
    hold_end     = FRAMES_PER_YEAR - FADE_FRAMES,
    medoid_alpha = case_when(
      do_fade_in  & frame_within <= FADE_FRAMES ~ frame_within / FADE_FRAMES,
      do_fade_out & frame_within >  hold_end    ~ (FRAMES_PER_YEAR - frame_within + 1) / (FADE_FRAMES + 1),
      TRUE                                      ~ 1
    ),
    fill_color = CLUSTER_COLORS[cluster]
  ) %>%
  select(-hold_end) %>%
  left_join(
    all_states_df,
    by           = c("state" = "state_name"),
    relationship = "many-to-many"
  ) %>%
  mutate(group = paste0(group, "_c", cluster, "_f", frame_id)) %>%
  select(frame_id, year_label, medoid_alpha, fill_color,
         state, cluster, long, lat, group, order)

message("medoid_frames rows: ", nrow(medoid_frames))


# ── 4. RENDER FRAMES & STITCH MP4 ────────────────────────────
frame_dir <- file.path(OUTPUT_DIR, "frames_tmp_2cs")
dir.create(frame_dir, showWarnings = FALSE)

base_plot <- ggplot() +
  geom_polygon(
    data      = all_states_df,
    aes(x = long, y = lat, group = group),
    fill      = BASE_MAP_FILL,
    color     = BASE_MAP_BORDER,
    linewidth = 0.25 * SCALE
  ) +
  coord_fixed(
    ratio  = 1.3,
    xlim   = c(-128, -65),
    ylim   = c(22,   50),
    expand = FALSE
  ) +
  theme_void(base_family = "lato") +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(t = 10 * SCALE, r = 20 * SCALE,
                             b = 10 * SCALE, l = 20 * SCALE)
  )

total_frames <- max(frame_lookup$frame_id)

for (fid in seq_len(total_frames)) {
  
  yr_label   <- frame_lookup$year_label[frame_lookup$frame_id == fid]
  frame_data <- medoid_frames %>% filter(frame_id == fid)
  
  p <- base_plot +
    
    geom_polygon(
      data        = frame_data,
      aes(x = long, y = lat, group = group, alpha = medoid_alpha),
      fill        = frame_data$fill_color,
      color       = BASE_MAP_BORDER,
      linewidth   = 0.25 * SCALE,
      show.legend = FALSE
    ) +
    scale_alpha_identity() +
    
    labs(
      title    = "Geographic differences demarcate cluster\ndistinctions over time",
      subtitle = paste0("States closest to their respective cluster centroid, in ", yr_label)
    ) +
    
    theme(
      plot.title.position = "plot",
      plot.title    = element_text(size   = 25 * SCALE,
                                   face   = "bold",
                                   family = "lato",
                                   hjust  = 0,
                                   margin = margin(t = 20 * SCALE, b = 8 * SCALE)),
      plot.subtitle = element_text(size   = 14 * SCALE,
                                   color  = "#555555",
                                   family = "lato",
                                   hjust  = 0,
                                   margin = margin(b = 8 * SCALE)),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin     = margin(t = 10 * SCALE, r = 20 * SCALE,
                               b = 10 * SCALE, l = 20 * SCALE)
    )
  
  ggsave(
    filename = file.path(frame_dir, sprintf("frame_%04d.png", fid)),
    plot     = p,
    width    = OUTPUT_WIDTH,
    height   = OUTPUT_HEIGHT,
    units    = "px",
    dpi      = 150,
    bg       = "white"
  )
  
  if (fid %% 10 == 0) message("Rendered frame ", fid, " of ", total_frames)
}


# ── 5. STITCH FRAMES INTO MP4 ────────────────────────────────
png_files <- list.files(frame_dir, pattern = "\\.png$",
                        full.names = TRUE) %>% sort()

av::av_encode_video(
  input     = png_files,
  output    = file.path(OUTPUT_DIR, "medoid_map_2cs.mp4"),
  framerate = FRAMES_PER_YEAR,
  vfilter   = "scale=trunc(iw/2)*2:trunc(ih/2)*2"
)

unlink(frame_dir, recursive = TRUE)

message("MP4 saved to: ", file.path(OUTPUT_DIR, "medoid_map_2cs.mp4"))

rm(list = ls())



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
# Cluster 1 Medoid Animation: State Proximity Over Time
# 2000–2019 | Animated US Choropleth using gganimate
# ============================================================
# Required packages:
   install.packages(c("ggplot2", "dplyr", "maps", "gganimate", "gifski", "transformr"))

library(ggplot2)
library(dplyr)
library(maps)
library(gganimate)
library(gifski)
library(transformr)
library(tidyverse)

# ── 1. Load Data ─────────────────────────────────────────────
df <- read_csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Medoids.csv")

# ── 2. Filter to Cluster 1 only ──────────────────────────────
cl1 <- df %>%
  filter(state_cluster_id == 1) %>%
  select(state, id, year, total_distance, medoid_rank1)

# ── 3. Per-year: identify medoid and top-5 closest states ────
# The medoid is rank == 1 (or tied at rank 1). 
# We want to highlight: the medoid (rank 1) + 4 next closest by distance.
# "If more than 5 states share the medoid score, all are shown."
# Coloring is by total_distance (lower = more saturated), not rank.

cl1_highlighted <- cl1 %>%
  group_by(year) %>%
  arrange(total_distance, .by_group = TRUE) %>%
  mutate(
    is_medoid = medoid_rank1 == 1,
    # rank all states in cluster 1 by distance ascending
    dist_rank = rank(total_distance, ties.method = "min"),
    # how many states share the minimum distance (medoid tie)
    n_medoid_ties = sum(is_medoid, na.rm = TRUE),
    # include: all medoid-tied states + enough next-closest to reach top 5
    #   if ties >= 5, show all ties; otherwise show ties + fill up to 5
    top5_cutoff = pmax(5, n_medoid_ties),
    highlight = dist_rank <= top5_cutoff
  ) %>%
  ungroup()

# ── 4. Build color/saturation variable ───────────────────────
# For highlighted states: rescale total_distance within [0,1] per year,
# where 0 = medoid (most saturated) and 1 = least saturated among top-5.
# Non-highlighted states get NA (mapped to a neutral grey).

cl1_highlighted <- cl1_highlighted %>%
  group_by(year) %>%
  mutate(
    # only scale within the highlighted group
    dist_min  = min(total_distance[highlight]),
    dist_max  = max(total_distance[highlight]),
    # 0 = closest (medoid), 1 = farthest in the highlight set
    dist_norm = ifelse(
      highlight,
      (total_distance - dist_min) / pmax(dist_max - dist_min, 1e-9),
      NA_real_
    )
  ) %>%
  ungroup()

# ── 5. Join to US map polygons ───────────────────────────────
states_map <- map_data("state")

# Standardise state names to lowercase for joining
cl1_highlighted <- cl1_highlighted %>%
  mutate(region = tolower(state))

# Note: "District of Columbia" is "district of columbia" in map_data
map_df <- states_map %>%
  left_join(cl1_highlighted, by = "region")

# ── 6. Define a saturated-to-muted colour scale ──────────────
# Medoid (dist_norm = 0): deep crimson/scarlet  → most saturated
# 4th/5th closest (dist_norm ≈ 1): pale pink    → least saturated
# Non-highlighted: medium grey
MEDOID_COLOR   <- "#C1121F"   # vivid red
NEAR_COLOR     <- "#FFCCD0"   # very pale pink
GREY_COLOR     <- "#D9D9D9"   # neutral grey for non-highlighted
BORDER_COLOR   <- "#FFFFFF"
BACKGROUND     <- "#1A1A2E"
LAND_BASE      <- "#2E2E4A"

# ── 7. Build the base map ────────────────────────────────────
# We create a "fill_val" that smoothly encodes distance:
# highlighted states → dist_norm in [0,1]; others → NA (grey)

p <- ggplot(map_df, aes(x = long, y = lat, group = group, fill = dist_norm)) +
  geom_polygon(color = BORDER_COLOR, linewidth = 0.25) +
  # Continuous fill for highlighted states
  scale_fill_gradient(
    low      = MEDOID_COLOR,
    high     = NEAR_COLOR,
    na.value = GREY_COLOR,
    limits   = c(0, 1),
    name     = "Proximity\n(0 = medoid)",
    guide    = guide_colorbar(
      title.position = "top",
      barwidth       = unit(0.4, "cm"),
      barheight      = unit(4, "cm"),
      ticks.colour   = "white",
      frame.colour   = "white"
    )
  ) +
  coord_fixed(1.3, xlim = c(-125, -66), ylim = c(24, 50)) +
  # ── year label ──────────────────────────────────────────────
  labs(
    title    = "Cluster 1 — State Proximity to Medoid",
    subtitle = "Year: {round(frame_time)}",
    caption  = "Color intensity reflects distance to cluster centroid.\nMost saturated = medoid | Grey = outside top-5 closest"
  ) +
  theme_void(base_family = "sans") +
  theme(
    plot.background    = element_rect(fill = BACKGROUND, color = NA),
    panel.background   = element_rect(fill = BACKGROUND, color = NA),
    plot.title         = element_text(color = "white", size = 18,
                                      face = "bold",  hjust = 0.5,
                                      margin = margin(t = 12, b = 4)),
    plot.subtitle      = element_text(color = "#AAAACC", size = 14,
                                      hjust = 0.5,
                                      margin = margin(b = 8)),
    plot.caption       = element_text(color = "#777799", size = 8,
                                      hjust = 0.5,
                                      margin = margin(t = 8, b = 8)),
    legend.position    = c(0.92, 0.30),
    legend.title       = element_text(color = "white", size = 9),
    legend.text        = element_text(color = "#AAAACC", size = 8),
    plot.margin        = margin(10, 10, 10, 10)
  )

# ── 8. Animate ───────────────────────────────────────────────
# transition_time() interpolates continuously between years.
# ease_aes('cubic-in-out') gives a smooth easing between frames.
anim <- p +
  transition_time(year) +
  ease_aes("cubic-in-out")

# ── 9. Render ────────────────────────────────────────────────
# fps=20 with 200ms per year transition gives ~20 real frames per year.
# nframes: 20 years × 20 frames = 400 frames; increase for smoother output.
animate(
  anim,
  nframes   = 400,      # total frames (≈ 20 per year)
  fps       = 20,       # playback speed
  width     = 900,
  height    = 560,
  renderer  = gifski_renderer("cluster1_medoid_animation.gif"),
  end_pause = 30        # hold on final year for 1.5 s
)

message("✓ Animation saved to: cluster1_medoid_animation.gif")








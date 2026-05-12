# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Cluster analysis - line plots
#==============================================================================#
# CLUSTER COMPARISON LINE PLOTS                                                #
#==============================================================================#
# ── 0. CONFIG ─────────────────────────────────────────────────────────────────
# Set working directory
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

# Load dependencies
library(ggplot2)
library(patchwork)
library(showtext)
font_add_google("Lato", "lato")
showtext_auto()

# Load data
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/cluster_sumstats.csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# Subset to clusters 1 and 2 only
cluster_data <- subset(DATA_PATH, cluster %in% c(1, 2))
cluster_data$cluster <- factor(cluster_data$cluster)

# ── 1. CLUSTER COLORS ─────────────────────────────────────────────────────────
cluster_colors <- c("1" = "#B5463A", "2" = "#2E86B5")

# ── 2. ENDPOINT LABELS (last data point per cluster) ─────────────────────────
labels_n    <- subset(cluster_data, year == max(year))
labels_dist <- subset(cluster_data, year == max(year))

# ── 3. PLOT 1: N by cluster ───────────────────────────────────────────────────
p1 <- ggplot(cluster_data, aes(x = year, y = n_cluster, color = cluster, group = cluster)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  geom_text(
    data         = labels_n,
    aes(label    = paste0("Cluster ", cluster)),
    hjust        = -0.15,
    size         = 12,
    fontface     = "bold",
    family       = "lato",
    show.legend  = FALSE
  ) +
  scale_color_manual(values = cluster_colors) +
  scale_x_continuous(
    breaks = c(2000, 2005, 2010, 2015, 2019),
    limits = c(2000, 2019)          # hard stop at 2019
  ) +
  coord_cartesian(clip = "off") +   # lets geom_text bleed into the margin
  scale_y_continuous(breaks = seq(0, 40, by = 10), limits = c(0, 40)) +
  labs(
    title = "Once stable, the number of states per cluster converges\nsignificantly around 2010",
    x     = NULL,
    y     = NULL
  ) +
  theme_minimal(base_family = "lato") +
  theme(
    plot.title           = element_text(size = 60, color = "black", face = "bold",
                                        family = "lato", lineheight = 0.35,
                                        hjust = 0, margin = margin(t = 10, b = 10)),
    axis.text            = element_text(size = 35, color = "#444444"),
    panel.grid.major     = element_line(color = "#CCCCCC", linewidth = 0.4),
    panel.grid.minor     = element_blank(),
    plot.background      = element_rect(fill = "white", color = NA),
    plot.margin          = margin(t = 5, r = 60, b = 10, l = 20),
    plot.title.position  = "plot",
    legend.position      = "none"
  )

# ── 4. PLOT 2: Mean distance to own centroid by cluster ───────────────────────
p2 <- ggplot(cluster_data, aes(x = year, y = mean_dist_own, color = cluster, group = cluster)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  geom_text(
    data         = labels_dist,
    aes(label    = paste0("Cluster ", cluster)),
    hjust        = -0.15,
    size         = 12,
    fontface     = "bold",
    family       = "lato",
    show.legend  = FALSE
  ) +
  scale_color_manual(values = cluster_colors) +
  scale_x_continuous(
    breaks = c(2000, 2005, 2010, 2015, 2019),
    limits = c(2000, 2019)          # hard stop at 2019
  ) +
  coord_cartesian(clip = "off") +   # lets geom_text bleed into the margin
  scale_y_continuous(breaks = seq(0.8, 1.8, by = 0.2), limits = c(0.8, 1.8)) +
  labs(
    title = "Cluster 2 states average much further from own-cluster\ncentroid that Cluster 1 counterparts, 2000-2019",
    x     = NULL,
    y     = NULL
  ) +
  theme_minimal(base_family = "lato") +
  theme(
    plot.title           = element_text(size = 60, color = "black", face = "bold",
                                        family = "lato", lineheight = 0.35,
                                        hjust = 0, margin = margin(t = 10, b = 10)),
    axis.text            = element_text(size = 35, color = "#444444"),
    panel.grid.major     = element_line(color = "#CCCCCC", linewidth = 0.4),
    panel.grid.minor     = element_blank(),
    plot.background      = element_rect(fill = "white", color = NA),
    plot.margin          = margin(t = 5, r = 60, b = 10, l = 20),
    plot.title.position  = "plot",
    legend.position      = "none"
  )

# ── 5. SAVE PLOTS ─────────────────────────────────────────────────────────────
ggsave(
  filename = file.path(OUTPUT_DIR, "cluster_n_comparison.png"),
  plot     = p1,
  width    = 7.5,
  height   = 5,
  dpi      = 300,
  bg       = "white"
)

ggsave(
  filename = file.path(OUTPUT_DIR, "cluster_dist_comparison.png"),
  plot     = p2,
  width    = 7.5,
  height   = 5,
  dpi      = 300,
  bg       = "white"
)

###
# Subset to only 2000–2005 for the lines/points
cluster_data_05 <- subset(cluster_data, year <= 2005)
labels_n_05     <- subset(cluster_data, year == 2005)

p1_short <- ggplot() +
  geom_line(
    data     = cluster_data_05,
    aes(x = year, y = n_cluster, color = cluster, group = cluster),
    linewidth = 0.9
  ) +
  geom_point(
    data = cluster_data_05,
    aes(x = year, y = n_cluster, color = cluster, group = cluster),
    size = 2
  ) +
  geom_text(
    data     = labels_n_05,
    aes(x = year, y = n_cluster, label = paste0("Cluster ", cluster), color = cluster),
    hjust    = -0.15,
    size     = 12,
    fontface = "bold",
    family   = "lato",
    show.legend = FALSE
  ) +
  scale_color_manual(values = cluster_colors) +
  scale_x_continuous(
    breaks = c(2000, 2005, 2010, 2015, 2019),
    limits = c(2000, 2019)
  ) +
  scale_y_continuous(breaks = seq(0, 40, by = 10), limits = c(0, 40)) +
  coord_cartesian(clip = "off") +
  labs(
    title = "Once stable, the number of states per cluster converges\nsignificantly around 2010",
    x     = NULL,
    y     = NULL
  ) +
  theme_minimal(base_family = "lato") +
  theme(
    plot.title          = element_text(size = 60, color = "black", face = "bold",
                                       family = "lato", lineheight = 0.35,
                                       hjust = 0, margin = margin(t = 10, b = 10)),
    axis.text           = element_text(size = 35, color = "#444444"),
    panel.grid.major    = element_line(color = "#CCCCCC", linewidth = 0.4),
    panel.grid.minor    = element_blank(),
    plot.background     = element_rect(fill = "white", color = NA),
    plot.margin         = margin(t = 5, r = 60, b = 10, l = 20),
    plot.title.position = "plot",
    legend.position     = "none"
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "cluster_dist_short.png"),
  plot     = p1_short,
  width    = 7.5,
  height   = 5,
  dpi      = 300,
  bg       = "white"
)


rm(list = ls())

OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"


library(ggplot2)
library(dplyr)
library(maps)
library(showtext)
font_add_google("Lato", "lato")
showtext_auto()

BASE_MAP_FILL   <- "#D55E00"
BASE_MAP_BORDER <- "#FFFFFF"

target_states <- c("California", "New York", "Washington", "Texas", "Illinois")

five_states_df <- map_data("state") %>%
  mutate(state_name = tools::toTitleCase(region)) %>%
  filter(state_name %in% target_states)

abbr_lookup <- c(
  "California" = "CA",
  "New York"   = "NY",
  "Washington" = "WA",
  "Texas"      = "TX",
  "Illinois"   = "IL"
)

state_labels <- five_states_df %>%
  group_by(state_name) %>%
  summarise(long = mean(range(long)), lat = mean(range(lat))) %>%
  mutate(abbr = abbr_lookup[state_name])

p <- ggplot() +
  geom_polygon(
    data  = five_states_df,
    aes(x = long, y = lat, group = group),
    fill      = BASE_MAP_FILL,
    color     = BASE_MAP_BORDER,
    linewidth = 0.25
  ) +
  coord_fixed(ratio = 1.3) +
  theme_void(base_family = "lato") +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(t = 10, r = 10, b = 10, l = 10)
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "five_states_map.png"),
  plot     = p,
  width    = 9,
  height   = 5.5,
  dpi      = 300,
  bg       = "white"
)
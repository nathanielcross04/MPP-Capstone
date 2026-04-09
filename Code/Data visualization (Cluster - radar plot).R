# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Cluster analysis - radar plot


#=======#
# Setup #
#=======#

# Set working directory
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")
getwd()
file.exists("Data/Other data/Radar plot centroids.csv")

library(showtext)

font_add_google("Lato", "lato")
showtext_auto()

# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Radar%20plot%20centroids.csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# ============================================================
# Radar Plot — Animated GIF (2000–2019)
# Requires: ggplot2, dplyr, tidyr, scales, gganimate, gifski
# ============================================================

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(gganimate)
library(gifski)


# Color palette: pro spokes = teal, anti spokes = red
# Color palette: pro spokes = teal, anti spokes = red/orange
SPOKE_COLORS <- c(
  "index_enf_anti" = "black",
  "index_enf_pro"  = "black",
  "index_pub_pro"  = "black",
  "index_int_pro"  = "black",
  "index_int_anti" = "black"
)

SPOKE_LABEL_COLORS <- c(
  "index_enf_anti" = "#D55E00",
  "index_enf_pro"  = "#009E73",
  "index_pub_pro"  = "#009E73",
  "index_int_pro"  = "#009E73",
  "index_int_anti" = "#D55E00"
)

# Human-readable spoke labels
SPOKE_LABELS <- c(
  "index_enf_anti" = "Anti-immigrant\nenforcement policies",
  "index_enf_pro"  = "Pro-immigrant\nenforcement policies",
  "index_pub_pro"  = "Pro-immigrant\npublic benefits policies",
  "index_int_pro"  = "Pro-immigrant\nintegration polices",
  "index_int_anti" = "Anti-immigrant\nintegration policies "
)

YEARS           <- 2000:2019
FRAMES_PER_YEAR <- 64


# ── 1. LOAD & PREP DATA ──────────────────────────────────────
raw <- DATA_PATH

long_data <- raw %>%
  filter(year %in% YEARS) %>%
  pivot_longer(cols = -year, names_to = "variable", values_to = "value")

# Global max for consistent axis scaling across all years
axis_max <- 0.50

# ── 2. RADAR GEOMETRY HELPERS ────────────────────────────────
SPOKES       <- names(SPOKE_LABELS)
N_SPOKES     <- length(SPOKES)
SPOKE_ANGLES <- seq(0, 2 * pi, length.out = N_SPOKES + 1)[-(N_SPOKES + 1)]

polar_to_xy <- function(angle, value, max_val) {
  r <- value / max_val
  list(x = r * sin(angle), y = r * cos(angle))
}

# Build polygon rows; append first point to close the shape
build_polygon <- function(yr_values, max_val) {
  coords <- mapply(function(angle, val) polar_to_xy(angle, val, max_val),
                   SPOKE_ANGLES, yr_values, SIMPLIFY = FALSE)
  xs <- sapply(coords, `[[`, "x")
  ys <- sapply(coords, `[[`, "y")
  data.frame(
    x        = c(xs, xs[1]),
    y        = c(ys, ys[1]),
    variable = c(SPOKES, SPOKES[1])
  )
}

# Build polygon rows WITHOUT closing repeat (for points layer)
build_points <- function(yr_values, max_val) {
  coords <- mapply(function(angle, val) polar_to_xy(angle, val, max_val),
                   SPOKE_ANGLES, yr_values, SIMPLIFY = FALSE)
  data.frame(
    x        = sapply(coords, `[[`, "x"),
    y        = sapply(coords, `[[`, "y"),
    variable = SPOKES
  )
}

build_gridlines <- function(max_val, n_rings = 5) {
  ring_vals <- seq(max_val / n_rings, max_val, length.out = n_rings)
  lapply(ring_vals, function(rv) {
    angles <- c(SPOKE_ANGLES, SPOKE_ANGLES[1])
    data.frame(
      x     = (rv / max_val) * sin(angles),
      y     = (rv / max_val) * cos(angles),
      label = rv
    )
  })
}

build_spokes <- function() {
  data.frame(
    x_end    = sin(SPOKE_ANGLES),
    y_end    = cos(SPOKE_ANGLES),
    variable = SPOKES,
    color    = unname(SPOKE_COLORS),
    stringsAsFactors = FALSE
  )
}

build_labels <- function(label_radius = 1.35) {
  data.frame(
    x        = label_radius * sin(SPOKE_ANGLES),
    y        = label_radius * cos(SPOKE_ANGLES),
    variable = SPOKES,
    label    = unname(SPOKE_LABELS),
    color    = unname(SPOKE_LABEL_COLORS),
    stringsAsFactors = FALSE
  )
}

# ── 3. BUILD PER-YEAR VALUES ──────────────────────────────────
year_values <- lapply(YEARS, function(yr) {
  row <- raw %>% filter(year == yr)
  sapply(SPOKES, function(s) as.numeric(row[[s]]))
})
names(year_values) <- as.character(YEARS)

# ── 4. INTERPOLATE FRAMES ────────────────────────────────────
# Polygon frames (closed — for fill + outline)
interp_poly <- lapply(seq_along(YEARS), function(i) {
  yr_a   <- YEARS[i]
  yr_b   <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
  vals_a <- year_values[[as.character(yr_a)]]
  vals_b <- year_values[[as.character(yr_b)]]
  steps  <- if (i < length(YEARS)) {
    seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)]
  } else { rep(0, FRAMES_PER_YEAR) }
  
  lapply(seq_along(steps), function(si) {
    t    <- steps[si]
    vals <- vals_a + t * (vals_b - vals_a)
    poly <- build_polygon(vals, axis_max)
    poly$frame_id   <- (i - 1) * FRAMES_PER_YEAR + si
    poly$year_label <- as.character(yr_a)
    poly
  })
}) %>% unlist(recursive = FALSE) %>% bind_rows()

# Points frames (N_SPOKES rows only — for colored dots)
interp_pts <- lapply(seq_along(YEARS), function(i) {
  yr_a   <- YEARS[i]
  yr_b   <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
  vals_a <- year_values[[as.character(yr_a)]]
  vals_b <- year_values[[as.character(yr_b)]]
  steps  <- if (i < length(YEARS)) {
    seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)]
  } else { rep(0, FRAMES_PER_YEAR) }
  
  lapply(seq_along(steps), function(si) {
    t    <- steps[si]
    vals <- vals_a + t * (vals_b - vals_a)
    pts  <- build_points(vals, axis_max)
    pts$frame_id    <- (i - 1) * FRAMES_PER_YEAR + si
    pts$year_label  <- as.character(yr_a)
    pts$spoke_color <- unname(SPOKE_COLORS[pts$variable])
    pts
  })
}) %>% unlist(recursive = FALSE) %>% bind_rows()

# Year label lookup (one row per frame_id) — used for animated subtitle
year_label_df <- interp_poly %>%
  distinct(frame_id, year_label)

# ── 5. STATIC CHART ELEMENTS ─────────────────────────────────
gridlines  <- build_gridlines(axis_max)
spoke_axes <- build_spokes()
labels_df  <- build_labels()

labels_df$x[labels_df$variable == "index_pub_pro"]  <-
  labels_df$x[labels_df$variable == "index_pub_pro"]  * 0.85
labels_df$y[labels_df$variable == "index_pub_pro"]  <-
  labels_df$y[labels_df$variable == "index_pub_pro"]  * 0.85

labels_df$x[labels_df$variable == "index_int_pro"] <-
  labels_df$x[labels_df$variable == "index_int_pro"] * 0.85
labels_df$y[labels_df$variable == "index_int_pro"] <-
  labels_df$y[labels_df$variable == "index_int_pro"] * 0.85

labels_df$x[labels_df$variable == "index_enf_anti"] <-
  labels_df$x[labels_df$variable == "index_enf_anti"] * 0.85
labels_df$y[labels_df$variable == "index_enf_anti"] <-
  labels_df$y[labels_df$variable == "index_enf_anti"] * 0.85


ring_label_angle <- SPOKE_ANGLES[1]
ring_labels <- data.frame(
  x     = sapply(seq(axis_max / 5, axis_max, length.out = 5),
                 function(v) (v / axis_max) * sin(ring_label_angle) + 0.04),
  y     = sapply(seq(axis_max / 5, axis_max, length.out = 5),
                 function(v) (v / axis_max) * cos(ring_label_angle)),
  label = sprintf("%.1f", seq(axis_max / 5, axis_max, length.out = 5))
)

# ── 6. BUILD ANIMATED PLOT ───────────────────────────────────
p_radar <- ggplot() +
  
  # -- Gridline rings (static)
  lapply(gridlines, function(gl) {
    geom_path(data = gl, aes(x = x, y = y),
              color = "#CCCCCC", linewidth = 0.5, linetype = "dashed",
              inherit.aes = FALSE)
  }) +
  
  # -- Spoke axes (colored by pro/anti, static)
  geom_segment(data = spoke_axes,
               aes(x = 0, y = 0, xend = x_end, yend = y_end, color = color),
               linewidth = 1.2, show.legend = FALSE) +
  scale_color_identity() +
  
  # -- Animated polygon: neutral gray fill + dark gray outline
  geom_polygon(data = interp_poly,
               aes(x = x, y = y, group = frame_id),
               fill = "#AAAAAA", alpha = 0.20, color = NA) +
  geom_path(data = interp_poly,
            aes(x = x, y = y, group = frame_id),
            color = "#888888", linewidth = 0.3) +
  
  # -- Animated spoke points: colored by pro/anti
  geom_point(data = interp_pts,
             aes(x = x, y = y, color = spoke_color),
             size = 5, show.legend = FALSE) +
  
  # -- Spoke labels (static, colored)
  geom_text(data = labels_df,
            aes(x = x, y = y, label = label, color = color),
            size = 4, lineheight = 0.9, fontface = "bold",
            show.legend = FALSE) +
  
  # -- Animated subtitle: year ticker embedded in subtitle text
  geom_text(data = year_label_df,
            aes(x = -1.54, y = 1.55,
                label = paste0("Policy index scores for a one-cluster solution, in ", year_label)),
            size = 5, color = "#555555",
            hjust = 0, vjust = 1,
            inherit.aes = FALSE) +
  
  coord_fixed(xlim = c(-1.4, 1.4), ylim = c(-1.6, 1.4), clip = "off") +
  
  labs(
    title = "\nCentroid states diversify implemented\npolicy types over time"
  ) +
  
  theme_void(base_family = "lato") +
  theme(
    plot.title.position = "plot",
    plot.title      = element_text(size = 25, face = "bold", family = "lato", 
                                   hjust = 0, margin = margin(t = 50, b = 8)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(t = 20, r = 20, b = -30, l = 20)
  ) +
  
  transition_states(
    states            = frame_id,
    transition_length = 0,
    state_length      = 1,
    wrap              = FALSE
  )

# ── 7. RENDER & SAVE GIF ─────────────────────────────────────
total_frames <- max(interp_poly$frame_id)

anim_obj <- animate(
  p_radar,
  nframes  = total_frames,
  fps      = FRAMES_PER_YEAR,   # 1 second per year
  width    = 700,
  height   = 700,
  renderer = gifski_renderer(file.path(OUTPUT_DIR, "radar_plot_2000_2019.gif")),
  bg       = "white"
)

message("GIF saved to: ", file.path(OUTPUT_DIR, "radar_plot_2000_2019.gif"))

rm(list = ls())

# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Cluster analysis - radar plot (2-cluster solution)


#=======#
# Setup #
#=======#

setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

library(showtext)
font_add_google("Lato", "lato")
showtext_auto()

# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Radar%20plot%20centroids%20-%202CS.csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# ============================================================
# Radar Plot — Animated GIF (2000–2019), 2-cluster solution
# Requires: ggplot2, dplyr, tidyr, scales, gganimate, gifski
# ============================================================

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(gganimate)
library(gifski)


# Color palette: pro spokes = teal, anti spokes = red/orange
SPOKE_COLORS <- c(
  "index_enf_anti" = "black",
  "index_enf_pro"  = "black",
  "index_pub_pro"  = "black",
  "index_int_pro"  = "black",
  "index_int_anti" = "black"
)

SPOKE_LABEL_COLORS <- c(
  "index_enf_anti" = "#D55E00",
  "index_enf_pro"  = "#009E73",
  "index_pub_pro"  = "#009E73",
  "index_int_pro"  = "#009E73",
  "index_int_anti" = "#D55E00"
)


# Cluster polygon/path colors: slightly desaturated versions of provided colors
# Cluster 1: #D55E00 (burnt orange) → desaturated
# Cluster 2: #0072B2 (blue)         → desaturated
CLUSTER_COLORS <- c(
  "1" = "#B5463A",   # desaturated #D55E00
  "2" = "#2E86B5"    # desaturated #0072B2
)

# Human-readable spoke labels
SPOKE_LABELS <- c(
  "index_enf_anti" = "Anti-immigrant\nenforcement policies",
  "index_enf_pro"  = "Pro-immigrant\nenforcement policies",
  "index_pub_pro"  = "Pro-immigrant\npublic benefits policies",
  "index_int_pro"  = "Pro-immigrant\nintegration polices",
  "index_int_anti" = "Anti-immigrant\nintegration policies "
)

YEARS           <- 2000:2019
FRAMES_PER_YEAR <- 64


# ── 1. LOAD & PREP DATA ──────────────────────────────────────
raw <- DATA_PATH

# Global max for consistent axis scaling across all years
axis_max <- 0.80

# ── 2. RADAR GEOMETRY HELPERS ────────────────────────────────
SPOKES       <- names(SPOKE_LABELS)
N_SPOKES     <- length(SPOKES)
SPOKE_ANGLES <- seq(0, 2 * pi, length.out = N_SPOKES + 1)[-(N_SPOKES + 1)]

polar_to_xy <- function(angle, value, max_val) {
  r <- value / max_val
  list(x = r * sin(angle), y = r * cos(angle))
}

# Build polygon rows; append first point to close the shape
build_polygon <- function(yr_values, max_val) {
  coords <- mapply(function(angle, val) polar_to_xy(angle, val, max_val),
                   SPOKE_ANGLES, yr_values, SIMPLIFY = FALSE)
  xs <- sapply(coords, `[[`, "x")
  ys <- sapply(coords, `[[`, "y")
  data.frame(
    x        = c(xs, xs[1]),
    y        = c(ys, ys[1]),
    variable = c(SPOKES, SPOKES[1])
  )
}

# Build polygon rows WITHOUT closing repeat (for points layer)
build_points <- function(yr_values, max_val) {
  coords <- mapply(function(angle, val) polar_to_xy(angle, val, max_val),
                   SPOKE_ANGLES, yr_values, SIMPLIFY = FALSE)
  data.frame(
    x        = sapply(coords, `[[`, "x"),
    y        = sapply(coords, `[[`, "y"),
    variable = SPOKES
  )
}

build_gridlines <- function(max_val, n_rings = 5) {
  ring_vals <- seq(max_val / n_rings, max_val, length.out = n_rings)
  lapply(ring_vals, function(rv) {
    angles <- c(SPOKE_ANGLES, SPOKE_ANGLES[1])
    data.frame(
      x     = (rv / max_val) * sin(angles),
      y     = (rv / max_val) * cos(angles),
      label = rv
    )
  })
}

build_spokes <- function() {
  data.frame(
    x_end    = sin(SPOKE_ANGLES),
    y_end    = cos(SPOKE_ANGLES),
    variable = SPOKES,
    color    = unname(SPOKE_COLORS),
    stringsAsFactors = FALSE
  )
}

build_labels <- function(label_radius = 1.35) {
  data.frame(
    x        = label_radius * sin(SPOKE_ANGLES),
    y        = label_radius * cos(SPOKE_ANGLES),
    variable = SPOKES,
    label    = unname(SPOKE_LABELS),
    color    = unname(SPOKE_LABEL_COLORS),
    stringsAsFactors = FALSE
  )
}

# ── 3. BUILD PER-YEAR VALUES (both clusters) ─────────────────
CLUSTERS <- c("1", "2")

year_values <- lapply(CLUSTERS, function(cl) {
  vals <- lapply(YEARS, function(yr) {
    row <- raw %>% filter(year == yr, state_cluster_id == as.integer(cl))
    sapply(SPOKES, function(s) as.numeric(row[[s]]))
  })
  names(vals) <- as.character(YEARS)
  vals
})
names(year_values) <- CLUSTERS

# ── 4. INTERPOLATE FRAMES (both clusters) ────────────────────

# Helper: build interpolated polygon data for one cluster
interp_poly_for_cluster <- function(cl) {
  cl_color <- CLUSTER_COLORS[cl]
  lapply(seq_along(YEARS), function(i) {
    yr_a   <- YEARS[i]
    yr_b   <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
    vals_a <- year_values[[cl]][[as.character(yr_a)]]
    vals_b <- year_values[[cl]][[as.character(yr_b)]]
    steps  <- if (i < length(YEARS)) {
      seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)]
    } else { rep(0, FRAMES_PER_YEAR) }
    
    lapply(seq_along(steps), function(si) {
      t    <- steps[si]
      vals <- vals_a + t * (vals_b - vals_a)
      poly <- build_polygon(vals, axis_max)
      poly$frame_id     <- (i - 1) * FRAMES_PER_YEAR + si
      poly$year_label   <- as.character(yr_a)
      poly$cluster      <- cl
      poly$cluster_color <- cl_color
      poly
    })
  }) %>% unlist(recursive = FALSE) %>% bind_rows()
}

# Helper: build interpolated points data for one cluster
interp_pts_for_cluster <- function(cl) {
  lapply(seq_along(YEARS), function(i) {
    yr_a   <- YEARS[i]
    yr_b   <- if (i < length(YEARS)) YEARS[i + 1] else YEARS[i]
    vals_a <- year_values[[cl]][[as.character(yr_a)]]
    vals_b <- year_values[[cl]][[as.character(yr_b)]]
    steps  <- if (i < length(YEARS)) {
      seq(0, 1, length.out = FRAMES_PER_YEAR + 1)[-(FRAMES_PER_YEAR + 1)]
    } else { rep(0, FRAMES_PER_YEAR) }
    
    lapply(seq_along(steps), function(si) {
      t    <- steps[si]
      vals <- vals_a + t * (vals_b - vals_a)
      pts  <- build_points(vals, axis_max)
      pts$frame_id    <- (i - 1) * FRAMES_PER_YEAR + si
      pts$year_label  <- as.character(yr_a)
      pts$cluster     <- cl
      pts$spoke_color <- unname(SPOKE_COLORS[pts$variable])
      pts
    })
  }) %>% unlist(recursive = FALSE) %>% bind_rows()
}

interp_poly <- bind_rows(
  interp_poly_for_cluster("1"),
  interp_poly_for_cluster("2")
)

interp_pts <- bind_rows(
  interp_pts_for_cluster("1"),
  interp_pts_for_cluster("2")
)

# Year label lookup (one row per frame_id) — used for animated subtitle
year_label_df <- interp_poly %>%
  distinct(frame_id, year_label)

# ── 5. STATIC CHART ELEMENTS ─────────────────────────────────
gridlines  <- build_gridlines(axis_max)
spoke_axes <- build_spokes()
labels_df  <- build_labels()

labels_df$x[labels_df$variable == "index_pub_pro"]  <-
  labels_df$x[labels_df$variable == "index_pub_pro"]  * 0.85
labels_df$y[labels_df$variable == "index_pub_pro"]  <-
  labels_df$y[labels_df$variable == "index_pub_pro"]  * 0.85

labels_df$x[labels_df$variable == "index_int_pro"] <-
  labels_df$x[labels_df$variable == "index_int_pro"] * 0.85
labels_df$y[labels_df$variable == "index_int_pro"] <-
  labels_df$y[labels_df$variable == "index_int_pro"] * 0.85

labels_df$x[labels_df$variable == "index_enf_anti"] <-
  labels_df$x[labels_df$variable == "index_enf_anti"] * 0.85
labels_df$y[labels_df$variable == "index_enf_anti"] <-
  labels_df$y[labels_df$variable == "index_enf_anti"] * 0.85

ring_label_angle <- SPOKE_ANGLES[1]
ring_labels <- data.frame(
  x     = sapply(seq(axis_max / 5, axis_max, length.out = 5),
                 function(v) (v / axis_max) * sin(ring_label_angle) + 0.04),
  y     = sapply(seq(axis_max / 5, axis_max, length.out = 5),
                 function(v) (v / axis_max) * cos(ring_label_angle)),
  label = sprintf("%.1f", seq(axis_max / 5, axis_max, length.out = 5))
)

# ── 6. BUILD ANIMATED PLOT ───────────────────────────────────
p_radar <- ggplot() +
  
  # -- Gridline rings (static)
  lapply(gridlines, function(gl) {
    geom_path(data = gl, aes(x = x, y = y),
              color = "#CCCCCC", linewidth = 0.5, linetype = "dashed",
              inherit.aes = FALSE)
  }) +
  
  # -- Spoke axes (colored by pro/anti, static)
  geom_segment(data = spoke_axes,
               aes(x = 0, y = 0, xend = x_end, yend = y_end, color = color),
               linewidth = 1.2, show.legend = FALSE) +
  scale_color_identity() +
  
  # -- Animated polygon fills (per cluster, colored fill + no outline here)
  geom_polygon(data = interp_poly,
               aes(x = x, y = y, group = interaction(frame_id, cluster),
                   fill = cluster_color),
               alpha = 0.15, color = NA, show.legend = FALSE) +
  scale_fill_identity() +
  
  # -- Animated polygon outlines (per cluster, colored)
  geom_path(data = interp_poly,
            aes(x = x, y = y, group = interaction(frame_id, cluster),
                color = cluster_color),
            linewidth = 0.8, show.legend = FALSE) +
  
  # -- Animated spoke points: colored by pro/anti spoke type
  geom_point(data = interp_pts,
             aes(x = x, y = y, color = CLUSTER_COLORS[cluster]),
             size = 5, show.legend = FALSE) +
  
  # -- Spoke labels (static, colored)
  geom_text(data = labels_df,
            aes(x = x, y = y, label = label, color = color),
            size = 4, lineheight = 0.9, fontface = "bold",
            show.legend = FALSE) +
  
  # -- Animated subtitle: year ticker
  geom_text(data = year_label_df,
            aes(x = -1.54, y = 1.55,
                label = paste0("Centroid policy index scores for a two-cluster solution, in ", year_label)),
            size = 5, color = "#555555",
            hjust = 0, vjust = 1,
            inherit.aes = FALSE) +
  
  coord_fixed(xlim = c(-1.4, 1.4), ylim = c(-1.6, 1.4), clip = "off") +
  
  labs(
    title = "\nA two-cluster solution reveals starkly\ncontrasting policy profiles"
  ) +
  
  theme_void(base_family = "lato") +
  theme(
    plot.title.position = "plot",
    plot.title      = element_text(size = 25, face = "bold", family = "lato",
                                   hjust = 0, margin = margin(t = 50, b = 8)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(t = 20, r = 20, b = -30, l = 20)
  ) +
  
  transition_states(
    states            = frame_id,
    transition_length = 0,
    state_length      = 1,
    wrap              = FALSE
  )

# ── 7. RENDER & SAVE GIF ─────────────────────────────────────
total_frames <- max(interp_poly$frame_id)

anim_obj <- animate(
  p_radar,
  nframes  = total_frames,
  fps      = FRAMES_PER_YEAR,   # 1 second per year
  width    = 700,
  height   = 700,
  renderer = gifski_renderer(file.path(OUTPUT_DIR, "radar_plot_2CS_2000_2019.gif")),
  bg       = "white"
)

message("GIF saved to: ", file.path(OUTPUT_DIR, "radar_plot_2CS_2000_2019.gif"))
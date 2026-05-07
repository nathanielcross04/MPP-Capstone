# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Cluster analysis - radar plots


#==============================================================================#
# 1CS RADAR PLOT                                                               #
#==============================================================================#


# ── 0. CONFIG ────────────────────────────────────────────────
# Set working directory
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

# Load data
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Radar%20plot%20centroids.csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# Load dependencies
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(gganimate)
library(gifski)
library(showtext)

# Import font
font_add_google("Lato", "lato")           # regular weight → family name "lato"
font_add_google("Lato", "lato-bold", regular.wt = 700)  # bold weight → family name "lato-bold"
showtext_auto()

# Set color palette
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

# Relabel spoke labels
SPOKE_LABELS <- c(
  "index_enf_anti" = "Anti-immigrant\nenforcement policies",
  "index_enf_pro"  = "Pro-immigrant\nenforcement policies",
  "index_pub_pro"  = "Pro-immigrant\npublic benefits policies",
  "index_int_pro"  = "Pro-immigrant\nintegration polices",
  "index_int_anti" = "Anti-immigrant\nintegration policies "
)

# Misc. parameters
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
    pts$spoke_color <- unname(SPOKE_LABEL_COLORS[pts$variable])
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
    plot.title      = element_text(size = 25, 
                                   family = "lato-bold", 
                                   lineheight = 1.2,
                                   hjust = 0, 
                                   margin = margin(t = 50, b = 15)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(t = 20, r = 20, b = -30, l = 20)
  ) +
  
  transition_states(
    states            = frame_id,
    transition_length = 0,
    state_length      = 1,
    wrap              = FALSE
  )

# ── 7. RENDER & SAVE MP4 ─────────────────────────────────────
# install.packages("av") if needed
library(av)

total_frames <- max(interp_poly$frame_id)

animate(
  p_radar,
  nframes  = total_frames,
  fps      = FRAMES_PER_YEAR,
  width    = 1400,
  height   = 1400,
  renderer = av_renderer(
    file.path(OUTPUT_DIR, "radar_plot.mp4"),
    vfilter = "scale=trunc(iw/2)*2:trunc(ih/2)*2"
  ),
  bg = "white"
)

message("MP4 saved to: ", file.path(OUTPUT_DIR, "radar_plot.mp4"))
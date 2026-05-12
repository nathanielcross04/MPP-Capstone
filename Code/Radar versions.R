# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Cluster analysis - radar plot (2-cluster solution)
# Versions:
#   1. Animated 2000–2019, both clusters        → radar_plot_2CS_2000_2019_both.gif
#   2. Static 2000, both clusters               → radar_plot_2CS_2000_both.gif
#   3. Static 2000, blank (no polygons)         → radar_plot_2CS_2000_blank.gif
#   4. Static 2000, red (cluster 1) only        → radar_plot_2CS_2000_red.gif


#=======#
# Setup #
#=======#

setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

library(showtext)
font_add_google("Lato", "lato")
font_add_google("Lato", "lato-bold", regular.wt = 700)
showtext_auto()
showtext_opts(dpi = 96)   # match the dpi used in animate(); gganimate renders at screen dpi

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(gganimate)
library(gifski)
library(ragg)


# ── 0. CONFIG ────────────────────────────────────────────────
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/Radar%20plot%20centroids%20-%202CS.csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

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

CLUSTER_COLORS <- c(
  "1" = "#B5463A",
  "2" = "#2E86B5"
)

SPOKE_LABELS <- c(
  "index_enf_anti" = "Anti-immigrant\nenforcement policies",
  "index_enf_pro"  = "Pro-immigrant\nenforcement policies",
  "index_pub_pro"  = "Pro-immigrant\npublic benefits policies",
  "index_int_pro"  = "Pro-immigrant\nintegration polices",
  "index_int_anti" = "Anti-immigrant\nintegration policies "
)

axis_max <- 0.80
raw      <- DATA_PATH


# ── 1. RADAR GEOMETRY HELPERS ────────────────────────────────
SPOKES       <- names(SPOKE_LABELS)
N_SPOKES     <- length(SPOKES)
SPOKE_ANGLES <- seq(0, 2 * pi, length.out = N_SPOKES + 1)[-(N_SPOKES + 1)]

polar_to_xy <- function(angle, value, max_val) {
  r <- value / max_val
  list(x = r * sin(angle), y = r * cos(angle))
}

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
  df <- data.frame(
    x        = label_radius * sin(SPOKE_ANGLES),
    y        = label_radius * cos(SPOKE_ANGLES),
    variable = SPOKES,
    label    = unname(SPOKE_LABELS),
    color    = unname(SPOKE_LABEL_COLORS),
    stringsAsFactors = FALSE
  )
  # Nudge overlapping labels inward
  for (v in c("index_pub_pro", "index_int_pro", "index_enf_anti")) {
    df$x[df$variable == v] <- df$x[df$variable == v] * 0.85
    df$y[df$variable == v] <- df$y[df$variable == v] * 0.85
  }
  df
}


# ── 2. INTERPOLATION HELPERS ─────────────────────────────────
interp_poly_for_cluster <- function(cl, years, frames_per_year) {
  cl_color <- CLUSTER_COLORS[cl]
  lapply(seq_along(years), function(i) {
    yr_a   <- years[i]
    yr_b   <- if (i < length(years)) years[i + 1] else years[i]
    vals_a <- year_values[[cl]][[as.character(yr_a)]]
    vals_b <- year_values[[cl]][[as.character(yr_b)]]
    steps  <- if (i < length(years)) {
      seq(0, 1, length.out = frames_per_year + 1)[-(frames_per_year + 1)]
    } else {
      rep(0, frames_per_year)
    }
    lapply(seq_along(steps), function(si) {
      t    <- steps[si]
      vals <- vals_a + t * (vals_b - vals_a)
      poly <- build_polygon(vals, axis_max)
      poly$frame_id      <- (i - 1) * frames_per_year + si
      poly$year_label    <- as.character(yr_a)
      poly$cluster       <- cl
      poly$cluster_color <- cl_color
      poly
    })
  }) %>% unlist(recursive = FALSE) %>% bind_rows()
}

interp_pts_for_cluster <- function(cl, years, frames_per_year) {
  lapply(seq_along(years), function(i) {
    yr_a   <- years[i]
    yr_b   <- if (i < length(years)) years[i + 1] else years[i]
    vals_a <- year_values[[cl]][[as.character(yr_a)]]
    vals_b <- year_values[[cl]][[as.character(yr_b)]]
    steps  <- if (i < length(years)) {
      seq(0, 1, length.out = frames_per_year + 1)[-(frames_per_year + 1)]
    } else {
      rep(0, frames_per_year)
    }
    lapply(seq_along(steps), function(si) {
      t    <- steps[si]
      vals <- vals_a + t * (vals_b - vals_a)
      pts  <- build_points(vals, axis_max)
      pts$frame_id    <- (i - 1) * frames_per_year + si
      pts$year_label  <- as.character(yr_a)
      pts$cluster     <- cl
      pts$spoke_color <- unname(SPOKE_LABEL_COLORS[pts$variable])
      pts
    })
  }) %>% unlist(recursive = FALSE) %>% bind_rows()
}


# ── 3. SHARED THEME & STATIC ELEMENTS ────────────────────────
radar_theme <- function() {
  list(
    coord_fixed(xlim = c(-1.4, 1.4), ylim = c(-1.6, 1.4), clip = "off"),
    labs(title = "\nA two-cluster solution reveals starkly\ncontrasting policy profiles"),
    theme_void(base_family = "lato"),
    theme(
      plot.title.position = "plot",
      plot.title      = element_text(size = 25, family = "lato-bold",
                                     hjust = 0, lineheight = 1.2,
                                     margin = margin(t = 50, b = 15)),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin     = margin(t = 20, r = 20, b = -30, l = 20)
    )
  )
}

gridlines  <- build_gridlines(axis_max)
spoke_axes <- build_spokes()
labels_df  <- build_labels()

ring_label_angle <- SPOKE_ANGLES[1]
ring_labels <- data.frame(
  x     = sapply(seq(axis_max / 5, axis_max, length.out = 5),
                 function(v) (v / axis_max) * sin(ring_label_angle) + 0.04),
  y     = sapply(seq(axis_max / 5, axis_max, length.out = 5),
                 function(v) (v / axis_max) * cos(ring_label_angle)),
  label = sprintf("%.1f", seq(axis_max / 5, axis_max, length.out = 5))
)

# Shared static layers (gridlines + spokes + labels)
static_layers <- function() {
  list(
    lapply(gridlines, function(gl) {
      geom_path(data = gl, aes(x = x, y = y),
                color = "#CCCCCC", linewidth = 0.5, linetype = "dashed",
                inherit.aes = FALSE)
    }),
    geom_segment(data = spoke_axes,
                 aes(x = 0, y = 0, xend = x_end, yend = y_end, color = color),
                 linewidth = 1.2, show.legend = FALSE),
    scale_color_identity(),
    scale_fill_identity(),
    geom_text(data = labels_df,
              aes(x = x, y = y, label = label, color = color),
              size = 4, lineheight = 0.9, fontface = "bold",
              show.legend = FALSE)
  )
}

subtitle_layer <- function(year_label_df) {
  geom_text(data = year_label_df,
            aes(x = -1.54, y = 1.55,
                label = paste0("Centroid policy index scores for a two-cluster solution, in ", year_label)),
            size = 5, color = "#555555",
            hjust = 0, vjust = 1,
            inherit.aes = FALSE)
}

polygon_layers <- function(poly_data, pts_data) {
  list(
    geom_polygon(data = poly_data,
                 aes(x = x, y = y, group = interaction(frame_id, cluster),
                     fill = cluster_color),
                 alpha = 0.15, color = NA, show.legend = FALSE),
    geom_path(data = poly_data,
              aes(x = x, y = y, group = interaction(frame_id, cluster),
                  color = cluster_color),
              linewidth = 0.8, show.legend = FALSE),
    geom_point(data = pts_data,
               aes(x = x, y = y, color = CLUSTER_COLORS[cluster]),
               size = 5, show.legend = FALSE)
  )
}

animate_and_save <- function(plot_obj, total_frames, fps, filename) {
  animate(
    plot_obj,
    nframes  = total_frames,
    fps      = fps,
    width    = 700,
    height   = 700,
    device   = "ragg_png",        # ← swap png device for ragg
    renderer = gifski_renderer(file.path(OUTPUT_DIR, filename)),
    bg       = "white"
  )
  message("GIF saved to: ", file.path(OUTPUT_DIR, filename))
}


#==============================================================================#
# VERSION 1: ANIMATED 2000–2019, BOTH CLUSTERS                                #
#==============================================================================#

YEARS_ANIM           <- 2000:2019
FRAMES_PER_YEAR_ANIM <- 32
CLUSTERS             <- c("1", "2")

year_values <- lapply(CLUSTERS, function(cl) {
  vals <- lapply(YEARS_ANIM, function(yr) {
    row <- raw %>% filter(year == yr, state_cluster_id == as.integer(cl))
    sapply(SPOKES, function(s) as.numeric(row[[s]]))
  })
  names(vals) <- as.character(YEARS_ANIM)
  vals
})
names(year_values) <- CLUSTERS

interp_poly_anim <- bind_rows(
  interp_poly_for_cluster("1", YEARS_ANIM, FRAMES_PER_YEAR_ANIM),
  interp_poly_for_cluster("2", YEARS_ANIM, FRAMES_PER_YEAR_ANIM)
)
interp_pts_anim <- bind_rows(
  interp_pts_for_cluster("1", YEARS_ANIM, FRAMES_PER_YEAR_ANIM),
  interp_pts_for_cluster("2", YEARS_ANIM, FRAMES_PER_YEAR_ANIM)
)
year_label_df_anim <- interp_poly_anim %>% distinct(frame_id, year_label)

p_v1 <- ggplot() +
  static_layers() +
  polygon_layers(interp_poly_anim, interp_pts_anim) +
  subtitle_layer(year_label_df_anim) +
  radar_theme() +
  transition_states(
    states            = frame_id,
    transition_length = 0,
    state_length      = 1,
    wrap              = FALSE
  )

animate_and_save(p_v1,
                 total_frames = max(interp_poly_anim$frame_id),
                 fps          = FRAMES_PER_YEAR_ANIM,
                 filename     = "radar_plot_2CS_2000_2019_both.gif")


#==============================================================================#
# VERSION 2: STATIC 2000, BOTH CLUSTERS                                       #
#==============================================================================#

YEARS_STATIC           <- 2019
FRAMES_PER_YEAR_STATIC <- 1

year_values_static <- lapply(CLUSTERS, function(cl) {
  vals <- lapply(YEARS_STATIC, function(yr) {
    row <- raw %>% filter(year == yr, state_cluster_id == as.integer(cl))
    sapply(SPOKES, function(s) as.numeric(row[[s]]))
  })
  names(vals) <- as.character(YEARS_STATIC)
  vals
})
names(year_values_static) <- CLUSTERS

# Temporarily override year_values for static interpolation
year_values <- year_values_static

interp_poly_static <- bind_rows(
  interp_poly_for_cluster("1", YEARS_STATIC, FRAMES_PER_YEAR_STATIC),
  interp_poly_for_cluster("2", YEARS_STATIC, FRAMES_PER_YEAR_STATIC)
)
interp_pts_static <- bind_rows(
  interp_pts_for_cluster("1", YEARS_STATIC, FRAMES_PER_YEAR_STATIC),
  interp_pts_for_cluster("2", YEARS_STATIC, FRAMES_PER_YEAR_STATIC)
)
year_label_df_static <- interp_poly_static %>% distinct(frame_id, year_label)

p_v2 <- ggplot() +
  static_layers() +
  polygon_layers(interp_poly_static, interp_pts_static) +
  subtitle_layer(year_label_df_static) +
  radar_theme() +
  transition_states(
    states            = frame_id,
    transition_length = 0,
    state_length      = 1,
    wrap              = FALSE
  )

animate_and_save(p_v2,
                 total_frames = max(interp_poly_static$frame_id),
                 fps          = FRAMES_PER_YEAR_STATIC,
                 filename     = "radar_plot_2CS_2019_both.gif")

#==============================================================================#
# VERSION 3: STATIC 2000, BLANK (NO POLYGONS)                                 #
#==============================================================================#

# Reuses year_label_df_static (frame_id = 1, year_label = "2000")

p_v3 <- ggplot() +
  static_layers() +
  subtitle_layer(year_label_df_static) +
  radar_theme() +
  transition_states(
    states            = frame_id,
    transition_length = 0,
    state_length      = 1,
    wrap              = FALSE
  )

animate_and_save(p_v3,
                 total_frames = max(year_label_df_static$frame_id),
                 fps          = FRAMES_PER_YEAR_STATIC,
                 filename     = "radar_plot_2CS_2000_blank.gif")

#==============================================================================#
# VERSION 4: STATIC 2000, RED (CLUSTER 1) ONLY                                #
#==============================================================================#

interp_poly_c1_static <- interp_poly_static %>% filter(cluster == "1")
interp_pts_c1_static  <- interp_pts_static  %>% filter(cluster == "1")

p_v4 <- ggplot() +
  static_layers() +
  polygon_layers(interp_poly_c1_static, interp_pts_c1_static) +
  subtitle_layer(year_label_df_static) +
  radar_theme() +
  transition_states(
    states            = frame_id,
    transition_length = 0,
    state_length      = 1,
    wrap              = FALSE
  )

animate_and_save(p_v4,
                 total_frames = max(interp_poly_c1_static$frame_id),
                 fps          = FRAMES_PER_YEAR_STATIC,
                 filename     = "radar_plot_2CS_2000_red.gif")

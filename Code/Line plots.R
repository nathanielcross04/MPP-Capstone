# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Cluster analysis - line plots


#==============================================================================#
# INDIVIDUALIZATION LINE PLOTS                                                 #
#==============================================================================#

# ── 0. CONFIG ─────────────────────────────────────────────────────────────────
# Set working directory
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

#Load dependencies
library(ggplot2)
library(patchwork)
library(showtext)

font_add_google("Lato", "lato")
showtext_auto()

# Load data
DATA_PATH  <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/line_indiv.csv")
OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# ── 1. GRAPH ──────────────────────────────────────────────────────────────────

# Plot
p1 <- ggplot(DATA_PATH, aes(x = year, y = n_medoids)) +
  geom_line(color = "#56B4E9", linewidth = 0.9) +
  geom_point(color = "#56B4E9", size = 2) +
  scale_x_continuous(breaks = c(2000, 2005, 2010, 2015, 2019)) +
  scale_y_continuous(breaks = seq(0, 9, by = 2), limits = c(0, 8)) +
  labs(
    title = "Number of medoids equidistant to the centroid\ndecreases sharply from 2000 to 2019",
    x        = NULL,
    y        = NULL
  ) +
  theme_minimal(base_family = "lato") +
  theme(
    plot.title           = element_text(size = 60, color = "black", face = "bold",
                                        family = "lato", lineheight = 0.3,
                                        hjust = 0, margin = margin(t = 10, b = 10)),
    axis.text            = element_text(size = 35, color = "#444444"),
    panel.grid.major     = element_line(color = "#CCCCCC", linewidth = 0.4),
    panel.grid.minor     = element_blank(),
    plot.background      = element_rect(fill = "white", color = NA),
    plot.margin          = margin(t = 5, r = 20, b = 10, l = 20),
    plot.title.position = "plot"
  )



# Save plot
ggsave(
  filename = file.path(OUTPUT_DIR, "medoids_combined.png"),
  width    = 7.5,
  height   = 5,
  dpi      = 300,
  bg       = "white"
)

p2 <- ggplot(DATA_PATH, aes(x = year, y = min_dist)) +
  geom_line(color = "#56B4E9", linewidth = 0.9) +
  geom_point(color = "#56B4E9", size = 2) +
  scale_x_continuous(breaks = c(2000, 2005, 2010, 2015, 2019)) +
  scale_y_continuous(breaks = c(2.6, 3.0, 3.4, 3.8, 4.2, 4.6), limits = c(2.6, 4.6)) +
  labs(
    subtitle = "Distance from medoid to the centroid",
    x        = NULL,
    y        = NULL
  ) +
  theme_minimal(base_family = "lato") +
  theme(
    plot.subtitle        = element_text(size = 40, color = "black", family = "lato",
                                        hjust = 0),
    axis.text            = element_text(size = 35, color = "#444444"),
    panel.grid.major     = element_line(color = "#CCCCCC", linewidth = 0.4),
    panel.grid.minor     = element_blank(),
    plot.background      = element_rect(fill = "white", color = NA),
    plot.margin          = margin(t = 10, r = 20, b = 5, l = 20),
    plot.title.position = "plot"
  )

p1 / p2 +
  plot_annotation(
    title = "Once-convergent state policy profiles markedly\nindividualize from 2000 to 2019",
    theme = theme(
      plot.title      = element_text(size = 70, face = "bold", family = "lato",
                                     hjust = 0, lineheight = 0.3,
                                     margin = margin(b = 10, l = -20, t = 6)),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin     = margin(t = 15, r = 20, b = 15, l = 20)
    )
  )

# Save plot
ggsave(
  filename = file.path(OUTPUT_DIR, "medoids_combined.png"),
  width    = 7.5,
  height   = 10,
  dpi      = 300,
  bg       = "white"
)

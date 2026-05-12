# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data analysis:
# Immigration salience bar plots — phased (3 PNGs for successive slides)


#==============================================================================#
# IMMIGRATION SALIENCE BAR PLOTS                                               #
#==============================================================================#

# ── 0. CONFIG ─────────────────────────────────────────────────────────────────
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

library(ggplot2)
library(showtext)
font_add_google("Lato", "lato")
font_add_google("Lato", "lato-bold", regular.wt = 700)
showtext_auto()
showtext_opts(dpi = 300)

OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# ── 1. DATA ───────────────────────────────────────────────────────────────────
all_bars <- data.frame(
  group  = factor(
    c("All voters", "Trump supporters", "Harris supporters"),
    levels = c("All voters", "Trump supporters", "Harris supporters")
  ),
  value       = c(61, 82, 39),
  fill        = c("#444444", "#B5463A", "#2E86B5"),
  label_color = c("#444444", "#B5463A", "#2E86B5"),
  stringsAsFactors = FALSE
)

# ── 2. SHARED PLOT FUNCTION ───────────────────────────────────────────────────
TITLE    <- "Immigration remains salient among top issues in\n2024 presidential election"
SUBTITLE <- "Percent of voters who find immigration very important to their decision"

bar_plot <- function(data_subset) {
  ggplot(data_subset, aes(x = group, y = value)) +
    
    geom_col(
      aes(fill = fill),
      width     = 0.55,
      color     = NA
    ) +
    scale_fill_identity() +
    
    # Labels just above each bar, colored to match
    geom_text(
      aes(label = paste0(value, "%"), color = label_color, y = value),
      vjust    = -0.6,
      size     = 5.5,
      fontface = "bold",
      family   = "lato-bold"
    ) +
    scale_color_identity() +
    
    scale_x_discrete(limits = levels(all_bars$group)) +
    scale_y_continuous(
      breaks = seq(0, 100, by = 20),
      limits = c(0, 105),
      expand = expansion(mult = c(0, 0))
    ) +
    
    labs(
      title    = TITLE,
      subtitle = SUBTITLE,
      x        = NULL,
      y        = NULL
    ) +
    
    theme_minimal(base_family = "lato") +
    theme(
      plot.title           = element_text(size = 22, face = "bold", family = "lato-bold",
                                          color = "black", hjust = 0, lineheight = 0.9,
                                          margin = margin(b = 6)),
      plot.subtitle        = element_text(size = 13, color = "#555555", family = "lato",
                                          hjust = 0, lineheight = 1.3,
                                          margin = margin(b = 16)),
      plot.title.position  = "plot",
      axis.text.x          = element_text(
        size   = 13,
        family = "lato",
        margin = margin(t = 6),
        color  = ifelse(
          levels(all_bars$group) %in% data_subset$group,
          all_bars$fill[match(levels(all_bars$group), all_bars$group)],
          "white"
        )
      ),
      axis.text.y          = element_text(size = 11, color = "#888888", family = "lato"),
      panel.grid.major.y   = element_line(color = "#DDDDDD", linewidth = 0.4),
      panel.grid.major.x   = element_blank(),
      panel.grid.minor     = element_blank(),
      plot.background      = element_rect(fill = "white", color = NA),
      panel.background     = element_rect(fill = "white", color = NA),
      plot.margin          = margin(t = 20, r = 30, b = 20, l = 20)
    )
}

# ── 3. SAVE THREE PLOTS ───────────────────────────────────────────────────────

# Slide 1: All voters only
ggsave(
  filename = file.path(OUTPUT_DIR, "bar_immigration_slide1.png"),
  plot     = bar_plot(all_bars[1, ]),
  width    = 8,
  height   = 5,
  dpi      = 300,
  bg       = "white"
)

# Slide 2: All voters + Trump supporters
ggsave(
  filename = file.path(OUTPUT_DIR, "bar_immigration_slide2.png"),
  plot     = bar_plot(all_bars[1:2, ]),
  width    = 8,
  height   = 5,
  dpi      = 300,
  bg       = "white"
)

# Slide 3: All three bars
ggsave(
  filename = file.path(OUTPUT_DIR, "bar_immigration_slide3.png"),
  plot     = bar_plot(all_bars[1:3, ]),
  width    = 8,
  height   = 5,
  dpi      = 300,
  bg       = "white"
)

message("All three bar plot PNGs saved to: ", OUTPUT_DIR)
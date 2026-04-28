# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data visualization:
# 3D Network Map — State policy clusters (2019)


#==============================================================================#
# 3D NETWORK MAP                                                               #
#==============================================================================#


# ── 0. CONFIG ────────────────────────────────────────────────

# Set working directory
setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

# Load data
DATA_PATH <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/network_map.csv")

# Load dependencies
library(dplyr)
library(threejs)
library(igraph)
library(htmlwidgets)

# Cluster centroid colors (mirrors radar plot)
CLUSTER_COLORS <- c(
  "1" = "#B5463A",
  "2" = "#2E86B5"
)

# State node colors: lighter tint of each cluster's centroid color
# (50% blend toward white)
NODE_COLORS <- c(
  "1" = "#DAA29C",   # light tint of #B5463A
  "2" = "#96C2DA"    # light tint of #2E86B5
)

# Policy columns (25 variables — excludes id, state, year, cluster)
POLICY_COLS <- c(
  "enf_task_force_287g", "enf_warrant_287g", "enf_jail_287g",
  "enf_secure_comms", "enf_lim_coop_detainers", "enf_everify",
  "enf_limits_everify", "enf_state_omnibus", "pub_tanf_post5",
  "pub_cashass_during5", "pub_foodass_lprkids", "pub_foodass_lpradults",
  "pub_ssi_replacement", "pub_medicaid_lprkids", "pub_pubins_unauthkids",
  "pub_pubins_lpradults", "pub_pubins_unauthadult", "pub_medicaid_lprpreg",
  "pub_medicaid_unauthpreg", "pub_medicaid_lpr_post5", "int_instate_tuition",
  "int_state_finaid", "int_uni_ban", "int_official_eng", "int_drivers_license"
)

# State name → abbreviation lookup (all 51 including DC)
STATE_ABBR <- c(
  "Alabama"              = "AL", "Alaska"               = "AK",
  "Arizona"              = "AZ", "Arkansas"             = "AR",
  "California"           = "CA", "Colorado"             = "CO",
  "Connecticut"          = "CT", "Delaware"             = "DE",
  "District of Columbia" = "DC", "Florida"              = "FL",
  "Georgia"              = "GA", "Hawaii"               = "HI",
  "Idaho"                = "ID", "Illinois"             = "IL",
  "Indiana"              = "IN", "Iowa"                 = "IA",
  "Kansas"               = "KS", "Kentucky"             = "KY",
  "Louisiana"            = "LA", "Maine"                = "ME",
  "Maryland"             = "MD", "Massachusetts"        = "MA",
  "Michigan"             = "MI", "Minnesota"            = "MN",
  "Mississippi"          = "MS", "Missouri"             = "MO",
  "Montana"              = "MT", "Nebraska"             = "NE",
  "Nevada"               = "NV", "New Hampshire"        = "NH",
  "New Jersey"           = "NJ", "New Mexico"           = "NM",
  "New York"             = "NY", "North Carolina"       = "NC",
  "North Dakota"         = "ND", "Ohio"                 = "OH",
  "Oklahoma"             = "OK", "Oregon"               = "OR",
  "Pennsylvania"         = "PA", "Rhode Island"         = "RI",
  "South Carolina"       = "SC", "South Dakota"         = "SD",
  "Tennessee"            = "TN", "Texas"                = "TX",
  "Utah"                 = "UT", "Vermont"              = "VT",
  "Virginia"             = "VA", "Washington"           = "WA",
  "West Virginia"        = "WV", "Wisconsin"            = "WI",
  "Wyoming"              = "WY"
)

# ── NODE SIZE CONTROLS ───────────────────────────────────────
# Adjust these two values to change how large nodes appear in the map.
# Centroid nodes are always rendered larger than state nodes to stand out.

STATE_NODE_SIZE    <- 0.4   # size of the 51 state nodes
CENTROID_NODE_SIZE <- 1.0   # size of the 2 cluster centroid nodes

# ── CIRCLE STYLING CONTROLS ──────────────────────────────────
# NODE_OPACITY: transparency of all node circles (0 = invisible, 1 = solid)
NODE_OPACITY <- 1.0

# ── BORDER STYLING CONTROLS ──────────────────────────────────
# NODE_STROKE: TRUE = draw a thin black border ring around each circle,
#              FALSE = no border (clean flat look)
# Note: threejs only supports a single black stroke natively.
# Color and width of the border cannot be customized beyond on/off.
NODE_STROKE <- TRUE

# ── LAYOUT SPREAD CONTROL ────────────────────────────────────
# Controls how spread out nodes are in 3D space relative to their size.
# Lower values pull nodes closer together so circle borders visually
# cover edge endpoints — making edges appear to emerge from circle edges
# rather than from centers. Higher values spread nodes further apart.
# Range: 0.5 (very tight) to 1.0 (fully spread). Default: 0.82.
LAYOUT_SPREAD <- 0.82

# Year to visualize
YEAR <- 2000


# ── 1. LOAD & PREP DATA ──────────────────────────────────────

raw <- DATA_PATH

df <- raw %>%
  filter(year == YEAR) %>%
  arrange(state)

stopifnot(nrow(df) == 51)
stopifnot(all(POLICY_COLS %in% names(df)))


# ── 2. COMPUTE CLUSTER CENTROIDS ─────────────────────────────

# Centroid = mean policy vector across all states in that cluster
centroids <- df %>%
  group_by(state_cluster_id) %>%
  summarise(across(all_of(POLICY_COLS), mean), .groups = "drop") %>%
  mutate(state = paste0("Cluster ", state_cluster_id, " Centroid"))


# ── 3. BUILD COMBINED NODE TABLE ─────────────────────────────

# State nodes: lighter tint of their cluster color
# node_label = abbreviation shown as vertex name in the widget
# node_hover = full state name shown in the mouse-follow tooltip
state_nodes <- df %>%
  select(state, state_cluster_id, all_of(POLICY_COLS)) %>%
  mutate(
    node_label = STATE_ABBR[state],
    node_hover = state,
    node_type  = "state",
    node_color = NODE_COLORS[as.character(state_cluster_id)],
    node_size  = STATE_NODE_SIZE
  )

# Centroid nodes: full cluster color
centroid_nodes <- centroids %>%
  mutate(
    node_label = paste0("Cluster ", state_cluster_id, " Centroid"),
    node_hover = paste0("Cluster ", state_cluster_id, " Centroid"),
    node_type  = "centroid",
    node_color = CLUSTER_COLORS[as.character(state_cluster_id)],
    node_size  = CENTROID_NODE_SIZE
  )

# Stack: states first (rows 1–51), centroids last (rows 52–53)
nodes <- bind_rows(state_nodes, centroid_nodes)
n_total <- nrow(nodes)   # 53


# ── 4. PAIRWISE EUCLIDEAN DISTANCES → 3D MDS LAYOUT ─────────

# Build distance matrix across all 53 nodes
policy_matrix <- as.matrix(nodes[, POLICY_COLS])
dist_matrix   <- dist(policy_matrix, method = "euclidean")

# Classical MDS into 3D: places nodes such that their 3D distances reflect
# the original 25-dimensional Euclidean distances as faithfully as possible.
# Centroids are embedded in the same space as state nodes.
set.seed(42)
mds_coords <- cmdscale(dist_matrix, k = 3)

# graphjs internally clamps layouts to [-1, 1] per axis. We rescale
# explicitly so the full coordinate range is used and nodes are not
# artificially compressed into a small region of the viewport.
rescale_axis <- function(x) {
  rng <- range(x)
  if (diff(rng) == 0) return(x)
  2 * (x - rng[1]) / diff(rng) - 1   # maps to [-1, 1]
}

mds_scaled        <- apply(mds_coords, 2, rescale_axis) * LAYOUT_SPREAD
nodes$x           <- mds_scaled[, 1]
nodes$y           <- mds_scaled[, 2]
nodes$z           <- mds_scaled[, 3]

# In early years many states share identical policy vectors and land on the
# exact same MDS coordinates, making them invisible behind each other.
# A small reproducible jitter separates them while preserving the overall
# structure — jitter magnitude is tiny relative to the layout spread.
set.seed(42)
JITTER_AMOUNT <- 0.03   # increase slightly if nodes still overlap; keep < 0.05
nodes$x <- nodes$x + runif(n_total, -JITTER_AMOUNT, JITTER_AMOUNT)
nodes$y <- nodes$y + runif(n_total, -JITTER_AMOUNT, JITTER_AMOUNT)
nodes$z <- nodes$z + runif(n_total, -JITTER_AMOUNT, JITTER_AMOUNT)


# ── 5. BUILD EDGES (state → its cluster centroid only) ───────

# Map each cluster id to its node index (rows 52–53 in `nodes`)
centroid_idx <- which(nodes$node_type == "centroid")
centroid_cluster_map <- setNames(centroid_idx, nodes$state_cluster_id[centroid_idx])

state_idx <- which(nodes$node_type == "state")

# Compute every state's Euclidean distance to its own cluster centroid
state_to_centroid_dists <- sapply(state_idx, function(idx_i) {
  clust <- as.character(nodes$state_cluster_id[idx_i])
  idx_c <- centroid_cluster_map[clust]
  sqrt(sum((policy_matrix[idx_i, ] - policy_matrix[idx_c, ])^2))
})

# Threshold = median distance per cluster so exactly half of each
# cluster's states receive an edge to their centroid
cluster_medians <- tapply(
  state_to_centroid_dists,
  nodes$state_cluster_id[state_idx],
  function(x) quantile(x, 0.75)  # more edges (75th percentile)
)
message("Cluster medians: ", paste(names(cluster_medians),
                                   round(cluster_medians, 3), sep = " = ", collapse = ", "))

edges_from <- integer()
edges_to   <- integer()

for (i in seq_along(state_idx)) {
  idx_i <- state_idx[i]
  clust  <- as.character(nodes$state_cluster_id[idx_i])
  idx_c  <- centroid_cluster_map[clust]
  
  d <- state_to_centroid_dists[i]
  if (d <= cluster_medians[clust]) {
    edges_from <- c(edges_from, idx_i)
    edges_to   <- c(edges_to,   idx_c)
  }
}


# ── 6. BUILD IGRAPH OBJECT ───────────────────────────────────

g <- make_empty_graph(n = n_total, directed = FALSE)

if (length(edges_from) > 0) {
  g <- add_edges(g, as.vector(rbind(edges_from, edges_to)))
}

V(g)$name  <- nodes$node_label   # abbreviation rendered in widget
V(g)$label <- nodes$node_hover   # full name shown in tooltip
V(g)$color <- nodes$node_color
V(g)$size  <- nodes$node_size

layout_3d <- as.matrix(nodes[, c("x", "y", "z")])


# ── 7. JS PROGRAM: mouse-follow tooltip + Lato font ──────────

# graphjs renders hover labels inside a div with class "infobox".
# The infobox is always present in the DOM but empty when not hovering —
# this causes an empty box to trail the cursor. The fix:
#   - Start the infobox hidden (display:none)
#   - On mousemove: show it only if it has non-empty text content
#   - On mousemove: hide it again if text is empty (cursor left a node)
# Lato is loaded via Google Fonts and applied to the tooltip.

hover_program <- "
  /* Inject Lato from Google Fonts */
  (function() {
    if (!document.getElementById('lato-font-link')) {
      var link = document.createElement('link');
      link.id   = 'lato-font-link';
      link.rel  = 'stylesheet';
      link.href = 'https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap';
      document.head.appendChild(link);
    }
  })();

  /* Hide infobox on init so it is invisible before first hover */
  (function() {
    var boxes = document.getElementsByClassName('infobox');
    for (var i = 0; i < boxes.length; i++) {
      boxes[i].style['display'] = 'none';
    }
  })();

  document.addEventListener('mousemove', function(e) {
    var boxes = document.getElementsByClassName('infobox');
    if (boxes.length === 0) return;
    var x = boxes[boxes.length - 1];

    /* Only show tooltip when the infobox actually contains a label */
    if (!x.textContent || x.textContent.trim() === '') {
      x.style['display'] = 'none';
      return;
    }

    x.style['display']        = 'block';
    x.style['position']       = 'absolute';
    x.style['top']            = (e.pageY + 14) + 'px';
    x.style['left']           = (e.pageX + 14) + 'px';
    x.style['font-family']    = \"'Lato', sans-serif\";
    x.style['font-size']      = '13px';
    x.style['font-weight']    = '700';
    x.style['color']          = '#222222';
    x.style['background']     = 'rgba(255,255,255,0.92)';
    x.style['border']         = '1px solid #cccccc';
    x.style['border-radius']  = '5px';
    x.style['padding']        = '4px 8px';
    x.style['pointer-events'] = 'none';
    x.style['box-shadow']     = '0 2px 6px rgba(0,0,0,0.15)';
    x.style['white-space']    = 'nowrap';
  });
"


# ── 8. RENDER INTERACTIVE 3D NETWORK ─────────────────────────

net <- graphjs(
  g,
  layout       = layout_3d,
  vertex.color = V(g)$color,
  vertex.size  = V(g)$size,
  vertex.shape = "circle",        # crisp flat circles — cleaner than unlit spheres
  vertex.label = V(g)$label,      # full state name shown in mouse-follow tooltip
  edge.color   = "#CCCCCC",
  edge.width   = 0.3,
  edge.alpha   = 0.5,
  bg           = "#F7F7F7",
  main         = "",
  opacity      = NODE_OPACITY,    # circle fill transparency (0–1)
  stroke       = NODE_STROKE,     # TRUE = thin black border ring around circles
  program      = hover_program
)

# Render in RStudio viewer
net


# ── 9. SAVE AS SELF-CONTAINED HTML (for GitHub Pages) ───────

OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

saveWidget(
  net,
  file          = file.path(OUTPUT_DIR, "network_map_2019.html"),
  selfcontained = TRUE,
  title         = "State Immigration Policy Clusters, 2019"
)

message("HTML saved to: ", file.path(OUTPUT_DIR, "network_map_2019.html"))
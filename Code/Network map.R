# Nathaniel Cross
# PA 594
# Capstone Project
#
# Data visualization:
# 3D Network Map — State policy clusters (all years, interactive slider)


#==============================================================================#
# 3D NETWORK MAP — MULTI-YEAR SELF-CONTAINED HTML                              #
#==============================================================================#


# ── 0. CONFIG ────────────────────────────────────────────────

setwd("C:/Users/ndmcr/Desktop/MPP Capstone")

DATA_PATH <- read.csv("https://raw.githubusercontent.com/nathanielcross04/MPP-Capstone/refs/heads/main/Data/Other%20data/network_map.csv")

library(dplyr)
library(threejs)
library(igraph)
library(htmlwidgets)

CLUSTER_COLORS <- c("1" = "#B5463A", "2" = "#2E86B5")
NODE_COLORS    <- c("1" = "#DAA29C", "2" = "#96C2DA")

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

STATE_NODE_SIZE    <- 0.6
CENTROID_NODE_SIZE <- 1.0
NODE_OPACITY       <- 1.0
NODE_STROKE        <- TRUE
JITTER_AMOUNT      <- 0.03

# ── LAYOUT SPREAD CONTROL ────────────────────────────────────
# Controls how spread out nodes are in 3D space relative to their size.
# Range: 0.5 (very tight) to 1.0 (fully spread). Default: 0.82.
LAYOUT_SPREAD <- 0.82

# ── CENTROID WEIGHT CONTROL ──────────────────────────────────
# Option A: centroid rows are duplicated in the distance matrix before MDS
# so the algorithm treats centroid proximity as more important than
# interstate distances alone. Higher values = centroids pull harder.
# 1 = no extra weight (pure joint MDS); 5 = strong centroid emphasis.
# Default: 3.
CENTROID_WEIGHT <- 5

# ── EDGE THRESHOLD ───────────────────────────────────────────
# Draw a state-to-state edge if Euclidean distance <= this value.
# ~10th percentile of pairwise distances — only the most similar
# same-cluster states are connected.
EDGE_THRESHOLD <- 1.5

YEARS <- 2000:2019


# ── 1. FUNCTION: build graphjs widget for one year ───────────

build_widget <- function(year, raw) {
  
  df <- raw %>% filter(year == !!year) %>% arrange(state)
  stopifnot(nrow(df) == 51)
  
  # ── Centroids ─────────────────────────────────────────────
  centroids <- df %>%
    group_by(state_cluster_id) %>%
    summarise(across(all_of(POLICY_COLS), mean), .groups = "drop") %>%
    mutate(state = paste0("Cluster ", state_cluster_id, " Centroid"))
  
  # ── Node table ────────────────────────────────────────────
  state_nodes <- df %>%
    select(state, state_cluster_id, all_of(POLICY_COLS)) %>%
    mutate(
      node_label = STATE_ABBR[state],
      node_hover = state,
      node_type  = "state",
      node_color = NODE_COLORS[as.character(state_cluster_id)],
      node_size  = STATE_NODE_SIZE
    )
  
  centroid_nodes <- centroids %>%
    mutate(
      node_label = paste0("Cluster ", state_cluster_id, " Centroid"),
      node_hover = paste0("Cluster ", state_cluster_id, " Centroid"),
      node_type  = "centroid",
      node_color = CLUSTER_COLORS[as.character(state_cluster_id)],
      node_size  = CENTROID_NODE_SIZE
    )
  
  # States first (rows 1–51), centroids last (rows 52–53)
  nodes   <- bind_rows(state_nodes, centroid_nodes)
  n_total <- nrow(nodes)   # 53
  
  state_idx    <- which(nodes$node_type == "state")
  centroid_idx <- which(nodes$node_type == "centroid")
  
  policy_matrix <- as.matrix(nodes[, POLICY_COLS])
  
  
  # ── Weighted MDS layout (Option A) ───────────────────────
  #
  # Strategy: build the distance matrix on an *augmented* node list where
  # each centroid row is repeated CENTROID_WEIGHT times. This forces cmdscale()
  # to prioritize fitting centroid-to-state distances accurately, because
  # errors involving centroid rows cost CENTROID_WEIGHT× as much as errors
  # between regular state rows. After MDS, we keep only the coordinates for
  # the original 53 nodes (first n_total rows of the result).
  
  # Build augmented policy matrix:
  # original 53 rows + (CENTROID_WEIGHT - 1) extra copies of each centroid
  centroid_extra <- do.call(
    rbind,
    replicate(CENTROID_WEIGHT - 1, policy_matrix[centroid_idx, ], simplify = FALSE)
  )
  aug_matrix <- rbind(policy_matrix, centroid_extra)
  
  # Distance matrix on augmented set
  aug_dist <- dist(aug_matrix, method = "euclidean")
  
  # Classical MDS into 3D on the augmented matrix
  set.seed(42)
  aug_mds <- cmdscale(aug_dist, k = 3)
  
  # Discard the extra centroid rows — keep only original 53
  mds_coords <- aug_mds[seq_len(n_total), ]
  
  # Rescale each axis to [-1, 1] so the full viewport is used
  rescale_axis <- function(x) {
    rng <- range(x)
    if (diff(rng) == 0) return(x * 0)
    2 * (x - rng[1]) / diff(rng) - 1
  }
  mds_scaled <- apply(mds_coords, 2, rescale_axis) * LAYOUT_SPREAD
  
  nodes$x <- mds_scaled[, 1]
  nodes$y <- mds_scaled[, 2]
  nodes$z <- mds_scaled[, 3]
  
  # Small reproducible jitter to separate identical policy vectors
  # (common in early years where many states share the same profile)
  set.seed(42)
  nodes$x <- nodes$x + runif(n_total, -JITTER_AMOUNT, JITTER_AMOUNT)
  nodes$y <- nodes$y + runif(n_total, -JITTER_AMOUNT, JITTER_AMOUNT)
  nodes$z <- nodes$z + runif(n_total, -JITTER_AMOUNT, JITTER_AMOUNT)
  
  
  # ── Edges: same-cluster states below distance threshold ──
  
  edges_from <- integer()
  edges_to   <- integer()
  
  for (i in seq_along(state_idx)) {
    for (j in seq_along(state_idx)) {
      if (j <= i) next
      
      idx_i <- state_idx[i]
      idx_j <- state_idx[j]
      
      if (nodes$state_cluster_id[idx_i] != nodes$state_cluster_id[idx_j]) next
      
      d <- sqrt(sum((policy_matrix[idx_i, ] - policy_matrix[idx_j, ])^2))
      if (d <= EDGE_THRESHOLD) {
        edges_from <- c(edges_from, idx_i)
        edges_to   <- c(edges_to,   idx_j)
      }
    }
  }
  
  # Distance of each state to its own cluster centroid (for tooltip)
  centroid_cluster_map <- setNames(centroid_idx, nodes$state_cluster_id[centroid_idx])
  
  state_to_centroid_dists <- sapply(state_idx, function(idx_i) {
    clust <- as.character(nodes$state_cluster_id[idx_i])
    idx_c <- centroid_cluster_map[clust]
    sqrt(sum((policy_matrix[idx_i, ] - policy_matrix[idx_c, ])^2))
  })
  
  
  # ── igraph object ─────────────────────────────────────────
  
  g <- make_empty_graph(n = n_total, directed = FALSE)
  if (length(edges_from) > 0)
    g <- add_edges(g, as.vector(rbind(edges_from, edges_to)))
  
  V(g)$name  <- nodes$node_label
  V(g)$label <- nodes$node_hover
  V(g)$color <- nodes$node_color
  V(g)$size  <- nodes$node_size
  
  layout_3d <- as.matrix(nodes[, c("x", "y", "z")])
  
  
  # ── Tooltip JS ────────────────────────────────────────────
  
  node_data_js <- paste0(
    "var nodeData = {",
    paste(
      sapply(seq_len(nrow(nodes)), function(i) {
        hover <- gsub('"', '\\"', nodes$node_hover[i])
        clust <- as.character(nodes$state_cluster_id[i])
        
        if (nodes$node_type[i] == "centroid") {
          dist_str <- "null"
        } else {
          pos      <- which(state_idx == i)
          dist_val <- if (length(pos)) state_to_centroid_dists[pos] else NA
          dist_str <- if (!is.na(dist_val)) formatC(dist_val, digits = 4, format = "f") else "null"
        }
        
        paste0('"', hover, '":{"dist":',
               if (dist_str == "null") "null" else paste0('"', dist_str, '"'),
               ',"cluster":"', clust, '"}')
      }),
      collapse = ", "
    ),
    "};"
  )
  
  hover_program <- paste0('
    ', node_data_js, '

    (function() {
      if (!document.getElementById("lato-font-link")) {
        var link = document.createElement("link");
        link.id   = "lato-font-link";
        link.rel  = "stylesheet";
        link.href = "https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap";
        document.head.appendChild(link);
      }
    })();

    (function() {
      if (!document.getElementById("nmap-tt-style")) {
        var s = document.createElement("style");
        s.id = "nmap-tt-style";
        s.textContent = [
          "#nmap-tooltip {",
          "  position: fixed;",
          "  z-index: 9999;",
          "  background: #fff;",
          "  border: 1px solid #ccc;",
          "  border-radius: 7px;",
          "  padding: 9px 13px;",
          "  font-size: 12px;",
          "  font-family: \'Lato\', sans-serif;",
          "  color: #333;",
          "  box-shadow: 0 4px 16px rgba(0,0,0,.12);",
          "  pointer-events: none;",
          "  display: none;",
          "  max-width: 260px;",
          "  line-height: 1.7;",
          "}",
          "#nmap-tooltip .tt-title {",
          "  font-weight: 700;",
          "  font-size: 13px;",
          "  margin-bottom: 4px;",
          "  color: #222;",
          "}",
          "#nmap-tooltip .tt-row {",
          "  display: flex;",
          "  justify-content: space-between;",
          "  gap: 12px;",
          "}",
          "#nmap-tooltip .tt-label { color: #777; }"
        ].join("\\n");
        document.head.appendChild(s);
      }
    })();

    (function() {
      if (!document.getElementById("nmap-tooltip")) {
        var d = document.createElement("div");
        d.id = "nmap-tooltip";
        document.body.appendChild(d);
      }
    })();

    (function() {
      var boxes = document.getElementsByClassName("infobox");
      for (var i = 0; i < boxes.length; i++) {
        boxes[i].style.display = "none";
      }
    })();

    function positionTooltip(e) {
      var tip = document.getElementById("nmap-tooltip");
      if (!tip) return;
      var tw = tip.offsetWidth  || 240;
      var th = tip.offsetHeight || 100;
      var x  = e.clientX + 14;
      var y  = e.clientY + 14;
      if (x + tw > window.innerWidth  - 10) x = e.clientX - tw - 10;
      if (y + th > window.innerHeight - 10) y = e.clientY - th - 10;
      tip.style.left = x + "px";
      tip.style.top  = y + "px";
    }

    function buildTooltip(label) {
      var d = nodeData[label];
      if (!d) return "";
      var isCentroid = (d.dist === null);
      var rows = "";
      if (!isCentroid && d.dist !== null) {
        rows += "<div class=\'tt-row\'><span class=\'tt-label\'>Distance to centroid</span><span>" + d.dist + "</span></div>";
      }
      if (d.cluster) {
        rows += "<div class=\'tt-row\'><span class=\'tt-label\'>Cluster</span><span>" + d.cluster + "</span></div>";
      }
      return "<div class=\'tt-title\'>" + label + "</div>" + rows;
    }

    document.addEventListener("mousemove", function(e) {
      var tip   = document.getElementById("nmap-tooltip");
      var boxes = document.getElementsByClassName("infobox");
      if (!tip || !boxes.length) return;
      var infobox = boxes[boxes.length - 1];
      var label   = infobox.textContent ? infobox.textContent.trim() : "";
      infobox.style.display = "none";
      if (!label) { tip.style.display = "none"; return; }
      var html = buildTooltip(label);
      if (!html)  { tip.style.display = "none"; return; }
      tip.innerHTML     = html;
      tip.style.display = "block";
      positionTooltip(e);
    });
  ')
  
  graphjs(
    g,
    layout       = layout_3d,
    vertex.color = V(g)$color,
    vertex.size  = V(g)$size,
    vertex.shape = "circle",
    vertex.label = V(g)$label,
    edge.color   = "#CCCCCC",
    edge.width   = 0.3,
    edge.alpha   = 0.5,
    bg           = "#F7F7F7",
    main         = "",
    opacity      = NODE_OPACITY,
    stroke       = NODE_STROKE,
    program      = hover_program
  )
}


# ── 2. PRE-RENDER ALL 20 YEARS ───────────────────────────────

raw <- DATA_PATH
message("Pre-rendering ", length(YEARS), " years...")

widgets <- lapply(YEARS, function(yr) {
  message("  Rendering year ", yr, "...")
  build_widget(yr, raw)
})
names(widgets) <- as.character(YEARS)

message("All years rendered. Saving individual year files...")


# ── 3. SAVE EACH YEAR AS INDIVIDUAL HTML ─────────────────────

OUTPUT_DIR <- "C:/Users/ndmcr/Desktop/MPP Capstone/Figures"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

TEMP_DIR <- file.path(OUTPUT_DIR, "network_map_years")
dir.create(TEMP_DIR, showWarnings = FALSE)

for (yr in as.character(YEARS)) {
  message("  Saving year ", yr, "...")
  fpath <- file.path(TEMP_DIR, paste0("map_", yr, ".html"))
  saveWidget(
    widgets[[yr]],
    file          = fpath,
    selfcontained = TRUE,
    title         = paste("Network Map", yr)
  )
}

message("All years saved. Building combined HTML...")


# ── 4. BUILD FINAL HTML WITH LAZY-LOADED IFRAMES ─────────────

page_css <- '
  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: "Lato", sans-serif;
    background: #F7F7F7;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 100vh;
    padding: 28px 16px 16px;
  }

  #page-title {
    font-size: 20px;
    font-weight: 700;
    color: #222222;
    letter-spacing: 0.01em;
    margin-bottom: 18px;
    text-align: center;
  }

  #page-title span {
    font-size: 20px;
    font-weight: 700;
  }

  #controls {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 16px;
  }

  #year-label {
    font-size: 17px;
    font-weight: 700;
    color: #222222;
    min-width: 42px;
    text-align: center;
  }

  #year-slider {
    -webkit-appearance: none;
    appearance: none;
    width: 340px;
    height: 5px;
    border-radius: 3px;
    background: #cccccc;
    outline: none;
    cursor: pointer;
  }

  #year-slider::-webkit-slider-thumb {
    -webkit-appearance: none;
    appearance: none;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: #444444;
    cursor: pointer;
  }

  #year-slider::-moz-range-thumb {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: #444444;
    cursor: pointer;
    border: none;
  }

  #map-container {
    width: 100%;
    max-width: 960px;
    height: 680px;
    position: relative;
  }

  .map-frame {
    position: absolute;
    top: 0; left: 0;
    width: 100%;
    height: 100%;
    border: none;
    visibility: hidden;
    z-index: 0;
    background: #F7F7F7;
  }
'

slider_js <- '
  var slider    = document.getElementById("year-slider");
  var yearLabel = document.getElementById("year-label");
  var loaded    = { "2000": true };

  function showYear(yr) {
    var yrStr = String(yr);

    document.querySelectorAll(".map-frame").forEach(function(f) {
      f.style.visibility = "hidden";
      f.style.zIndex     = "0";
    });

    var target = document.getElementById("map-" + yrStr);
    if (!target) return;

    if (!loaded[yrStr]) {
      var dataSrc = target.getAttribute("data-src");
      if (dataSrc) {
        target.src = dataSrc;
        target.removeAttribute("data-src");
        loaded[yrStr] = true;
      }
    }

    target.style.visibility = "visible";
    target.style.zIndex     = "1";
    yearLabel.textContent   = yrStr;
  }

  slider.addEventListener("input", function() {
    showYear(parseInt(this.value));
  });

  window.addEventListener("load", function() {
    showYear(2000);
  });
'

iframe_tags <- sapply(YEARS, function(yr) {
  fname <- paste0("network_map_years/map_", yr, ".html")
  vis   <- if (yr == min(YEARS)) "visible" else "hidden"
  zi    <- if (yr == min(YEARS)) "1" else "0"
  src   <- if (yr == min(YEARS)) paste0('src="', fname, '"') else paste0('data-src="', fname, '"')
  paste0(
    '<iframe id="map-', yr, '" class="map-frame" ',
    src, ' ',
    'style="visibility:', vis, ';z-index:', zi, ';background:#F7F7F7;" ',
    'scrolling="no"></iframe>'
  )
})

html_out <- paste0(
  '<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>State Immigration Policy Network Map</title>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap">
  <style>', page_css, '</style>
</head>
<body>

  <div id="page-title">State Immigration Policy Network Map, <span id="year-label">2000</span></div>

  <div id="controls">
    <span style="font-size:13px;color:#555;">2000</span>
    <input type="range" id="year-slider" min="2000" max="2019" step="1" value="2000">
    <span style="font-size:13px;color:#555;">2019</span>
  </div>

  <div id="map-container">',
  paste(iframe_tags, collapse = "\n"),
  '
  </div>

  <script>', slider_js, '</script>
</body>
</html>'
)


# ── 5. SAVE ──────────────────────────────────────────────────

OUTPUT_FILE <- file.path(OUTPUT_DIR, "network_map_interactive.html")
writeLines(html_out, OUTPUT_FILE)
message("Saved to: ", OUTPUT_FILE)


# ── 6. LOCAL PREVIEW ─────────────────────────────────────────
# Run this block separately after saving to preview locally.
# Requires the servr package: install.packages("servr")

library(servr)
servr::httd("C:/Users/ndmcr/Desktop/MPP Capstone/Figures")
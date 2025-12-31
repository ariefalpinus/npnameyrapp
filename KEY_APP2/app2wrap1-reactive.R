# Load occupancy function
source("run_occupancy_analysis.R")
# ✅ Safety check
if (!exists("run_occupancy_analysis")) {
  stop("❌ Function 'run_occupancy_analysis' not found. Please check sourcing.")
}

# 🧭 Step 1: Initializing reactive storage for App2
#WRAP 1
# Core reactive values from App1 output
rec_data <- reactiveVal()
camop_data <- reactiveVal()
report_data <- reactiveVal()
# Custom subset for analysis
Dfsubset <- reactiveVal()
# GBIF tagging results
gbif_tagged <- reactiveVal()

# NEW: Reference species list (TXT file in workdir)
gbif_ref <- reactiveVal(NULL)

# NEW: Helper function for Find & Match
find_scientific_name <- function(species_input, ref) {
  idx <- match(species_input, ref$SPtag)
  sci_name <- ref$ScientificName[idx]
  data.frame(
    SPnameTAG = species_input,
    ScientificName = sci_name,
    stringsAsFactors = FALSE
  )
}


# RAI table
species_events <- reactiveVal()
# Kernel density plot object (optional for preview)
kernel_plot <- reactiveVal()
# Occupancy modeling results
occupancy_summary <- reactiveVal()
# Combined summary table for all species
summary_table_all_species <- reactiveVal()


# ---- Global reactive storage for Layer 5 ----
kernel_data <- reactiveValues(
  plot_data = NULL,            # frozen plot data (species, rad, RAI, etc.)
  create_plot_for_save = NULL, # frozen plotting function
  output_pdf = NULL,           # path for PDF export
  output_tif = NULL            # path for TIFF export
)


# ---- Global reactive storage for Layer 7 ----
overlap_data <- reactiveValues(
  est_data = NULL,        # stores estimator choice, point estimate
  ci_table = NULL,        # stores CI summary table
  create_plot_for_save = NULL, # frozen plot function for saving
  output_pdf = NULL,
  output_tif = NULL
)
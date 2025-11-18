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
# RAI table
species_events <- reactiveVal()
# Kernel density plot object (optional for preview)
kernel_plot <- reactiveVal()
# Occupancy modeling results
occupancy_summary <- reactiveVal()
# Combined summary table for all species
summary_table_all_species <- reactiveVal()


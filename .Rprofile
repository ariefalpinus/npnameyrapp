# ============================================================
# 🎉 Welcome to Shiny App v1.1
# ------------------------------------------------------------
# APP1 - Field to Raw Data
# Using camtrapR Workflow by Niedballa
# @arief.b @s.pudyatmoko
#
# APP2 - Analysis & Visualization
# Supporting overlap, RPresence, and related workflows
#
# ⚠️ IMPORTANT: The app will only run after ALL required
# packages are installed and loaded successfully.
# ============================================================

message("🎉 Welcome to Shiny App v1.1")
message("🔧 Checking required packages for App1 and App2...")

# ============================================================
# Combined list of required packages
# ============================================================

pkgs <- c(
  # --- App1 requirements ---
  "camtrapR", "shiny", "tools", "stringr", "fs",
  "DT", "zip", "readr", "openxlsx", "exiftoolr",
  
  # --- App2 requirements ---
  "readxl", "overlap", "RColorBrewer", "lubridate", "rgbif",
  "dplyr", "RPresence", "magrittr", "rhandsontable",
  "Cairo", "magick", "bslib", "shinyjs", "shinybusy",
  
  # --- Test package ---
  "janitor" # skimr
)

# ============================================================
# Define reusable function
# ============================================================

check_and_load_packages <- function(pkgs) {
  missing <- character(0)
  
  for (pkg in pkgs) {
    message("➡ Loading package: ", pkg)
    tryCatch(
      {
        suppressWarnings(
          suppressPackageStartupMessages(
            library(pkg, character.only = TRUE)
          )
        )
        message("   ✔ Package '", pkg, "' loaded successfully.")
      },
      error = function(e) {
        message("   ❌ Package '", pkg, "' is not installed.")
        message("      To install, run: install.packages(\"", pkg, "\")")
        
        if (pkg == "RPresence") {
          message("      Note: RPresence must be installed from USGS repo:")
          message("      install.packages(\"RPresence\", repos = \"https://www.mbr-pwrc.usgs.gov/mbrCRAN\")")
        }
        
        missing <- c(missing, pkg)
      }
    )
  }
  
  if (length(missing) == 0) {
    message("✅ All required packages were successfully loaded.")
    message("🚀 You can now launch the app — all dependencies are ready.")
  } else {
    message("⚠️ The following packages are missing and need to be installed:")
    message("   ", paste(missing, collapse = ", "))
    message("💡 Please install them using the commands shown above, then restart R.")
  }
  
  message("📋 Package check completed at: ", Sys.time())
}

# ============================================================
# Run once at startup
# ============================================================

check_and_load_packages(pkgs)
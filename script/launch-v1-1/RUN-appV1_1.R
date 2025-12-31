
# ============================================================
# R SHINY APP version 1.1
# APP1 – Field to Raw Data Workflow
# Based on camtrapR (Niedballa)
# @arief.b @s.pudyatmoko
# ============================================================

# ============================================================
# Required R Packages for App1 and App2
# These packages will be checked and installed automatically
# when you run the helper function (see startup script).
# ============================================================

# App1 packages
# camtrapR, shiny, tools, stringr, fs,
# DT, zip, readr, openxlsx, exiftoolr

# App2 packages
# readxl, overlap, RColorBrewer, lubridate, rgbif,
# dplyr, RPresence, magrittr, rhandsontable,
# Cairo, magick, bslib, shinyjs, shinybusy

# Setting the Environment
# Confirm the working directory
getwd()

# Auto-run package check & load
check_and_load_packages(pkgs)

# ============================================================
# // LAUNCH APP //
# ============================================================

## Workspace Options

# LOCAL-HOST
## auto-run
source("KEY_APP2/launch-app.R")
shinyApp(ui, server)

## manual-run
source("KEY_APP2/wrap1-reactive.R")  # active setup
source("KEY_APP2/wrap2-ui.R")        # UI definition
source("KEY_APP2/wrap3-server.R")    # ⚙ Server logic
shinyApp(ui, server)                 # Viewer pane launch

# WEB-BROWSER
## auto-run
source("KEY_APP2/launch-browser.R")

## manual-run
source("KEY_APP2/wrap2-ui.R")        # UI definition
source("KEY_APP2/wrap3-server.R")    # ⚙ Server logic
runApp(list(ui = ui, server = server), port = 7253, launch.browser = TRUE)




# ============================================================
# Manual check & install (alternative method using pacman)
# ============================================================
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  camtrapR, shiny, tools, stringr, fs,
  DT, zip, readr, openxlsx, exiftoolr,
  readxl, overlap, RColorBrewer, lubridate, rgbif,
  dplyr, RPresence, magrittr, rhandsontable,
  Cairo, magick, bslib, shinyjs, shinybusy
)


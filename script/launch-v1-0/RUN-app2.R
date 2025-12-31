#R SHINNY APP 2- GBIF_RAI_KERNEL_STATIC OCCUPANCY
#USING camtrapR Workflow by Niedballa, R. Linkie, Mc Kenzie
#@arief.b @s.pudyatmoko

#Setting the Environment
#work directory
#setwd("C:/Users/ACER/ariefb/SharedAssets/wsl2/Rshinny/NPname2025") 
#setwd("/home/unixcuon/SharedAssets/wsl2/Rshinny/NPname2025")  
getwd()

#R package activation
library(camtrapR)
library(shiny)
library(xlsx)
library(tools)
library(stringr)
library(fs)
library(DT)
library(zip)
library(readr)
library(openxlsx)
#pkg app2
library(readxl)
library(overlap)
library(RColorBrewer)
library(lubridate)
library(rgbif)
library(dplyr)
library(RPresence)
library(magrittr)
library(rhandsontable)
library(Cairo)
library(magick)
library(bslib)
library(shinyjs)
library(shinybusy)


#//LAUNCH-APP

##Workspace-Options

#Local-Host
##autorun
source("KEY_APP/launch-app2.R")
shinyApp(ui, server)

#m%anual-run
source("KEY_APP/app2wrap1-reactive.R")  # active setup
source("KEY_APP/app2wrap2-ui.R")        # UI definition
source("KEY_APP/app2wrap3-server.R")    # ⚙ Server logic
shinyApp(ui, server)                # Viewer pane launch


#Web-Browser
#a#utorun
source("KEY_APP/launch-browser2.R")
#manual-run
source("KEY_APP/app2wrap2-ui.R")        # UI definition
source("KEY_APP/app2wrap3-server.R")    # ⚙Server logic
runApp(list(ui = ui, server = server), port = 7253, launch.browser = TRUE)




#R SHINNY APP 1 - Field to Raw Data
#USING camtrapR Workflow by Niedballa
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


#//LAUNCH-APP

##Workspace-Options

#Local-Host
##autorun
source("KEY_APP/launch-app.R")
shinyApp(ui, server)
#m%anual-run
source("KEY_APP/wrap1-reactive.R")  # active setup
source("KEY_APP/wrap2-ui.R")        # UI definition
source("KEY_APP/wrap3-server.R")    # ⚙ Server logic
shinyApp(ui, server)                # Viewer pane launch


#Web-Browser
#a#utorun
source("KEY_APP/launch-browser.R")
#manual-run
source("KEY_APP/wrap2-ui.R")        # UI definition
source("KEY_APP/wrap3-server.R")    # ⚙Server logic
runApp(list(ui = ui, server = server), port = 7253, launch.browser = TRUE)

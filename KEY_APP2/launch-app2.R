message("🧭 Step 1: Initializing reactive storage...")
source("KEY_APP2/app2wrap1-reactive.R")
Sys.sleep(1)

message("🧭 Step 2: Loading UI definition...")
source("KEY_APP2/app2wrap2-ui.R")
Sys.sleep(1)

message("🧭 Step 3: Loading server logic...")
source("KEY_APP2/app2wrap3-server.R")
Sys.sleep(1)

#message("🚀 Step 4: Launching Shiny app...")
#shinyApp(ui, server)

message("🚦 All components loaded. Launch manually with: shinyApp(ui, server)")
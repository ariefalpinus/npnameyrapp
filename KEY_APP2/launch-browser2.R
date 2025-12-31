message("🧭 Step 1: Loading UI...")
source("KEY_AP2P/app2wrap2-ui.R")
Sys.sleep(1)

message("🧭 Step 2: Loading server...")
source("KEY_APP2/app2wrap3-server.R")
Sys.sleep(1)

message("🚀 Step 3: Launching in browser...")
runApp(list(ui = ui, server = server), port = 7253, launch.browser = TRUE)
# SCRIPT #3: UI Definition
#WRAP 2
ui <- fluidPage(
  #useShinyjs(),  # ← Add this line
  
  div(
    h1("npnameyrapp v1.1 — Wildlife Monitoring Tool (App2)", 
       style = "color:blue; font-weight:bold; margin-bottom:10px;")
  ),
  
  
  # Unified CSS styling
  tags$head(
    tags$style(HTML("
    .btn-active {
      background-color: black !important;
      color: white !important;
      font-weight: bold;
      border-radius: 4px;
      padding: 6px 12px;
    }
    .btn-active:hover {
      background-color: #333 !important;
      color: #fff !important;
    }
    .btn-exif {
      background-color: darkgreen !important;
      color: white !important;
      font-weight: bold;
    }
    .btn-exif:hover {
      background-color: #006400 !important;
      color: #fff !important;
    }
    .logo-img {
      position: absolute;
      top: 15px;
      right: 15px;
      height: 60px;
      opacity: 0.95;
      z-index: 1000;
    }
    .license-block {
      margin-top: -10px;
      margin-bottom: 20px;
      font-size: 14px;
      color: #444;
    }
  "))
  ),
  
  
  # Dynamically rendered logo
  uiOutput("logo_block"),
  
  # License block
  div(class = "license-block",
      h4("📕 License: GNU General Public License v3 (GPL-3.0)"),
      helpText("This app is licensed under the GNU GPL v3. You may use, modify, and share it freely, provided that any distributed versions remain open-source and include the same license."),
      tags$a(href = "https://www.gnu.org/licenses/gpl-3.0.en.html", "🔗 View full license", target = "_blank")
  ),
  
  navlistPanel(
    widths = c(2, 10),
    
    
    # Layer 1: Setup
    tabPanel("Layer 1: Opening",
             
             # System Info
             #h4("🧭 System Info"),
             verbatimTextOutput("os_info"),
             
             # Folder Structure Guide
             #h4("📁 Folder Structure Guide"),
             verbatimTextOutput("folder_structure"),
             
             # Working Directory
             textInput("wd_path", "Working Directory (setwd):", value = getwd()),
             div(
               actionButton("set_wd", "Set Working Directory", class = "btn-active"),
               tags$span(
                 " Auto-create folders & fill paths",
                 style = "color:red; margin-left:10px; font-size:90%;"
               )
             ),
             verbatimTextOutput("wd_confirm"),
             
             # Input Folder
             textInput("indir_path", "📥 Input Folder (inDir):", value = ""),
             verbatimTextOutput("indir_status"),
             
             # Output Folder
             textInput("outdir_path", "📤 Output Folder (outDir):", value = ""),
             verbatimTextOutput("outdir_status")
    ),
    
    # Layer 2: Upload
    tabPanel("Layer 2: Upload App1_output",
             
             # Controls section - full width
             card(
               card_header("Upload Data"),
               fileInput("app1_rdata", "Upload App1_output.RData", accept = ".RData"),
               actionButton("load_app1", "Load App1 Data", class = "btn-active"),
               # NEW: numeric input for preview limit
               numericInput("preview_limit", "Rows to preview:", value = 100, min = 10, max = 1000, step = 10),
               verbatimTextOutput("app1_status")
             ),
             
             # Tables section - each card full width
             card(
               card_header("📄 Preview: rec"),
               DTOutput("rec_preview")
             ),
             
             card(
               card_header("📄 Preview: camop"),
               DTOutput("camop_preview")
             ),
             
             card(
               card_header("📄 Preview: Report$survey_dates"),
               DTOutput("survey_dates_preview")
             )
    ),
    
    
    
    # Layer 3: GBIF validation - ✅ FIXED
    
    # Modified Layer 3 UI with dedicated download card
    tabPanel("Layer 3: GBIF Validation",
             
             h4("📋 Species Name Tags (App.1-Dataset)"),
             div(
               tags$a(href = "https://www.gbif.org/", target = "_blank", 
                      "🌐 Visit GBIF for species data"),
               style = "margin-bottom: 15px;"  # adds a bit of space
             ),
             
             layout_columns(
               col_widths = c(2, 6, 4),  # Changed from c(2, 10)
               
               # Input card (left)
               card(
                 card_header("✏️ Enter Real Species Names"),
                 # NEW: mode selector
                 radioButtons(
                   "fill_mode",
                   "Filling mode:",
                   choices = c("Manual input" = "manual",
                               "Automation (use A_LIST_OF_SPECIES-NAME-TAG.txt in workdir)" = "auto"),
                   selected = "manual", inline = TRUE
                 ),
                 
                 rHandsontableOutput("species_input_table"),
                 br(),
                 actionButton("run_gbif", "Validate Species via GBIF", 
                              class = "btn-primary w-100"),
                 verbatimTextOutput("gbif_fill_status")
               ),
               
               # Results card (middle) 
               card(
                 card_header("🔍 GBIF Checking & Matching Results"),
                 DTOutput("gbif_preview"),
                 verbatimTextOutput("gbif_status")
               ),
               
               # NEW: Dedicated Download card (right)
               # Replace the entire download card with this simple version:
               card(
                 card_header("📥 Download Results"),
                 uiOutput("download_card_content")
               )
             )
    ),
    
    
    # Layer 4: RAI Analysis
    tabPanel("Layer 4: Relative Abundance Index (RAI)",
             actionButton("run_rai", "Run RAI Analysis", class = "btn-active"),
             DTOutput("rai_preview"),
             verbatimTextOutput("rai_status")
    ),
    
    
    # Layer 5: Kernel Density Plot
    tabPanel("Layer 5: Kernel Density Plot (KDP)",
             add_busy_spinner(spin = "fading-circle", color = "#0072B2", timeout = 100),
             
             radioButtons("kernel_mode", "Plot Mode:", choices = c("Single Species", "Two Species", "All Species")),
             
             conditionalPanel(
               condition = "input.kernel_mode == 'Single Species'",
               selectInput("kernel_species", "Select Species:", choices = NULL)
             ),
             
             conditionalPanel(
               condition = "input.kernel_mode == 'Two Species'",
               selectInput("kernel_species_A", "Select Species A:", choices = NULL),
               selectInput("kernel_species_B", "Select Species B:", choices = NULL)
             ),
             
             radioButtons("kernel_center", "Center Plot At:", choices = c("Midnight", "Daylight")),
             actionButton("run_kernel", "Generate Kernel Plot", class = "btn-active"),
             
             # Make plot wider and taller
             plotOutput("kernel_preview", height = "600px", width = "100%"),
             #actionButton("save_kernel", "📁 Save Preview to PDF & TIFF"),
             verbatimTextOutput("kernel_status"),
             # In your UI, add a download button
             downloadButton("download_kernel_plot", "📥 Download Plot", 
                            class = "btn-primary", style = "margin: 5px;"),
             verbatimTextOutput("download_status")
    ),
    
    
    # Layer 6: Static Occupancy Model
    tabPanel("Layer 6: Static Occupancy Model",
             add_busy_spinner(spin = "fading-circle", color = "#0072B2", timeout = 100),
             
             radioButtons("occupancy_mode", "Run Mode:", 
                          choices = c("Single Species", "All Species"),
                          selected = "Single Species"),
             
             radioButtons("download_format", "Choose file format:",
                          choices = c("CSV" = "csv", "Excel (.xlsx)" = "xlsx"),
                          selected = "csv",
                          inline = TRUE),
             
             conditionalPanel(
               condition = "input.occupancy_mode == 'Single Species'",
               selectInput("occupancy_species", "Select Species:", choices = NULL)
             ),
             
             actionButton("run_occupancy", "Run Occupancy Model", class = "btn-active"),
             
             DTOutput("occupancy_summary"),
             verbatimTextOutput("occupancy_status"),
             
             h4("AIC Table Preview"),
             DTOutput("aic_table_preview"),
             
             # Optional: Add download button for summary table
             downloadButton("download_occupancy_summary", "📥 Download Summary", 
                            class = "btn-primary", style = "margin: 5px;"),
             verbatimTextOutput("occupancy_download_status")
    ),
    
    
    # ---- Layer 7: Coefficient Overlap Estimation ----
    tabPanel("Layer 7: Coefficient Overlap Estimation",
             add_busy_spinner(spin = "fading-circle", color = "#D55E00", timeout = 100),
             
             # Mode selector (start with One Pair, extend later)
             radioButtons("overlap_mode", "Estimation Mode:", choices = c("One Pair")),
             
             conditionalPanel(
               condition = "input.overlap_mode == 'One Pair'",
               selectInput("overlap_species_A", "Select Species A:", choices = NULL),
               selectInput("overlap_species_B", "Select Species B:", choices = NULL)
             ),
             
             # ✅ Added centering option, same as Layer 5
             radioButtons("overlap_center", "Center Plot At:", choices = c("Midnight", "Daylight"), selected = "Daylight"),
             
             numericInput("overlap_bootstrap", "Bootstrap Replicates:", value = 1000, min = 1000, max = 10000, step = 500),
             
             # ✅ Added run button, same style as Layer 5
             actionButton("run_overlap", "RUN Coeff. Overlap Estimation", class = "btn-active"),
             
             verbatimTextOutput("overlap_status"),
             verbatimTextOutput("overlap_result"),
             
             plotOutput("overlap_preview", height = "600px", width = "100%"),
             DTOutput("overlap_ci_table"),
             
             downloadButton("download_overlap_plot", "📥 Download Overlap Plot",
                            class = "btn-primary", style = "margin: 5px;"),
             verbatimTextOutput("overlap_download_status")
    )
    
    
  )
)




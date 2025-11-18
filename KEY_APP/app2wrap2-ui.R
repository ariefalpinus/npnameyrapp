# SCRIPT #3: UI Definition
#WRAP 2
ui <- fluidPage(
  #useShinyjs(),  # ← Add this line
  titlePanel("npnameyrapp v1.0 — Wildlife Monitoring Tool (App2)"),
  
  # Dynamically rendered logo
  uiOutput("logo_block"),
  
  # License block
  div(class = "license-block",
      h4("📝 License: GNU General Public License v3 (GPL-3.0)"),
      helpText("This app is licensed under the GNU GPL v3. You may use, modify, and share it freely, provided that any distributed versions remain open-source and include the same license."),
      tags$a(href = "https://www.gnu.org/licenses/gpl-3.0.en.html", "🔗 View full license", target = "_blank")
  ),
  
  navlistPanel(
    widths = c(2, 10),
    
    
    # Layer 1: Setup
    tabPanel("Layer 1: Opening",
             
             #h4("🧭 System Info"),
             verbatimTextOutput("os_info"),
             #h4("📁 Folder Structure Guide"),
             verbatimTextOutput("folder_structure"),
             
             verbatimTextOutput("os_info"),
             verbatimTextOutput("folder_structure"),
             
             textInput("wd_path", "Working Directory (setwd):", value = getwd()),
             actionButton("set_wd", "Set Working Directory"),
             verbatimTextOutput("wd_confirm"),
             
             textInput("indir_path", "Input Folder (inDir):", value = ""),
             verbatimTextOutput("indir_status"),
             
             textInput("outdir_path", "Output Folder (outDir):", value = ""),
             verbatimTextOutput("outdir_status")
    ),
    
    # Layer 2: Upload
    tabPanel("Layer 2: Upload App1_output",
             
             # Controls section - full width
             card(
               card_header("Upload Data"),
               fileInput("app1_rdata", "Upload App1_output.RData", accept = ".RData"),
               actionButton("load_app1", "Load App1 Data"),
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
                 rHandsontableOutput("species_input_table"),
                 br(),
                 actionButton("run_gbif", "Validate Species via GBIF", 
                              class = "btn-primary w-100")
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
             actionButton("run_rai", "Run RAI Analysis"),
             DTOutput("rai_preview"),
             verbatimTextOutput("rai_status")
    ),
    
    
    # Layer 5: Kernel Density Plot
    tabPanel("Layer 5: Kernel Density Plot (KDP)",
             add_busy_spinner(spin = "fading-circle", color = "#0072B2", timeout = 100),
             
             radioButtons("kernel_mode", "Plot Mode:", choices = c("Single Species", "All Species")),
             
             conditionalPanel(
               condition = "input.kernel_mode == 'Single Species'",
               selectInput("kernel_species", "Select Species:", choices = NULL)
             ),
             
             radioButtons("kernel_center", "Center Plot At:", choices = c("Midnight", "Daylight")),
             actionButton("run_kernel", "Generate Kernel Plot"),
             
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
             
             actionButton("run_occupancy", "Run Occupancy Model"),
             
             DTOutput("occupancy_summary"),
             verbatimTextOutput("occupancy_status"),
             
             h4("AIC Table Preview"),
             DTOutput("aic_table_preview"),
             
             # Optional: Add download button for summary table
             downloadButton("download_occupancy_summary", "📥 Download Summary", 
                            class = "btn-primary", style = "margin: 5px;"),
             verbatimTextOutput("occupancy_download_status")
    )
    
    
    
  )
)




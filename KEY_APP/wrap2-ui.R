#WRAP 2
# SCRIPT #3: UI Definition
ui <- fluidPage(
  titlePanel("npnameyrapp v1.0 — Wildlife Monitoring Tool (App1)"),
  
  # Dynamically rendered logo (Javan Dhole)
  uiOutput("logo_block"),
  
  # Embedded logo (Javan Dhole)
  tags$head(
    tags$style(HTML("
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
  #tags$img(src = "dhole2.png", class = "logo-img"),
  
  # License block displayed under title
  div(class = "license-block",
      #tags$img(src = "https://www.r-project.org/logo/Rlogo.png", height = "60px"),
      h4("📝 License: GNU General Public License v3 (GPL-3.0)"),
      helpText("This app is licensed under the GNU GPL v3. You may use, modify, and share it freely, provided that any distributed versions remain open-source and include the same license."),
      tags$a(href = "https://www.gnu.org/licenses/gpl-3.0.en.html", "🔗 View full license", target = "_blank")
  ),
  
  navlistPanel(
    widths = c(2, 10),
    
    # Layer 1: Opening
    tabPanel("Layer 1: Opening",
             verbatimTextOutput("os_info"),
             verbatimTextOutput("folder_structure"),
             textInput("wd_path", "Working Directory (setwd):", value = getwd()),
             actionButton("set_wd", "Set Working Directory"),
             verbatimTextOutput("wd_confirm"),
             textInput("indir_path", "Input Folder (inDir):", value = ""),
             verbatimTextOutput("indir_status"),
             textInput("outdir_path", "Output Folder (outDir):", value = ""),
             verbatimTextOutput("outdir_status"),
             textInput("excel_outdir", "Excel Output Folder (for Layer 2 & 3):", value = ""),
             verbatimTextOutput("excel_outdir_status"),
             textInput("exif_path", "EXIFTOOL Path (windows_only):", value = ""),
             actionButton("set_exif", "Configure EXIFTOOL"),
             verbatimTextOutput("exif_status")
    ),
    
    # Layer 2.1: CT Table Upload
    tabPanel("Layer 2.1: CT Table Upload",
             fileInput("ct_table", "Upload CT_TABLE.txt", accept = ".txt"),
             actionButton("load_ct", "Load CT Table"),
             verbatimTextOutput("ct_preview"),
             verbatimTextOutput("ct_structure")
    ),
    
    # Layer 2.2: Folder Creation
    tabPanel("Layer 2.2: Folder Creation",
             actionButton("create_folders", "Run createStationFolders()"),
             DTOutput("folder_result")
    ),
    
    # Layer 2.3: Image Rename
    tabPanel("Layer 2.3: Image Rename",
             actionButton("run_rename", "Run imageRename()"),
             verbatimTextOutput("rename_status")
    ),
    
    # Layer 2.4: Record Table
    tabPanel("Layer 2.4: Record Table",
             textInput("record_name", "Record Table Name:", value = "recCT.table.NPname"),
             textInput("exclude_tag", "Exclude Tag:", value = "Miscellaneous"),
             actionButton("run_record", "Run recordTable()"),
             DTOutput("record_preview"),
             verbatimTextOutput("record_status")
    ),
    
    # Layer 2.5: Camera Operation
    tabPanel("Layer 2.5: Camera Operation",
             actionButton("run_camop", "Run cameraOperation()"),
             DTOutput("camop_preview"),
             verbatimTextOutput("camop_status")
    ),
    
    # Layer 3: Final Output Display
    tabPanel("Layer 3: Final Output Display",
             actionButton("run_report", "Run surveyReport()"),
             verbatimTextOutput("report_status"),
             DTOutput("species_by_station"),
             DTOutput("events_by_species"),
             DTOutput("events_by_station2"),
             DTOutput("survey_dates")
    )
  )  # End of navlistPanel
)  # End of fluidPage
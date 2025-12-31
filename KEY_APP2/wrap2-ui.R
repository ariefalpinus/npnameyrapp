#WRAP 2
# SCRIPT #3: UI Definition
ui <- fluidPage(
  
  div(
    h1("npnameyrapp v1.1 — Wildlife Monitoring Tool (App1)", 
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
  
  
  # License block displayed under title
  div(class = "license-block",
      #tags$img(src = "https://www.r-project.org/logo/Rlogo.png", height = "60px"),
      h4("📕 License: GNU General Public License v3 (GPL-3.0)"),
      helpText("This app is licensed under the GNU GPL v3. You may use, modify, and share it freely, provided that any distributed versions remain open-source and include the same license."),
      tags$a(href = "https://www.gnu.org/licenses/gpl-3.0.en.html", "🔗 View full license", target = "_blank")
  ),
  
  navlistPanel(
    widths = c(2, 10),
    
    # Layer 1: Opening
    tabPanel("Layer 1: Opening",
             verbatimTextOutput("os_info"),
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
             #actionButton("set_wd", "Set Working Directory"),
             verbatimTextOutput("wd_confirm"),
             
             # Auto-managed folders (status only)
             h4("📷 CTmonitoring Folder"),
             textInput("indir_path", "Input Folder (inDir):", value = "", 
                       width = "100%", placeholder = "Auto-filled"),
             verbatimTextOutput("indir_status"),
             
             h4("📸 CTmonitoring_rename Folder"),
             textInput("outdir_path", "Output Folder (outDir):", value = "", 
                       width = "100%", placeholder = "Auto-filled"),
             verbatimTextOutput("outdir_status"),
             
             h4("📥 Workdir Folder"),
             textInput("excel_outdir", "Excel Output Folder (for Layer 2 & 3):", value = "", 
                       width = "100%", placeholder = "Auto-filled"),
             verbatimTextOutput("excel_outdir_status"),
           
             # EXIFTOOL setup
             textInput("exif_path", "EXIFTOOL Path (windows_only):", value = ""),
             actionButton("set_exif", "Configure EXIFTOOL", class = "btn-exif"),
             verbatimTextOutput("exif_status")
    ),
    
    # Layer 2.1: CT Table Upload
    tabPanel("Layer 2.1: CT Table Upload",
             fileInput("ct_table", "Upload CT_TABLE.txt", accept = ".txt"),
             actionButton("load_ct", "Load CT Table", class = "btn-active"),
             verbatimTextOutput("ct_preview"),
             verbatimTextOutput("ct_structure")
    ),
    
    # Layer 2.2: Folder Creation
    tabPanel("Layer 2.2: Folder Creation",
             actionButton("create_folders", "Run createStationFolders()", class = "btn-active"),
             DTOutput("folder_result")
    ),
    
    # Layer 2.3: Image Rename
    tabPanel("Layer 2.3: Image Rename",
             actionButton("run_rename", "Run imageRename()", class = "btn-active"),
             verbatimTextOutput("rename_status")
    ),
    
    
    # Layer 2.4: Record Table
    tabPanel("Layer 2.4: Record Table",
             
             textInput("record_name", "Record Table Name:", value = "recCT.table.NPname"),
             textInput("exclude_tag", "Exclude Tag:", value = "Miscellaneous"),
             
             # DigiKam Path input with green text tightly beside the box
             div(
               style = "display:flex; align-items:center;",
               
               # Input box
               div(
                 style = "flex:0 0 auto;",
                 textInput("digikam_path", "📁 DigiKam DB Directory:", value = "D:/digikam")
               ),
               
               # Helper text
               div(
                 style = "margin-left:12px; margin-top:5px; color:green; font-size:16px; font-weight:normal;",
                 "📂 ",
                 tags$b("Fill in the path to your DigiKam database folder"),
                 ". This folder contains files such as digikam4.db, recognition.db, similarity.db, and thumbnails-digikam.db, created automatically during DigiKam installation."
               )
             ),
             
            # --- CRITICAL instructions for users ---
             tags$div(
               style = "color:red; font-weight:bold; border:2px solid red; padding:10px; margin-bottom:15px; background-color:#fff5f5;",
               tags$p("⚠️ CRITICAL: Before running recordTable(), ensure video files are properly re-species tagged in DigiKam. Follow these steps:"),
               tags$div(
                 style = "color:black; font-weight:normal;",
                 tags$ol(
                   tags$li("Launch DigiKam"),
                   tags$li("Introduce CTmonitoring Folder to DigiKam as albums [Settings > Configure-digikam > Collections > Root Albums Folders > Add Local collections > Browse to CTmonitoring Folder > OK]"),
                   tags$li("Find Video Station Folder in Left-Tab Menu > Albums"),
                   tags$li("Re-species name tag all video files [Click video file > RE-Species Name Tag > Apply]"),
                   tags$li("Close DigiKam. The video metadata Species Name Tag will be written automatically in DigiKam temporary files"),
                   tags$li("Now you can safely run the 'recordTable()' button")
                 )
               )
             ),
             
             # Action button
             actionButton("run_record", "Run recordTable()", class = "btn-active"),
             
             # Outputs
             DTOutput("record_preview"),
             verbatimTextOutput("record_status")
    ),
    
    
    # Layer 2.5: Camera Operation
    tabPanel("Layer 2.5: Camera Operation",
             actionButton("run_camop", "Run cameraOperation()", class = "btn-active"),
             DTOutput("camop_preview"),
             verbatimTextOutput("camop_status")
    ),
    
    # Layer 3: Final Output Display
    tabPanel("Layer 3: Final Output Display",
             actionButton("run_report", "Run surveyReport()", class = "btn-active"),
             verbatimTextOutput("report_status"),
             DTOutput("species_by_station"),
             DTOutput("events_by_species"),
             DTOutput("events_by_station2"),
             DTOutput("survey_dates")
    )
  )  # End of navlistPanel
)  # End of fluidPage
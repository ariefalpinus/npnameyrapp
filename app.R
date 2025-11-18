
#setwd("C:/Users/ACER/ariefb/SharedAssets/wsl2/Rshinny/NPname2025") #WINDOWS ONLY
#setwd("/home/unixcuon/SharedAssets/wsl2/Rshinny/NPname2025") #LINUX ONLY
getwd()

# ============================
# "npnameyrapp v1.0 — Wildlife Monitoring Tool (App1)"
# ============================

# SCRIPT #1: Load Libraries
library(shiny)
library(camtrapR)
library(DT)
library(tools)
library(fs)
library(readr)
library(xlsx)
library(openxlsx)


# SCRIPT #2: Reactive Storage
Dctm <- reactiveVal()
rec_table <- reactiveVal()
DCamMat <- reactiveVal()

# SCRIPT #3: UI Definition
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
      h4("📋 License: GNU General Public License v3 (GPL-3.0)"),
      helpText("This app is licensed under the GNU GPL v3. You may use, modify, and share it freely, provided that any distributed versions remain open-source and include the same license."),
      tags$a(href = "https://www.gnu.org/licenses/gpl-3.0.en.html", "🔗 View full license", target = "_blank")
  ),

  navlistPanel(
    widths = c(2, 10),
    
    # Layer 1: Opening
    tabPanel("Layer 1: Opening",
             #h4("License: Open-source, for NP staff use"),
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
  )
)

# SCRIPT #4: Server Logic
server <- function(input, output, session) {

  # Helper: Strip timezone attributes and suffixes if running under Conda
  #safeParseDateTimeOriginal <- function(x) {
  #  is_conda <- grepl("miniconda3", R.home(), ignore.case = TRUE)
  #  x <- as.character(x)
  #  attributes(x) <- NULL
  #  x <- gsub(" ?(Asia/Jakarta|GMT|America/New_York)$", "", x)
  #  x <- strptime(x, format = "%Y:%m:%d %H:%M:%S", tz = if (is_conda) "Asia/Jakarta" else "")
  #  return(x)
  #}

  #cat("🧪 Runtime context:", if (grepl("miniconda3", R.home(), ignore.case = TRUE)) "Conda R" else "Windows R", "\n")
  #cat("📍 R.home():", R.home(), "\n")
  #cat("🕒 Sys.timezone():", Sys.timezone(), "\n")
  #cat("📁 TZDIR:", Sys.getenv("TZDIR"), "\n\n")

  # Dynamically render logo (Javan Dhole)
  #output$logo_block <- renderUI({
  #  tags$img(src = "https://www.dropbox.com/scl/fi/5gg3nesh2gcqbcwuxla67/dhole2.png.png?rlkey=g9ni7ezuyzwctaglp69kvfjom&st=ioxx57j2&raw=1", class = "logo-img")
  #})
  output$logo_block <- renderUI({
  tags$div(
    style = "position: absolute; top: 15px; right: 15px; text-align: center; z-index: 1000;",
    tags$img(
      src = "https://www.dropbox.com/scl/fi/5gg3nesh2gcqbcwuxla67/dhole2.png.png?rlkey=g9ni7ezuyzwctaglp69kvfjom&st=ioxx57j2&raw=1",
      style = "height: 60px; opacity: 0.95; display: block; margin: 0 auto;"
    ),
    tags$div(
      "@AB & @SP",
       style = "font-size: 7px; color: #444; margin-top: 2px; font-style: italic;"
    )
   )
  })  # ✅ This closes only renderUI — not the whole server
  
  # OS and folder preview
  output$os_info <- renderText({ paste("🖥️ Detected OS:", Sys.info()["sysname"]) })
  output$folder_structure <- renderText({
  paste(
    "📁 Expected folder structure:",
    "npnameyrapp/",
    "├── data/",
    "│   ├── CTmonitoring/CTA",
    "│   ├── CTmonitoring_rename/",
    "│   └── ctTable/CT_TABLE.txt",
    "├── script/",
    "├── KEY_APP/",
    "├── app.R",
    "└── workdir/",
    sep = "\n"
  )
 })
  
  # Validate paths
  output$indir_status <- renderText({
    path <- input$indir_path
    if (nzchar(path)) {
      full <- normalizePath(path, winslash = "/", mustWork = FALSE)
      if (dir.exists(full)) paste("👍 inDir exists:", full)
      else paste("❌ inDir does not exist:", full)
    } else {
      "ℹ️ inDir not set."
    }
  })
  
  output$outdir_status <- renderText({
    path <- input$outdir_path
    if (nzchar(path)) {
      full <- normalizePath(path, winslash = "/", mustWork = FALSE)
      if (dir.exists(full)) paste("👍 outDir exists:", full)
      else paste("❌ outDir does not exist:", full)
    } else {
      "ℹ️ outDir not set."
    }
  })
  
  output$excel_outdir_status <- renderText({
    path <- input$excel_outdir
    if (nzchar(path)) {
      full <- normalizePath(path, winslash = "/", mustWork = FALSE)
      if (dir.exists(full)) paste("👍 Excel output folder exists:", full)
      else paste("❌ Excel output folder does not exist:", full)
    } else {
      "ℹ️ Excel output folder not set."
    }
  })
  
  # Working directory
  observeEvent(input$set_wd, {
    tryCatch({
      setwd(input$wd_path)
      output$wd_confirm <- renderText({ paste("✅ Working directory set to:", getwd()) })
    }, error = function(e) {
      output$wd_confirm <- renderText({ paste("❌ Error:", e$message) })
    })
  })
  
  # EXIFTOOL setup
  observeEvent(input$set_exif, {
    if (.Platform$OS.type == "windows") {
      Sys.setenv(PATH = paste(Sys.getenv("PATH"), input$exif_path, sep = .Platform$path.sep))
    } else {
      Sys.setenv(PATH = paste("/usr/bin", Sys.getenv("PATH"), sep = ":"))
    }
    found <- Sys.which("exiftool")
    output$exif_status <- renderText({
      if (nzchar(found)) paste("✅ EXIFTOOL found at:", found)
      else "❌ EXIFTOOL not found. Please check the path."
    })
  })
  
  # Load CT Table
  observeEvent(input$load_ct, {
    req(input$ct_table)
    df <- read.table(input$ct_table$datapath, header = TRUE, sep = "\t")
    Dctm(df)
    output$ct_preview <- renderPrint({ head(df) })
    output$ct_structure <- renderPrint({ str(df) })
  })
  
  # Create folders
  observeEvent(input$create_folders, {
    req(Dctm())
    result <- createStationFolders(
      inDir = input$indir_path,
      stations = as.character(Dctm()$Station_ID),
      createinDir = TRUE
    )
    output$folder_result <- renderDT({ result })
  })
  
  # Rename images      
  observeEvent(input$run_rename, {
    withProgress(message = "Renaming images...", value = 0.5, {
      tryCatch({
        inDir <- normalizePath(input$indir_path, winslash = "/")
        outDir <- normalizePath(input$outdir_path, winslash = "/")
        if (!dir.exists(inDir)) stop("inDir does not exist.")
        if (!dir.exists(outDir)) dir.create(outDir, recursive = TRUE)

        # ✅ Normalize timestamps for Conda compatibility
        #if (exists("metadata.tmp", inherits = TRUE)) {
        #if ("DateTimeOriginal" %in% names(metadata.tmp)) {
        #  metadata.tmp$DateTimeOriginal <- safeDateTimeForImageRename(metadata.tmp$DateTimeOriginal)
        #  cat("✅ Timestamps normalized for imageRename.\n")
        # }
        #}
        
        imageRename(
          inDir = inDir,
          outDir = outDir,
          hasCameraFolders = FALSE,
          keepCameraSubfolders = FALSE,
          copyImages = TRUE,
          writecsv = FALSE
        )
        output$rename_status <- renderText({ "✅ imageRename completed." })
      }, error = function(e) {
        output$rename_status <- renderText({ paste("❌ Error in imageRename:", e$message) })
      })
    })
  })
  
  # Record table
  observeEvent(input$run_record, {
    withProgress(message = "Generating record table...", value = 0.5, {
      req(Dctm())
      rec <- recordTable(
        inDir = input$outdir_path,
        IDfrom = "metadata",
        cameraID = "filename",
        camerasIndependent = TRUE,
        exclude = input$exclude_tag,
        minDeltaTime = 30,
        deltaTimeComparedTo = "lastIndependentRecord",
        timeZone = "Asia/Jakarta",
        stationCol = "Station_ID",
        writecsv = TRUE,
        outDir = input$excel_outdir,
        metadataHierarchyDelimitor = "|",
        metadataSpeciesTag = "Species",
        removeDuplicateRecords = TRUE
      )
      rec_table(rec)
      
      # Save to Excel
      write.xlsx2(
        rec,
        file = file.path(input$excel_outdir, paste0(input$record_name, ".xlsx")),
        sheetName = input$record_name,
        col.names = TRUE,
        row.names = TRUE,
        append = FALSE
      )
      
      output$record_preview <- renderDT({ rec })
      output$record_status <- renderText({ "✅ recordTable completed and saved to Excel." })
    })
  })
  
  
  # Camera operation
  observeEvent(input$run_camop, {
    withProgress(message = "Generating camera operation matrix...", value = 0.5, {
      req(Dctm())
      camop <- cameraOperation(
        CTtable = Dctm(),
        stationCol = "Station_ID",
        setupCol = "Setup_date",
        retrievalCol = "Retrieval_date",
        hasProblems = FALSE,
        dateFormat = "%Y-%m-%d"
      )
      class(camop) <- c("camOp", class(camop))
      DCamMat(camop)
      
      # Save to Excel
      write.xlsx2(
        camop,
        file = file.path(input$excel_outdir, "cameraOPSmatrix.xlsx"),
        sheetName = "d.camMat",
        col.names = TRUE,
        row.names = TRUE,
        append = FALSE
      )
      
      output$camop_preview <- renderDT({ camop })
      output$camop_status <- renderText({ "✅ cameraOperation completed and saved to Excel." })
    })
  })
  
  # Layer 3: surveyReport
  observeEvent(input$run_report, {
    withProgress(message = "Generating survey report...", value = 0.5, {
      tryCatch({
        req(rec_table(), DCamMat(), Dctm())
        
        Report <- surveyReport(
          recordTable = rec_table(),
          CTtable = Dctm(),
          camOp = DCamMat(),
          speciesCol = "Species",
          stationCol = "Station_ID",
          setupCol = "Setup_date",
          retrievalCol = "Retrieval_date",
          CTDateFormat = "%Y-%m-%d",
          recordDateTimeCol = "DateTimeOriginal",
          recordDateTimeFormat = "%Y-%m-%d %H:%M:%S",
          Xcol = "utm_x",
          Ycol = "utm_y",
          sinkpath = input$excel_outdir,
          makezip = FALSE
        )
        
        # Display preview
        output$species_by_station <- renderDT({ Report$species_by_station })
        output$events_by_species <- renderDT({ Report$events_by_species })
        output$events_by_station2 <- renderDT({ Report$events_by_station2 })
        output$survey_dates <- renderDT({ Report$survey_dates })
        
        # Save to Excel
        write.xlsx2(Report$species_by_station,
                    file = file.path(input$excel_outdir, "stationevents.xlsx"),
                    sheetName = "stationevents", col.names = TRUE, row.names = TRUE, append = FALSE
        )
        write.xlsx2(Report$events_by_species,
                    file = file.path(input$excel_outdir, "speciesevents.xlsx"),
                    sheetName = "speciesevents", col.names = TRUE, row.names = TRUE, append = FALSE
        )
        write.xlsx2(Report$events_by_station2,
                    file = file.path(input$excel_outdir, "station2events.xlsx"),
                    sheetName = "station2events", col.names = TRUE, row.names = TRUE, append = FALSE
        )
        write.xlsx2(Report$survey_dates,
                    file = file.path(input$excel_outdir, "surveydateevents.xlsx"),
                    sheetName = "surveydateevents", col.names = TRUE, row.names = TRUE, append = FALSE
        )
        
        # Extract reactive values
        rec <- rec_table()
        camop <- DCamMat()

        # Save all three to .RData
        tryCatch({
          save(
            rec,
            camop,
            Report,
            file = file.path(input$excel_outdir, "App1_output.RData")
          )
        }, error = function(e) {
          showNotification(paste("❌ Failed to save App1_output.RData:", e$message), type = "error")
        })

        output$report_status <- renderText({ "✅ surveyReport completed, Excel and .RData saved." })
       
      }, error = function(e) {
        output$report_status <- renderText({ paste("❌ Error in surveyReport:", e$message) })
      })
    })
  })
}  # End of server function

# SCRIPT #5: Launch App
shinyApp(ui, server)
  
#shiny::runApp("/home/unixcuon/SharedAssets/wsl2/Rshinny/NPname2025")

shiny::runApp("C:/Users/ACER/ariefb/SharedAssets/wsl2/Rshinny/NPname2025")






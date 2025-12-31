#WRAP 3
# SCRIPT #4: Server Logic
server <- function(input, output, session) {
  
  # Logo block
  output$logo_block <- renderUI({
    tags$div(
      style = "position: absolute; top: 15px; right: 15px; text-align: center; z-index: 1000;",
      tags$div(
        style = "display: flex; align-items: center; justify-content: center;",
        
        # Left logo (wcc.png)
        tags$div(
          style = "margin-right: 10px; text-align: center;",
          tags$img(
            src = "https://www.dropbox.com/scl/fi/g32vlynk4603kpyrngp97/wcc.png?rlkey=q9r0wzwe0n1zjs4ndjpmvembp&st=bd6d3zbv&raw=1",
            style = "height: 60px; opacity: 0.95; display: block; margin: 0 auto;"
          ),
          tags$div("@wcc_ugm", style = "font-size: 7px; color: #444; margin-top: 2px; font-style: italic;")
        ),
        
        # Right logo (dhole2.png.png)
        tags$div(
          style = "margin-left: 10px; text-align: center;",
          tags$img(
            src = "https://www.dropbox.com/scl/fi/5gg3nesh2gcqbcwuxla67/dhole2.png.png?rlkey=g9ni7ezuyzwctaglp69kvfjom&st=ioxx57j2&raw=1",
            style = "height: 60px; opacity: 0.95; display: block; margin: 0 auto;"
          ),
          tags$div("@AB & @SP", style = "font-size: 7px; color: #444; margin-top: 2px; font-style: italic;")
        )
      )
    )
  })
  
  # OS and folder preview
  output$os_info <- renderText({ paste("🖥️ Detected OS:", Sys.info()["sysname"]) })
  output$folder_structure <- renderText({
  paste(
    "📁 Expected folder structure:",
    "npnameyrapp/",
    "├── data/",
    "│   ├── 📷CTmonitoring/CTA",
    "│   ├── 📸CTmonitoring_rename/",
    "│   └── 📗ctTable/CT_TABLE.txt",
    "├── script/",
    "│   ├── launch-v1-0",
    "│   └── launch-v1-1",
    "│       └──⭕RUN-appV1_1.R",
    "├── KEY_APP/",
    "├── KEY_APP2/",
    "├── app.R",
    "├── app2.R",
    "├── 🐓A_LIST_OF_SPECIES-NAME-TAG.txt",
    "└── 📥workdir/",
    "    ├── analysis/  <- App2_output_Folder",
    "    └── 💾App1_output.RData  <- App1_Data_Base",
    sep = "\n"
  )
 })
  
  # Validate paths
  output$indir_status <- renderText({
    path <- input$indir_path
    if (nzchar(path)) {
      full <- normalizePath(path, winslash = "/", mustWork = FALSE)
      if (dir.exists(full)) paste("📂 inDir exists:", full)
      else paste("❌ inDir does not exist:", full)
    } else {
      "ℹ️ inDir not set."
    }
  })
  
  output$outdir_status <- renderText({
    path <- input$outdir_path
    if (nzchar(path)) {
      full <- normalizePath(path, winslash = "/", mustWork = FALSE)
      if (dir.exists(full)) paste("📁 outDir exists:", full)
      else paste("❌ outDir does not exist:", full)
    } else {
      "ℹ️ outDir not set."
    }
  })
  
  output$excel_outdir_status <- renderText({
    path <- input$excel_outdir
    if (nzchar(path)) {
      full <- normalizePath(path, winslash = "/", mustWork = FALSE)
      if (dir.exists(full)) paste("📁 Excel output folder exists:", full)
      else paste("❌ Excel output folder does not exist:", full)
    } else {
      "ℹ️ Excel output folder not set."
    }
  })
  
  # Working directory
  observeEvent(input$set_wd, {
    tryCatch({
      # --- ORIGINAL LINE ---
      setwd(input$wd_path)
      
      # --- NEW IMPROVEMENT START ---
      wd_now <- getwd()
      
      # Define required folders
      indir <- file.path(wd_now, "data", "CTmonitoring")
      outdir <- file.path(wd_now, "data", "CTmonitoring_rename")
      excel_outdir <- file.path(wd_now, "workdir")
      analysis_dir <- file.path(wd_now, "workdir", "analysis")
      
      required_dirs <- c(indir, outdir, excel_outdir, analysis_dir)
      
      # Scan & create
      results <- vapply(required_dirs, function(d) {
        if (!dir.exists(d)) {
          dir.create(d, recursive = TRUE, showWarnings = FALSE)
          paste("✅ Created:", d)
        } else {
          paste("📂 Exists:", d)
        }
      }, FUN.VALUE = character(1))
      
      # Auto-fill UI inputs to keep server/UI in sync
      updateTextInput(session, "indir_path",  value = indir)
      updateTextInput(session, "outdir_path", value = outdir)
      updateTextInput(session, "excel_outdir", value = excel_outdir)
      # (analysis_dir is internal; no input field to update)
      
      # --- NEW IMPROVEMENT END ---
    
      # Report results
      output$wd_confirm <- renderText({ paste("✅ Working directory set to:", getwd()) })
    }, error = function(e) {
      output$wd_confirm <- renderText({ paste("❌ Error:", e$message) })
    })
  })
  
  
  # EXIFTOOL setup with conditional auto-fill
  observeEvent(input$set_exif, {
    if (.Platform$OS.type == "windows") {
      # Default scan in C:/Windows
      default_exif <- file.path("C:/Windows", "exiftool.exe")
      
      if (file.exists(default_exif)) {
        # Configure automatically
        Sys.setenv(PATH = paste(Sys.getenv("PATH"), dirname(default_exif), sep = .Platform$path.sep))
        
        # Auto-fill the UI input only when found
        updateTextInput(session, "exif_path", value = default_exif)
        
        output$exif_status <- renderText({
          paste("✅ EXIFTOOL found and configured at:", default_exif)
        })
      } else {
        # Fall back to user input
        Sys.setenv(PATH = paste(Sys.getenv("PATH"), input$exif_path, sep = .Platform$path.sep))
        found <- Sys.which("exiftool")
        
        output$exif_status <- renderText({
          if (nzchar(found)) {
            # Auto-fill with whatever path was typed
            updateTextInput(session, "exif_path", value = found)
            paste("✅ EXIFTOOL found at:", found)
          } else {
            "❌ EXIFTOOL not found. Please provide the path manually."
          }
        })
      }
      
    } else {
      # Non-Windows fallback
      Sys.setenv(PATH = paste("/usr/bin", Sys.getenv("PATH"), sep = ":"))
      found <- Sys.which("exiftool")
      
      output$exif_status <- renderText({
        if (nzchar(found)) {
          updateTextInput(session, "exif_path", value = found)
          paste("✅ EXIFTOOL found at:", found)
        } else {
          "❌ EXIFTOOL not found. Please install exiftool."
        }
      })
    }
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
        
        imageRename(
          inDir = inDir,
          outDir = outDir,
          hasCameraFolders = FALSE,
          keepCameraSubfolders = FALSE,
          copyImages = TRUE,
          writecsv = FALSE,
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
      
      # --- Verification step ---
      files <- list.files(input$indir_path, recursive = TRUE, full.names = TRUE)
      has_video <- any(grepl("\\.avi$", files, ignore.case = TRUE))
      unsupported <- files[grepl("\\.(mp4|mov)$", files, ignore.case = TRUE)]
      
      # --- Adaptive parameters ---
      camID_mode <- if (has_video) "directory" else "filename"
      inDir_mode <- if (has_video) input$indir_path else input$outdir_path
      
      # --- Inform user ---
      # --- Inform user ---
      if (length(unsupported) > 0) {
        output$record_status <- renderText(
          paste("⚠️ Unsupported formats detected:",
                paste(basename(unsupported), collapse = ", "),
                "Only .avi video and .jpg images will be processed.")
        )
      } else if (has_video) {
        output$record_status <- renderText(
          paste(
            "⚠️ Video files detected.",
            "Using original input folder and directory-based camera IDs.",
            "IMPORTANT: You must re-species name tag all video files in DigiKam BEFORE running recordTable().",
            "Only .avi video and .jpg images are supported."
          )
        )
      } else {
        output$record_status <- renderText(
          "✅ No video files detected. Using renamed output folder and filename-based camera IDs."
        )
      }
      
      # --- Run recordTable ---
      if (has_video) {
        rec <- recordTable(
          inDir = inDir_mode,
          IDfrom = "metadata",
          cameraID = camID_mode,
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
          removeDuplicateRecords = TRUE,
          video = list(
            file_formats = c("jpg", "avi"),
            dateTimeTag = "File:FileModifyDate",
            db_directory = input$digikam_path,
            db_filename = "digikam4.db"
          )
        )
      } else {
        rec <- recordTable(
          inDir = inDir_mode,
          IDfrom = "metadata",
          cameraID = camID_mode,
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
          # no video argument here
        )
      }
      
      rec_table(rec)
      rec_table_final(rec)       # NEW line: freeze snapshot
      
  
     # Save to Excel using openxlsx
      openxlsx::write.xlsx(
        x = rec,
        file = file.path(input$excel_outdir, paste0(input$record_name, ".xlsx")),
        sheetName = input$record_name,
        colNames = TRUE,
        rowNames = TRUE,
        overwrite = TRUE   # replaces append=FALSE
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
      
      # Save to Excel using openxlsx
      openxlsx::write.xlsx(
        x = camop,
        file = file.path(input$excel_outdir, "cameraOPSmatrix.xlsx"),
        sheetName = "camMat",
        col.names = TRUE,
        row.names = TRUE,
        overwrite = TRUE
      )
      
      output$camop_preview <- renderDT({ camop })
      output$camop_status <- renderText({ "✅ cameraOperation completed and saved to Excel." })
    })
  })
  
  # Layer 3: surveyReport
  observeEvent(input$run_report, {
    withProgress(message = "Generating survey report...", value = 0.5, {
      tryCatch({
        req(rec_table_final(), DCamMat(), Dctm())
        
        Report <- surveyReport(
          recordTable = rec_table_final(),
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
        # Save to Excel using openxlsx
        openxlsx::write.xlsx(
          x = Report$species_by_station,
          file = file.path(input$excel_outdir, "stationevents.xlsx"),
          sheetName = "stationevents",
          colNames = TRUE,
          rowNames = TRUE,
          overwrite = TRUE
        )
        
        openxlsx::write.xlsx(
          x = Report$events_by_species,
          file = file.path(input$excel_outdir, "speciesevents.xlsx"),
          sheetName = "speciesevents",
          colNames = TRUE,
          rowNames = TRUE,
          overwrite = TRUE
        )
        
        openxlsx::write.xlsx(
          x = Report$events_by_station2,
          file = file.path(input$excel_outdir, "station2events.xlsx"),
          sheetName = "station2events",
          colNames = TRUE,
          rowNames = TRUE,
          overwrite = TRUE
        )
        
        openxlsx::write.xlsx(
          x = Report$survey_dates,
          file = file.path(input$excel_outdir, "surveydateevents.xlsx"),
          sheetName = "surveydateevents",
          colNames = TRUE,
          rowNames = TRUE,
          overwrite = TRUE
        )

        # Extract reactive values
        rec <- rec_table_final()
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

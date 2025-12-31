# SCRIPT #3: SERVER Definition
#WRAP 3
server <- function(input, output, session) { #START BRACKET
  
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
  
  
  
  # 🖥️ OS and Folder Structure Preview
  output$os_info <- renderText({
    paste("🖥️ Detected OS:", Sys.info()["sysname"])
  })
  
  output$folder_structure <- renderText({
    paste(
      "📁 Expected folder structure:",
      "npnameyrapp/",
      "├── data/",
      "│   ├── 📷 CTmonitoring/CTA",
      "│   ├── 📸 CTmonitoring_rename/",
      "│   └── 📗 ctTable/CT_TABLE.txt",
      "├── script/",
      "│   ├── launch-v1-0",
      "│   └── launch-v1-1",
      "│       └── ⭕RUN-app2V1_1.R",
      "├── KEY_APP/",
      "├── KEY_APP2/",
      "├── app.R",
      "├── app2.R",
      "├── 🐓 A_LIST_OF_SPECIES-NAME-TAG.txt",
      "├── ✅npnameyrapp.Rproj",
      "├── run_occupancy_analysis.R",
      "└── 📥 workdir/",
      "    ├── 📥 analysis/  <- App2_output_Folder",
      "    └── 💾 App1_output.RData  <- App1_Data_Base",
      sep = "\n"
    )
  })
  
  
  # Layer 1: Setup
  observeEvent(input$set_wd, {
    tryCatch({
      setwd(input$wd_path)
      wd <- getwd()
      
      # Define expected paths
      indir <- file.path(wd, "workdir")
      outdir <- file.path(wd, "workdir", "analysis")
      
      # Check existence and auto-fill if empty
      if (dir.exists(indir)) {
        if (input$indir_path == "") {
          updateTextInput(session, "indir_path", value = indir)
        }
      } else {
        showNotification(paste("❌ Input folder not found:", indir), type = "error")
      }
      
      if (dir.exists(outdir)) {
        if (input$outdir_path == "") {
          updateTextInput(session, "outdir_path", value = outdir)
        }
      } else {
        showNotification(paste("❌ Output folder not found:", outdir), type = "error")
      }
      
      # Confirmation message
      output$wd_confirm <- renderText({
        paste("✅ Working directory set to:", wd,
              "\n📂 Input folder:", normalizePath(indir, winslash = "/", mustWork = FALSE),
              "\n📁 Output folder:", normalizePath(outdir, winslash = "/", mustWork = FALSE))
      })
      
    }, error = function(e) {
      output$wd_confirm <- renderText({ paste("❌ Error:", e$message) })
    })
  })
  
  
  # Keep these unchanged
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
  
  
  # Layer : Input Data
  observeEvent(input$load_app1, {
    req(input$app1_rdata)
    tryCatch({
      load(input$app1_rdata$datapath)
      rec_data(rec)
      camop_data(camop)
      report_data(Report)
      Dfsubset(rec[, c("Station_ID", "Species", "Date", "Time", "n_images")])
      
      output$app1_status <- renderText({ "✅ App1_output.RData loaded successfully." })
      
      # Preview species tags
      SPname_TAG <- unique(Dfsubset()$Species)
      output$spname_tag_preview <- renderDT({ data.frame(SPname_TAG = SPname_TAG) })
      
      # Editable species mapping table
      species_map <- data.frame(SPname_TAG = SPname_TAG, Species_input = "", stringsAsFactors = FALSE)
      output$species_input_table <- renderRHandsontable({
        rhandsontable(species_map)
      })
      
      # Preview tables
      output$rec_preview <- renderDT({ head(rec, input$preview_limit) })
      output$camop_preview <- renderDT({ head(camop, input$preview_limit) })
      output$survey_dates_preview <- renderDT({
        if (!is.null(Report$survey_dates)) head(Report$survey_dates, input$preview_limit) else data.frame(Note = "No survey_dates found")
      })
      
    }, error = function(e) {
      output$app1_status <- renderText({ paste("❌ Error loading App1 data:", e$message) })
    })
  })
  
  
  # Layer 5: Update kernel_species dropdown when Dfsubset updates
  observeEvent(Dfsubset(), {
    sp_choices <- sort(unique(Dfsubset()$Species))
    updateSelectInput(session, "kernel_species", choices = sp_choices)    # single species
    updateSelectInput(session, "kernel_species_A", choices = sp_choices)  # species A
    updateSelectInput(session, "kernel_species_B", choices = sp_choices)  # species B
  })
  
  
  # Layer 6: Update occupancy_species dropdown when Dfsubset updates
  observeEvent(Dfsubset(), {
    sp_choices <- sort(unique(Dfsubset()$Species))
    updateSelectInput(session, "occupancy_species", choices = sp_choices)
  })
  
  
  
  
  
  
  # Layer 3: GBIF Tagging
  
  # Define gbif_tagged as a reactiveVal
  gbif_tagged <- reactiveVal()
  
  
  # Helper: load reference file from root working directory
  load_gbif_reference <- function(root_dir) {
    ref_file <- file.path(root_dir, "A_LIST_OF_SPECIES-NAME-TAG.txt")
    if (!file.exists(ref_file)) return(NULL)
    ref <- tryCatch(read.delim(ref_file, header = TRUE, stringsAsFactors = FALSE),
                    error = function(e) NULL)
    if (is.null(ref)) return(NULL)
    if (!all(c("SPtag","ScientificName") %in% names(ref))) return(NULL)
    ref
  }
  
  
  # Layer 3: GBIF Tagging with download card management
  observeEvent(input$run_gbif, {
    req(input$species_input_table)
    
    
    
    # Show processing message
    output$gbif_status <- renderText({ "🔄 Processing GBIF validation..." })
    
    tryCatch({
      species_map <- hot_to_r(input$species_input_table) %>%
        arrange(SPname_TAG)
      
      # Validate input
      if (all(species_map$Species_input == "" | is.na(species_map$Species_input))) {
        
        output$gbif_status <- renderText({ "⚠️ Please enter species names before running GBIF validation." })
        return()
      }
      
      # GBIF processing (your existing code)
      gbif_lookup <- lapply(species_map$Species_input, function(sp) {
        if (sp == "" | is.na(sp)) {
          return(data.frame(
            Species_input = sp,
            GBIFchecked_scientific_name = NA,
            GBIF_family = NA,
            GBIF_match_type = "EMPTY",
            stringsAsFactors = FALSE
          ))
        }
        
        res <- tryCatch(name_backbone(name = sp), error = function(e) NULL)
        sci_name <- if (!is.null(res) && !is.null(res$scientificName)) res$scientificName else NA
        family   <- if (!is.null(res) && !is.null(res$family)) res$family else NA
        match    <- if (!is.null(res) && !is.null(res$matchType)) res$matchType else "NONE"
        
        data.frame(
          Species_input = sp,
          GBIFchecked_scientific_name = sci_name,
          GBIF_family = family,
          GBIF_match_type = match,
          stringsAsFactors = FALSE
        )
      })
      
      gbif_df <- do.call(rbind, gbif_lookup)
      tagged <- species_map %>% left_join(gbif_df, by = "Species_input")
      
      # Store result
      gbif_tagged(tagged)
      
      # Update preview table
      output$gbif_preview <- renderDT({
        datatable(
          tagged,
          options = list(pageLength = 15, scrollX = TRUE),
          rownames = FALSE
        ) %>%
          formatStyle(
            "GBIF_match_type",
            target = "row",
            backgroundColor = styleEqual(
              c("EXACT", "NONE", "FUZZY", "EMPTY"),
              c("#d4edda", "#f8d7da", "#fff3cd", "#f8f9fa")
            )
          )
      })
      
      
      
      output$gbif_status <- renderText({ 
        paste0("✅ GBIF tagging completed. Processed ", nrow(tagged), " species entries.") 
      })
      
    }, error = function(e) {
      
      output$gbif_status <- renderText({ paste0("❌ GBIF processing failed: ", e$message) })
      showNotification(paste("GBIF Error:", e$message), type = "error")
    })
  })
  

  
  # Keep existing species input table observer
  observeEvent(Dfsubset(), {
    req(Dfsubset())
    sp_tags <- sort(unique(Dfsubset()$Species))
    
    if (input$fill_mode == "auto") {
      ref <- load_gbif_reference(input$indir_path)
      if (!is.null(ref)) {
        result <- find_scientific_name(sp_tags, ref)
        species_input_df <- data.frame(
          SPname_TAG    = result$SPnameTAG,
          Species_input = result$ScientificName,
          stringsAsFactors = FALSE
        )
        status_msg <- paste0("✅ Automation applied: matched ",
                             sum(!is.na(species_input_df$Species_input)), " of ",
                             nrow(species_input_df), " tags.")
      } else {
        species_input_df <- data.frame(
          SPname_TAG = sp_tags,
          Species_input = rep("", length(sp_tags))
        )
        status_msg <- "⚠️ Reference file not found. Staying in manual mode."
      }
    } else {
      species_input_df <- data.frame(
        SPname_TAG = sp_tags,
        Species_input = rep("", length(sp_tags))
      )
      status_msg <- "✍️ Manual input mode: please type scientific names."
    }
    
    output$species_input_table <- renderRHandsontable({
      rhandsontable(species_input_df, rowHeaders = NULL) %>%
        hot_col("SPname_TAG", readOnly = TRUE)
    })
    
    output$gbif_fill_status <- renderText({ status_msg })
  })
  
  
  
  observeEvent(input$fill_mode, {
    req(Dfsubset())
    sp_tags <- sort(unique(Dfsubset()$Species))
    
    # Use wd_path because TXT is in the root folder
    ref <- if (input$fill_mode == "auto") load_gbif_reference(input$wd_path) else NULL
    
    if (!is.null(ref)) {
      result <- find_scientific_name(sp_tags, ref)
      species_input_df <- data.frame(
        SPname_TAG    = result$SPnameTAG,
        Species_input = result$ScientificName,
        stringsAsFactors = FALSE
      )
      status_msg <- paste0("✅ Automation applied: matched ",
                           sum(!is.na(species_input_df$Species_input)), " of ",
                           nrow(species_input_df), " tags.")
    } else {
      species_input_df <- data.frame(
        SPname_TAG = sp_tags,
        Species_input = rep("", length(sp_tags)),
        stringsAsFactors = FALSE
      )
      status_msg <- if (input$fill_mode == "auto")
        "⚠️ Reference file not found. Staying in manual mode."
      else
        "✍️ Manual input mode: please type scientific names."
    }
    
    output$species_input_table <- renderRHandsontable({
      rhandsontable(species_input_df, rowHeaders = NULL) %>%
        hot_col("SPname_TAG", readOnly = TRUE)
    })
    
    output$gbif_fill_status <- renderText({ status_msg })
  })
  
  
  
  
  # Add this output to your server (this handles everything automatically)
  output$download_card_content <- renderUI({
    if (is.null(gbif_tagged())) {
      # Waiting state
      div(class = "text-center p-3",
          div(class = "text-muted",
              icon("cloud-arrow-down", style = "font-size: 3em; opacity: 0.3;"),
              h5("Ready to Download", class = "mt-2"),
              p("Run GBIF validation first", class = "small")))
    } else {
      # Success state with download button
      exact_count <- sum(gbif_tagged()$GBIF_match_type == "EXACT", na.rm = TRUE)
      fuzzy_count <- sum(gbif_tagged()$GBIF_match_type == "FUZZY", na.rm = TRUE)
      none_count <- sum(gbif_tagged()$GBIF_match_type == "NONE", na.rm = TRUE)
      
      tagList(
        div(class = "text-center p-3 text-success",
            icon("check-circle", style = "font-size: 2em;"),
            h5("GBIF Validation Complete!", class = "mt-2"),
            p("Results are ready for download", class = "small")),
        
        downloadButton("download_gbif_tagged", 
                       "⬇️ Download GBIF Results", 
                       class = "btn-success w-100 btn-lg"),
        br(), br(),
        div(class = "small text-muted text-center", 
            paste0("Ready: ", nrow(gbif_tagged()), " entries (", 
                   exact_count, " exact, ", fuzzy_count, " fuzzy, ", none_count, " no match)"))
      )
    }
  })
  
  
  
  # Keep existing download handler
  output$download_gbif_tagged <- downloadHandler(
    filename = function() {
      paste0("GBIFchecked_SP_tag_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".xlsx")
    },
    content = function(file) {
      req(gbif_tagged())
      
      tryCatch({
        # Write to Shiny temp file for browser download
        openxlsx::write.xlsx(gbif_tagged(), file, overwrite = TRUE)
        
        # ALSO save a copy into analysis folder
        outDir <- normalizePath(input$outdir_path, winslash = "/", mustWork = FALSE)
        if (!dir.exists(outDir)) dir.create(outDir, recursive = TRUE)
        outFile <- file.path(outDir, basename(file))
        file.copy(file, outFile, overwrite = TRUE)
        
        message("✅ GBIF-tagged table saved to: ", outFile)
        showNotification("File saved successfully!", type = "success")
      }, error = function(e) {
        message("⚠️ Failed to save GBIF-tagged table: ", e$message)
        showNotification(paste("Save error:", e$message), type = "error")
      })
    }
  )
  
  
  
  # Layer 4: RAI Analysis
  observeEvent(input$run_rai, {
    req(Dfsubset())
    
    species_counts <- as.data.frame(table(Dfsubset()$Species))
    colnames(species_counts) <- c("Species", "n_events")
    
    species_events_tbl <- species_counts %>%
      mutate(
        total_events = sum(n_events),
        RAI = round(n_events / total_events, 3)
      ) %>%
      select(Species, n_events, RAI) %>%
      arrange(desc(RAI))  # ✅ Sort by RAI descending
    
    species_events(species_events_tbl)
    
    # ✅ Normalize outDir path
    outDir <- normalizePath(input$outdir_path, winslash = "/", mustWork = FALSE)
    outFile <- file.path(outDir, "species_events_RAI.xlsx")
    
    # ✅ Save with confirmation
    tryCatch({
      openxlsx::write.xlsx(species_events_tbl, outFile, overwrite = TRUE)
      export_msg <- paste("✅ RAI analysis completed and saved to:", outFile)
    }, error = function(e) {
      export_msg <- paste("⚠️ RAI analysis completed but failed to save:", e$message)
    })
    
    output$rai_preview <- renderDT({
      datatable(
        species_events_tbl,
        options = list(pageLength = 15, scrollX = TRUE),
        rownames = FALSE
      )
    })
    
    output$rai_status <- renderText({ export_msg })
  })
  
  
  
  
  
  # Layer 5: Kernel Density Plot
  #Define the plotting function outside observers so both can access it
  # ---- 📦 Global reactive storage ----
  kernel_data <- reactiveValues(
    plot_data = NULL,
    create_plot = NULL,
    output_pdf = NULL,
    output_tif = NULL
  )
  
  
  
  
  # ---- Modular plotting function ----
  
  makeKernelPlot <- function(data) {
    par(pty = "s")
    par(cex = 1.2, mar = c(4, 4, 2, 0), xpd = TRUE)
    
    
    if (data$mode == "Single Species") {
      # Compute density first (no plot)
      d <- densityPlot(data$rad,
                       xscale = 24,
                       xcenter = data$center_valid,
                       plot = FALSE,
                       n.grid = 100)
      
      # Define axis ticks and labels
      if (data$center_valid == "midnight") {
        xlim <- c(-12, 12)
        xat <- seq(-12, 12, 3)
        xlabels <- c("Noon", "15:00", "18:00", "21:00", "Midnight", "03:00", "06:00", "09:00", "Noon")
      } else {
        xlim <- c(0, 24)
        xat <- seq(0, 24, 3)
        xlabels <- c("Midnight", "03:00", "06:00", "09:00", "Noon", "15:00", "18:00", "21:00", "Midnight")
      }
      
      # Open a controlled canvas
      plot(NULL,
           xlim = xlim,
           ylim = c(0, max(d$y) * 1.1),
           xlab = "Time of Day (hours)",
           ylab = "Kernel Density",
           main = paste(data$selected_sp, "Activity Pattern"),
           axes = FALSE, bty = "n")
      
      # Add daylight shading blocks
      if (data$center_valid == "midnight") {
        rect(-6, 0, 6, max(d$y) * 1.1, col = adjustcolor("gray90", alpha.f = 0.8), border = NA)
      } else {
        rect(6, 0, 18, max(d$y) * 1.1, col = adjustcolor("gray90", alpha.f = 0.8), border = NA)
      }
      
      # Add axes and box
      axis(1, at = xat, labels = xlabels, cex.axis = 0.9)
      axis(2, las = 1)
      box(bty = "l")
      
      # Overlay the density curve
      densityPlot(data$rad,
                  xscale = 24,
                  xcenter = data$center_valid,
                  add = TRUE,
                  rug = TRUE,
                  col = "darkgreen",
                  n.grid = 100,
                  lwd = 2)
      
      # Add sunrise/sunset reference lines
      abline(v = c(5.5, 18 + 47/60), lty = 3)
      
      
      
    } else if (data$mode == "Two Species") {
      if (length(data$radA) < 2 || length(data$radB) < 2) {
        plot.new()
        text(0.5, 0.5, "One or both species have <2 detections", cex = 1.5)
        return()
      }
      
      dA <- densityPlot(data$radA, xscale = 24, xcenter = data$center_valid, plot = FALSE, adjust = 1.5)
      dB <- densityPlot(data$radB, xscale = 24, xcenter = data$center_valid, plot = FALSE, adjust = 1.5)
      max_density <- max(c(dA$y, dB$y))
      
      if (data$center_valid == "midnight") {
        xlim <- c(-12, 12)
        xat <- seq(-12, 12, 3)
        xlabels <- c("Noon","15:00","18:00","21:00","Midnight","03:00","06:00","09:00","Noon")
        daylight_start <- -6; daylight_end <- 6
      } else {
        xlim <- c(0, 24)
        xat <- seq(0, 24, 3)
        xlabels <- c("Midnight","03:00","06:00","09:00","Noon","15:00","18:00","21:00","Midnight")
        daylight_start <- 6; daylight_end <- 18
      }
      
      plot(NULL, xlim = xlim, ylim = c(0, max_density * 1.1),
           xlab = "Time of Day (hours)", ylab = "Kernel Density",
           main = paste("Activity Patterns:", data$spA, "vs", data$spB),
           axes = FALSE, bty = "n")
      
      rect(daylight_start, 0, daylight_end, max_density * 1.1,
           col = adjustcolor("gray90", alpha.f = 0.8), border = NA)
      
      axis(1, at = xat, labels = xlabels, cex.axis = 0.9)
      axis(2, las = 1); box(bty = "l")
      
      densityPlot(data$radA, xscale = 24, xcenter = data$center_valid, add = TRUE, col = "blue", lwd = 2, adjust = 1.5)
      densityPlot(data$radB, xscale = 24, xcenter = data$center_valid, add = TRUE, col = "red", lwd = 2, adjust = 1.5)
      
      legend("topright",
             legend = c(paste(data$spA, "(RAI =", formatC(data$RAI_A, digits = 3), ")"),
                        paste(data$spB, "(RAI =", formatC(data$RAI_B, digits = 3), ")")),
             col = c("blue","red"), lwd = 2, cex = 0.8, bty = "n")
      
      
      
      
      
    } else {
      if (data$no_species) {
        plot.new()
        text(0.5, 0.5, "No species with ≥2 events available", cex = 1.5)
        return()
      }
      
      # ✅ Filter species with valid data
      valid_species <- vector()
      valid_rad_data <- list()
      for (sp in data$species_list) {
        sp_rad <- data$species_rad_data[[sp]]
        if (!is.null(sp_rad) && length(sp_rad) >= 2) {
          valid_species <- c(valid_species, sp)
          valid_rad_data[[sp]] <- sp_rad
        }
      }
      
      if (length(valid_species) == 0) {
        plot.new()
        text(0.5, 0.5, "No species with ≥2 valid detections", cex = 1.5)
        return()
      }
      
      # ✅ Rebuild palette and RAI values
      base_colors <- RColorBrewer::brewer.pal(8, "Set2")
      palette_colors <- if (length(valid_species) > 8) {
        colorRampPalette(base_colors)(length(valid_species))
      } else {
        base_colors[1:length(valid_species)]
      }
      RAI_values <- data$RAI_values[match(valid_species, data$species_list)]
      
      # ✅ Recompute max density
      max_density <- 0
      for (sp in valid_species) {
        d <- densityPlot(valid_rad_data[[sp]], xscale = 24, xcenter = data$center_valid, plot = FALSE, adjust = 1.5)
        max_density <- max(max_density, max(d$y))
      }
      
      plot(NULL,
           xlim = if (data$center == "Midnight") c(-12, 12) else c(0, 24),
           ylim = c(0, max_density * 1.1),
           xlab = paste("Time of Day (centered at", data$center, ")"),
           ylab = "Kernel Density",
           main = paste("Activity Patterns Centered at", data$center),
           axes = FALSE, bty = "n")
      
      axis(1,
           at = if (data$center == "Midnight") seq(-12, 12, 3) else seq(0, 24, 3),
           labels = if (data$center == "Midnight")
             c("Noon", "15:00", "18:00", "21:00", "Midnight", "03:00", "06:00", "09:00", "Noon")
           else
             c("Midnight", "03:00", "06:00", "09:00", "Noon", "15:00", "18:00", "21:00", "Midnight"),
           cex.axis = 0.9)
      axis(2, las = 1)
      box(bty = "l")
      
      for (i in seq_along(valid_species)) {
        sp <- valid_species[i]
        densityPlot(valid_rad_data[[sp]],
                    xscale = 24,
                    xcenter = data$center_valid,
                    add = TRUE,
                    col = palette_colors[i],
                    lwd = 2,
                    adjust = 1.5)
      }
      
      legend("topright",
             legend = paste0(valid_species, " (RAI=", formatC(RAI_values, digits = 3), ")"),
             col = palette_colors,
             lwd = 2,
             cex = 0.8,
             bty = "n")
    }
  }
  
  
  
  
  
  # ---- 🎛️ Kernel preview trigger ----
  observeEvent(input$run_kernel, {
    req(Dfsubset(), species_events())
    
    df <- Dfsubset()
    mode <- input$kernel_mode
    center <- input$kernel_center
    center_valid <- if (center == "Daylight") "noon" else "midnight"
    selected_sp <- input$kernel_species
    timestamp <- format(Sys.time(), "%Y%m%d-%H%M")
    
    filename_base <- paste(
      if (mode == "Single Species") "singleSP" else "allSP",
      center_valid,
      if (mode == "Single Species") selected_sp else NULL,
      timestamp,
      sep = "-"
    )
    
    kernel_data$output_pdf <- file.path("workdir/analysis", paste0(filename_base, ".pdf"))
    kernel_data$output_tif <- file.path("workdir/analysis", paste0(filename_base, ".tif"))
    dir.create("workdir/analysis", recursive = TRUE, showWarnings = FALSE)
    
    if (!"timeDec" %in% colnames(df)) {
      df$timeDec <- with(df, (hour(hms(Time)) * 3600 + minute(hms(Time)) * 60 + second(hms(Time))) / (24 * 3600))
    }
    if (!"timeRAD" %in% colnames(df)) {
      df$timeRAD <- df$timeDec * 2 * pi
    }
    
    if (mode == "Single Species") {
      rad <- df$timeRAD[df$Species == selected_sp]
      rad <- rad[!is.na(rad)]
      kernel_data$plot_data <- list(
        mode = mode,
        center = center,
        center_valid = center_valid,
        selected_sp = selected_sp,
        rad = rad
      )
      
      
    } else if (mode == "Two Species") {
      spA <- input$kernel_species_A
      spB <- input$kernel_species_B
      
      radA <- df$timeRAD[df$Species == spA]
      radA <- radA[!is.na(radA)]
      radB <- df$timeRAD[df$Species == spB]
      radB <- radB[!is.na(radB)]
      
      RAI_A <- species_events()$RAI[species_events()$Species == spA]
      RAI_B <- species_events()$RAI[species_events()$Species == spB]
      
      kernel_data$plot_data <- list(
        mode = mode,
        center = center,
        center_valid = center_valid,
        spA = spA,
        spB = spB,
        radA = radA,
        radB = radB,
        RAI_A = RAI_A,
        RAI_B = RAI_B
      )
      
      
    } else {  # ---- All Species branch ----

     # Defensive builder for species_info
      se <- isolate(species_events())
      if (is.null(se) || !all(c("Species","n_events") %in% names(se))) {
        # fallback: compute directly from df
        species_info <- df %>%
          dplyr::filter(!is.na(Species)) %>%
          dplyr::group_by(Species) %>%
          dplyr::summarise(n_events = dplyr::n(), .groups = "drop") %>%
          dplyr::filter(n_events >= 2) %>%
          dplyr::mutate(RAI = NA_real_)
      } else {
        species_info <- se %>% dplyr::filter(n_events >= 2)
      }
      
      if (nrow(species_info) == 0) {
        kernel_data$plot_data <- list(
          mode = mode,
          center = center,
          center_valid = center_valid,
          no_species = TRUE
        )
        
      
      } else {
        species_list <- species_info$Species
        RAI_values <- species_info$RAI
        palette_colors <- RColorBrewer::brewer.pal(min(length(species_list), 8), "Set2")
        if (length(species_list) > 8) {
          palette_colors <- colorRampPalette(palette_colors)(length(species_list))
        }
        
        max_density <- 0
        species_rad_data <- list()
        for (sp in species_list) {
          sp_rad <- df$timeRAD[df$Species == sp]
          sp_rad <- sp_rad[!is.na(sp_rad)]
          species_rad_data[[sp]] <- sp_rad
          if (length(sp_rad) >= 2) {
            d <- densityPlot(sp_rad, xscale = 24, xcenter = center_valid, plot = FALSE, adjust = 1.5)
            max_density <- max(max_density, max(d$y))
          }
        }
        
        kernel_data$plot_data <- list(
          mode = mode,
          center = center,
          center_valid = center_valid,
          species_list = species_list,
          RAI_values = RAI_values,
          palette_colors = palette_colors,
          max_density = max_density,
          species_rad_data = species_rad_data,
          no_species = FALSE
        )
      }
    }
    
    # ✅ Freeze the exact plot data and function for saving
    kernel_data$create_plot_for_save <- function() {
      makeKernelPlot(kernel_data$plot_data)
    }
    
    output$kernel_preview <- renderPlot({
      makeKernelPlot(kernel_data$plot_data)
    })
    
    
    output$kernel_status <- renderText({
      if (mode == "Single Species") {
        paste("✅ Kernel plot generated for:", selected_sp)
      
      } else if (mode == "Two Species") {
        paste("✅ Kernel plot generated for:", input$kernel_species_A, "and", input$kernel_species_B)
        
      } else if (kernel_data$plot_data$no_species) {
        "⚠️ No species with ≥2 events available for kernel plot."
      } else {
        "✅ Kernel plot generated for all species."
      }
    })
    
    
    # In server, add this download handler
    output$download_kernel_plot <- downloadHandler(
      
      filename = function() {
        mode_raw <- kernel_data$plot_data$mode
        mode <- if (mode_raw == "Single Species") "singleSP" else if (mode_raw == "Two Species") "twoSP" else "allSP"
        center <- if (kernel_data$plot_data$center == "Daylight") "noon" else "midnight"
        
        sp_name <- if (mode == "singleSP") {
          kernel_data$plot_data$selected_sp
        } else if (mode == "twoSP") {
          paste0(kernel_data$plot_data$spA, "_vs_", kernel_data$plot_data$spB)
        } else {
          ""
        }
        
        timestamp <- format(Sys.time(), "%Y%m%d-%H%M")
        paste0(mode, "-", center, "-", sp_name, "-", timestamp, ".png")
      },
      content = function(file) {
        png(file, width = 2400, height = 1800, res = 300)
        makeKernelPlot(kernel_data$plot_data)
        
        dev.off()
      }
    )
    
    
  })
  
  
  
  
  # ---- 💾 Save kernel plot ----
  observeEvent(input$save_kernel, {
    req(!is.null(kernel_data$create_plot_for_save()), !is.null(kernel_data$output_pdf), !is.null(kernel_data$output_tif))
    
    tryCatch({
      output$kernel_status <- renderText({ "⏳ Saving kernel plot to PDF and TIFF..." })
      
      dir.create(dirname(kernel_data$output_pdf), recursive = TRUE, showWarnings = FALSE)
      
      pdf(kernel_data$output_pdf, width = 11, height = 7)
      kernel_data$create_plot_for_save()  # ✅ Use frozen plot
      dev.off()
      
      if (file.exists(kernel_data$output_pdf) && file.info(kernel_data$output_pdf)$size > 0) {
        library(magick)
        img <- image_read_pdf(kernel_data$output_pdf, density = 600)
        image_write(img, path = kernel_data$output_tif, format = "tiff", density = 600)
        
        output$kernel_status <- renderText({
          paste0("✅ Plot saved successfully!\n",
                 "- PDF: ", normalizePath(kernel_data$output_pdf), "\n",
                 "- TIFF: ", normalizePath(kernel_data$output_tif), "\n",
                 "📊 File sizes: PDF = ", round(file.info(kernel_data$output_pdf)$size / 1024, 1), " KB, ",
                 "TIFF = ", round(file.info(kernel_data$output_tif)$size / 1024, 1), " KB")
        })
      } else {
        output$kernel_status <- renderText({ "❌ Failed to create PDF file. Please try again." })
      }
      
    }, error = function(e) {
      output$kernel_status <- renderText({ paste("❌ Error saving plot:", e$message) })
    })
  })
  
  
  
  observeEvent(input$download_kernel_plot, {
    output$download_status <- renderText({
      paste0("✅ Download initiated for kernel plot:\n",
             "• Mode: ", if (kernel_data$plot_data$mode == "Single Species") {
               paste("Single Species —", kernel_data$plot_data$selected_sp)
             } else {
               "All Species"
             }, "\n",
             "• Centered at: ", kernel_data$plot_data$center, "\n",
             "• Resolution: 2400×1800 px, 300 DPI\n",
             "• Format: PNG\n",
             "🕒 Timestamp: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
    })
  })
  
  
  
  
  
  # Layer 6: Occupancy Modeling
  # Reactive values to store summaries
  occupancy_summary <- reactiveVal()
  summary_table_all_species <- reactiveVal()
  
  # Reactive value to store AIC table
  aic_table_preview <- reactiveVal()
  
  round_df <- function(df, digits = 5) {
    df[] <- lapply(df, function(x) {
      if (is.numeric(x)) round(x, digits) else x
    })
    df
  }
  
  observeEvent(input$run_occupancy, {
    req(rec_data(), camop_data(), report_data())
    
    mode <- input$occupancy_mode
    selected_sp <- input$occupancy_species
    all_sp <- sort(unique(Dfsubset()$Species))
    all_summaries <- list()
    all_aics <- list()
    
    if (mode == "Single Species") {
      res <- run_occupancy_analysis(selected_sp, rec_data(), camop_data(), report_data())
      occupancy_summary(round_df (res$summary_table, 5))
      aic_table_preview(round_df (res$aic_table, 5))
      
      output$occupancy_summary <- renderDT({ res$summary_table })
      output$aic_table_preview <- renderDT({ res$aic_table })
      output$occupancy_status <- renderText({ paste("✅ Occupancy model completed for:", selected_sp) })
      
    } else {
      for (sp in all_sp) {
        res <- run_occupancy_analysis(sp, rec_data(), camop_data(), report_data())
        all_summaries[[sp]] <- round_df (res$summary_table, 5)
        all_aics[[sp]] <- cbind(Species = sp, round_df (res$aic_table, 5))
      }
      combined_summary <- do.call(rbind, all_summaries)
      combined_aic <- do.call(rbind, all_aics)
      
      summary_table_all_species(combined_summary)
      aic_table_preview(combined_aic)
      
      output$occupancy_summary <- renderDT({ combined_summary })
      output$aic_table_preview <- renderDT({ combined_aic })
      output$occupancy_status <- renderText({ "✅ Occupancy models completed for all species." })
    }
  })
  
  
  
  
  
  # Layer 6: Download handler
  
  output$download_occupancy_summary <- downloadHandler(
    filename = function() {
      ext <- if (input$download_format == "xlsx") ".xlsx" else ".csv"
      if (input$occupancy_mode == "Single Species") {
        paste0("occupancy_summary_", input$occupancy_species, ext)
      } else {
        paste0("occupancy_summary_all_species", ext)
      }
    },
    content = function(file) {
      if (input$download_format == "xlsx") {
        # Create workbook with openxlsx
        wb <- openxlsx::createWorkbook()
        
        if (input$occupancy_mode == "Single Species") {
          openxlsx::addWorksheet(wb, "Summary")
          openxlsx::addWorksheet(wb, "AIC Table")
          openxlsx::writeData(wb, "Summary", occupancy_summary())
          openxlsx::writeData(wb, "AIC Table", aic_table_preview())
        } else {
          openxlsx::addWorksheet(wb, "All Species Summary")
          openxlsx::addWorksheet(wb, "All Species AIC")
          openxlsx::writeData(wb, "All Species Summary", summary_table_all_species())
          openxlsx::writeData(wb, "All Species AIC", aic_table_preview())
        }
        
        # Save workbook
        openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
        
      } else {
        # CSV fallback
        if (input$occupancy_mode == "Single Species") {
          write.csv(occupancy_summary(), file, row.names = FALSE)
        } else {
          write.csv(summary_table_all_species(), file, row.names = FALSE)
        }
      }
    }
  )
    
  
  
  
  
    
    # ---- Layer 7: Update overlap_species dropdown when Dfsubset updates ----
    observeEvent(Dfsubset(), {
      sp_choices <- sort(unique(Dfsubset()$Species))
      updateSelectInput(session, "overlap_species_A", choices = sp_choices)
      updateSelectInput(session, "overlap_species_B", choices = sp_choices)
    })
    
    # ---- 🎛️ Overlap estimation trigger ----
  observeEvent(input$run_overlap, {
    req(Dfsubset())
    
    df <- Dfsubset()
    
    # Ensure timeDec and timeRAD exist (same as Layer 5)
    if (!"timeDec" %in% colnames(df)) {
      df$timeDec <- with(df, (hour(hms(Time)) * 3600 +
                                minute(hms(Time)) * 60 +
                                second(hms(Time))) / (24 * 3600))
    }
    if (!"timeRAD" %in% colnames(df)) {
      df$timeRAD <- df$timeDec * 2 * pi
    }
    
    spA <- input$overlap_species_A
    spB <- input$overlap_species_B
    
    radA <- df$timeRAD[df$Species == spA]; radA <- radA[!is.na(radA)]
    radB <- df$timeRAD[df$Species == spB]; radB <- radB[!is.na(radB)]
    
    # ✅ Validation using species_events (like Layer 5)
    sp_info <- isolate(species_events())
    nA <- sp_info$n_events[sp_info$Species == spA]
    nB <- sp_info$n_events[sp_info$Species == spB]
    
    if (is.null(nA) || is.null(nB) || nA < 2 || nB < 2) {
      output$overlap_status <- renderText({
        paste("⚠️ Estimation failed: One or both species have fewer than 2 valid detections.",
              "\n• Species A:", spA, "(events:", nA, ")",
              "\n• Species B:", spB, "(events:", nB, ")")
      })
      return()

      }
      
      # ✅ Estimator choice
      est_type <- if (min(length(radA), length(radB)) < 50) "Dhat1" else "Dhat4"
      adjust_val <- if (est_type == "Dhat1") 0.8 else 1
      
      # ✅ Point estimate
      coeff <- overlapEst(radA, radB, kmax = 3, n.grid = 128, type = est_type)
      
      # ✅ Bootstrap
      spA_sim <- resample(radA, input$overlap_bootstrap)
      spB_sim <- resample(radB, input$overlap_bootstrap)
      spABboots <- bootEst(spA_sim, spB_sim, adjust = adjust_val)
      
      # ✅ CI extraction
      tmp <- spABboots[, 1]
      ci_raw <- bootCI(coeff[1], tmp)
      ci_logit <- bootCIlogit(coeff[1], tmp)
      
      # ✅ Preferred CI (basic0/logit basic0)
      ci_lower <- round(ci_logit["basic0","lower"], 3)
      ci_upper <- round(ci_logit["basic0","upper"], 3)
      
      # ✅ Save results in reactive storage
      overlap_data$est_data <- list(est_type = est_type, coeff = coeff[1])
      overlap_data$ci_table <- data.frame(
        Method = c("perc","basic0","norm0","logit basic0","logit norm0"),
        Lower = c(ci_raw["perc","lower"], ci_raw["basic0","lower"], ci_raw["norm0","lower"],
                  ci_logit["basic0","lower"], ci_logit["norm0","lower"]),
        Upper = c(ci_raw["perc","upper"], ci_raw["basic0","upper"], ci_raw["norm0","upper"],
                  ci_logit["basic0","upper"], ci_logit["norm0","upper"])
      )
      
      
      
      # ---- 🔧 Step 1 Refinement: Freeze the plot ----
      overlap_data$plot_data <- list(
        spA = spA,
        spB = spB,
        radA = radA,
        radB = radB,
        est_type = est_type,
        coeff = coeff[1],
        ci_lower = ci_lower,
        ci_upper = ci_upper,
        adjust_val = adjust_val,
        center_valid = if (input$overlap_center == "Daylight") "noon" else "midnight"
      )
      
      overlap_data$create_plot_for_save <- function() {
        pd <- overlap_data$plot_data
    
        # ---- Full renderPlot logic ----
        par(pty = "s")
        par(cex = 1.2, mar = c(4, 4, 2, 0), xpd = TRUE)
        
        dA <- densityPlot(pd$radA, xscale = 24, xcenter = pd$center_valid, plot = FALSE, n.grid = 100)
        dB <- densityPlot(pd$radB, xscale = 24, xcenter = pd$center_valid, plot = FALSE, n.grid = 100)
        max_density <- max(c(dA$y, dB$y))
        
        if (pd$center_valid == "midnight") {
          xlim <- c(-12, 12)
          xat <- seq(-12, 12, 3)
          xlabels <- c("Noon","15:00","18:00","21:00","Midnight","03:00","06:00","09:00","Noon")
        } else {
          xlim <- c(0, 24)
          xat <- seq(0, 24, 3)
          xlabels <- c("Midnight","03:00","06:00","09:00","Noon","15:00","18:00","21:00","Midnight")
        }
        
        plot(NULL, xlim = xlim, ylim = c(0, max_density * 1.1),
             xlab = "Time of Day (hours)", ylab = "Kernel Density",
             main = paste("Overlap of:", pd$spA, "vs", pd$spB),
             axes = FALSE, bty = "n")
        axis(1, at = xat, labels = xlabels, cex.axis = 0.9)
        axis(2, las = 1)
        box(bty = "l")
        
        overlap_x <- dA$x
        overlap_y <- pmin(dA$y, dB$y)
        polygon(c(overlap_x, rev(overlap_x)),
                c(overlap_y, rep(0, length(overlap_y))),
                col = adjustcolor("gray70", alpha.f = 0.6), border = NA)
        
        densityPlot(pd$radA, xscale = 24, xcenter = pd$center_valid,
                    add = TRUE, rug = TRUE, col = "blue", lwd = 2, n.grid = 100)
        densityPlot(pd$radB, xscale = 24, xcenter = pd$center_valid,
                    add = TRUE, rug = TRUE, col = "red", lwd = 2, n.grid = 100)
        
        legend("topright",
               legend = c(pd$spA, pd$spB,
                          bquote(Delta[.(substr(pd$est_type,5,5))] == .(round(pd$coeff,3))),
                          bquote("95% CI: ["*.(pd$ci_lower)*"–"*.(pd$ci_upper)*"]")),
               lty = c(1,1,0,0), col = c("blue","red",NA,NA), bty = "n")
      }
      
        
        
      
      
      # ✅ Outputs
      output$overlap_result <- renderText({
        paste0(est_type, " = ", round(coeff[1], 3),
               " (95% CI: ", ci_lower, "–", ci_upper, ", bias-corrected bootstrap)")
      })
      
      output$overlap_ci_table <- renderDT({ overlap_data$ci_table })
      
      output$overlap_preview <- renderPlot({
        overlap_data$create_plot_for_save()   # ✅ use frozen function
      })
      
      output$overlap_status <- renderText({
        paste("✅ Overlap estimation completed for:", spA, "vs", spB)
      })
  })
  
      
      
  #})
  
  # ---- 💾 Download overlap plot (WYSIWYG) ----
  output$download_overlap_plot <- downloadHandler(
    
    filename = function() {
      spA <- input$overlap_species_A
      spB <- input$overlap_species_B
      est_type <- overlap_data$est_data$est_type
      timestamp <- format(Sys.time(), "%Y%m%d-%H%M")
      paste0("overlap-", est_type, "-", spA, "-", spB, "-", timestamp, ".png")
    },
    
    content = function(file) {
      png(file, width = 2400, height = 1800, res = 300)
      overlap_data$create_plot_for_save()  # ✅ Use frozen plot
      dev.off()
    }
  )
  
  # ---- 💾 Save overlap plot to PDF + TIFF ----
  observeEvent(input$save_overlap_plot, {
    req(!is.null(overlap_data$create_plot_for_save), 
        !is.null(overlap_data$output_pdf), 
        !is.null(overlap_data$output_tif))
    
    tryCatch({
      output$overlap_status <- renderText({ "⏳ Saving overlap plot to PDF and TIFF..." })
      
      dir.create(dirname(overlap_data$output_pdf), recursive = TRUE, showWarnings = FALSE)
      
      pdf(overlap_data$output_pdf, width = 11, height = 7)
      overlap_data$create_plot_for_save()  # ✅ Use frozen plot
      dev.off()
      
      if (file.exists(overlap_data$output_pdf) && file.info(overlap_data$output_pdf)$size > 0) {
        library(magick)
        img <- image_read_pdf(overlap_data$output_pdf, density = 600)
        image_write(img, path = overlap_data$output_tif, format = "tiff", density = 600)
        
        output$overlap_status <- renderText({
          paste0("✅ Plot saved successfully!\n",
                 "- PDF: ", normalizePath(overlap_data$output_pdf), "\n",
                 "- TIFF: ", normalizePath(overlap_data$output_tif), "\n",
                 "📊 File sizes: PDF = ", round(file.info(overlap_data$output_pdf)$size / 1024, 1), " KB, ",
                 "TIFF = ", round(file.info(overlap_data$output_tif)$size / 1024, 1), " KB")
        })
      } else {
        output$overlap_status <- renderText({ "❌ Failed to create PDF file. Please try again." })
      }
      
    }, error = function(e) {
      output$overlap_status <- renderText({ paste("❌ Error saving plot:", e$message) })
    })
  })
  
  # ---- 💬 Status message when download triggered ----
  observeEvent(input$download_overlap_plot, {
    output$overlap_status <- renderText({
      paste0("✅ Download initiated for overlap plot:\n",
             "• Species A: ", input$overlap_species_A, "\n",
             "• Species B: ", input$overlap_species_B, "\n",
             "• Estimator: ", overlap_data$est_data$est_type, "\n",
             "• Resolution: 2400×1800 px, 300 DPI\n",
             "• Format: PNG\n",
             "🕒 Timestamp: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
    })
  })
      
      
  #)
  
} # <--------- END OF SERVER BRACKET


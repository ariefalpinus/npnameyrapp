run_occupancy_analysis <- function (
    species_name,
    rec,
    camop,
    Report,   # add Report explicitly so defaults can be derived
    day1 = format(min(Report$survey_dates$setup), "%Y-%m-%d"),
    max_days = max(Report$survey_dates$n_calendar_days_total), # longest survey window
    tz = Sys.timezone()                                   # system timezone
) {
  # validate timezone
  if (!tz %in% OlsonNames()) {
    stop("Invalid timezone: ", tz,
         ". Please use a valid Olson name (e.g., 'Asia/Jakarta', 'Asia/Bangkok').")
  }
  
  message(paste0("🔍 Running occupancy analysis for: ", species_name))
  
  dhist_obj <- detectionHistory(
    recordTable = rec,
    species = species_name,
    camOp = camop,
    stationCol = "Station_ID",
    speciesCol = "Species",
    recordDateTimeCol = "DateTimeOriginal",
    recordDateTimeFormat = "%Y-%m-%d %H:%M:%S",
    occasionLength = 1,
    day1 = day1,
    maxNumberDays = max_days,
    includeEffort = TRUE,
    scaleEffort = FALSE,
    datesAsOccasionNames = FALSE,
    timeZone = tz,
    writecsv = FALSE
  )
  
  dhist <- as.data.frame(dhist_obj$detection_history)
  unitnames <- gsub("CT", "CT ", rownames(dhist))
  
  pao_data <- createPao(
    dhist,
    unitnames = unitnames,
    paoname = paste0(tolower(species_name), ".pao")
  )
  
  naive_occ <- mean(apply(pao_data$det.data, 1, function(x) any(x == 1, na.rm = TRUE)))
  
  mod1 <- occMod(model = list(psi ~ 1, p ~ SURVEY), data = pao_data, type = "so")
  mod2 <- occMod(model = list(psi ~ 1, p ~ 1), data = pao_data, type = "so")
  
  mod.list <- list(mod1, mod2)
  aic.results <- createAicTable(mod.list, use.aicc = TRUE, chat = 1)
  
  best_mod <- mod2
  psi_df <- as.data.frame(best_mod$real$psi)
  p_df   <- as.data.frame(best_mod$real$p)
  
  psi_df$Unit <- rownames(psi_df)
  p_df$Unit   <- rownames(p_df)
  psi_df$Parameter <- "psi"
  p_df$Parameter   <- "p"
  
  psi_df <- psi_df[, c("Parameter", "Unit", "est", "se", "lower_0.95", "upper_0.95")]
  p_df   <- p_df[, c("Parameter", "Unit", "est", "se", "lower_0.95", "upper_0.95")]
  
  result_table <- rbind(psi_df, p_df)
  
  psi_summary <- data.frame(
    Species = species_name,
    Parameter = "Occupancy (ψ)",
    Mean_Estimate = mean(psi_df$est),
    Mean_SE = mean(psi_df$se),
    Mean_Lower_CI = mean(psi_df$lower_0.95),
    Mean_Upper_CI = mean(psi_df$upper_0.95),
    Naive_Occupancy = naive_occ
  )
  
  p_summary <- data.frame(
    Species = species_name,
    Parameter = "Detection Probability (p)",
    Mean_Estimate = mean(p_df$est),
    Mean_SE = mean(p_df$se),
    Mean_Lower_CI = mean(p_df$lower_0.95),
    Mean_Upper_CI = mean(p_df$upper_0.95),
    Naive_Occupancy = NA
  )
  
  summary_table <- rbind(psi_summary, p_summary)
  
  return(list(
    species = species_name,
    naive_occupancy = naive_occ,
    aic_table = aic.results$table,
    result_table = result_table,
    summary_table = summary_table
  ))
  
} #<<15_11


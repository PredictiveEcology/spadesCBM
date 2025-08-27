
# Set project path
projectPath <- "~/GitHub/spadesCBM"

# Install SpaDES.project
if (tryCatch(packageVersion("SpaDES.project") < "0.1.1", error = function(x) TRUE)){
  install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")
}

# Set simulation time span
times <- list(start = 1985, end = 2011) ## Needs updating

# Set available project types
projectChoices <- expand.grid(
  studyArea     = c("small", "managedForests", "full"),
  ageSource     = c("CASFRI-2012", "SCANFI-2020", "KNN-2001", "KNN-2020"),
  speciesSource = c("CASFRI"),
  distSource    = c(NA, "NTEMS") # NA is no disturbances
)
projectChoices <- cbind(projectName = apply(projectChoices, 1, function(row){
  with(as.list(row), paste(c(
    paste0("SK-",   studyArea),
    paste0("age-",  ageSource),
    paste0("sp-",   speciesSource),
    paste0("dist-", distSource)
  ), collapse = "_"))
}), projectChoices)

# Choose project based on user selection of data sources
if (!exists(".studyArea"))      .studyArea     <- "small"
if (!exists(".ageSource"))      .ageSource     <- "CASFRI-2012"
if (!exists(".speciesSource"))  .speciesSource <- "CASFRI"
if (!exists(".distSource"))     .distSource    <- "NTEMS"
projectParams <- as.list(subset(
  projectChoices, studyArea %in% .studyArea &
    ageSource %in% .ageSource & speciesSource %in% .speciesSource &
    distSource %in% .distSource
))
projectParams <- projectParams[!sapply(projectParams, is.na)]
projectParams$ageSource <- strsplit(as.character(projectParams$ageSource), "-")[[1]]
projectParams$ageSource[[2]] <- as.numeric(projectParams$ageSource[[2]])

# Set up project
simSetup <- SpaDES.project::setupProject(

  # Clone and open RStudio project
  useGit  = "PredictiveEcology",
  Restart = getOption("SpaDES.project.Restart", TRUE),

  # Set options
  options = list(
    Require.cloneFrom       = Sys.getenv("R_LIBS_USER"),
    reproducible.useMemoise = TRUE,
    spades.moduleCodeChecks = FALSE
  ),

  # Set project paths
  paths   = list(
    projectPath = projectPath,
    modulePath  = file.path(projectPath, "modules"),
    inputPath   = getOption("SpaDES.project.inputs", file.path(projectPath, "inputs")),
    packagePath = file.path(projectPath, "packages"),
    cachePath   = file.path(projectPath, "cache"),
    outputPath  = file.path(projectPath, "outputs", projectParams$projectName)
  ),

  # Set modules and simulation time span
  times   = times,
  modules = c(
    CBM_defaults       = "PredictiveEcology/CBM_defaults@development",
    CBM_dataPrep_SK    = "PredictiveEcology/CBM_dataPrep_SK@development",
    CBM_dataPrep       = "PredictiveEcology/CBM_dataPrep@development",
    CBM_vol2biomass_SK = "PredictiveEcology/CBM_vol2biomass_SK@development",
    CBM_core           = "PredictiveEcology/CBM_core@development"
  ),
  overwrite = TRUE, # Use current versions of modules

  # Set parameters
  params = list(
    CBM_dataPrep = list(
      saveRasters = TRUE # Save result of input alignment to masterRaster for review
    ),
    CBM_core = list(
      .plot = FALSE # Temporary
    )
  ),

  # Set packages required for project set up
  require = c("terra", "PredictiveEcology/LandR@development"),

  # Set input: CBM_core save outputs table (temporary)
  outputs = as.data.frame(expand.grid(
    objectName = c("cbmPools", "NPP"),
    saveTime = sort(c(times$start, times$start + c(1:(times$end - times$start))))
  ))
)

## Would be better to set all of this within setupProject()..

# Set study area
if (projectParams$studyArea == "small"){
  simSetup$masterRaster <- terra::rast(
    crs  = "EPSG:3979",
    ext  = c(xmin = -687696, xmax = -681036, ymin = 711955, ymax = 716183),
    res  = 30,
    vals = 1L
  )
}
if (projectParams$studyArea == "managedForests"){
  simSetup$masterRaster <- terra::rast(
    crs  = "EPSG:3979",
    ext  = c(xmin = -710000, xmax = -640000, ymin = 690000, ymax = 760000),
    res  = 50,
    vals = 1L
  )
}

# Set cohort age data source
if (projectParams$ageSource[[1]] %in% c("SCANFI", "KNN")){

  simSetup$ageDataYear <- projectParams$ageSource[[2]]
  simSetup$ageLocator  <- LandR::prepInputsStandAgeMap(
    dataSource = projectParams$ageSource[[1]],
    dataYear   = projectParams$ageSource[[2]]
  )
}

# Set cohort species data source
if (projectParams$speciesSource %in% c("SCANFI")){

  ## CASFRI is the default
  ## Jonathan is working on a LandR function to read in species from SCANFI etc
}

# Set disturbances source
disturbanceSource <- projectParams$disturbanceSource

# Run simulation
simCBM <- SpaDES.core::simInit2(simSetup[!sapply(simSetup, is.null)])
simCBM <- SpaDES.core::spades(simCBM)




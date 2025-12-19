projectPath <- "~/GitHub/spadesCBM"
repos <- unique(c("predictiveecology.r-universe.dev", getOption("repos")))
install.packages("SpaDES.project", repos = repos)

# Set times
times <- list(start = 1985, end = 2020)

# Set up project
projSetup <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = "PredictiveEcology", # a developer sets and keeps this = TRUE
  overwrite = TRUE, # a user who wants to get latest modules sets this to TRUE
  paths = list(projectPath = projectPath,
               outputPath  = file.path(projectPath, "outputs", "SK-30m-SCANFI"),
               modulePath  = file.path(projectPath, "modules"),
               packagePath = file.path(projectPath, "packages"),
               inputPath   = file.path(projectPath, "inputs"),
               cachePath   = file.path(projectPath, "cache")),

  options = options(
    repos = c(repos = repos),
    Require.cloneFrom = Sys.getenv("R_LIBS_USER"),
    ## These are for speed
    reproducible.useMemoise = FALSE,
    # Require.offlineMode = TRUE,
    spades.moduleCodeChecks = FALSE
  ),
  modules =  c("PredictiveEcology/CBM_defaults@development",
               "PredictiveEcology/CBM_dataPrep_SK@development",
               "PredictiveEcology/CBM_dataPrep@development",
               "PredictiveEcology/CBM_vol2biomass@development",
               "PredictiveEcology/CBM_core@development"),
  times = times,

  params = list(
    CBM_dataPrep_SK = list(
      parallel.cores     = NULL,
      parallel.tileSize  = 2500
    ),
    CBM_dataPrep = list(
      parallel.cores     = NULL,
      parallel.chunkSize = 25000,
      saveRasters        = TRUE # Save aligned inputs as output rasters
    )
  ),

  # Set cohort data sources
  ageLocator = "SCANFI-2020-age",
  spsLocator = "SCANFI-2020-LandR",

  # Set disturbances data source
  disturbanceSource = "NTEMS"
)

# Run
simCBM <- SpaDES.core::simInit2(projSetup)
simCBM <- SpaDES.core::spades(simCBM)




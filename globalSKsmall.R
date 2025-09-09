projectPath <- "~/GitHub/spadesCBM"
repos <- unique(c("predictiveecology.r-universe.dev", getOption("repos")))
install.packages("SpaDES.project",
                 repos = repos)

# start in 1998, and end in 2000
times <- list(start = 1998, end = 2000)

out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = "PredictiveEcology", # a developer sets and keeps this = TRUE
  overwrite = TRUE, # a user who wants to get latest modules sets this to TRUE
  paths = list(projectPath = projectPath,
               outputPath  = file.path(projectPath, "outputs", "SK-testArea"),
               modulePath  = file.path(projectPath, "modules"),
               packagePath = file.path(projectPath, "packages"),
               inputPath   = file.path(projectPath, "inputs"),
               cachePath   = file.path(projectPath, "cache")),

  options = options(
    repos = c(repos = repos),
    Require.cloneFrom = Sys.getenv("R_LIBS_USER"),
    reproducible.destinationPath = "inputs",
    ## These are for speed
    reproducible.useMemoise = TRUE,
    # Require.offlineMode = TRUE,
    spades.moduleCodeChecks = FALSE
  ),
  modules =  c("PredictiveEcology/CBM_defaults@development",
               "PredictiveEcology/CBM_dataPrep_SK@development",
               "PredictiveEcology/CBM_dataPrep@development",
               "PredictiveEcology/CBM_vol2biomass_SK@development",
               "PredictiveEcology/CBM_core@development"),
  times = times,

  params = list(
    CBM_defaults = list(
      .useCache = TRUE
    ),
    CBM_dataPrep_SK = list(
      .useCache = TRUE
    ),
    CBM_vol2biomass = list(
      .useCache = TRUE
    )
  ),

  #### begin manually passed inputs #########################################
  require = "terra",

  # Set study area
  masterRaster = terra::rast(
    crs  = "EPSG:3979",
    res  = 30,
    vals = 1L,
    xmin = -690643.4762,
    xmax = -632143.4762,
    ymin =  700447.9315,
    ymax =  757447.9315
  ),

  # Set disturbances data source: NTEMS disturbances sample
  disturbanceRastersURL = "https://drive.google.com/file/d/12YnuQYytjcBej0_kdodLchPg7z9LygCt"
)

# Run
simMngedSKsmall <- SpaDES.core::simInitAndSpades2(out)

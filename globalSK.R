
# Install SpaDES.project
if (tryCatch(packageVersion("SpaDES.project") < "0.1.1", error = function(x) TRUE)){
  install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")
}

# Set project path
projectPath <- "~/GitHub/spadesCBM"

# Set times
times <- list(start = 1985, end = 2020)

# Set up project
out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = "PredictiveEcology", # a developer sets and keeps this = TRUE
  overwrite = TRUE, # a user who wants to get latest modules sets this to TRUE
  paths = list(projectPath = projectPath,
               outputPath  = file.path(projectPath, "outputs", "SK-30m"),
               modulePath  = file.path(projectPath, "modules"),
               packagePath = file.path(projectPath, "packages"),
               inputPath   = file.path(projectPath, "inputs"),
               cachePath   = file.path(projectPath, "cache")),

  options = options(
    repos = unique(c("predictiveecology.r-universe.dev", getOption("repos"))),
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
               "PredictiveEcology/CBM_core@CBM4"),
  times = times,

  params = list(
    CBM_core = list(
      .chunk_size  = 100,
      .max_workers = NA
    )
  ),

  #### begin manually passed inputs #########################################
  require = c("PredictiveEcology/CBM4r@development (>=1.0.1)",
              "PredictiveEcology/CBMutils@development (>=2.5.6)",
              "terra"),

  # Set up Python virtual environment
  python = {
    CBM4r::cbm4_virtualenv_create(
      "r-CBM4",
      python  = CBMutils::ReticulateFindPython(
        version        = ">=3.12,<3.13",
        versionInstall = "3.12:latest",
        pyenvOnly      = TRUE))
    reticulate::use_virtualenv("r-CBM4")
    reticulate::import("pyarrow")
  },

  # Set study area
  masterRaster = terra::rast(
    crs  = "EPSG:3979",
    res  = 30,
    vals = 1L,
    xmin = -1077673.4762,
    xmax =  -426673.4762,
    ymin =   108487.9315,
    ymax =   971077.9315
  ),

  # Set disturbances data source
  disturbanceSource = "NTEMS"
)

# Run
simMngedSK <- SpaDES.core::simInit2(out)
simMngedSK <- SpaDES.core::spades(simMngedSK)




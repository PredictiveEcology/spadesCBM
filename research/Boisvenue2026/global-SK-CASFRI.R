
# Install SpaDES.project
install.packages("SpaDES.project", repos = unique(c("predictiveecology.r-universe.dev", getOption("repos"))))

# Set project path
projectPath <- "~/GitHub/spadesCBM"

# Set times
times <- list(start = 1985, end = 2020)

# Set up project
projSetup <- SpaDES.project::setupProject(
  Restart   = FALSE,
  useGit    = FALSE,
  overwrite = TRUE,
  options = options(
    repos = unique(c("predictiveecology.r-universe.dev", getOption("repos"))),
    Require.cloneFrom = Sys.getenv("R_LIBS_USER"),
    reproducible.useMemoise = FALSE,
    spades.moduleCodeChecks = FALSE
  ),

  paths = list(projectPath = projectPath,
               outputPath  = file.path(projectPath, "outputs", "SK-30m-CASFRI"),
               modulePath  = file.path(projectPath, "modules"),
               packagePath = file.path(projectPath, "packages"),
               inputPath   = file.path(projectPath, "inputs"),
               cachePath   = file.path(projectPath, "cache")),

  modules =  c("PredictiveEcology/CBM_defaults@v1.0.0",
               "PredictiveEcology/CBM_dataPrep_SK@v1.0.0",
               "PredictiveEcology/CBM_dataPrep@v1.0.0",
               "PredictiveEcology/CBM_vol2biomass@v1.0.0",
               "PredictiveEcology/CBM_core@v1.0.0"),
  times = times,

  params = list(
    CBM_dataPrep = list(
      saveRasters = TRUE # Save aligned inputs as output rasters
    ),
    CBM_core = list(
      .saveAll = TRUE
    )
  ),

  #### begin manually passed inputs #########################################
  require = c("reproducible", "terra"),

  # Set study area
  masterRaster = {
    mr <- reproducible::prepInputs(url = "https://drive.google.com/file/d/1RGj8wxHj4lyq1v9x_xkVoMS1a5_w2nmn",
                                   destinationPath = paths$inputPath,
                                   fun = terra::rast)
    mr[mr[] == 0] <- NA
    mr
  },

  # Set disturbances data source
  disturbanceSource = "NTEMS"
)

# Run
simCBM <- SpaDES.core::simInit2(projSetup)
simCBM <- SpaDES.core::spades(simCBM)



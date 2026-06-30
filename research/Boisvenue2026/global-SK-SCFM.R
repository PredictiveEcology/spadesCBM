
# Install SpaDES.project
install.packages("SpaDES.project", repos = unique(c("predictiveecology.r-universe.dev", getOption("repos"))))

# Set project path
projectPath <- "~/GitHub/spadesCBM"

# Set times
times <- list(start = 1985, end = 2485)

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
               outputPath  = file.path(projectPath, "outputs", "spadesCBMscfm"),
               modulePath  = file.path(projectPath, "modules"),
               packagePath = file.path(projectPath, "packages"),
               inputPath   = file.path(projectPath, "inputs"),
               cachePath   = file.path(projectPath, "cache")),

  modules =  c("PredictiveEcology/CBM_defaults@v1.0.0",
               "PredictiveEcology/CBM_dataPrep_SK@v1.0.0",
               "PredictiveEcology/CBM_dataPrep@v1.0.0",
               "PredictiveEcology/CBM_vol2biomass@v1.0.0",
               "PredictiveEcology/CBM_core@v1.0.0",
               file.path("PredictiveEcology/scfm@5b3361a003f6a8e6f5cc788ad33b37fbcf1d1a70/modules",
                         c("scfmDataPrep",
                           "scfmIgnition", "scfmEscape", "scfmSpread",
                           "scfmDiagnostics"))),
  times = times,

  params = list(
    scfmDataPrep = list(targetN = 4000,
                        dataYear = 2011,
                        .useParallelFireRegimePolys = FALSE,
                        fireEpoch = c(1971, 2020)
    ),
    .globals = list(
      .saveInterval = 10,
      .runName = "SK",
      .plots = c("png"),
      .saveSpinup = TRUE,
      .plotInterval = 10
    )
  ),

  #### begin manually passed inputs #########################################
  require = c("reproducible", "terra", "patchwork",
              "PredictiveEcology/CBMutils@c5599f18288ec0fa4eab6b47591fc308d6adbf04",
              "PredictiveEcology/LandR@1af648d1a62be46be8d0370e14221dafda0df9ff",
              "PredictiveEcology/scfmutils@c0042fa51a29ebafc19c0beee9c8bf155bb47bd8"),

  ## define the  study area.
  masterRaster = reproducible::prepInputs(url = "https://drive.google.com/file/d/1diHYHvukLfRkD9mnU9JxP_VIXBpdxhgJ",
                                          destinationPath = paths$inputPath),
  studyArea = {
    sa <- reproducible::prepInputs(url = "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lpr_000a21a_e.zip",
                                   destinationPath = paths$inputPath)
    sa <- sa[sa$PRENAME == "Saskatchewan",]
    sa <- reproducible::postProcess(sa,
                                    cropTo = masterRaster,
                                    projectTo = masterRaster) |> Cache()
    sa
  },
  studyAreaCalibration = studyArea,
  rasterToMatch = {
    rtm <- reproducible::prepInputs(url = "https://drive.google.com/file/d/1FmtbEKbkzufIifETONxOkoplGX50lrT_",
                                    destinationPath = paths$inputPath,
                                    projectTo = masterRaster,
                                    cropTo = terra::vect(studyArea)) |>
      reproducible::Cache()
    rtm[!is.na(rtm)] <- 1L
    rtm <- terra::aggregate(rtm, fact = 250/30, fun = "modal")
    rtm
  },
  rasterToMatchCalibration = rasterToMatch,
  flammableMapCalibration =  {
    fmc <- Cache(
      LandR::prepInputs_NTEMS_LCC_FAO,
      year = 2011,
      destinationPath = paths$inputPath,
      overwrite = TRUE,
      maskTo = studyAreaCalibration,
      cropTo = rasterToMatchCalibration,
      writeTo = .suffix("rstLCC.tif", paste0("_SK2011"))
    )

    fmc <- terra::setValues(fmc, LandR::asInteger(terra::values(fmc)))
    fmc <- LandR::defineFlammable(fmc, nonFlammClasses = c(20, 31, 32, 33))
    fmc <- flammableMapCalibration <- postProcess(fmc,
                                                  to = rasterToMatchCalibration,
                                                  method = "average") |> Cache()

    fmc <- terra::rast(fmc, vals = LandR::asInteger(fmc[] > 0.10))
    # making sure that all pixels with growth curves are flammable
    fmc <- !is.na(terra::aggregate(masterRaster, fact = 250/30, fun = "modal", na.rm = T)) | fmc
    fmc
  },
  flammableMap = flammableMapCalibration,
  disturbanceMeta = data.table(eventID = 1,
                               disturbance_type_id = 1,
                               wholeStand = 1,
                               name = "Wildfire",
                               sourceValue = 1,
                               sourceDelay = 0,
                               sourceObjectName = "rstCurrentBurn")
)

# Run
simCBMwSCFM <- simInit2(projSetup)
simCBMwSCFM <- spades(simCBMwSCFM)



projectPath <- "~/GitHub/spadesCBM"
repos <- unique(c("predictiveecology.r-universe.dev", getOption("repos")))
install.packages("SpaDES.project",
                 repos = repos)

# start in 1998, and end in 2000
times <- list(start = 1985, end = 2020)

out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = "PredictiveEcology", # a developer sets and keeps this = TRUE
  overwrite = TRUE, # a user who wants to get latest modules sets this to TRUE
  paths = list(projectPath = projectPath,
               outputPath  = file.path(projectPath, "outputs", "SK-30m-SCANFI"),
               modulePath  = file.path(projectPath, "modules"),
               packagePath = file.path(projectPath, "packages"),
               inputPath   = file.path(projectPath, "inputs-SCANFI"),
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
  require = c("reproducible"),

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
  ## define the  study area.
  masterRaster = {
    mr <- reproducible::prepInputs(url = "https://drive.google.com/file/d/1EIct8OMMdUP3_F0njXyeqIe004TTTtWU/view?usp=drive_link",
                                   destinationPath = inputPath)
    mr[mr[] == 0] <- NA
    mr
  },

  ageLocator = terra::round(reproducible::prepInputs(url = "https://drive.google.com/file/d/1OvloZLpXvx-Wc2Qr4LAgXkweS-u97BE7/view?usp=drive_link",
                                                     destinationPath = inputPath,
                                                     fun = terra::rast)),
  ageDataYear = 2020,
  userGcMeta = as.data.table(reproducible::prepInputs(url = "https://drive.google.com/file/d/12RHUTxQX9yRwgkWKDzWrA3q27FVYU_3h/view?usp=drive_link",
                                                      destinationPath = inputPath,
                                                      fun = fread)),
  userGcM3 = as.data.table(reproducible::prepInputs(url = "https://drive.google.com/file/d/1rlygsfT9Te6XHNAKNQxfQJDwMybXLijG/view?usp=drive_link",
                                                    destinationPath = inputPath,
                                                    fun = fread)),

  ## If not using curveID, comment this in.
  # gcIndexLocator = terra::rast("~/GitHub/Data/scanfi/gcIndex.tif"),

  ## Comment this out if not using curveID
  curveID = c("speciesId", "prodclass"),
  leadSpeciesRaster = reproducible::prepInputs(url = "https://drive.google.com/file/d/1EIct8OMMdUP3_F0njXyeqIe004TTTtWU/view?usp=drive_link",
                                               destinationPath = inputPath,
                                               fun = terra::rast),
  siteProductivityRaster = reproducible::prepInputs(url = "https://drive.google.com/file/d/1mPkDfGBNxkYPorUxSog36ayRpeISo8iT/view?usp=drive_link",
                                                    destinationPath = inputPath,
                                                    fun = terra::rast),
  cohortLocators = list(
    speciesId  = leadSpeciesRaster,
    prodclass = siteProductivityRaster),


  disturbanceSource = "NTEMS",

  outputs = as.data.frame(expand.grid(
    objectName = c("cbmPools", "NPP"),
    saveTime = sort(c(times$start, times$start + c(1:(times$end - times$start))))
  ))
)

# Run
simMngedSK <- SpaDES.core::simInitAndSpades2(out)

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
  paths = list(projectPath = projectPath),

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
               "PredictiveEcology/CBM_vol2biomass@development",
               "PredictiveEcology/CBM_core@development"),
  times = times,
  require = c("PredictiveEcology/CBMutils@development (>=2.0)", "reticulate",
              "reproducible"),

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

  ret = {
    reticulate::virtualenv_create(
      "r-spadesCBM",
      python = if (!reticulate::virtualenv_exists("r-spadesCBM")){
        CBMutils::ReticulateFindPython(
          version        = ">=3.9,<=3.12.7",
          versionInstall = "3.10:latest"
        )
      },
      packages = c(
        "numpy<2",
        "pandas>=1.1.5",
        "scipy",
        "numexpr>=2.8.7",
        "numba",
        "pyyaml",
        "mock",
        "openpyxl",
        "libcbm"
      )
    )
    reticulate::use_virtualenv("r-spadesCBM")
  },

  #### begin manually passed inputs #########################################
  ## define the  study area.
  masterRaster = {
    mr <- reproducible::prepInputs(url = "https://drive.google.com/file/d/1zUyFH8k6Ef4c_GiWMInKbwAl6m6gvLJW/view?usp=drive_link",
                                   destinationPath = "inputs")
    mr[mr[] == 0] <- NA
    mr
  },

  disturbanceRastersURL = "https://drive.google.com/file/d/12YnuQYytjcBej0_kdodLchPg7z9LygCt",

  outputs = as.data.frame(expand.grid(objectName = c("cbmPools", "NPP"),
                                      saveTime = sort(c(times$start,
                                                        times$start +
                                                          c(1:(times$end - times$start))
                                      )))),

)

# Run
simPython <- SpaDES.core::simInitAndSpades2(out)

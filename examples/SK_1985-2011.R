
## Run simulation ----

  ## STUDY AREA : Saskatchewan
  ## TIME SPAN  : 1985 - 2011
  projectName <- "SK_1985-2011"
  times       <- list(start = 1985, end = 2011)

  # Install SpaDES.project
  install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")

  # Set up simulation
  simSetup <- SpaDES.project::setupProject(

    # Open RStudio project
    Restart = TRUE,

    # Set project paths
    paths   = list(
      projectPath = file.path("~/spadesCBM/examples", projectName),
      modulePath  = file.path("~/spadesCBM/examples", projectName, "modules"),
      outputPath  = file.path("~/spadesCBM/examples", projectName, "outputs"),
      inputPath   = "~/spadesCBM/inputs",
      packagePath = "~/spadesCBM/packages",
      cachePath   = "~/spadesCBM/cache"
    ),

    # Set modules and simulation time span
    times   = times,
    modules = c(
      CBM_defaults    = "PredictiveEcology/CBM_defaults@main",
      CBM_dataPrep_SK = "PredictiveEcology/CBM_dataPrep_SK@main",
      CBM_vol2biomass = "PredictiveEcology/CBM_vol2biomass@main",
      CBM_core        = "PredictiveEcology/CBM_core@main"
    ),

    # Set options
    options = list(
      spades.moduleCodeChecks = FALSE
    ),

    # Set packages required for set up
    require = c("PredictiveEcology/CBMutils@development (>=2.0)", "reticulate"),

    # Set up Python
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

    # Set input: Output table
    outputs = as.data.frame(expand.grid(
      objectName = c("cbmPools", "NPP"),
      saveTime = sort(c(times$start, times$start + c(1:(times$end - times$start))))
    ))
  )

  # Run simulation
  simCBM <- SpaDES.core::simInitAndSpades2(simSetup)


## Review results ----

  # View completed events
  completed(simCBM)

  # View outputs
  outputs(simCBM)

  # View module diagram
  moduleDiagram(simCBM)

  # View object diagram
  Require::Require("DiagrammeR")
  objectDiagram(simCBM)

  # Plot yearly forest products and yearly emissions for the length of the simulation
  CBMutils::carbonOutPlot(
    emissionsProducts = simCBM$emissionsProducts
  )

  # Plot carbon proportions above and below ground each simulation year
  CBMutils::barPlot(
    cbmPools = simCBM$cbmPools
  )

  # Plots the per-pixel average net primary production
  CBMutils::NPPplot(
    masterRaster = simCBM$masterRaster,
    spatialDT    = simCBM$spatialDT,
    NPP          = simCBM$NPP
  )

  # Plot the Total Carbon per pixel for the final simulation year
  CBMutils::spatialPlot(
    masterRaster = simCBM$masterRaster,
    spatialDT    = simCBM$spatialDT,
    cbmPools     = simCBM$cbmPools,
    years        = end(simCBM)
  )



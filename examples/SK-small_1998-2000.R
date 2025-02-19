
## Run simulation ----

  ## STUDY AREA : Saskatchewan - Small AOI
  ## TIME SPAN  : 1998 - 2000
  projectName <- "SK-small_1998-2000"
  times       <- list(start = 1998, end = 2000)

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
    require = c("reticulate", "terra"),

    # Set up Python
    functions = "PredictiveEcology/CBM_core@main/R/ReticulateFindPython.R",
    ret = {
      reticulate::virtualenv_create(
        "r-spadesCBM",
        python = if (!reticulate::virtualenv_exists("r-spadesCBM")){
          ReticulateFindPython(
            version        = ">=3.9,<=3.12.7",
            versionInstall = "3.10:latest",
            pyenvRoot      = tools::R_user_dir("r-spadesCBM")
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

    # Set input: Study area
    masterRaster = {

      # Set study area extent and resolution
      mrAOI <- list(
        ext = c(xmin = -687696, xmax = -681036, ymin = 711955, ymax = 716183),
        res = 30
      )

      # Align SK master raster with study area
      mrSource <- terra::rast(
        reproducible::preProcess(
          destinationPath = "~/spadesCBM/inputs",
          url             = "https://drive.google.com/file/d/1zUyFH8k6Ef4c_GiWMInKbwAl6m6gvLJW",
          targetFile      = "ldSp_TestArea.tif"
        )$targetFilePath)

      reproducible::postProcess(
        mrSource,
        to = terra::rast(
          extent     = mrAOI$ext,
          resolution = mrAOI$res,
          crs        = terra::crs(mrSource),
          vals       = 1
        ),
        method = "near"
      ) |> terra::classify(cbind(0, NA))
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



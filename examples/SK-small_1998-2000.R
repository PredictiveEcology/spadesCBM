
## Run simulation ----

  ## STUDY AREA : Saskatchewan - Small AOI
  ## TIME SPAN  : 1998 - 2000
  projectName <- "SK-small_1998-2000"
  times       <- list(start = 1998, end = 2000)

  # Install SpaDES.project
  if (tryCatch(packageVersion("SpaDES.project") < "0.1.1", error = function(x) TRUE)){
    install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")
  }

  # Set up simulation
  simSetup <- SpaDES.project::setupProject(

    # Open RStudio project
    Restart = getOption("SpaDES.project.Restart", TRUE),

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
      CBM_defaults       = "PredictiveEcology/CBM_defaults@main",
      CBM_dataPrep_SK    = "PredictiveEcology/CBM_dataPrep_SK@main",
      CBM_dataPrep       = "PredictiveEcology/CBM_dataPrep@main",
      CBM_vol2biomass_SK = "PredictiveEcology/CBM_vol2biomass@main",
      CBM_core           = "PredictiveEcology/CBM_core@main"
    ),

    # Set options
    options = list(
      spades.moduleCodeChecks = FALSE
    ),

    # Set packages required for set up
    require = "terra",

    # Set input: Study area
    masterRaster = terra::rast(
      crs  = "EPSG:3979",
      res  = 30,
      vals = 1L,
      xmin = -690643.4762,
      xmax = -632143.4762,
      ymin =  700447.9315,
      ymax =  757447.9315
    ),

    # NTEMS disturbances sample
    disturbanceRastersURL = "https://drive.google.com/file/d/12YnuQYytjcBej0_kdodLchPg7z9LygCt",

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
  SpaDES.core::completed(simCBM)

  # View outputs
  SpaDES.core::outputs(simCBM)

  # View module diagram
  SpaDES.core::moduleDiagram(simCBM)

  # View object diagram
  Require::Require("DiagrammeR")
  SpaDES.core::objectDiagram(simCBM)

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
    masterRaster    = simCBM$masterRaster,
    cohortGroupKeep = simCBM$cohortGroupKeep,
    NPP             = simCBM$NPP
  )

  # Plot the Total Carbon per pixel for the final simulation year
  CBMutils::spatialPlot(
    masterRaster    = simCBM$masterRaster,
    cohortGroupKeep = simCBM$cohortGroupKeep,
    cbmPools        = simCBM$cbmPools,
    years           = SpaDES.core::end(simCBM)
  )



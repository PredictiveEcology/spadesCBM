
## Run simulation ----

  ## STUDY AREA : Saskatchewan
  ## TIME SPAN  : 1985 - 2011
  projectName <- "SK_1985-2011"
  times       <- list(start = 1985, end = 2011)

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
      CBM_defaults    = "PredictiveEcology/CBM_defaults@main",
      CBM_dataPrep_SK = "PredictiveEcology/CBM_dataPrep_SK@main",
      CBM_dataPrep    = "PredictiveEcology/CBM_dataPrep@main",
      CBM_vol2biomass = "PredictiveEcology/CBM_vol2biomass@main",
      CBM_core        = "PredictiveEcology/CBM_core@main"
    ),

    # Set options
    options = list(
      spades.moduleCodeChecks = FALSE
    ),

    # NTEMS disturbances
    disturbanceSource = "NTEMS"
  )

  # Run simulation
  simCBM <- SpaDES.core::simInit2(simSetup)
  simCBM <- SpaDES.core::spades(simCBM)


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
  CBMutils::simPlotEmissionsProducts(simCBM)

  # Plot carbon proportions above and below ground each simulation year
  CBMutils::simPlotPoolProportions(simCBM)

  # Plots the per-pixel average net primary production
  CBMutils::simMapNPP(simCBM)

  # Plot the Total Carbon per pixel for the final simulation year
  CBMutils::simMapTotalCarbon(simCBM)




if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("SK-med with NTEMS disturbances 1998-2000", {

  ## Run simInit and spades ----

  # Set up project
  projectName <- "2_SK-med_NTEMS_1998-2000"
  times       <- list(start = 1998, end = 2000)

  simInitInput <- SpaDEStestMuffleOutput(

    SpaDES.project::setupProject(

      modules = c(
        paste0("PredictiveEcology/CBM_defaults@",       Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_dataPrep_SK@",    Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_dataPrep@",       Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_vol2biomass_SK@", Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_core@",           Sys.getenv("BRANCH_NAME", "development"))
      ),
      times   = times,
      paths   = list(
        projectPath = spadesTestPaths$projectPath,
        modulePath  = spadesTestPaths$modulePath,
        packagePath = spadesTestPaths$packagePath,
        inputPath   = spadesTestPaths$inputPath,
        cachePath   = spadesTestPaths$cachePath,
        outputPath  = file.path(spadesTestPaths$temp$outputs, projectName)
      ),

      require = "terra",

      # Test area covering SPU 27 & 28
      masterRaster = terra::rast(
        crs  = "EPSG:3979",
        res  = 50,
        vals = 1L,
        xmin = -710000,
        xmax = -640000,
        ymin =  690000,
        ymax =  760000
      ),

      # NTEMS disturbances
      disturbanceSource = "NTEMS"
    )
  )

  # Run simInit
  simTestInit <- SpaDEStestMuffleOutput(
    SpaDES.core::simInit2(simInitInput)
  )

  expect_s4_class(simTestInit, "simList")

  # Run spades
  simTest <- SpaDEStestMuffleOutput(
    SpaDES.core::spades(simTestInit)
  )

  expect_s4_class(simTest, "simList")


  ## Check outputs ----

  expect_true(!is.null(simTest$emissionsProducts))

})



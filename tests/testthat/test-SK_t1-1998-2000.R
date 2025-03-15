
## This test runs the modules with all the default inputs.
## Times: 1998 - 2000
## Study area: All available for SK

if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("SK 1998-2000", {

  ## Run simInit and spades ----

  # Set times
  times <- list(start = 1998, end = 2000)

  # Set project path
  projectPath <- file.path(spadesTestPaths$temp$projects, "SK_1998-2000")
  dir.create(projectPath)
  withr::local_dir(projectPath)

  # Set up project
  simInitInput <- SpaDEStestMuffleOutput(

    SpaDES.project::setupProject(

      modules = c("CBM_defaults", "CBM_dataPrep_SK", "CBM_vol2biomass", "CBM_core"),
      times   = times,
      paths   = list(
        projectPath = projectPath,
        modulePath  = spadesTestPaths$temp$modules,
        packagePath = spadesTestPaths$temp$packages,
        inputPath   = spadesTestPaths$temp$inputs,
        cachePath   = spadesTestPaths$temp$cache,
        outputPath  = file.path(projectPath, "outputs")
      ),

      require = c("PredictiveEcology/CBMutils@development (>=2.0)", "reticulate"),

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

      outputs = as.data.frame(expand.grid(
        objectName = c("cbmPools", "NPP"),
        saveTime   = sort(c(times$start, times$start + c(1:(times$end - times$start))))
      ))
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


  ## Check completed events ----

  # Check that all modules initiated in the correct order
  expect_identical(tail(completed(simTest)[eventType == "init",]$moduleName, 4),
                   c("CBM_defaults", "CBM_dataPrep_SK", "CBM_vol2biomass", "CBM_core"))

  # CBM_core module: Check events completed in expected order
  with(
    list(
      moduleTest  = "CBM_core",
      eventExpect = c(
        "init"              = times$start,
        "postSpinup"        = times$start,
        setNames(times$start:times$end, rep("annual", length(times$star:times$end))),
        "accumulateResults" = times$end
      )),
    expect_equal(
      completed(simTest)[moduleName == moduleTest, .(eventTime, eventType)],
      data.table::data.table(
        eventTime = data.table::setattr(eventExpect, "unit", "year"),
        eventType = names(eventExpect)
      ))
  )


  ## Check output 'cbmPools' ----

  expect_true(!is.null(simTest$cbmPools))


  ## Check output 'gcid_is_sw_hw' ----

  expect_true(!is.null(simTest$gcid_is_sw_hw))


  ## Check output 'spinup_input' ----

  expect_true(!is.null(simTest$spinup_input))


  ## Check output 'spinupResult' ----

  expect_true(!is.null(simTest$spinupResult))


  ## Check output 'cbm_vars' ----

  expect_true(!is.null(simTest$cbm_vars))


  ## Check output 'pixelGroupC' ----

  expect_true(!is.null(simTest$pixelGroupC))


  ## Check output 'NPP' ----

  expect_true(!is.null(simTest$NPP))


  ## Check output 'emissionsProducts' ----

  expect_true(!is.null(simTest$emissionsProducts))


  ## Check output 'pixelKeep' ----

  expect_true(!is.null(simTest$pixelKeep))

})




# Get a list of test directory paths
## These will need to be updated if a DESCRIPTION file is added.
.test_directories <- function(tempDir = tempdir()){

  testDirs <- list()

  # Set R project location
  testDirs$Rproj <- ifelse(testthat::is_testing(), dirname(dirname(getwd())), getwd())

  # Set input data path (must be absolute)
  testDirs$testdata <- file.path(testDirs$Rproj, "tests/testthat", "testdata")

  # Set temporary directory paths
  testDirs$temp <- list(
    root = file.path(tempDir, paste0("testthat-", basename(testDirs$Rproj)))
  )
  testDirs$temp$modules  <- file.path(testDirs$temp$root, "modules")  # For modules
  testDirs$temp$inputs   <- file.path(testDirs$temp$root, "inputs")   # For shared inputs
  testDirs$temp$libPath  <- file.path(testDirs$temp$root, "library")  # R package library
  testDirs$temp$outputs  <- file.path(testDirs$temp$root, "outputs")  # For unit test outputs
  testDirs$temp$projects <- file.path(testDirs$temp$root, "projects") # For project directories

  # Return
  testDirs
}

# Helper function: suppress output and messages; muffle common warnings
.SpaDESwithCallingHandlers <- function(expr){

  if (testthat::is_testing()){

    withr::local_output_sink(tempfile())

    withCallingHandlers(
      expr,
      message = function(c) tryInvokeRestart("muffleMessage"),
      packageStartupMessage = function(c) tryInvokeRestart("muffleMessage"),
      warning = function(w){
        if (getOption("spadesCBM.test.suppressWarnings", default = FALSE)){
          tryInvokeRestart("muffleWarning")
        }else{
          if (grepl("^package ['\u2018]{1}[a-zA-Z0-9.]+['\u2019]{1} was built under R version [0-9.]+$", w$message)){
            tryInvokeRestart("muffleWarning")
          }
        }
      }
    )

  }else expr
}

# Helper function: get or set default module locations
.moduleLocations <- function() c(
  CBM_core        = getOption("spadesCBM.test.module.CBM_core",        default = "PredictiveEcology/CBM_core@main"),
  CBM_defaults    = getOption("spadesCBM.test.module.CBM_defaults",    default = "PredictiveEcology/CBM_defaults@main"),
  CBM_vol2biomass = getOption("spadesCBM.test.module.CBM_vol2biomass", default = "PredictiveEcology/CBM_vol2biomass@main"),
  CBM_dataPrep_SK = getOption("spadesCBM.test.module.CBM_dataPrep_SK", default = "PredictiveEcology/CBM_dataPrep_SK@main")
)


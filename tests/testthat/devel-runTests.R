
## OPTIONS ----

  # Suppress warnings from calls to setupProject, simInit, and spades
  options("spades.test.suppressWarnings" = TRUE)

  # Set custom directory paths
  ## Speed up tests by allowing inputs, cache, and R packages to persist between runs
  options("spades.test.paths.inputs"   = NULL) # inputPath
  options("spades.test.paths.cache"    = NULL) # cachePath
  options("spades.test.paths.packages" = NULL) # packagePath

  # Test recreating the Python virtual environment
  ## WARNING: this will slow down testing, avoid unless Python is having issues
  Sys.setenv(RETICULATE_VIRTUALENV_ROOT = file.path(tempdir(), "virtualenvs"))


## RUN ALL TESTS ----

  # Run all tests
  testthat::test_dir("tests/testthat")

  # Run all tests with different reporters
  testthat::test_dir("tests/testthat", reporter = testthat::LocationReporter)
  testthat::test_dir("tests/testthat", reporter = testthat::SummaryReporter)


## RUN INDIVIDUAL TESTS ----

  ## Run SK-small 1998-2000
  testthat::test_file("tests/testthat/test-SK-small_t1-1998-2000.R")

  ## Run SK-small 1985-2011
  testthat::test_file("tests/testthat/test-SK-small_t2-1985-2011.R")

  ## Run SK 1998-2000
  testthat::test_file("tests/testthat/test-SK_t1-1998-2000.R")

  ## Run SK 1985-2011
  testthat::test_file("tests/testthat/test-SK_t2-1985-2011.R")


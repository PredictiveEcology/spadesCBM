
if (!testthat::is_testing()){
  suppressPackageStartupMessages(library(testthat))
  testthat::source_test_helpers(env = globalenv())
}

# Source work in progress SpaDES module testing functions
suppressPackageStartupMessages(library(SpaDES.core))
tempScript <- tempfile(fileext = ".R")
download.file(
  "https://raw.githubusercontent.com/suz-estella/SpaDES.core/refs/heads/suz-testthat/R/testthat.R",
  tempScript, quiet = TRUE)
source(tempScript)

# Set up testing directories and global options
SpaDEStestSetGlobalOptions()
spadesTestPaths <- SpaDEStestSetUpDirectories(modulePath = NA)

# Install required packages
withr::with_options(c(timeout = 600), Require::Install(
  c("SpaDES.project", "googledrive"),
  repos = unique(c("predictiveecology.r-universe.dev", getOption("repos")))
))

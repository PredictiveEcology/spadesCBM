
if (!testthat::is_testing()){
  library(testthat)
  testthat::source_test_helpers(env = globalenv())
}

# Set teardown environment
teardownEnv <- if (testthat::is_testing()) testthat::teardown_env() else parent.frame()

# List test directories
testDirs <- .test_directories()

# Create temporary directories
for (d in testDirs$temp) dir.create(d)
withr::defer({
  unlink(testDirs$temp$root, recursive = TRUE)
  if (file.exists(testDirs$temp$root)) warning(
    "Temporary test directory could not be removed: ", testDirs$temp$root, call. = F)
}, envir = teardownEnv, priority = "last")

# Set reproducible options:
# - Silence messaging
if (testthat::is_testing()) withr::local_options(list(reproducible.verbose = -2), .local_envir = teardownEnv)

# Set Require package options:
# - Clone R packages from user library
# - Silence messaging
withr::local_options(list(Require.cloneFrom = Sys.getenv("R_LIBS_USER")), .local_envir = teardownEnv)
if (testthat::is_testing()) withr::local_options(list(Require.verbose = -2), .local_envir = teardownEnv)

# Set SpaDES.project option to never update R profile
withr::local_options(list(SpaDES.project.updateRprofile = FALSE), .local_envir = teardownEnv)

# Set Python virtual environment location within temporary directory
if (getOption("spadesCBM.test.virtualEnv", default = TRUE)){
  dir.create(file.path(testDirs$temp$root, "virtualenvs"))
  withr::local_envvar(
    list(RETICULATE_VIRTUALENV_ROOT = file.path(testDirs$temp$root, "virtualenvs")),
    .local_envir = teardownEnv)
}



options(SpaDES.project.Restart = FALSE)
options(SpaDES.project.inputs  = "~/GitHub/inputs") ## custom option

# SK-small with NTEMS disturbances
.studyArea     <- "small"
.ageSource     <- "CASFRI-2012" # CBM_dataPrep_SK default age source
.speciesSource <- "CASFRI"      # CBM_dataPrep_SK default gcIndexLocator
.distSource    <- "NTEMS"
source("C:/Users/sumurray/Documents/ForkSpaDES/SCANFI/spadesCBM/globalSK-experiment.R")

# SK-small with SCANFI 2020 ages, no disturbances
.studyArea     <- "small"
.ageSource     <- "SCANFI-2020"
.speciesSource <- "CASFRI" # CBM_dataPrep_SK default gcIndexLocator
.distSource    <- NA
source("C:/Users/sumurray/Documents/ForkSpaDES/SCANFI/spadesCBM/globalSK-experiment.R")

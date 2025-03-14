# SpaDES CBM

SpaDES CBM is a [SpaDES](https://predictiveecology.org/SpaDES.html) project for modelling forest carbon balances in Canada. spadesCBM is a modular, transparent, and spatially explicit implementation of the logic, pools structure, equations, and default assumptions of the Carbon Budget Model of the Canadian Forest Sector [CBM](https://natural-resources.canada.ca/climate-change/climate-change-impacts-forests/carbon-accounting/carbon-budget-model/13107).
It applies the science presented in @kurz2009 in a similar way to the
simulations in @boisvenue2016 and @boisvenue2022 but calls Python
functions for annual processes. These functions are, like much of
modelling-based science, continuously under development.

## SpaDES Modules

**Key modules**

-   [CBM_core](https://github.com/PredictiveEcology/spadesCBM)
-   [CBM_defaults](https://github.com/PredictiveEcology/spadesCBM)
-   [CBM_vol2biomass](https://github.com/PredictiveEcology/CBM_vol2biomass)

**Data preparation modules**

-   [CBM_dataPrep_SK](https://github.com/PredictiveEcology/CBM_dataPrep_SK)
-   [CBM_dataPrep_RIA](https://github.com/PredictiveEcology/CBM_dataPrep_RIA)

## Examples

The [examples](examples) directory contains SpaDES simulation project scripts that can be used to run a SpaDES CBM simulation. Each project has a set study area, time span, and sometimes other custom inputs or parameters.

See the [Forest Carbon Modelling in SpaDES](https://predictiveecology.org/training/_book/spadesCBMDemo.html) for more information.

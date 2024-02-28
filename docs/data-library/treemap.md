# TreeMap

TreeMap 2016 is a USFS tree-level model of the forests of the conterminous United States created by using machine learning algorithms to match forest plot data from Forest Inventory and Analysis (FIA) to a 30x30 meter (m) grid.

The main output of this project is a raster map of imputed plot identifiers at 30×30 m spatial resolution for the conterminous U.S. for landscape conditions circa 2016. The plot identifiers can be associated with data from FIA plots held in the associated csv and SQL files.

[An overview of the data product can be found here.](https://www.fs.usda.gov/rds/archive/Catalog/RDS-2021-0074)

[The TreeMap data dictionary PDF can be found here.](https://github.com/CU-ESIIL/forest-carbon-codefest/blob/main/docs/assets/TreeMap2016_Data_Dictionary.pdf)

A portion of the TreeMap dataset covering the Southern Rockies has been prepared and placed in the CyVerse data store at the below directroy. The associated CSV and SQL DB files are in the same location. A script showing how to access it, as well as how the raster was accessed, is available in the code repository, as well as copied below.

```
~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/TreeMap
```

``` r
# This script demonstrates how to open and access pre-downloaded TreeMap data from the data store
# It also, at the bottom, shows how the data was accessed via VSI.
# A similar approach could be used to access the SnagHazard data in the zip file via VSI if desired. (Path inside zip: Data/SnagHazard2016.tif) 

# ESIIL, 2024
# Tyler L. McIntosh


require(terra)

#Move data from data store to instance
system("cp -r ~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/TreeMap ~/TreeMap
")

#Open the raster
treemap <- terra::rast("~/TreeMap/treemap2016_southernrockies.tif")
terra::plot(treemap)

#Open the csv
treemapCsv <- readr::read_csv("~/TreeMap/TreeMap2016_tree_table.csv")

head(treemapCsv)





#######################################################
# DATA ACCESS SCRIPT
#######################################################

# Access treemap data, crop to southern rockies, and save to data store

require(glue)
require(terra)
require(sf)

#Access EPA L3 data for cropping
epa_l3 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip", #copied link to download location
  "/us_eco_l3.shp") |> #path inside zip file
  sf::st_read()

#get just S.Rockies
southernRockies <- epa_l3 |>
  dplyr::filter(US_L3NAME == "Southern Rockies") |>
  dplyr::group_by(US_L3NAME) |>
  dplyr::summarize(geometry = sf::st_union(geometry))

#Access treemap data
treemap <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection 
  "https://s3-us-west-2.amazonaws.com/fs.usda.rds/RDS-2021-0074/RDS-2021-0074_Data.zip", #copied link to download location
  "/Data/TreeMap2016.tif") |> #path inside zip file
  terra::rast() 

#Crop to s.rockies
treemapSR <- treemap |> terra::crop(southernRockies, mask = FALSE)

#check data
terra::plot(treemapSR)

#Write to instance
terra::writeRaster(treemapSR,
                   filename = '~/treemap2016_southernrockies.tif',
                   overwrite = TRUE,
                   gdal=c("COMPRESS=DEFLATE"))

#Move data to data store
system("cp ~/treemap2016_southernrockies.tif ~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/TreeMap/treemap2016_southernrockies_again.tif
")

```
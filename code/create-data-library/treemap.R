# This script demonstrates how to open and access pre-downloaded TreeMap data from the data store
# It also, at the bottom, shows how the data was accessed via VSI.
# A similar approach could be used to access the SnagHazard data in the zip file via VSI if desired. (Path inside zip: Data/SnagHazard2016.tif) 

# ESIIL, 2024
# Tyler L. McIntosh


require(terra)

#Move data from data store to instance
system("cp -r ~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/TreeMap ~/TreeMap
")

treemap <- terra::rast("~/TreeMap/treemap2016_southernrockies.tif")
terra::plot(treemap)

treemapCsv <- readr::read_csv("~/TreeMap/TreeMap2016_tree_table.csv")

head(treemapCsv





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

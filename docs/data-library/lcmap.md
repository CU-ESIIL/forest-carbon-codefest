# Land Change Monitoring, Assessment, and Projection

Land Change Monitoring, Assessment, and Projection (LCMAP) represents a new generation of land cover mapping and change monitoring from the U.S. Geological Survey’s Earth Resources Observation and Science (EROS) Center. LCMAP answers a need for higher quality results at greater frequency with additional land cover and change variables than previous efforts. [The USGS website for LCMAP is here.](https://www.usgs.gov/special-topics/lcmap)

Collection 1.3 of the LCMAP product contains 10 different science products ([details here](https://www.usgs.gov/special-topics/lcmap/collection-13-conus-science-products)).

To accelerate your access to this dataset, the ESIIL team has made LCMAP 1.3 Primary Land Cover product (LCPRI) data for the Southern Rockies available on the Cyverse data store at the below directory:

```
~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/LCMAP_SR_1985_2021
```

Additional LCMAP layers and products may be accessed via STAC and VSI (see below for example).

The script used to download the LCMAP data already available is located in the GitHub repo at /code/create-data-library/LCMAP_Direct_Access-adapted.ipynb. The code is from the LCMAP data access tutorial.

```

#Access LCMAP data from STAC
#Adapted from 'Download data from a STAC API using R, rstac, and GDAL'
#https://stacspec.org/en/tutorials/1-download-data-using-r/


require(glue)
require(sf)
require(terra)
require(rstac)


#Access ecoregiosn via VSI
epa_l3 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip", #copied link to download location
  "/us_eco_l3.shp") |> #path inside zip file
  sf::st_read()

#Get just S.Rockies and ensure that it is in EPSG:4326
southernRockies <- epa_l3 |>
  dplyr::filter(US_L3NAME == "Southern Rockies") |>
  dplyr::group_by(US_L3NAME) |>
  dplyr::summarize(geometry = sf::st_union(geometry)) |>
  sf::st_transform("EPSG:4326")

bboxSR4326 <- sf::st_bbox(southernRockies)

# Create a stac query for just the 2021 LCMAP data
stac_query <- rstac::stac(
  "https://planetarycomputer.microsoft.com/api/stac/v1"
) |>
  rstac::stac_search(
    collections = "usgs-lcmap-conus-v13",
    bbox = bboxSR4326,
    datetime = "2021-01-01/2021-12-31"
  ) |>
  rstac::get_request()

#A function to get a vsicurl url form a base url
make_lcmap_vsicurl_url <- function(base_url) {
  paste0(
    "/vsicurl", 
    "?pc_url_signing=yes",
    "&pc_collection=usgs-lcmap-conus-v13",
    "&url=",
    base_url
  )
}

lcpri_url <- make_lcmap_vsicurl_url(rstac::assets_url(stac_query, "lcpri"))

#Pull the file
out_file <- tempfile(fileext = ".tif")
sf::gdal_utils(
  "warp",
  source = lcpri_url,
  destination = out_file,
  options = c(
    "-t_srs", sf::st_crs(southernRockies)$wkt,
    "-te", sf::st_bbox(southernRockies)
  )
)

#Create the raster and plot!
terra::rast(out_file) |>
  terra::plot()
southernRockies |> 
  sf::st_geometry() |> 
  plot(lwd = 3, add = TRUE)
```
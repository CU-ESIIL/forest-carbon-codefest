
require(glue)
require(sf)

epa_l3 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip", #copied link to download location
  "/us_eco_l3.shp") |> #path inside zip file
  sf::st_read()

#get just S.Rockies and ensure that it is in EPSG:4326
southernRockies <- epa_l3 |>
  dplyr::filter(US_L3NAME == "Southern Rockies") |>
  dplyr::group_by(US_L3NAME) |>
  dplyr::summarize(geometry = sf::st_union(geometry)) |>
  sf::st_transform("EPSG:4326")


bboxSR4326 <- sf::st_bbox(southernRockies)

southernRockies <- southernRockies |> sf::st_transform("EPSG:32613")

bboxSRproj <- sf::st_bbox(southernRockies)


stac("https://earth-search.aws.element84.com/v1") |>
  get_request()
## ###STACCatalog
## - id: earth-search-aws
## - description: A STAC API of public datasets on AWS
## - field(s): stac_version, type, id, title, description, links, conformsTo

collection_formats()


# Record start time
a <- Sys.time()

# Initialize STAC connection
s = stac("https://earth-search.aws.element84.com/v0")


# Search for Sentinel-2 images within specified bounding box and date range
#22 Million items
items = s |>
  stac_search(collections = "sentinel-s2-l2a-cogs",
              bbox = c(bboxSR4326["xmin"], 
                       bboxSR4326["ymin"],
                       bboxSR4326["xmax"], 
                       bboxSR4326["ymax"]), 
              datetime = "2021-05-15/2021-05-16") |>
  post_request() |>
  items_fetch(progress = FALSE)

# Print number of found items
length(items$features)
## [1] 1

# Prepare the assets for analysis
library(gdalcubes)
assets = c("B01", "B02", "B03", "B04", "B05", "B06", 
           "B07", 
           "B08", "B8A", "B09", "B11", "B12", "SCL")
s2_collection = stac_image_collection(items$features, asset_names = assets,
                                      property_filter = function(x) {x[["eo:cloud_cover"]] < 20}) #all images with less than 20% clouds

b <- Sys.time()
difftime(b, a)
## Time difference of 0.4706092 secs

# Display the image collection
s2_collection
## Image collection object, referencing 1 images with 13 bands
## Images:
##                       name      left      top   bottom     right
## 1 S2B_13TDE_20210516_0_L2A -106.1832 40.65079 39.65576 -104.8846
##              datetime        srs
## 1 2021-05-16T18:02:54 EPSG:32613
## 
## Bands:
##    name offset scale unit nodata image_count
## 1   B01      0     1                       1
## 2   B02      0     1                       1
## 3   B03      0     1                       1
## 4   B04      0     1                       1
## 5   B05      0     1                       1
## 6   B06      0     1                       1
## 7   B07      0     1                       1
## 8   B08      0     1                       1
## 9   B09      0     1                       1
## 10  B11      0     1                       1
## 11  B12      0     1                       1
## 12  B8A      0     1                       1
## 13  SCL      0     1                       1


# Record start time
a <- Sys.time()

# Define a specific view on the satellite image collection
v = cube_view(
  srs = "EPSG:32613",
  dx = 100, 
  dy = 100, 
  dt = "P1M", 
  aggregation = "median", 
  resampling = "near",
  extent = list(
    t0 = "2021-05-15", 
    t1 = "2021-05-16",
    left = bboxSRproj[1], 
    right = bboxSRproj[2],
    top = bboxSRproj[4], 
    bottom = bboxSRproj[3]
  )
)

b <- Sys.time()
difftime(b, a)
## Time difference of 0.002738953 secs

# Display the defined view
v
## A data cube view object
## 
## Dimensions:
##                 low             high  count pixel_size
## t        2021-05-01       2021-05-31      1        P1M
## y -3103099.52398788 15434400.4760121 185375        100
## x -3178878.98542359 15369521.0145764 185484        100
## 
## SRS: "EPSG:32720"
## Temporal aggregation method: "median"
## Spatial resampling method: "near"

# Record start time
a <- Sys.time()

s2_collection |>
  raster_cube(v) |>
  select_bands(c( "B04", "B05"))  |>
  apply_pixel(c("(B05-B04)/(B05+B04)"), names="NDVI") |>
  write_tif() |>
  raster::stack() -> x
x
## class      : RasterStack 
## dimensions : 185375, 185484, 34384096500, 1  (nrow, ncol, ncell, nlayers)
## resolution : 100, 100  (x, y)
## extent     : -3178879, 15369521, -3103100, 15434400  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=20 +south +datum=WGS84 +units=m +no_defs 
## names      : NDVI

b <- Sys.time()
difftime(b, a)
## Time difference of  seconds!

mapview::mapview(x, layer.name = "NDVI") + mapview::mapview(southernRockies)

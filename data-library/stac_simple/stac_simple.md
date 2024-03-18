# Accessing data via STAC

ESIIL, 2024
Ty Tuff & Tyler McIntosh

SpatioTemporal Asset Catalog, is an open-source specification designed to standardize the way geospatial data is indexed and discovered. Developed by Element 84 among others, it facilitates better interoperability and sharing of geospatial assets by providing a common language for describing them. STAC’s flexible design allows for easy cataloging of data, making it simpler for individuals and systems to search and retrieve geospatial information. By effectively organizing data about the Earth’s spatial and temporal characteristics, STAC enables users to harness the full power of the cloud and modern data processing technologies, optimizing the way we access and analyze environmental data on a global scale.

Element 84’s Earth Search is a STAC compliant search and discovery API that offers users access to a vast collection of geospatial open datasets hosted on AWS. It serves as a centralized search catalog providing standardized metadata for these open datasets, designed to be freely used and integrated into various applications. Alongside the API, Element 84 also provides a web application named Earth Search Console, which is map-centric and allows users to explore and visualize the data contained within the Earth Search API’s catalog. This suite of tools is part of Element 84’s initiative to make geospatial data more accessible and actionable for a wide range of users and applications.

## First, we need an area of interest

```
require(glue)
require(sf)
require(gdalcubes)
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
```

To access data from STAC correctly, we need to request the data in a projected CRS.
```
southernRockies <- southernRockies |> sf::st_transform("EPSG:32613")

bboxSRproj <- sf::st_bbox(southernRockies)
```

## Search the STAC catalog

To get information about a STAC archive, you can use rstac::get_request(). You can also use gdalcubes::collection_formats() to see various collection formats that you may encounter.

To search a STAC catalog online, [stacindex.org](stacindex.org) is a useful tool. For example, [here is the page](https://stacindex.org/catalogs/earth-search#/) for the Earth Search catalog by Element84 that we will use.

```
stac("https://earth-search.aws.element84.com/v1") |>
  get_request()
## ###STACCatalog
## - id: earth-search-aws
## - description: A STAC API of public datasets on AWS
## - field(s): stac_version, type, id, title, description, links, conformsTo

collection_formats()
```

Initialize a STAC connection (rstac::stac()) and search for data that you are interested in (rstac::stac_search()). Note that you will request a spatial area of interest as well as a temporal window of interest. To get more information on the data and how it is structured, you can examine the 'items' object we create.

```
# Record start time
a <- Sys.time()

# Initialize STAC connection
s = rstac::stac("https://earth-search.aws.element84.com/v0")


# Search for Sentinel-2 images within specified bounding box and date range
#22 Million items
items = s |>
  rstac::stac_search(collections = "sentinel-s2-l2a-cogs",
              bbox = c(bboxSR4326["xmin"], 
                       bboxSR4326["ymin"],
                       bboxSR4326["xmax"], 
                       bboxSR4326["ymax"]), 
              datetime = "2021-05-15/2021-05-16") |>
  post_request() |>
  items_fetch(progress = FALSE)

# Print number of found items
length(items$features)

items
```

There is data we want! Now, we need to prepare the assets for us to access. We will list the assets we want, and set any property filters that we would like to apply.

```
# Prepare the assets for analysis
library(gdalcubes)
assets = c("B01", "B02", "B03", "B04", "B05", "B06", 
           "B07", 
           "B08", "B8A", "B09", "B11", "B12", "SCL")
s2_collection = gdalcubes::stac_image_collection(items$features, asset_names = assets,
                                      property_filter = function(x) {x[["eo:cloud_cover"]] < 20}) #all images with less than 20% clouds

b <- Sys.time()
difftime(b, a)

# Display the image collection
s2_collection

```
## Access the data

First, we need to set up our view on the collection. We will set our spatial and temporal resolution, as well as how we want the data temporally aggregated and spatially resampled. We then also set our spatial and temporal window. Note that the spatial extent here should be in a projected CRS!

```
# Record start time
a <- Sys.time()

# Define a specific view on the satellite image collection
v = gdalcubes::cube_view(
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

# Display the defined view
v
```

Finally, let's take our snapshot of the data! Let's also calculate NDVI and then view the data.

```
# Record start time
a <- Sys.time()

s2_collection |>
  raster_cube(v) |>
  select_bands(c( "B04", "B05"))  |>
  apply_pixel(c("(B05-B04)/(B05+B04)"), names="NDVI") |>
  write_tif() |>
  raster::stack() -> x

#View the product
x

b <- Sys.time()
difftime(b, a)

#Let's view the dat
mapview::mapview(x, layer.name = "NDVI") + mapview::mapview(southernRockies)

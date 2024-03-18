# EPA Ecoregions

EPA ecoregions are a convenient spatial framework for ecosystem regions used by the United States Environmental Protection Agency. Full details on EPA ecoregions [can be found here.](https://www.epa.gov/eco-research/ecoregions)

A Roman numeral classification scheme has been adopted for different hierarchical levels of ecoregions, ranging from general regions to more detailed:

- Level I - 12 ecoregions in the continental U.S.
- Level II - 25 ecoregions in the continental U.S.
- Level III -105 ecoregions in the continental U.S.
- Level IV - 967 ecoregions in the conterminous U.S.

Instructions for accessing spatial EPA ecoregion data can be found in the script code/create-data-library/access_epa_ecoregions.R. The script is also copied below:

``` r
# This brief script demonstrates how to access level 3 and 4 EPA ecoregions for North America.
# Directly accessing the files via VSI is recommended, as this uses cloud-hosted data.
# A version for downloading the zipped files is also provided in case for some reason you need the actual files.

# ESIIL, February 2024
# Tyler L. McIntosh

####### ACCESS SHAPEFILES DIRECTLY VIA VSI #########

require(glue)
require(sf)

epa_l3 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip", #copied link to download location
  "/us_eco_l3.shp") |> #path inside zip file
  sf::st_read()
epa_l4 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l4.zip", #copied link to download location
  "/us_eco_l4_no_st.shp") |> #path inside zip file
  sf::st_read()



######### DOWNLOAD ZIPPED DATA FILES #########

#Set up directory
directory <- "~/data/ecoregions"
if (!dir.exists(directory)) {
  dir.create(directory)
}

#Avoid download timeout
options(timeout = max(1000, getOption("timeout")))

#URLs for downloads
epaUrls <- c("https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip",
             "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l4.zip")
destFiles <- file.path(directory, basename(epaUrls))

#Download
mapply(FUN = function(url, destfile) {download.file(url = url,
                                                    destfile = destfile,
                                                    mode = "wb")},
       url = epaUrls,
       destfile = destFiles)

#Unzip downloaded files
mapply(FUN = function(destfile, exdir) {unzip(zipfile = destfile,
                                              files = NULL,
                                              exdir = exdir)},
       destfile = destFiles,
       exdir = gsub(pattern = ".zip", replacement = "", x = destFiles))

```
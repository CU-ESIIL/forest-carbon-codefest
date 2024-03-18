# Mounting data directly from a URL

ESIIL, 2024
Tyler McIntosh

Data can be directly accessed from where it is hosted on the internet, without the need to download the entire file to your local machine.

For spatial data, special protocols from the GDAL library can be used.

The first part of enabling remote access is "vsicurl". VSI is GDAL's Virtual File System. This is a virtual file system handler allows access to files hosted on remote servers over protocols like HTTP, HTTPS, and FTP. When you prepend "vsicurl/" to a URL, GDAL reads the file directly from the remote location without downloading it entirely to the local disk. It's particularly useful for large files, as it only fetches the portions of the file needed for the current operation.

The second part of enabling remote access to a zipped file (most large data files hosted online) is "vsizip". This is another virtual file system handler in GDAL that enables reading files inside zip archives as if they were unzipped, without the need to extract them manually. By using "vsizip/", you can directly access the contents of a zip file.

When combined, "/vsizip/vsicurl/" allows GDAL (and, subsequently, a package such as 'terra' or 'sf' in R, or similar Python packages) to access files inside of a zip archive on a remote server. The URL following this protocol specifies the remote location of the zip file, and the path after the URL specifies the particular file within the zip archive that you want to access.

## Example

For example, you may have a url to a spatial dataset that you want to use, "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip". You may have found this link on a website.

### Figure out your archive contents

In order to open a specific file within the zip archive, you need to know the names of the files within the archive. You can either:

  - Download the archive once, view the data structure, and then access it remotely from then on, or, a better solution is to...
  - Access the contents of the zip file using GDAL from a command-line environment

To access the contents from a command-line environment, you would use a line of code like this:
```
gdalinfo /vsizip/vsicurl/https://example.com/data.zip
```
Or, in our example:
```
gdalinfo /vsizip/vsicurl/https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip
```

If you would like to do this without leaving your R or Python environment, you can use R or Python to execute command line calls:

*R, using "system":*
```
zip_url = "/vsizip//vsicurl/https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip"
system(paste("gdalinfo", zip_url))
```

*Python, using "subprocess.run":*
```
import subprocess

zip_url = "/vsizip//vsicurl/https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip"
subprocess.run(["gdalinfo", zip_url])
```

This will tell you that the archive contains several files, one of which is "us_eco_l3.shp" - our shapefile of interest. (If there were subdirectories within the directory, repeat the process).

### Mounting the data

We now know the full path to our file of interest:
```
"/vsizip//vsicurl/https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip/us_eco_l3.shp"
```

To mount the data, we simply feed this string to our spatial data package just as we would any other data location. For example, in R, we could do:
```
require(glue)
require(sf)

epa_l3 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip", #copied link to download location
  "/us_eco_l3.shp") |> #path inside zip file
  sf::st_read()
```

From this point, we now have the data mounted in our epa_l3 variable, and can manipulate it as usual.

Note that, since vsicurl only fetches the portions of the file needed for an operation, the data mounted very quickly. Only once you attempt an operation with the data that requires the entire dataset will it actually fetch the entire dataset!







# TreeMap

TreeMap 2016 is a USFS tree-level model of the forests of the conterminous United States created by using machine learning algorithms to match forest plot data from Forest Inventory and Analysis (FIA) to a 30x30 meter (m) grid.

The main output of this project is a raster map of imputed plot identifiers at 30×30 m spatial resolution for the conterminous U.S. for landscape conditions circa 2016. The plot identifiers can be associated with data from FIA plots held in the associated csv and SQL files.

[An overview of the data product can be found here.](https://www.fs.usda.gov/rds/archive/Catalog/RDS-2021-0074)

[The TreeMap data dictionary PDF can be found here.](https://github.com/CU-ESIIL/forest-carbon-codefest/blob/main/docs/assets/TreeMap2016_Data_Dictionary.pdf)

A portion of the TreeMap dataset covering the Southern Rockies has been prepared and placed in the CyVerse data store. The associated CSV and SQL DB files are in the same location. A script showing how to access it, as well as how the raster was accessed, is available in the code repository.
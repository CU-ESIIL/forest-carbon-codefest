# LANDFIRE Public Events Geodatabase

*From ['LANDFIRE Product Descriptions with References'](https://landfire.gov/documents/LF_Data_Product_Descriptions_w-References2019.pdf)*

The LF National (LF 1.X) Public Events Geodatabase is a collection of recent natural disturbance and
land management activities used to update existing vegetation and fuel layers during LF Program
deliverables. Public Events exclude proprietary and/or sensitive data.
This geodatabase includes three feature classes - Raw Events, Model Ready Events, and Exotics. The
Public Raw and Model Ready Event feature classes include natural disturbance and vegetation/fuel
treatment data. The Public Exotics feature class contains data on the occurrence of exotic or invasive
plant species. There is also a look up table for the source code (lutSource_Code), an attribute found in
all three feature classes. The source code is an LF internal code assigned to each data source. Consult
thetable“lutSource_Code” in thegeodatabases for more information about the data sources included
in, and excluded from, releases.
The data compiled in the three feature classes are collected from disparate sources including federal,
state, local, and private organizations. All data submitted to LF are evaluated for inclusion into the LF
Events geodatabase. Acceptable Event data must have the following minimum requirements to be
included in the Events geodatabase:
  1) be represented by a polygon on the landscape and have a defined spatial coordinate
system
  2) have an acceptable event type (Appendix B) or exotics plant species
  3) be attributed with year of occurrence or observation of the current data call.


## Metadata

The LANDFIRE public events geodatabase contents description is available [here](https://landfire.gov/documents/LANDFIRE_2022_Public_Events_README.pdf).

[This document](https://landfire.gov/documents/Disturbance_Data_Processing.pdf) provides a description of how polygon data of disturbans and treatments are evaluated and processed into the LANDFIRE Events geodatabase.

The Raw and Model Ready Events Data Dictionary is available [here](https://landfire.gov/documents/LANDFIREEventsDataDictionary.pdf).

Note that this is a large geodatabase (> 1 million polygons). Recommend filtering as soon as possible.

The relevant layers within the .gdb file are:

  - CONUS_230_PublicExotics
  - CONUS_230_PublicModelReadyEvents
  - CONUS_230_PublicRawEvents

## Access

Storage location:
```
~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/Disturbance/LF_Public_Events_1999_2022
```

Example access script:
```

system("cp -r ~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/Disturbance/LF_Public_Events_1999_2022 ~/LF_Events") #move the data first!!


landfireEvents <- sf::st_read("~/LF_Events/LF_Public_Events_1999_2022.gdb",
                              layer = "CONUS_230_PublicModelReadyEvents")

unique(landfireEvents$Event_Type)

# [1] "Thinning"          "Other Mechanical"  "Prescribed Fire"   "Herbicide"        
# [5] "Clearcut"          "Harvest"           "Wildfire"          "Mastication"      
# [9] "Wildland Fire"     "Chemical"          "Development"       "Biological"       
# [13] "Weather"           "Planting"          "Reforestation"     "Insects"          
# [17] "Seeding"           "Disease"           "Wildland Fire Use" "Insects/Disease"  
# [21] "Insecticide"  

landfireFireEvents <- landfireEvents |> dplyr::filter(Event_Type == "Wildfire" | 
                                                        Event_Type == "Wildland Fire Use" |
                                                        Event_Type == "Prescribed Fire" |
                                                        Event_Type == "Wildland Fire" |
                                                        Event_Type == "Fire")
```
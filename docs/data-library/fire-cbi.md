# Fire severity: Composite Burn Index (CBI)

The Composite Burn Index (CBI) is a commonly used and ecologically meaningful measure of fire severity. Unlike some other measures of fire burn severity (e.g. MTBS fire severity), CBI is more readily comparable across large regions.

To calculate this stack of CBI data the ESIIL team used the method described in [Parks et al. (2019)](https://www.mdpi.com/2072-4292/11/14/1735), which uses random forests regression to calculate CBI based on Relativized Burn Ratio (RBR), latitude, climatic water deficit, and other factors. RBR was calculated using pre- and post-fire image composites of Landsat 4-9 imagery (Collection 2) during the growing season. A correction was applied to the CBI estimates to prevent overprediction at low values (Parks et al., 2019).

This dataset has a layer for each year of data, with NA values at any location that was unburned during that year. Fire disturbance events documented in the Landfire fire events database will appear in these rasters.

The data is pre-loaded onto the Cyverse data store and is located in the below file:

```
~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/Disturbance/SR_landfire_fire_events_cbi_bc.tif
```
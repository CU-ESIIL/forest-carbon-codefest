# Moving data to your instance from the data store

Some data has been pre-downloaded for you and stored on the CyVerse data store in order to help expedite your projects.

While you CAN access that data directly on the data store, it is HIGHLY recommended that you copy the data over to your instance (see "Cyverse data management" under "Collaborating on the cloud" for more information). This is because your work with the data will be dramatically faster with it located on your instance.

Take, for instance, the treemap data.

If we load and plot the data without moving it, it takes just a few seconds. Not bad.
```
require(terra)
require(tictoc)
tictoc::tic()
treemap <- terra::rast("~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/TreeMap/treemap2016_southernrockies.tif")
terra::plot(treemap)
tictoc::toc()
```

However, if we load and plot the data after moving it, it takes less than a second. Even better! You will see far larger increases in speed as soon as you try to perform any more complex operations on the data.

```
require(terra)
require(tictoc)
system("cp -r ~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/TreeMap ~/TreeMap #move the data first!!
tictoc::tic()
treemap <- terra::rast("~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/TreeMap/treemap2016_southernrockies.tif")
terra::plot(treemap)
tictoc::toc()
```

Takeaway: seriously, just copy the data over.
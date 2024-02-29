# Earth Lab Disturbance Stack derived from Landfire

The CU Boulder Earth Lab has integrated annual (1999-2020) disturbance presence data from Landfire with a new index of hotter drought into an easily managed raster data stack.

To accelerate your access to this dataset, the ESIIL team has made disturbance stack data for the Southern Rockies available on the Cyverse data store at the below directory:

```
~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/disturbance
```

The stack data is in two versions, full and simplified.

The full version (dist_stack_Southern_Rockies.tif) has the below values:

| Code | Landfire disturbance status | Hotter-drought status                          |
|------|-----------------------------|------------------------------------------------|
| 0    | none                        | no hotter-drought/fewer than 4 thresholds exceeded |
| 1    | fire                        | no hotter-drought/fewer than 4 thresholds exceeded |
| 2    | insect/disease              | no hotter-drought/fewer than 4 thresholds exceeded |
| 3    | other Landfire disturbance  | no hotter-drought/fewer than 4 thresholds exceeded |
| 4    | none                        | hotter-drought with 4 thresholds exceeded     |
| 5    | fire                        | hotter-drought with 4 thresholds exceeded     |
| 6    | insects/disease             | hotter-drought with 4 thresholds exceeded     |
| 7    | other Landfire disturbance  | hotter-drought with 4 thresholds exceeded     |
| 8    | none                        | hotter-drought with 5 thresholds exceeded     |
| 9    | fire                        | hotter-drought with 5 thresholds exceeded     |
| 10   | insects/disease             | hotter-drought with 5 thresholds exceeded     |
| 11   | other Landfire disturbance  | hotter-drought with 5 thresholds exceeded     |
| 12   | none                        | hotter-drought with 6 thresholds exceeded     |
| 13   | fire                        | hotter-drought with 6 thresholds exceeded     |
| 14   | insects/disease             | hotter-drought with 6 thresholds exceeded     |
| 15   | other Landfire disturbance  | hotter-drought with 6 thresholds exceeded     |


The simplified version (simple_dist_stack_Southern_Rockies.tif) has the below values, and only includes the most extreme hot drought:

| Code | Landfire disturbance status | Hotter-drought status                          |
|------|-----------------------------|------------------------------------------------|
| 0    | none                        | no hotter-drought/fewer than 6 thresholds exceeded |
| 1    | fire                        | no hotter-drought/fewer than 6 thresholds exceeded |
| 2    | insect/disease              | no hotter-drought/fewer than 6 thresholds exceeded |
| 3    | none  | hotter-drought with 6 thresholds exceeded |
| 4    | fire                        | hotter-drought with 6 thresholds exceeded |
| 5    | insect/disease              | hhotter-drought with 6 thresholds exceeded |


Additional MODIS data is best accessed via VSI or STAC.
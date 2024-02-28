# GEDI data overview

The Global Ecosystem Dynamics Investigation (GEDI) is a joint mission between NASA and the University of Maryland, with the instrument installed aboard the International Space Station. Data acquired using the instrument’s three lasers are used to construct detailed three-dimensional (3D) maps of forest canopy height and the distribution of branches and leaves. By accurately measuring forests in 3D, GEDI data play an important role in understanding the amounts of biomass and carbon forests store and how much they lose when disturbed – vital information for understanding Earth’s carbon cycle and how it is changing. GEDI data also can be used to study plant and animal habitats and biodiversity, and how these change over time.

[The GEDI homepage is located here](https://gedi.umd.edu/).

GEDI data is collected in footprints of ~25m along the track of the sensor. Each footprint is separated by 60m. GEDI footprint based aboveground biomass density (Mg/ha) over the Southern Rocky Mountains have been downloaded by Dr. Nayani Ilangakoon and placed on the Cyverse data store at the below path. The data are from 2019-2022, and are in the form of tiled CSV files.

```
~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/GEDI
```

Brief scripts in both R and Python are available in the GitHub repository demonstrating how to access and manipulate the data. The R script is copied below.

``` r
### This file reads, filter basedo on qulaity flag and ecoregion, and plots GEDI biomass data in csv format.
# ESIIL, 2024
# Nayani Ilangakoon

# Load necessary libraries
library(readr) # For read_csv
library(dplyr) # For data manipulation
library(ggplot2) # For plotting
library(tidyr) # For data tidying
library(forcats)

###############
# NOTE: This script is reading the data directly from the data store. It is only actually opening and processing a single csv
# If you want to use all of the GEDI data that has been made available for your use, you will want to move it
# to your cyverse instance to improve performance
###############

# Define the root path to the data drive
ROOT_PATH <- "~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest"
# Create the path to the GEDI data by appending the directory name to the root path
indir <- file.path(ROOT_PATH, "GEDI/GEDI_SR_footprint_data/GEDI_biomass_SR")

# List the contents of the indir directory
list.files(indir)

# List all files that end with .csv in indir
polyfiles <- list.files(indir, pattern = "\\.csv$", full.names = TRUE)

# Print the list of .csv files
polyfiles

out_csv <- file.path(indir, "recovery_treat_bms_64.csv")


# Reading the csv file created in the last step
l4a_df <- read_csv(out_csv)

# Assign "NA" to the values that needs to be discarded.
l4a_df <- l4a_df %>%
  mutate(agbd = if_else(agbd == -9999,NA_real_,agbd))

l4a_df <- na.omit(l4a_df)



# MCD12Q1 PFT types
pft_legend <- c('Water Bodies', 'Evergreen Needleleaf Trees', 'Evergreen Broadleaf Trees', 
                'Deciduous Needleleaf Trees', 'Deciduous Broadleaf Trees', 'Shrub', 'Grass',
                'Cereal Croplands', 'Broadleaf Croplands', 'Urban and Built-up Lands', 
                'Permanent Snow and Ice', 'Barren', 'Unclassified')

# label PFT classes with numbers
names(pft_legend) <- as.character(0:12)

# Creating mask with good quality shots and trees/shrubs pft class
mask <- l4a_df$l4_quality_flag == 1 & l4a_df$`land_cover_data/pft_class` <= 5

# Filter the dataframe based on the mask
filtered_df <- l4a_df[mask, ]

# Transforming the PFT class to a factor with labels
filtered_df$`land_cover_data/pft_class` <- factor(filtered_df$`land_cover_data/pft_class`, 
                                                  levels = names(pft_legend), labels = pft_legend)

# Plotting the distribution of GEDI L4A AGBD estimates by PFTs
ggplot(filtered_df, aes(x = agbd, fill = `land_cover_data/pft_class`)) +
  geom_histogram(bins = 30, alpha = 0.6, position = "identity") +
  scale_fill_manual(values = rainbow(length(unique(filtered_df$`land_cover_data/pft_class`)))) +
  labs(title = 'Distribution of GEDI L4A AGBD estimates by PFTs (Plant Functional Types) in ACA in 2020',
       x = 'agbd (Mg / ha)', y = 'Frequency') +
  theme_minimal() +
  guides(fill = guide_legend(title = "PFT Class")) +
  theme(legend.position = "bottom")

# Saving the plot
ggsave("test.png", width = 15, height = 5, units = "in")



# Assuming l4a_df and mask have been defined as before

# Binning the elevation data
l4a_df <- l4a_df %>%
  mutate(elev_bin = cut(elev_lowestmode, breaks = seq(0, 5000, by = 500)))

# Ensure PFT class is a factor with proper labels
l4a_df$`land_cover_data/pft_class` <- factor(l4a_df$`land_cover_data/pft_class`, 
                                             levels = names(pft_legend), labels = pft_legend)

# Filtering the dataframe based on mask and ensure it is applied correctly
filtered_df <- l4a_df %>%
  filter(mask)

# Creating the boxplot
g <- ggplot(filtered_df, aes(x = elev_bin, y = agbd)) +
  geom_boxplot() +
  facet_wrap(~`land_cover_data/pft_class`, scales = "free", labeller = labeller(`land_cover_data/pft_class` = as_labeller(pft_legend))) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Elevation (m)", y = "agbd", title = "AGBD by Elevation and PFT Class") +
  theme_minimal()

# Print the plot
print(g)

# Save the plot
ggsave("agbd_category.png", plot = g, width = 15, height = 10, units = "in")

```
# Forest Inventory and Analysis Database (FIA or FIADB)

## Database description

The Forest Inventory and Analysis (FIA) program of the USDA Forest Service Research and Development Branch collects, processes, analyzes, and reports on data necessary for assessing the extent and condition of forest resources in the United States.

This data is collected at the plot level across the US, and includes information such as tree quantity and identifications, downed woody materials, tree regeneration, and more. If you are looking for spatially continuous data, TreeMap is a data product derived from FIA data and uses machine learning algorithms to assign each forested pixel across the US with the id of the FIA plot that best matches it.

[This is an overview of the FIA program.](https://www.fs.usda.gov/research/programs/fia)

[This is the most recent user guide for the FIADB.](https://www.fs.usda.gov/research/understory/forest-inventory-and-analysis-database-user-guide-phase-2)

## Prepared data access functions

FIA data is available from the [FIA DataMart](https://apps.fs.usda.gov/fia/datamart/datamart.html).

Two R functions have been prepared for your use in downloading FIA data directly to your cloud instance. Those functions can be found at code/create-data-library/download_fia.R

The functions are also copied here:

``` r
# This script contains functions to download both individual
# FIA data csv files as well as bulk download data types. The two key functions
# described are fia_download_individual_data_files and fia_bulk_download_data_files

# ESIIL, February 2024
# Tyler L. McIntosh

options(timeout = 300)

################################
# DOWNLOAD INDIVIDUAL FIA DATASETS
#
# This function will download individual FIA datasets requested and return the filenames
# It will create a new subdirectory for the files, "fia_individual_data_files".
# If you want to bulk download data by type, use function fia_bulk_download_data_files
# Note that you may want to change your environment's download timeout option to allow longer downloads
# (e.g. options(timeout = 300))
#
#### PARAMETERS ####
# state_abbreviations : a vector of state abbreviations as strings (e.g. c("CO", "WY", "NM"))
# file_suffixes : a vector of data file oracle table names (e.g. c("DWM_VISIT", "COUNTY") from https://www.fs.usda.gov/research/understory/forest-inventory-and-analysis-database-user-guide-phase-2
# directory : the directory in which to store the data (a new subdirectory will be created for the new files)
#
#### Example call to the function and read of the data ####
# downloaded_files <- fia_download_individual_data_files(
#   state_abbreviations = c("CO"),
#   file_suffixes = c("DWM_VISIT", "COUNTY"),
#   directory = "~/data")
# data_list <- downloaded_files |> lapply(readr::read_csv)
# names(data_list) <- basename(downloaded_files)
#
fia_download_individual_data_files <- function(state_abbreviations, file_suffixes, directory) {
  
  #Ensure directory exists
  if (!dir.exists(directory)) {
    dir.create(directory)
  }
  
  base_url <- "https://apps.fs.usda.gov/fia/datamart/CSV/"
  
  # Define the subdirectory path
  subdirectory_path <- file.path(directory, "fia_individual_data_files")
  
  # Create the subdirectory if it does not exist
  if (!dir.exists(subdirectory_path)) {
    dir.create(subdirectory_path, recursive = TRUE)
  }
  
  downloaded_files <- c()  # Initialize an empty vector to store downloaded filenames
  
  for (state in state_abbreviations) {
    for (suffix in file_suffixes) {
      # Replace underscores with spaces to match the naming convention in the URL
      url_suffix <- gsub("_", " ", suffix)
      url_suffix <- gsub(" ", "_", toupper(url_suffix)) # URL seems to be uppercase
      
      # Construct the URL and filename using the subdirectory path
      url <- paste0(base_url, state, "_", url_suffix, ".csv")
      filename <- paste0(subdirectory_path, "/", state, "_", suffix, ".csv")
      
      # Attempt to download the file
      tryCatch({
        download.file(url, destfile = filename, mode = "wb")
        downloaded_files <- c(downloaded_files, filename)  # Add the filename to the vector
        message("Downloaded ", filename)
      }, error = function(e) {
        message("Failed to download ", url, ": ", e$message)
      })
    }
  }
  
  return(downloaded_files)  # Return the vector of downloaded filenames
}


################################
# BULK DOWNLOAD FIA DATASETS
#
# This function will bulk download FIA datasets requested into associated subdirectories and return the filenames
# as a named list of vectors, where each vector contains the files included in that bulk data set.
# All bulk data subdirectories will be put into a directory called 'fia_bulk_data_files'
# Note that you may want to change your environment's download timeout option to allow longer downloads
# (e.g. options(timeout = 300))
#
#### PARAMETERS ####
# state_abbreviations : a vector of state abbreviations as strings (e.g. c("CO", "WY", "NM"))
# directory : the directory in which to store the data
# bulk_data_types : a vector of bulk download mappings as strings (e.g. c("location level", "plot")) 
#       Available data mappings are:
          # "location level"
          # "tree level"
          # "invasives and understory vegetation"
          # "down woody material"
          # "tree regeneration"
          # "ground cover"
          # "soils"
          # "population"
          # "plot"
          # "reference"
#       Full descriptions of each of these data mappings can be found at the FIA user guide,
#       with each mapping associated with a different chapter of tables:
#          https://www.fs.usda.gov/research/understory/forest-inventory-and-analysis-database-user-guide-phase-2
# 
#### Example call to the function for multiple bulk data types and read in the data ####
# downloaded_files <- fia_bulk_download_data_files(
#   state = c("CO"),
#   directory = "~/data",
#   bulk_data_types = c("down woody material", "plot")
# )
# data_list_dwm <- downloaded_files$`down woody material`|> lapply(readr::read_csv)
# names(data_list_dwm) <- basename(downloaded_files$`down woody material`)
#
fia_bulk_download_data_files <- function(state, directory, bulk_data_types) {
  
  #Ensure directory exists
  if (!dir.exists(directory)) {
    dir.create(directory)
  }
  
  # Map bulk data types to their corresponding file suffixes
  bulk_data_mappings <- list(
    "down woody material" = c(
      "DWM_VISIT", "DWM_COARSE_WOODY_DEBRIS", "DWM_DUFF_LITTER_FUEL",
      "DWM_FINE_WOODY_DEBRIS", "DWM_MICROPLOT_FUEL", "DWM_RESIDUAL_PILE",
      "DWM_TRANSECT_SEGMENT", "COND_DWM_CALC"
    ),
    "location level" = c(
      "SURVEY", "PROJECT", "COUNTY", "PLOT", "COND",
      "SUBPLOT", "SUBP_COND", 
      #"BOUNDARY", 
      "SUBP_COND_CHNG_MTRX"
    ),
    "tree level" = c(
      "TREE", "WOODLAND_STEMS", "GRM_COMPONENT",
      "GRM_THRESHOLD", "GRM_MIDPT", "GRM_BEGIN",
      "GRM_ESTN", "BEGINEND", "SEEDLING", "SITETREE"
    ),
    "invasives and understory vegetation" = c(
      "INVASIVE_SUBPLOT_SPP", "P2VEG_SUBPLOT_SPP", "P2VEG_SUBP_STRUCTURE"
    ),
    "tree regeneration" = c(
      "PLOT_REGEN", "SUBPLOT_REGEN", "SEEDLING_REGEN"
    ),
    "ground cover" = c(
      "GRND_CVR", "GRND_LYR_FNCTL_GRP", "GRND_LYR_MICROQUAD"
    ),
    "soils" = c(
      "SUBP_SOIL_SAMPLE_LOC", "SUBP_SOIL_SAMPLE_LAYER"
    ),
    "population" = c(
      "POP_ESTN_UNIT", "POP_EVAL", "POP_EVAL_ATTRIBUTE",
      "POP_EVAL_GRP", "POP_EVAL_TYP", "POP_PLOT_STRATUM_ASSGN",
      "POP_STRATUM"
    ),
    "plot" = c(
      "PLOTGEOM", "PLOTSNAP"
    ),
    "reference" = c(
      "REF_POP_ATTRIBUTE", "REF_POP_EVAL_TYP_DESCR", "REF_FOREST_TYPE",
      "REF_FOREST_TYPE_GROUP", "REF_SPECIES", "REF_PLANT_DICTIONARY",
      "REF_SPECIES_GROUP", "REF_INVASIVE_SPECIES", "REF_HABTYP_DESCRIPTION",
      "REF_HABTYP_PUBLICATION", "REF_CITATION", "REF_FIADB_VERSION",
      "REF_STATE_ELEV", "REF_UNIT", "REF_RESEARCH_STATION",
      "REF_NVCS_HIERARCHY_STRICT", "REF_NVCS_LEVEL_1_CODES",
      "REF_NVCS_LEVEL_2_CODES", "REF_NVCS_LEVEL_3_CODES",
      "REF_NVCS_LEVEL_4_CODES", "REF_NVCS_LEVEL_5_CODES",
      "REF_NVCS_LEVEL_6_CODES", "REF_NVCS_LEVEL_7_CODES",
      "REF_NVCS_LEVEL_8_CODES", "REF_AGENT", "REF_DAMAGE_AGENT",
      "REF_DAMAGE_AGENT_GROUP", "REF_FVS_VAR_NAME", "REF_FVS_LOC_NAME",
      "REF_OWNGRP_CD", "REF_DIFFERENCE_TEST_PER_ACRE",
      "REF_DIFFERENCE_TEST_TOTALS", "REF_EQUATION_TABLE", "REF_SEQN",
      "REF_GRM_TYPE", "REF_INTL_TO_DOYLE_FACTOR", "REF_TREE_CARBON_RATIO_DEAD",
      "REF_TREE_DECAY_PROP", "REF_TREE_STAND_DEAD_CR_PROP", "REF_GRND_LYR"
    )
  )
  # Initialize a named list to store the filenames for each bulk data type
  all_downloaded_files <- setNames(vector("list", length(bulk_data_types)), bulk_data_types)
  
  # Define and create the main bulk data directory
  main_bulk_dir <- file.path(directory, "fia_bulk_data_files")
  if (!dir.exists(main_bulk_dir)) {
    dir.create(main_bulk_dir, recursive = TRUE)
  }
  
  # Loop through each bulk data type
  for (bulk_data_type in bulk_data_types) {
    # Check if the bulk data type is known
    if (!bulk_data_type %in% names(bulk_data_mappings)) {
      stop("Unknown bulk data type: ", bulk_data_type)
    }
    
    # Create a subdirectory name by replacing spaces with underscores
    subdirectory <- gsub(" ", "_", bulk_data_type)
    subdirectory_path <- file.path(main_bulk_dir, subdirectory)
    
    # Create the subdirectory if it does not exist
    if (!dir.exists(subdirectory_path)) {
      dir.create(subdirectory_path, recursive = TRUE)
    }
    
    # Retrieve the correct set of file suffixes for the current bulk data type
    file_suffixes <- bulk_data_mappings[[bulk_data_type]]
    
    # Call the download function for each file suffix and save in the new subdirectory
    downloaded_files <- download_data_files(
      state_abbreviations = state,
      file_suffixes = file_suffixes,
      location = subdirectory_path
    )
    
    # Store the downloaded filenames in the named list under the current bulk data type
    all_downloaded_files[[bulk_data_type]] <- downloaded_files
  }
  
  # Return the named list of vectors with filenames
  return(all_downloaded_files)
}

```
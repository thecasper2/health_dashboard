# This file provides a read_data() function, which:
# - Reads in the .csv datasource in the /data subfolder
# - Performs any necessary transformations on the data
# - Returns the data as a data.table

library(data.table)
library(lubridate)
library(magrittr)
library(stringr)

# Define the columns we expect to find when reading the data
expected_cols <- c("Time of Measurement", "Weight", "BMI", "Body Fat",
                   "Fat-free Body Weight", "Subcutaneous Fat", "Visceral Fat",
                   "Body Water", "Skeletal Muscle", "Muscle Mass", "Bone Mass",
                   "Protein", "BMR", "Metabolic Age")

# Define the columns that contain numeric data
data_cols <- c("Weight", "BMI", "Body Fat", "Fat-free Body Weight",
               "Subcutaneous Fat", "Visceral Fat", "Body Water",
               "Skeletal Muscle", "Muscle Mass", "Bone Mass",
               "Protein", "BMR", "Metabolic Age")

scales_char_to_numeric <- function(string){

    #' Takes a character value from the scales data, removes any description
    #' of the unit (e.g. kgs, kcal, %) and returns the numeric value
    #'
    #' @param string the string to be turned into a numeric value

    # Remove numeric values and decimal point to identify the character suffix
    suffix <- str_remove_all(string, "[[[:digit:]]\\.]")
    # If the suffix is unrecognised, throw an error
    if(!(suffix %in% c("%", "kg", "kcal", ""))){
        stop(paste0("Unrecognised character suffix: ", suffix))
    }
    # Remove suffix from string if it exists
    if(suffix != ""){string <- str_remove_all(string, suffix)}
    # Convert to numeric
    numeric_out <- as.numeric(string)
    # If value was a percent, return as a decimal
    if(suffix == "%"){numeric_out <- numeric_out/100}
    return(numeric_out)
}

read_scales_data <- function(directory="data", expected_cols_=expected_cols){

    #' 1) Looks for any .csv files in the data directory, and reads in the first
    #' instance.
    #' 2) Checks whether the read data matches the expected columns.
    #' 3) Returns data as a data.table
    #'
    #' @param directory The directory in which to look for data
    #' @param expected_cols A vector of column names the data should have

    # Find all .csv files in the specified directory
    files <- list.files(directory, pattern="csv")
    # Throw error if none are found
    if(length(files) <= 0){stop(paste0("No .csv files found in /", directory))}
    # Read first .csv file
    data <- fread(paste0(directory, "/", files[1]))
    # Check the column names are correct, if not throw an error.
    if(!all(colnames(data) == expected_cols_)){
        stop(
            paste0(
                "The following columns are missing in the data: ",
                expected_cols[!(expected_cols %in% colnames(data))]
            )
        )
    }
    return(data)
}

clean_scales_data <- function(data, data_cols_=data_cols){

    #' Takes the result of the read_scales_data() function and applies necessary
    #' transformations for the dashboard.
    #'
    #' @param data The output of the read_scales_data() function
    #' @param data_cols_w_suffix A vector of data columns that have a suffix,
    #' e.g. kg

    # Throw away rows with NA values, this can happen if the scales don't
    # successfully read impedence data
    data <- na.omit(data)

    # Turn the time into a proper datetime format, and rename as "Time"
    data[, `Time of Measurement` := as_datetime(
        `Time of Measurement`,
        format="%b %d, %Y %I:%M:%S %p"
    )] %>% setnames(., old = "Time of Measurement", new = "Time")

    # Remove suffixes from data columns and transform to numeric
    data[,
        (data_cols) := lapply(.SD, function(x) scales_char_to_numeric(x)),
        .SDcols = data_cols_
    ]
    return(data[])
}

add_metrics <- function(data){

    #' Takes cleaned scales data and adds additional metrics which are functions
    #' of existing metrics
    #'
    #' @param data The output of clean_scales_data()

    data[, `:=` (
        `Body Fat kg` = `Body Fat` * Weight,
        `Muscle Mass %` = `Muscle Mass` / Weight,
        `Bone Mass %` = `Bone Mass` / Weight
    )]

    return(data[])
}

get_scales_data <- function(){

    #' Reads the scales data, applys the cleaning function, adds metrics,
    #' then returns the resulting data.table

    data <- read_scales_data() %>% clean_scales_data() %>% add_metrics()
    return(data)
}
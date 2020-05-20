context("Testing read scales data")

source("../read_scales_data.R")

# For testing string to numeric manipulation
character_input <- c("90kg", "50.2kg", "500kcal", "20.5kcal", "50%", "20.2%",
                     "30", "30.2")
expected_numeric_output <- c(90, 50.2, 500, 20.5, 0.5, 0.202, 30, 30.2)

test_that("Character inputs get transformed to numeric values", {
    expect_equal(
        scales_char_to_numeric(character_input),
        expected_numeric_output
    )
})

bad_character_input <- c("May 15, 2020 11:15:45 am", "90kj", "50.2lb")

test_that("Unknown suffixes causes an error", {
    expect_error(
        scales_char_to_numeric(bad_character_input),
        "Unrecognised character suffixes:  May ,  :: am kj lb",
        fixed = TRUE
    )
})

# Test the reading of scales data using test data
good_test_data_directory <- "test_data/good_test_data"
expected_read_good_data <- data.table::data.table(
    "Time of Measurement" = c("May 15, 2020 11:15:45 am",
                              "Apr 25, 2020 11:40:43 am",
                              "Nov 20, 2019 08:26:59 am",
                              "Jun 8, 2019 12:03:32 pm",
                              "Jan 7, 2019 12:38:39 pm"),
    "Weight" = c("90.15kg", "91.25kg", "94.15kg", "94.35kg", "98.50kg"),
    "BMI" = c(26.1, 26.4, 27.2, 27.3, 28.5),
    "Body Fat" = c("26.0%", "26.4%", "27.4%", "27.5%", ""),
    "Fat-free Body Weight" = c("66.71kg", "67.15kg", "68.35kg", "68.43kg", ""),
    "Subcutaneous Fat" = c("23.1%", "23.4%", "24.2%", "24.3%", ""),
    "Visceral Fat" = c(9, 9, 10, 10, NA),
    "Body Water" =  c("53.4%", "53.1%", "52.4%", "52.4%", ""),
    "Skeletal Muscle" = c("47.8%", "47.5%", "46.9%", "46.9%", ""),
    "Muscle Mass" = c("63.38kg", "63.80kg", "64.94kg", "64.98kg", ""),
    "Bone Mass" = c("3.34kg", "3.36kg", "3.42kg", "3.42kg", ""),
    "Protein" = c("16.87%", "16.79%", "16.56%", "16.51%", ""),
    "BMR" = c("1810.0kcal", "1820.0kcal", "1846.0kcal", "1847.0kcal", ""),
    "Metabolic Age" = c(32, 32, 33, 33, NA)
)

test_that("Reading good scales data returns the correct data.table", {
    expect_equal(
        read_scales_data(directory = good_test_data_directory),
        expected_read_good_data
    )
})

empty_directory <- "test_data/empty_folder"

test_that("Reading a directory with no .csv returns an error", {
    expect_error(
        read_scales_data(directory = empty_directory),
        "No .csv files found in /test_data/empty_folder",
        fixed = TRUE
    )
})

data_with_column_missing_directory <- "test_data/bad_test_data"

test_that("Reading data with a column missing returns an error", {
    expect_error(
        read_scales_data(directory = data_with_column_missing_directory),
        "The following columns are missing in the data: Weight BMI",
        fixed = TRUE
    )    
})

# Test the cleaning of read data. We can recycle the expected good data for
# this.
data_to_clean <- data.table::copy(expected_read_good_data)
expected_clean_data <- data.table::data.table(
    "Time" = c(
        lubridate::as_datetime(
            "May 15, 2020 11:15:45 am", format="%b %d, %Y %I:%M:%S %p"
        ),
        lubridate::as_datetime(
            "Apr 25, 2020 11:40:43 am", format="%b %d, %Y %I:%M:%S %p"
        ),
        lubridate::as_datetime(
            "Nov 20, 2019 08:26:59 am", format="%b %d, %Y %I:%M:%S %p"
        ),
        lubridate::as_datetime(
            "Jun 8, 2019 12:03:32 pm", format="%b %d, %Y %I:%M:%S %p"
        )
    ),
    "Weight" = c(90.15, 91.25, 94.15, 94.35),
    "BMI" = c(26.1, 26.4, 27.2, 27.3),
    "Body Fat" = c(0.26, 0.264, 0.274, 0.275),
    "Fat-free Body Weight" = c(66.71, 67.15, 68.35, 68.43),
    "Subcutaneous Fat" = c(0.231, 0.234, 0.242, 0.243),
    "Visceral Fat" = c(9, 9, 10, 10),
    "Body Water" =  c(0.534, 0.531, 0.524, 0.524),
    "Skeletal Muscle" = c(0.478, 0.475, 0.469, 0.469),
    "Muscle Mass" = c(63.38, 63.80, 64.94, 64.98),
    "Bone Mass" = c(3.34, 3.36, 3.42, 3.42),
    "Protein" = c(0.1687, 0.1679, 0.1656, 0.1651),
    "BMR" = c(1810.0, 1820.0, 1846.0, 1847.0),
    "Metabolic Age" = c(32, 32, 33, 33)
)

test_that("Cleaning data returned the expected data.table", {
    expect_equal(clean_scales_data(data_to_clean), expected_clean_data)
})

# Test the adding of metrics. We can recycle the expected good data for this.
data_to_add_metrics <- data.table::copy(expected_clean_data)
expected_data_with_new_metrics <- data.table::data.table(
    "Time" = c(
        lubridate::as_datetime(
            "May 15, 2020 11:15:45 am", format="%b %d, %Y %I:%M:%S %p"
        ),
        lubridate::as_datetime(
            "Apr 25, 2020 11:40:43 am", format="%b %d, %Y %I:%M:%S %p"
        ),
        lubridate::as_datetime(
            "Nov 20, 2019 08:26:59 am", format="%b %d, %Y %I:%M:%S %p"
        ),
        lubridate::as_datetime(
            "Jun 8, 2019 12:03:32 pm", format="%b %d, %Y %I:%M:%S %p"
        )
    ),
    "Weight" = c(90.15, 91.25, 94.15, 94.35),
    "BMI" = c(26.1, 26.4, 27.2, 27.3),
    "Body Fat" = c(0.26, 0.264, 0.274, 0.275),
    "Fat-free Body Weight" = c(66.71, 67.15, 68.35, 68.43),
    "Subcutaneous Fat" = c(0.231, 0.234, 0.242, 0.243),
    "Visceral Fat" = c(9, 9, 10, 10),
    "Body Water" =  c(0.534, 0.531, 0.524, 0.524),
    "Skeletal Muscle" = c(0.478, 0.475, 0.469, 0.469),
    "Muscle Mass" = c(63.38, 63.80, 64.94, 64.98),
    "Bone Mass" = c(3.34, 3.36, 3.42, 3.42),
    "Protein" = c(0.1687, 0.1679, 0.1656, 0.1651),
    "BMR" = c(1810.0, 1820.0, 1846.0, 1847.0),
    "Metabolic Age" = c(32, 32, 33, 33),
    "Body Fat kg" = c(23.439, 24.09, 25.7971, 25.94625),
    "Muscle Mass %" = c(0.7030505, 0.6991781, 0.6897504, 0.6887122),
    "Bone Mass %" = c(0.03704936, 0.03682192, 0.03632501, 0.03624801)
    
)

test_that("Adding metrics returns the expected data.table", {
    expect_equal(
        add_metrics(data_to_add_metrics),
        expected_data_with_new_metrics,
        tolerance=1e-6
    )
})

# Test function that chains the other functions together, equivalent to an
# integration test. We can recycle the expected data with metrics from
# previously
get_scales_data_directory <- good_test_data_directory
expected_output_data <- copy(expected_data_with_new_metrics)

test_that("The good data can be read, cleaned, and metrics added as expected", {
    expect_equal(
        get_scales_data(directory=get_scales_data_directory),
        expected_output_data,
        tolerance=1e-6
    )
})

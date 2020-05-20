# Check currently installed packages
installed_packages <- rownames(installed.packages())

# We need devtools to install package versions
if(!("devtools" %in% installed_packages)){install.packages("devtools")}

# Required packages and versions
required_packages <- list(
    shiny = list(package="shiny", version="1.4.0.2"),
    flexdashboard = list(package="flexdashboard", version="0.5.1.1"),
    rmarkdown = list(package="rmarkdown", version="2.1"),
    data.table = list(package="data.table", version="1.12.8"),
    lubridate = list(package="lubridate", version="1.7.8"),
    magrittr = list(package="magrittr", version="1.5"),
    stringr = list(package="stringr", version="1.4.0"),
    ggplot2 = list(package="ggplot2", version="3.3.0"),
    plotly = list(package="plotly", version="4.9.2.1"),
    testthat = list(package="testthat", version="2.3.2")
)

for(package in required_packages){
    # If package is missing, inform that it is missing
    if(!(package$package %in% installed_packages)){
        cat(paste0("Installing missing package: ", package$package, "\n"))
    }
    # If it exists, check the version
    else{
        # If the version is correct, move on
        if(packageVersion(package$package) == package$version){
            cat(
                paste0(
                    "Package: ", package$package,
                    " already at correct version\n"
                )
            )
            next
        }
        # Otherwise inform of update to the package
        cat(
            paste0(
                "Updating package: ", package$package,
                " to version ", package$version, "\n"
            )
        )
    }
    # Install the specific package version from cran
    devtools::install_version(
        package$package,
        version=package$version,
        repos = "https://cran.rstudio.com/"
    )
}

cat("All necessary packages installed!")
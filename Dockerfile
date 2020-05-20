FROM rocker/shiny-verse:3.6.1

# Install required files
RUN apt-get update

# Copy app
COPY /health /srv/shiny-server/health

# Download and install required R libraries
RUN Rscript /srv/shiny-server/health/install_packages.R
#RUN R -e "install.packages(c('data.table'), repos='http://cran.us.r-project.org', version='1.12.8')"
#RUN R -e "install.packages(c('flexdashboard'), repos='http://cran.us.r-project.org', version='0.5.1.1')"
#RUN R -e "install.packages(c('plotly'), repos='http://cran.us.r-project.org', version='4.9.2.1')"
#RUN R -e "install.packages(c('lubridate'), repos='http://cran.us.r-project.org', version='1.7.8')"
#RUN R -e "remove.packages(c('rmarkdown'))"
#RUN R -e "remotes::install_github('rstudio/rmarkdown', version='2.1')"

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/
# Fire up the shiny server
CMD ["/usr/bin/shiny-server.sh"]

# Run tests
RUN R -e "testthat::test_dir('/srv/shiny-server/health/tests')"
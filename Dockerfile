FROM rocker/shiny-verse:3.6.1

# Install required files
RUN apt-get update

# Download and install required R libraries
RUN R -e "install.packages(c('data.table'), repos='http://cran.us.r-project.org')"
RUN R -e "install.packages(c('flexdashboard'), repos='http://cran.us.r-project.org')"
RUN R -e "install.packages(c('plotly'), repos='http://cran.us.r-project.org')"
RUN R -e "install.packages(c('lubridate'), repos='http://cran.us.r-project.org')"
RUN R -e "install.packages(c('lubridate'), repos='http://cran.us.r-project.org')"
RUN R -e "remove.packages(c('rmarkdown'))"
RUN R -e "remotes::install_github('rstudio/rmarkdown')"

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/
# Fire up the shiny server
CMD ["/usr/bin/shiny-server.sh"] 
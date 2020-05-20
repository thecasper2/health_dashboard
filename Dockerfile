FROM rocker/shiny-verse:3.6.1

# Install required files
RUN apt-get update

# Copy app
COPY /health /srv/shiny-server/health

# Download and install required R libraries
RUN Rscript /srv/shiny-server/health/install_packages.R

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/
# Fire up the shiny server
CMD ["/usr/bin/shiny-server.sh"]

# Run tests
RUN R -e "testthat::test_dir('/srv/shiny-server/health/tests')"
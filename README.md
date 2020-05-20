# Health dashboard

## Introduction

Where I can monitor my health!

## Running the dashboard

The dashboard is designed to run hassle-free with Docker. If you do not wish to use docker
there are steps below to run the dashboard directly in RStudio.

For either process you should place your Renpho scales .csv data in the following folder:
`health/data`

There is already an example.csv in this folder and it should be removed when a new file
is placed in there.

### Using Docker

If you have Docker already running, simply run the following command in the root directory
of this repository:
`docker-compose up -d`

This will download the necssary Docker image and install packages (this may take a
while if it is the first time). Once the process is complete the dashboard will be
available at the following link:

[Dashboard link](http://localhost:5001/health)

### Using RStudio

## Running tests

There are two ways to run the tests:

1) If you are using the steps above to run via Docker, the tests are run automatically
when `docker-compose up -d` is run. The output of the tests will be shown in the console.
2) If you wish to run the tests manually, you must:
	a) Ensure you have installed the necessary R packages in accordance with the section
	"Installing packages"
	b) From the command line, when you are in the root directory of this repository,
	run the command: `R -e "testthat::test_dir('health/tests')"`
# Overview

This example demonstrates:
1. How to use autoloaders in a DLT to ingest files
1. How to union multiple streaming tables
2. How to pass paramters into a DLT Pipeline

# Instructions

The script sets up the Autoloader pipeline and uploads `autoloader_1.csv` into `/Volumes/_jlieow_dev/etl/landing/files/`. If this file is not present when the DLT pipeline runs, initialisation will fail.

Upload `autoloader_2.csv` into `/Volumes/_jlieow_dev/etl/landing/files/` to observe the incremental loading.
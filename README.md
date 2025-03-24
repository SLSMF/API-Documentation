## SLSMF background information

The Flanders Marine Institute ([VLIZ](http://www.vliz.be/en), Belgium) hosts a Sea Level Station Monitoring Facility (SLSMF) that includes Global Sea Level Observing System
([GLOSS](https://www.gloss-sealevel.org/)) Core stations. VLIZ provides a web-based global sea level station monitoring service for viewing sea level data received in real-time from different network operators primarily via the Global Telecommunication Service (GTS), but also through other communications channels. The service provides information about the operational status of GLOSS stations through quick inspection of the raw data stream. The sea level station catalogue (SSC) system developed and maintained at VLIZ links sea level station metadata repositories.

The SLSMF provides an API web-service for direct data access of raw sea level data. The API allows users to retrieve information on the station metadata, list of stations and sensors, as well as sea level data for a station with a 30-day limit (or 150,000 records) within the user-defined time interval. More information on the use of the SLSMF API service can be found through this link:
[https://api.ioc-sealevelmonitoring.org/v1/doc#/](https://api.ioc-sealevelmonitoring.org/v1/doc#/).

A new API web-service of the SLSMF built by the OpenAPI standard
([https://api.ioc-sealevelmonitoring.org/v2/doc#/](https://api.ioc-sealevelmonitoring.org/v2/doc#/))
was launched by VLIZ in the spring of 2025 using the Slim Framework which allows for more endpoints, including research data. The users can access through the new API daily automated quality-controlled sea level data and retrieve information on the stations, sensors, station operators and (SSC and IOC) catalogue entries listed by countries. 

## Repository information

This repository aims to guide the users of the new SLSMF API web-service in:

- understaning the API functionalities, sea level data streaming/retrieval, and Quality Control (QC) steps performed in the web-service,
- accessing quality-controlled sea level data through the service.

Below is a breakdown of the material that can be found in the repository.

### API Description

A description of the new SLSMF API service can be found in the [API\_description](API_description.md) file. The aim of this manual is to provide a comprehensive explanation of the features and capabilities of the API service provided through the SLSMF portal. The manual guides users through the functionality of the API nodes, detailing how to retrieve, process, and utilize the available data for research and analysis in the field of sea level monitoring. It also includes information on registering to the service and acquiring an API-key.

### QC steps description

A description of the sea level data streaming/retrieval design and Quality Control (QC) steps performed in the new SLSMF API service can be found in the [QC\_steps\_description](research_data/) file. This document provides information on the post-processing steps performed daily for the automated quality control of the sea level data obtained from the new SLSMF API web-service. QC examples for sea level stations are provided to illustrate the individual post-processing functions.   

### API access examples 

- A Jupyter notebook is provided through the file [SLSMF\_API\_access\_example](SLSMF_API_access_example.ipynb), explaining the steps involved in accessing sea level data through the new SLSMF API web-service. The notebook breaks down the user inputs though R code and directly visualises the output sea level time series. It acts as a hands-on guide, allowing users to better understand the integration of the API into their workflows and the types of operations it supports. The notebook needs to be downloaded and run locally.
- A collection of code examples using both MATLAB and R programming languages, demonstrating the various functionalities of the API web-service in line with the QC\_steps\_description document, can be found in the folder [Examples](Examples). These code samples are designed to provide users with practical illustrations of how the API can be used in different scenarios, showcasing its capabilities for retrieving, processing, and analyzing sea level data. 

## Project information

This repository was prepared within Task 2.5 "Virtual access to sea level data" of the Horizon Europe project Geo-INQUIRE ([https://doi.org/10.3030/101058518](https://doi.org/10.3030/101058518)). It is a collaborative work between the National Observatory of Athens ([NOA](http://www.noa.gr/en)), Greece, and the Flanders Marine Institute ([VLIZ](http://www.vliz.be/en)), Belgium.






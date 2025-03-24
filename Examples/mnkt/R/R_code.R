# install.packages(c("httr", "dplyr", "readr", "lubridate", "ggplot2"))

setwd("/Users/nkalligeris/Documents/NOA/projects/Geo-Inquire/Github_page/examples/dakar")

library(httr)
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

# Clear environment
rm(list = ls())

##########################################################################
# user inputs 

api_key <- '' # enter API key
station_ID <- 'mnkt'
sensor <- 'one-sensor'
days_per_page <- 360  # maximum number of days spanning a page, max 3650 days
start_date <- '2023-01-01'  # from date, included in result. Default is 8days in the past, 'YYYY-MM-DD'
end_date <- '2023-02-01'  # until date, not included in result. Default is day of request 'YYYY-MM-DD'
includesensors <- 'prs'
level_data <- 'true' # Level data relative to the mean sea level of 30 days.
original_stime <- 'false' # Return the stime not corrected by sensor rate.
filter_out_of_range <- 'true' # Remove out of range values
filter_exceeded_neighbours <- 'true' # Remove exceeded neighbours values
filter_spikes_via_median <- 'true' # Remove spikes via median values
filter_flat_line <- 'true' # Remove flat line

##########################################################################
# download and read research-quality sea level data

api_url <- 'https://api.ioc-sealevelmonitoring.org/v2/research/stations/'

# Calculate number of days and pages
no_of_days <- as.Date(end_date) - as.Date(start_date)
no_of_pages <- ceiling(no_of_days / days_per_page)

# Initialize an empty data frame to store sea level data
S <- data.frame()

# Loop to download data
for (i in 1:no_of_pages) {
  page <- i  # current page number requested
  
  # Building the custom URL
  if (nchar(includesensors) > 0) {
    url <- paste0(api_url, station_ID, '/sensors/', sensor, 
                  '/data?days_per_page=', days_per_page,
                  '&page=', page, 
                  '&timestart=', start_date, 
                  '&timestop=', end_date, 
                  '&includesensors[]=', includesensors, 
                  '&level_data=', level_data, 
                  '&original_stime=', original_stime, 
                  '&filter_out_of_range=', filter_out_of_range, 
                  '&filter_exceeded_neighbours=', filter_exceeded_neighbours,
                  '&filter_spikes_via_median=', filter_spikes_via_median, 
                  '&filter_flat_line=', filter_flat_line)
  } else {
    url <- paste0(api_url, station_ID, '/sensors/', sensor, 
                  '/data?days_per_page=', days_per_page,
                  '&page=', page, 
                  '&timestart=', start_date, 
                  '&timestop=', end_date, 
                  '&level_data=', level_data, 
                  '&original_stime=', original_stime, 
                  '&filter_out_of_range=', filter_out_of_range, 
                  '&filter_exceeded_neighbours=', filter_exceeded_neighbours,
                  '&filter_spikes_via_median=', filter_spikes_via_median, 
                  '&filter_flat_line=', filter_flat_line)
  }
  
  # Downloading the data
  message(paste('Downloading page', page, '/', no_of_pages, 'of the data requested'))
  response <- GET(url, add_headers(`X-Api-Key` = api_key, Accept = 'text/csv'))
  
  # Writing the output file(s)
  writeLines(content(response, "text"), con = paste0('SLSMF_tg_data_pg', page, '.txt'))
  
  # Read the tables back
  if (i == 1) {
    S <- read_tsv(paste0('SLSMF_tg_data_pg', page, '.txt'), skip = 2)
  } else {
    tmp <- read_tsv(paste0('SLSMF_tg_data_pg', page, '.txt'), skip = 2)
    S <- bind_rows(S, tmp)
  }
}

##########################################################################
# Download v1 API data without post-processing
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 30)
frm <- 'json' # format of the output file (max 30 days)
v1_api_url <- 'https://ioc-sealevelmonitoring.org/service.php?query=data'

# Building the custom URL
if (nchar(includesensors) > 0) {
  url_link <- paste0(v1_api_url, '&code=',station_ID, 
                     '&timestart=', start_date,'T00%3A00', 
                     '&timestop=', end_date,'T00%3A00',
                     '&format=', frm, 
                     '&includesensors[]=', includesensors) 
} else {
  url_link <- paste0(v1_api_url, '&code=',station_ID, 
                     '&timestart=', start_date,'T00%3A00', 
                     '&timestop=', end_date,'T00%3A00',
                     '&format=', frm) 
}
# Downloading the data
message(paste('Downloading v1 API data requested'))
tmp <- read_json(url_link,simplifyVector = TRUE)

# Process the table
Spre <- data.frame(stime = strptime(tmp$stime,format="%Y-%m-%d %H:%M:%S", tz = "GMT"), slevel = tmp[1])
##########################################################################
# plot the data

ggplot() +
  # Plot the S.stime and S.slevel
  geom_line(data = S, aes(x = stime, y = slevel), color = "black", linewidth = 1.5) +
  # Add the second plot (adjusting for mean)
  geom_line(data = Spre, aes(x = stime, y = slevel-mean(slevel)), linetype = "dashed", color = "red") +
  # Add legend and labels
  labs(
    title = paste("data for SLSMF station ID =", station_ID),
    x = "date",
    y = "WL (m)"
  ) +
  # Enable grid
  theme_minimal() +
  theme(panel.grid.major = element_line(color = "grey"),
        panel.grid.minor = element_line(color = "lightgrey"))
# install.packages(c("httr", "dplyr", "readr", "lubridate", "ggplot2"))

library(httr)
library(readr)
library(jsonlite)
library(dplyr)
library(lubridate)
library(ggplot2)

# Clear environment
rm(list = ls())

##########################################################################
# user inputs 

api_key <- '' # enter API key
station_ID <- 'laru2'
sensor <- 'one-sensor'
days_per_page <- 360  # maximum number of days spanning a page, max 365 days
start_date <- '2023-01-01'  # from date, included in result. Default is 8days in the past, 'YYYY-MM-DD'
end_date <- '2023-02-01'  # until date, not included in result. Default is day of request 'YYYY-MM-DD'
includesensors <- 'rad'
level_data <- 'true' # Level data relative to the mean sea level of 30 days.
flag_qc <- 'true' # show qc flags
fit_to_sample_rate <- 'true' # Return the stime not corrected by sensor rate.
filter_out_of_range <- 'true' # Set slevel to NA for records with out of range values\n,
filter_exceeded_neighbours <- 'true' # Set slevel to NA for records with exceeded neighbour values\n,
filter_spikes_via_median <- 'true' # Set slevel to NA for records with spikes via median values\n,
filter_flat_line <- 'true' # Set slevel to NA for records with flat lines\n,
filter_completeness <- 'false' # Set slevel to NA for days with low completeness\n,
filter_distinctness <- 'false' # Set slevel to NA for days with low distinctness\n,
filter_shift <- 'false' # Set slevel to NA for days with shift\n

##########################################################################
# download and read research-quality sea level data

api_research_data_url <- 'https://api.ioc-sealevelmonitoring.org/v2/research/stations/'

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
    url <- paste0(api_research_data_url, station_ID, '/sensors/', sensor,
                  '/data?days_per_page=', days_per_page,
                  '&page=', page,
                  '&timestart=', start_date,
                  '&timestop=', end_date,
                  '&includesensors[]=', includesensors,
                  '&level_data=', level_data,
                  '&flag_qc=', flag_qc,
                  '&fit_to_sample_rate=', fit_to_sample_rate,
                  '&filter_out_of_range=', filter_out_of_range,
                  '&filter_exceeded_neighbours=', filter_exceeded_neighbours,
                  '&filter_spikes_via_median=', filter_spikes_via_median,
                  '&filter_flat_line=', filter_flat_line,
                  '&filter_completeness=', filter_completeness,
                  '&filter_distinctness=', filter_distinctness,
                  '&filter_shift=', filter_shift)
  } else {
    url <- paste0(api_research_data_url, station_ID, '/sensors/', sensor,
                  '/data?days_per_page=', days_per_page,
                  '&page=', page,
                  '&timestart=', start_date,
                  '&timestop=', end_date,
                  '&level_data=', level_data,
                  '&flag_qc=', flag_qc,
                  '&fit_to_sample_rate=', fit_to_sample_rate,
                  '&filter_out_of_range=', filter_out_of_range,
                  '&filter_exceeded_neighbours=', filter_exceeded_neighbours,
                  '&filter_spikes_via_median=', filter_spikes_via_median,
                  '&filter_flat_line=', filter_flat_line,
                  '&filter_completeness=', filter_completeness,
                  '&filter_distinctness=', filter_distinctness,
                  '&filter_shift=', filter_shift)
  }

  # Downloading the data
  message(paste('Downloading page', page, '/', no_of_pages, 'of the v2 API data requested'))
  response <- GET(url, add_headers(`X-Api-Key` = api_key, Accept = 'text/csv'))

  # Writing the output file(s)
  data.table::fwrite(list(content(response, "text")), file = paste0('SLSMF_tg_data_pg', page, '.txt'), quote=F)

  # Read the tables back
  if (i == 1) {
    S <- read_tsv(paste0('SLSMF_tg_data_pg', page, '.txt'), skip = 2)
  } else {
    tmp <- read_tsv(paste0('SLSMF_tg_data_pg', page, '.txt'), skip = 2)
    S <- bind_rows(S, tmp)
  }
}

##########################################################################
# Download v2 API data without post-processing
api_realtime_data_url <- "https://api.ioc-sealevelmonitoring.org/v2/stations/"
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 30)

# Building the custom URL
if (nchar(includesensors) > 0) {
  url_link <- paste0(api_realtime_data_url, station_ID,
                     '/data?days_per_page=', days_per_page,
                     '&timestart=', start_date,'T00:00',
                     '&timestop=', end_date,'T00:00',
                     '&includesensors[]=', includesensors)
} else {
  url_link <- paste0(api_realtime_data_url, station_ID,
                     '/data?days_per_page=', days_per_page,
                     '&timestart=', start_date,'T00:00',
                     '&timestop=', end_date,'T00:00')
}

# Downloading the data
message(paste('Downloading page', page, '/', no_of_pages, 'of the v2 API data requested'))
response <- GET(url_link, add_headers(`X-Api-Key` = api_key, Accept = 'application/json'))
response <- content(response, as = "text", encoding = "UTF-8")
tmp <- fromJSON(response, simplifyVector = TRUE)
colnames(tmp) = gsub("data\\.", "", colnames(tmp))
tmp$stime <- as.POSIXct(tmp$stime,format="%Y-%m-%d %H:%M:%S",tz="UTC")
Spre = tmp

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
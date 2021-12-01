library(janitor)
library(dplyr)
library(tidyverse)
library(lubridate)

data<- read_csv("202011-divvy-tripdata.csv")

# Create new column for ride length and convert to seconds
data2 <- data %>% 
  # mutate(ride_length = hms::as_hms(difftime(ended_at,started_at,units="secs"))) %>% 
  mutate(ride_length_secs = difftime(ended_at,started_at,units="secs")) %>% 
  relocate(ride_length_secs, .after=ended_at)
     
# Create new column for day of week, trim station names, drop N/A, and rearrange
data3 <- data2 %>% 
  mutate(day_of_week = wday(started_at)) %>% 
  relocate(day_of_week, .after=ride_length_secs) %>% 
  arrange(started_at) %>% 
  drop_na()

# Drop rows with missing values
data3_drop_negatives <- data3 %>% 
  filter(ride_length_secs > 0)

# Write dataframe to csv file
write.csv(data3_drop_negatives,"202011-divvy-tripdata-cleaned.csv", row.names = FALSE)

# ----------------------------------------------------------------

# Import csv with all time periods combined (created in a separate script)
data_full<- read_csv("full-year-tripdata-cleaned.csv")

# Create df with unique start station names
start_name<-data_full %>% 
  select(start_station_name)
start_name<- start_name %>% 
  distinct()
count(start_name)

# Create df with unique end station names
end_name<-data_full %>% 
  select(end_station_name)
end_name<- end_name %>% 
  distinct()
count(end_name)

# Find if there are any station names that aren't in both start and stop station
exclusive_start_station<-anti_join(start_name, end_name, by=c("start_station_name" = "end_station_name"))
View(exclusive_start_station)
exclusive_end_station<-anti_join(end_name, start_name, by=c("end_station_name"="start_station_name"))
View(exclusive_end_station)

# Create master station id df with all stations and a unique id
start_name_rn<- start_name %>% 
  rename(station_name = start_station_name)
exclusive_end_station_rn<- exclusive_end_station %>% 
  rename(station_name = end_station_name)

station_id_master <- rbind(start_name_rn, exclusive_end_station_rn)

station_id_master<- arrange(station_id_master,station_name)

station_id_master<- station_id_master%>% 
  mutate(station_id = row_number())
view(station_id_master)

# Map station id values and add to full data
data_full_final <- merge(x=data_full, y=station_id_master, by.x="start_station_name", by.y="station_name")
data_full_final<- data_full_final %>% 
  rename(start_station_id_new = station_id)

data_full_final <- merge(x=data_full_final, y=station_id_master, by.x="end_station_name", by.y="station_name")
data_full_final<- data_full_final %>% 
  rename(end_station_id_new = station_id)
# Remove old station_id and longitude/latitude column
data_full_final <- subset(data_full_final, select = -c(start_station_id, end_station_id, start_let, start_lng,
                                                       end_lat, end_lng))

# Create column for ride length in mins
data_full_final <- data_full_final %>% 
  mutate(ride_length_mins = (ride_length_secs/60))

# Write dataframe to csv file
write.csv(data_full,"full-year-tripdata-cleaned.csv", row.names = FALSE)


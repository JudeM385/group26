## Loading necessary libraries
library(tidyverse)
library(dplyr)

## Loading the data
elevation_data = read.csv("xc_rank.csv")
elevation_data = subset(elevation_data, select = c(Team))

## Finding the unique teams
elevation_data = 
  elevation_data %>% 
  group_by(Team) %>% 
  summarise(count = n_distinct(Team))

## Removing count column
elevation_data = subset(elevation_data, select = c(Team))

## Adding new elevation column
elevation_data$elevation = NA

## Saving formatted df as a csv file
write.csv(elevation_data, "XC_Team_Elevation.csv", row.names = FALSE)



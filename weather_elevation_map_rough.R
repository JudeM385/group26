#### Script Explanation:
# Data Wrangling: Various csv files holding data specific to XC Teams will be accessed and combined into a working df
# This working dataframe will have the team as the unit of interest
# Visualization: An interactive plotly visualization will be created from the resulting df
# This viz will be specific to each teams relative success/challenges when racing in different weather conditions
# Weather data collected from: weatherspark.com


#### Loading necessary libraries ####
# library(maps)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)


#### Accessing Data ####
lat_long_data <- read.csv("XC_Team_Elevation_Lat_Long.csv")
ranking_data <- read.csv("updated_xc_rank.csv")
weather_data <- read.csv("xc_basic_weather_data.csv", fileEncoding = "UTF-8-BOM")


#### Merging ranking and lat_long data frames ####
xc_merge <- left_join(ranking_data, lat_long_data, by = c("Team"))
## Saving merged df for team use
# write.csv(xc_merge, "Merged_Ranking_Lat_Long.csv", row.names = FALSE)


#### Filtering weather data to only have four weather conditions: wind, sun, snow, rain ####
filtered_weather_data <-
  weather_data %>%
  filter(Year == "2017" | Year == "2018" | Year == "2019" | Year == "2021")


#### Merging weather data with xc_merge ####
weather_merge <- left_join(xc_merge, filtered_weather_data)


#### Splitting the data into two seperate dataframes: one male - one female ####
xc_men <-
  weather_merge %>%
  filter(Gender == "Men")

xc_women <-
  weather_merge %>%
  filter(Gender == "Women")


#### Defining variables for visualization ####
## Styling the Geographic Area being displayed
# Will result in graph of only the USA
geo <- list(
  scope = "usa",
  projection = list(type = "albers usa"),
  showland = TRUE,
  landcolor = toRGB("gray95"),
  subunitcolor = toRGB("gray85"),
  countrycolor = toRGB("gray85"),
  countrywidth = 0.5,
  subunitwidth = 0.5
)


#### Creating XC Men's Teams Visualization ####
## Creating geographic plot
fig_men <- plot_geo(na.omit(xc_men), lat = ~lat, lon = ~long)
## Adding markers and hover stats.
fig_men <- fig_men %>% add_markers(
  text = ~ paste(Team,
    paste("Elevation (ft):", elevation),
    paste("National Placement: ", Rank),
    paste("Previous Week Ranking: ", Previous.Rank),
    sep = "<br />"
  ),
  color = ~Change,
  symbol = I("square"),
  size = I(60),
  hoverinfo = "text",
  colors = "RdYlGn",
  frame = ~Weather_Condition
)
## Adding legend and legend title
fig_men <- fig_men %>% colorbar(title = "Legend:<br />Placement at National Meet<br />Compared to<br />Previous Week Ranking")
## Adding viz title and defining the geographic region to display
fig_men <- fig_men %>% layout(
  title = "NCAA Men's Cross Country Teams Performance Dependent on Weather<br />(Hover for info)",
  geo = geo
)
## Adding slider animation
fig_men <- ggplotly(fig_men) %>%
  animation_opts(1000, easing = "elastic", redraw = FALSE) %>%
  animation_button(x = 1, xanchor = "right", y = 0, yanchor = "bottom") %>%
  animation_slider(currentvalue = list(prefix = "Weather Condition: ", font = list(color = "red")))
## Displaying the figure for the XC Men's Teams
fig_men


#### Creating XC Womens Teams Visualization ####
## Creating geographic plot
fig_women <- plot_geo(na.omit(xc_women), lat = ~lat, lon = ~long)
## Adding markers and hover stats.
fig_women <- fig_women %>% add_markers(
  text = ~ paste(Team,
    paste("Elevation (ft):", elevation),
    paste("National Placement: ", Rank),
    paste("Previous Week Ranking: ", Previous.Rank),
    sep = "<br />"
  ),
  color = ~Change,
  symbol = I("square"),
  size = I(60),
  hoverinfo = "text",
  colors = "RdYlGn",
  frame = ~Weather_Condition
)
## Adding legend and legend title
fig_women <- fig_women %>% colorbar(title = "Legend:<br />Placement at National Meet<br />Compared to<br />Previous Week Ranking")
## Adding viz title and defining the geographic region to display
fig_women <- fig_women %>% layout(
  title = "NCAA Women's Cross Country Teams Performance Dependent on Weather<br />(Hover for info)",
  geo = geo
)
## Adding slider animation
fig_women <- ggplotly(fig_women) %>%
  animation_opts(1000, easing = "elastic", redraw = FALSE) %>%
  animation_button(x = 1, xanchor = "right", y = 0, yanchor = "bottom") %>%
  animation_slider(currentvalue = list(prefix = "Weather Condition: ", font = list(color = "red")))
## Displaying the figure for the XC Men's Teams
fig_women


#### Saving visuals as a html files ####
htmlwidgets::saveWidget(as_widget(fig_men), "men_weather_dependent.html")
htmlwidgets::saveWidget(as_widget(fig_women), "women_weather_dependent.html")

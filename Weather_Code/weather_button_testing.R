#### Loading necessary libraries ####
# library(maps)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)


#### Accessing Data ####
lat_long_data <- read.csv("XC_Team_Elevation_Lat_Long.csv")
ranking_data <- read.csv("updated_xc_rank.csv")
weather_data <- read.csv("Weather_Data/xc_basic_weather_data.csv", fileEncoding = "UTF-8-BOM")


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


#### Defining variables for visualization ####
## Styling the Geographic Area being displayed
# Will result in graph of only the USA
geo <- list(
  scope = "usa",
  projection = list(type = "albers usa"),
  showland = TRUE,
  landcolor = toRGB("white"),
  lakecolor = toRGB("white"),
  subunitcolor = toRGB("grey85"),
  countrycolor = toRGB("grey85"),
  coastlinecolor = toRGB("black"),
  countrywidth = 0.5,
  subunitwidth = 0.5
)


#### Creating XC Men's Teams Visualization ####
## Creating geographic plot
fig_men <- plot_geo(na.omit(xc_men), lat = ~lat, lon = ~long, stroke = I("black"))
#fig_men = fig_men %>% group_by(Weather_Condition)
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
  colors = "RdYlGn"#,
  #frame = ~Weather_Condition
)
## Adding legend and legend title
fig_men <- fig_men %>% colorbar(title = "Legend:<br />Placement at National Meet<br />Compared to<br />Previous Week Ranking")
## Adding viz title and defining the geographic region to display
fig_men <- fig_men %>% layout(
  title = "NCAA Men's Cross Country Teams Performance Dependent on Weather<br />(Hover for info)",
  geo = geo,
  updatemenus = list(
    list(
      type = "list",
      label = "Weather_Condition: ",
      buttons = list(
        list(method = "restyle",
             args = list("visible", c(TRUE, FALSE, FALSE, FALSE)),
             label = "Sun (Year 2021)"),
        list(method = "restyle",
             args = list("visible", c(FALSE, TRUE, FALSE, FALSE)),
             label = "Rain (Year 2019)"),
        list(method = "restyle",
             args = list("visible", c(FALSE, FALSE, TRUE, FALSE)),
             label = "Snow (Year 2018)"),
        list(method = "restyle",
             args = list("visible", c(FALSE, FALSE, FALSE, TRUE)),
             label = "Wind (Year 2017)")
      )
    )
  )
)
## Adding slider animation
#fig_men <- ggplotly(fig_men) %>%
#  animation_opts(1000, easing = "elastic", redraw = FALSE) %>%
#  animation_button(x = 1, xanchor = "right", y = 0, yanchor = "bottom") %>%
#  animation_slider(currentvalue = list(prefix = "Weather Condition: ", font = list(color = "red")))
## Displaying the figure for the XC Men's Teams
fig_men
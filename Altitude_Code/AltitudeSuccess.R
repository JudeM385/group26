#### Loading necessary libraries ####
# library(maps)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)


#### Accessing Data ####
xc_men <- read.csv("Ranking_Data/men_team_caliber.csv")
xc_women <- read.csv("Ranking_Data/women_team_caliber.csv")

#### Create total change variable
xc_men = xc_men %>%
  mutate(total_change = Average.Change * Appearances)
xc_women = xc_women %>%
  mutate(total_change = Average.Change * Appearances)

#### Bin altitude into two groups
xc_men = xc_men %>% mutate(elevation_group = cut(elevation, breaks = 2, labels=c("Low Altitude", "High Altitude")))
xc_women = xc_women %>% mutate(elevation_group = cut(elevation, breaks = 2, labels=c("Low Altitude", "High Altitude")))

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
## Adding markers and hover stats.
fig_men <- fig_men %>% add_markers(
  text = ~ paste(
    paste("School: ", Team),
    paste("NCAA Appearances in 11 Years: ", Appearances),
    paste("Average National Placement: ", Average.Rank),
    paste("Average Previous Week Ranking: ", Average.Previous.Rank),
    paste("Average Change: ", Average.Change),
    paste("(Average Change x Appearances):", total_change),
    paste("Elevation: ", elevation),
    sep = "<br />"
  ),
  color = ~total_change,
  symbol = I("circle"),
  size = I(50),
  hoverinfo = "text",
  colors = "RdYlGn",
  frame = ~elevation_group
)
## Adding legend and legend title
fig_men <- fig_men %>% colorbar(title = "Legend:<br />Average Placement at National Meet<br />Compared to<br />Average Previous Week Ranking <br /> Multiplied by Appearances")
## Adding viz title and defining the geographic region to display
fig_men <- fig_men %>% layout(
  title = "NCAA Men's Cross Country Teams Performance Dependent on Altitude<br />(Hover for info)",
  geo = geo
)
## Adding slider animation
fig_men <- ggplotly(fig_men) %>%
  animation_opts(1000, easing = "elastic", redraw = FALSE) %>%
  animation_slider(currentvalue = list(prefix = "Elevation Group: ", font = list(color = "Black")))

## Displaying the figure for the XC Men's Teams
fig_men


#### Creating XC Womens Teams Visualization ####
## Creating geographic plot
fig_women <- plot_geo(na.omit(xc_men), lat = ~lat, lon = ~long, stroke = I("black"))
## Adding markers and hover stats.
fig_women <- fig_women %>% add_markers(
  text = ~ paste(
    paste("School: ", Team),
    paste("NCAA Appearances in 11 Years: ", Appearances),
    paste("Average National Placement: ", Average.Rank),
    paste("Average Previous Week Ranking: ", Average.Previous.Rank),
    paste("Average Change: ", Average.Change),
    paste("(Average Change x Appearances):", total_change),
    paste("Elevation: ", elevation),
    sep = "<br />"
  ),
  color = ~total_change,
  symbol = I("circle"),
  size = I(50),
  hoverinfo = "text",
  colors = "RdYlGn",
  frame = ~elevation_group
)
## Adding legend and legend title
fig_women <- fig_women %>% colorbar(title = "Legend:<br />Average Placement at National Meet<br />Compared to<br />Average Previous Week Ranking <br /> Multiplied by Appearances")
## Adding viz title and defining the geographic region to display
fig_women <- fig_women %>% layout(
  title = "NCAA Women's Cross Country Teams Performance Dependent on Altitude<br />(Hover for info)",
  geo = geo
)
## Adding slider animation
fig_women <- ggplotly(fig_women) %>%
  animation_opts(1000, easing = "elastic", redraw = FALSE) %>%
  animation_slider(currentvalue = list(prefix = "Elevation Group: ", font = list(color = "Black")))

## Displaying the figure for the XC Women's Teams
fig_women


#### Saving visuals as a html files ####
htmlwidgets::saveWidget(as_widget(fig_men), "men_elevation_dependent.html")
htmlwidgets::saveWidget(as_widget(fig_women), "women_elevation_dependent.html")


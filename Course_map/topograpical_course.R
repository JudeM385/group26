# ---------------------------------------------------
# Import Libraries
# ---------------------------------------------------

library(tidyverse)
library(leaflet)
library(htmltools)
library(htmlwidgets)
library(leaflet.extras)
library(raster)
library(lidR)
library(terra)



# ---------------------------------------------------
# Import Data for size & location
# ---------------------------------------------------

# Read Data
tal_dat = lidR::readLAS("Course_Map/utm_points.laz")

# Convert to dataframe
tal_dat = payload(tal_dat)

# Convert UTM to latitude & longitude
points = cbind(tal_dat$X, tal_dat$Y)
v <- vect(points, crs="+proj=utm +zone=16 +datum=WGS84  +units=m")
y <- project(v, "+proj=longlat +datum=WGS84")
lonlat <- as_tibble(geom(y)[, c("x", "y")])



# ---------------------------------------------------
# Get Elevation Data
# ---------------------------------------------------

# Corners of box for map
bbox <- list(
  p1 = list(long = min(lonlat$x), lat = min(lonlat$y)),
  p2 = list(long = max(lonlat$x), lat = max(lonlat$y))
)

# Function for matching size of raster image to box
# Function from: https://wcmbishop.github.io/rayshader-demo/
define_image_size <- function(bbox, major_dim = 400) {
  # calculate aspect ration (width/height) from lat/long bounding box
  aspect_ratio <- abs((bbox$p1$long - bbox$p2$long) / (bbox$p1$lat - bbox$p2$lat))
  # define dimensions
  img_width <- ifelse(aspect_ratio > 1, major_dim, major_dim*aspect_ratio) %>% round()
  img_height <- ifelse(aspect_ratio < 1, major_dim, major_dim/aspect_ratio) %>% round()
  size_str <- paste(img_width, img_height, sep = ",")
  list(height = img_height, width = img_width, size = size_str)
}


# Function that gets data from USGS
# Function from: https://wcmbishop.github.io/rayshader-demo/
get_usgs_elevation_data <- function(bbox, size = "400,400", file = NULL, 
                                    sr_bbox = 4326, sr_image = 4326) {
  require(httr)
  
  # TODO - validate inputs
  
  url <- parse_url(
    "https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/exportImage"
  )
  res <- GET(
    url, 
    query = list(
      bbox = paste(bbox$p1$long, bbox$p1$lat, bbox$p2$long, bbox$p2$lat,
                   sep = ","),
      bboxSR = sr_bbox,
      imageSR = sr_image,
      size = size,
      format = "tiff",
      pixelType = "F32",
      noDataInterpretation = "esriNoDataMatchAny",
      interpolation = "+RSP_BilinearInterpolation",
      f = "json"
    )
  )
  
  if (status_code(res) == 200) {
    body <- content(res, type = "application/json")
    # TODO - check that bbox values are correct
    # message(jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE))
    
    img_res <- GET(body$href)
    img_bin <- content(img_res, "raw")
    if (is.null(file)) 
      file <- tempfile("elev_matrix", fileext = ".tif")
    writeBin(img_bin, file)
    message(paste("image saved to file:", file))
  } else {
    warning(res)
  }
  invisible(file)
}

# Define image size
image_size <- define_image_size(bbox, major_dim = 1000)

# Get elevation data
elev_file <- file.path("Course_Map/data", "tal_elevation.tif")
get_usgs_elevation_data(bbox, size = image_size$size, file = elev_file,
                        sr_bbox = 4326, sr_image = 4326)


# ---------------------------------------------------
# Save elevation data as raster & dataframe
# ---------------------------------------------------

# Save as raster
tal <- raster("Course_Map/data/tal_elevation.tif")

# Convert raster to df
tal_df = as.data.frame(tal, xy=TRUE)
tal_df = as_tibble(tal_df)

# ---------------------------------------------------
# Extract Metadata for Map markers
# ---------------------------------------------------

# Set dataframes for top & bottom of hills
tops = tibble("x" = numeric(),
              "y" = numeric(),
              "Elevation" = numeric())
bottoms = tibble("x" = numeric(),
                 "y" = numeric(),
                 "Elevation" = numeric())

# Data for marker 1
bot1 = tal_df %>%
  filter(x > -84.1538 & x < -84.1536 & y < 30.42836& y >30.42834)
bot1 = bot1[bot1$tal_elevation == min(bot1$tal_elevation),]

# Data for marker 2
top1 = tal_df %>%
  filter(x > -84.15602 & x < -84.15600 & y < 30.42996& y >30.42994)
top1 = top1[top1$tal_elevation == max(top1$tal_elevation),]

bottoms[1,] = list(bot1$x,bot1$y,(top1$tal_elevation - bot1$tal_elevation))

# Data for marker 3
bot2 = tal_df %>%
  filter(x > -84.15802 & x < -84.15800 & y < 30.43040& y >30.43038)
bot2 = bot2[bot2$tal_elevation == min(bot2$tal_elevation),]
tops[1,] = list(top1$x,top1$y,(bot2$tal_elevation - top1$tal_elevation))

# Data for marker 4
top2 = tal_df %>%
  filter(x > -84.15861 & x < -84.15859 & y < 30.42781 & y >30.42779)
top2 = top2[top2$tal_elevation == max(top2$tal_elevation),]
bottoms[2,] = list(bot2$x,bot2$y,(top2$tal_elevation - bot2$tal_elevation))

# Data for marker 5
bot3 = tal_df %>%
  filter(x > -84.15391 & x < -84.15389 & y < 30.42701& y >30.42699)
bot3 = bot3[bot3$tal_elevation == min(bot3$tal_elevation),]
tops[2,] = list(top2$x,top2$y,(bot3$tal_elevation - top2$tal_elevation))

# Data for marker 6
top3 = tal_df %>%
  filter(x > -84.15166 & x < -84.15164 & y < 30.42711 & y >30.42709)
top3 = top3[top3$tal_elevation == max(top3$tal_elevation),]
bottoms[3,] = list(bot3$x,bot3$y,(top3$tal_elevation - bot3$tal_elevation))

# Data for marker 7
bot4 = tal_df %>%
  filter(x > -84.14841 & x < -84.14839 & y < 30.42925& y >30.42923)
bot4 = bot4[bot4$tal_elevation == min(bot4$tal_elevation),]
tops[3,] = list(top3$x,top3$y,(bot4$tal_elevation - top3$tal_elevation))

# Data for marker 8
top4 = tal_df %>%
  filter(x > -84.15082 & x < -84.15080 & y < 30.42872 & y >30.42870)
top4 = top4[top4$tal_elevation == max(top4$tal_elevation),]
bottoms[4,] = list(bot4$x,bot4$y,(top4$tal_elevation - bot4$tal_elevation))

# ---------------------------------------------------
# Create icons for markers
# ---------------------------------------------------
up_arrow_icon <- makeIcon(
  iconUrl = "uparrow.png",
  iconWidth = 25, iconHeight = 25,
  iconAnchorX = 0, iconAnchorY = 0
)

down_arrow_icon <- makeIcon(
  iconUrl = "downarrow.png",
  iconWidth = 25, iconHeight = 25,
  iconAnchorX = 0, iconAnchorY = 0
)

# ---------------------------------------------------
# Create visualization
# ---------------------------------------------------

# Palatte for raster overlay
pal_red <- colorNumeric(c("#fff5f0","#fee0d2","#fcbba1","#fc9272","#fb6a4a","#ef3b2c","#cb181d","#a50f15","#67000d"), values(tal),na.color = "transparent")

# Create leaflet of course 
m = leaflet() %>%
  addTiles() %>% 
  fitBounds(
    lng1 = bbox$p1$long, lat1 = bbox$p1$lat,
    lng2 = bbox$p2$long, lat2 = bbox$p2$lat,
  ) %>%
  
  # Add markers on map
  addMarkers(lng = bottoms$x,lat = bottoms$y,popup=paste("Uphill Starting Here:\n", round(bottoms$Elevation,2),"m", sep = " "), icon = up_arrow_icon) %>%
  addMarkers(lng = tops$x,lat = tops$y, popup=paste("Downhill Starting Here:\n:", round(tops$Elevation,2),"m", sep = " "), icon = down_arrow_icon) %>%
  
  # Add raster image overlay for heatmap of elevations
  addRasterImage(tal,opacity = .5,colors = pal_red) %>%
  
  # Add a legend for the heatmap
  addLegend("topright", colors= c("#fff5f0", "#67000d"), 
            labels=c(paste(round(min(tal_df$tal_elevation),1),"m", sep = " "), 
                     paste(round(max(tal_df$tal_elevation),1),"m", sep = " ")), 
            title="Elevation")
#m

# Save as an html file
saveWidget(m, file="Course_map/map.html")
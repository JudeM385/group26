### Read in library
library(stringr)
library(tidyverse)

### Read in dataframe
df<-read.csv("Ranking_Data/xc_rank.csv")

###Replace Receiving Votes with NR
df$Change[df$Change == "(LW: RV)"] <- "NR"

###Split column
split<-str_split_fixed(df$Change, "\\(", 2)
df$Change<-split[,1]
df$`Previous Rank`<-split[,2]

###Remove arrows
df$Change = gsub("◀▶", 0, df$Change)
df$Change = gsub("▲", "", df$Change)
df$Change = gsub("▼", "-", df$Change)

###Add NR to Previous Rank Column
df$`Previous Rank` = gsub("LW:", "", df$`Previous Rank`)
df$`Previous Rank` = gsub("\\)", "", df$`Previous Rank`)
df$`Previous Rank`[df$Change == "NR"] <- df$Change[df$Change == "NR"]

###Calculate change (31-Current Rank)
df$`Previous Rank` = gsub("NR", 32, df$`Previous Rank`) # Replace Unranked with 32
df$`Previous Rank` = as.numeric(df$`Previous Rank`)
df$ChangeNew = (df$`Previous Rank`-df$Rank)

## Add Categorical
df$`Previous Ranking Class` <- "Ranked"
df$`Previous Ranking Class`[df$Change == "NR"] <- df$Change[df$Change == "NR"]
df$`Previous Ranking Class`[df$`Previous Ranking Class` == "NR"] <- "Unranked"

## Reorder Dataframe
df<- df[c(1:4, 12, 11, 13, 6:10)]

## Rename New Change
df <- df %>% rename(Change = ChangeNew)

## Save csv
write.csv(df, "updated_xc_rank.csv", row.names=FALSE)

## Now find the sum of the reverse rank in order to see which teams performed really well over the span of the entire 10 years
df$team_performance<-(32 - df$Rank)
df$reg_season_performance<-(32 - df$Previous.Rank)

### Summarize by team
sum_df <- df[c(1:3,5,6,13:14)]
sum_df <- sum_df %>%
  group_by(Team) %>%
  summarize(across(everything(), sum))

## Reduce variables
sum_df <-sum_df[c(1,6:7)]

## Normalize
normalized <- function(x) (x- min(x))/(max(x) - min(x))
sum_df$reverse_rank <- normalized(sum_df$reverse_rank)
sum_df$reverse_previous <- normalized(sum_df$reverse_previous)

## Write to csv
write.csv(sum_df, "team_caliber.csv", row.names=FALSE)

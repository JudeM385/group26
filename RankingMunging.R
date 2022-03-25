### Read in library
library(stringr)
library(tidyverse)

### Read in dataframe
df<-read.csv("xc_rank.csv")

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
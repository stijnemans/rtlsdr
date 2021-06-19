library(readr)
fist_dump_030621 <- read_delim("sec2_dump_030621.txt", 
                                   "\t", escape_double = FALSE, col_names = FALSE, 
                                   trim_ws = TRUE)


library(dplyr)
library(tidyr)

## assign data to df ##
df <- freq938_6_G40_060621_1518

df <- df %>%
  .[-c(1:which(grepl("IMSI", df$X1) == TRUE)[1]-1),] 


df2 <- data.frame()
tomatch <- c("IMSI", "Association IMSI", "Mobile Country Code", "Mobile Network Code", "Arrival Time", "Signal Level")
for(i in 0:23359) {
  print(i)
  index <- seq(1,6, by=1) + (6 * i)
  print(index)
  dat <- df[index,]
  A <- grepl(tomatch[1], dat$X1[1])
  B <- grepl(tomatch[2], dat$X1[2])
  C <- grepl(tomatch[3], dat$X1[3])
  D <- grepl(tomatch[4], dat$X1[4])
  E <- grepl(tomatch[5], dat$X1[5])
  F <- grepl(tomatch[6], dat$X1[6])
  matches <- c(A, B, C, D, E, F)
  if (all(matches == TRUE)) {
    df2 <- rbind(df2, dat)}
  else {next}
  }


## data wrangling & pivot & clean-up

df <- df2 %>%
  separate(X1,c("descr", "value"), sep=": ") %>%
  mutate(index = rep(1:(nrow(df2)/6), each=6)) %>%
  pivot_wider(names_from = "descr") %>%
  separate("Arrival Time", c("day", "rest"), sep=", ") %>%
  separate("rest", c("year", "time", "indicator"), sep=" ") %>%
  na.omit(time)

## replace time date studff ##

df2 <- df %>%
  separate("day", c("month", "day"), sep="  ") %>%
  mutate(month = which(month.abb %in% month == TRUE))

## adjust time ##

df2$time <- as.character(gsub("\\..*","",df2$time))

## make data-time feature

df2 <- df2 %>%
  unite(date_time, c(year, month, day), sep="-") %>%
  unite(date_time2, c(date_time, time), sep=" ")

library(lubridate)
df2 <- df2 %>%
  filter(IMSI != "NULL") %>%
  mutate(level = as.numeric(`Signal Level (dBm)`)) %>%
  mutate(IMSI = as.numeric(unlist(IMSI))) %>%
  mutate(date_time2 = ymd_hms(date_time2))




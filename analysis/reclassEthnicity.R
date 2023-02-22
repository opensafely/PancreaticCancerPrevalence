

#library(Rcpp)
#library(feather)
#install.packages("arrow")
library(arrow)
library(tidyverse)
library(here)


fe <- read_feather(here::here("output", "input_ethnicity.feather"))

fe$ethnicity <- as.character(fe$ethnicity)

fe$ethnicity[which(fe$ethnicity %in% c("Chinese","Mixed"))] <- "Chinese&Mixed"
### this creates 2 entries per months of the same name - it is then required to add it up





### INFO
# project: Project #: Prostate cancer prevalence
# author: Agz Leman
# 12th October 2022
# Plots monthly rates 
###

## library
library(tidyverse)
library(here)
library(MASS)
library(plyr)

## Redactor code (W.Hulme)
redactor <- function(n, threshold=7,e_overwrite=NA_integer_){
  # given a vector of frequencies, this returns a boolean vector that is TRUE if
  # a) the frequency is <= the redaction threshold and
  # b) if the sum of redacted frequencies in a) is still <= the threshold, then the
  # next largest frequency is also redacted
  n <- as.integer(n)
  leq_threshold <- dplyr::between(n, 1, threshold)
  n_sum <- sum(n)
  # redact if n is less than or equal to redaction threshold
  redact <- leq_threshold
  # also redact next smallest n if sum of redacted n is still less than or equal to threshold
  if((sum(n*leq_threshold) <= threshold) & any(leq_threshold)){
    redact[which.min(dplyr::if_else(leq_threshold, n_sum+1L, n))] = TRUE
  }
  n_redacted <- if_else(redact, e_overwrite, n)
}

start <- "2020-03-01"

for (i in c("measure_incidence_rate.csv",
            "measure_prevalence_rate.csv","measure_mortality_rate.csv")){
  
  Rates <- read_csv(here::here("output", "measures", i))
  Rates_rounded <- as.data.frame(Rates)
  
  ###
  # Redact and round counts 
  ###
  # was redacted within the measures function - small number suppression 
  # Round and recalc rates 
  for (j in 1:2){
    Rates_rounded[,j] <- plyr::round_any(Rates_rounded[,j], 5, f = round)}
  
  Rates_rounded$value <- Rates_rounded[,1]/Rates_rounded$population
  # calc rate per 100,000
  Rates_rounded$value2 <- Rates_rounded$value*100000
  write.table(Rates_rounded, here::here("output", paste0("Rates_rounded_",colnames(Rates_rounded)[1],".csv")),
              sep = ",",row.names = FALSE)
  ###### cut date that is after November 
  

###
# Plot 
###
p <- ggplot(data = Rates_rounded,aes(date, value2)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = paste0(colnames(Rates_rounded)[1]), 
       x = "", y = "Rate per 100,000")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(value2)+(sd(value2)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP December 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename=paste0(colnames(Rates_rounded)[1],".png"), path=here::here("output"),
)
}

for (i in c("measure_incidencebyAge_rate.csv","measure_incidencebyEthnicity_rate.csv",
            "measure_incidencebyIMD_rate.csv","measure_incidencebyRegion_rate.csv",
            "measure_prevalencebyAge_rate.csv","measure_prevalencebyEthnicity_rate.csv",
            "measure_prevalencebyIMD_rate.csv","measure_prevalencebyRegion_rate.csv")){
  
  Rates <- read_csv(here::here("output", "measures", i))
  Rates_rounded <- as.data.frame(Rates)
  
  ###
  # Redact and round counts 
  ###
  # was redacted within the measures function - small number suppression 
  # Round and recalc rates 
  for (j in 2:3){
    Rates_rounded[,j] <- plyr::round_any(Rates_rounded[,j], 5, f = round)}
  
  Rates_rounded$value <- Rates_rounded[,2]/Rates_rounded$population
  # calc rate per 100,000
  Rates_rounded$value2 <- Rates_rounded$value*100000
  write.table(Rates_rounded, here::here("output", paste0("Rates_rounded_",colnames(Rates_rounded)[2],"_by_",colnames(Rates_rounded)[1],".csv")),
              sep = ",",row.names = FALSE)

  
p <- ggplot(data = Rates_rounded,aes(date, value2, color = Rates_rounded[,1], lty = Rates_rounded[,1])) +
  geom_line()+
  #geom_point(color = "region")+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = paste0(substr(i, 9, 17),"_by_",colnames(Rates_rounded)[1]), 
       x = "", y = "Rate per 100,000")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(value2)+(sd(value2)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP December 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename=paste0(substr(i, 9, 17),"_by_",colnames(Rates_rounded)[1],".png"), path=here::here("output"),
)
}

###
# Summarise population data from the input.csv
###

#Input <- read_csv(here::here("output", "input.csv"),show_col_types = FALSE)
Input <- read_csv(here::here("output", "input.csv"),col_types = cols(patient_id = col_integer()))

Table1 <- as.data.frame(NA)
xx <- c("total_number","average_age","sd_age")
Table1[xx] <- NA
Table1[1,"total_number"] <- plyr::round_any(length(which(Input$prostate_ca==1)), 5, f = round)
Input2 <- Input[Input$prostate_ca==1,]

Table1[1,"average_age"] <- mean(Input2$age_pa_ca)
Table1[1,"sd_age"] <- sd(Input2$age_pa_ca)
Table1[names(table(Input2$ethnicity))] <- NA
Table1[1,names(table(Input2$ethnicity))] <- plyr::round_any(as.numeric(table(Input2$ethnicity)), 5, f = round)
Table1[names(table(Input2$sex))] <- NA
Table1[1,names(table(Input2$sex))] <- plyr::round_any(as.numeric(table(Input2$sex)), 5, f = round)

write.table(Table1, here::here("output", "Table1.csv"),sep = ",",row.names = FALSE)





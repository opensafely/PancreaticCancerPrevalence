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
  Rates <- as.data.frame(Rates)
  ###
  # Redact and round counts 
  ###
  #Rates[,1] <- redactor(Rates[,1])
  #Rates[,1] <- round_any(Rates[,1],5)

###
# Plot count ADT injectables 
###
p <- ggplot(data = Rates,aes(date, value)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = paste0(colnames(Rates)[1]), 
       x = "", y = "Rate per 1000")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(Rates$value)+(sd(Rates$value)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP December 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename=paste0(colnames(Rates)[1],".png"), path=here::here("output"),
)
}

for (i in c("measure_incidencebyAge_rate.csv","measure_incidencebyEthnicity_rate.csv",
            "measure_incidencebyIMD_rate.csv","measure_incidencebyRegion_rate.csv",
            "measure_prevalencebyAge_rate.csv","measure_prevalencebyEthnicity_rate.csv",
            "measure_prevalencebyIMD_rate.csv","measure_prevalencebyRegion_rate.csv")){
  
  Rates <- read_csv(here::here("output", "measures", i))
  Rates <- as.data.frame(Rates)
  ###
  # Redact and round counts 
  ###
  #Rates[,1] <- redactor(Rates[,1])
  #Rates[,1] <- round_any(Rates[,1],5)
  
  ###
  # Plot count ADT injectables 
  ###

p <- ggplot(data = Rates,aes(date, value, color = Rates[,1], lty = Rates[,1])) +
  geom_line()+
  #geom_point(color = "region")+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = paste0(substr(i, 9, 17),"_by_",colnames(Rates)[1]), 
       x = "", y = "Rate per 1000")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(Rates$value)+(sd(Rates$value)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP December 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename=paste0(substr(i, 9, 17),"_by_",colnames(Rates)[1],".png"), path=here::here("output"),
)
}


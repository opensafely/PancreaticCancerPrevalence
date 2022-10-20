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

ADTinj_Rates <- read_csv(here::here("output", "measures", "measure_ADT_inj_rate.csv"))
###
# Redact and round counts 
###
ADTinj_Rates$ADTinj <- redactor(ADTinj_Rates$ADTinj) 
ADTinj_Rates$ADTinj <- round_any(ADTinj_Rates$ADTinj,5)

###
# Plot count ADT injectables 
###
p <- ggplot(data = ADTinj_Rates,
                    aes(date, ADTinj)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT injectable medications", 
       x = "", y = "Number of prescriptions")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(ADTinj_Rates$ADTinj)+(sd(ADTinj_Rates$ADTinj)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADTinj_count1.png", path=here::here("output"),
)

###
# rates per 100,000
###
ADTinj_Rates$rate <- ADTinj_Rates$ADTinj / ADTinj_Rates$population * 100000
p <- ggplot(data = ADTinj_Rates, aes(date, rate)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT injectable medications", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(ADTinj_Rates$rate)+(sd(ADTinj_Rates$rate)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADTinj_rates1.png", path=here::here("output"),
)

###
# rates per 100,000 ****by region***
###
Region <- read_csv(here::here("output", "measures", "measure_ADTinjbyRegion_rate.csv"))
Region$rate <- Region$ADTinj / Region$population * 100000

p <- ggplot(data = Region,
            aes(date, rate, color = region, lty = region)) +
  geom_line()+
  #geom_point(color = "region")+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT injectable medications by Region", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADTinjbyRegion1.png", path=here::here("output"),
)

####
# rates per 100,000 ****by IMD***
####
IMD <- read_csv(here::here("output", "measures", "measure_ADTinjbyIMD_rate.csv"))
IMD$rate <- IMD$ADTinj / IMD$population * 100000

p <- ggplot(data = IMD,
            aes(date, rate, color = imd_cat, lty = imd_cat)) +
  geom_line()+
  #geom_point(color = "imd_cat")+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT injectable medications by IMD", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))
p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADTinjbyIMD1.png", path=here::here("output"),
)

####
# rates per 100,000 ****by Ethnicity***
####
Ethn <- read_csv(here::here("output", "measures", "measure_ADTinjbyEthnicity_rate.csv"))
Ethn$rate <- Ethn$ADTinj / Ethn$population * 100000

p <- ggplot(data = Ethn,
            aes(date, rate, color = ethnicity, lty = ethnicity)) +
  geom_line()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT injectable medications by ethnicity", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))
p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADTinjbyEthnicity1.png", path=here::here("output"),
)

####
# rates per 100,000 ****by Age***
####
Age <- read_csv(here::here("output", "measures", "measure_ADTinjbyAge_rate.csv"))
Age$rate <- Age$ADTinj / Age$population * 100000

p <- ggplot(data = Age,
            aes(date, rate, color = age_group, lty = age_group)) +
  geom_line()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT injectable medications by age", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))
p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADTinjbyAge1.png", path=here::here("output"),
)


#################################################
#######
# Oral medications 
#######
#################################################


###
# Load data
###
ADToral_Rates <- read_csv(here::here("output", "measures", "measure_ADT_oral_rate.csv"))

###
# Redact and round counts 
###
ADToral_Rates$ADToral <- redactor(ADToral_Rates$ADToral) 
ADToral_Rates$ADToral <- round_any(ADToral_Rates$ADToral,5)

###
# count ADT Oral medications  
###
p <- ggplot(data = ADToral_Rates,
                    aes(date, ADToral)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT oral medications", 
       x = "", y = "Number of prescriptions")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(ADToral_Rates$ADToral)+(sd(ADToral_Rates$ADToral)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADToral_count1.png", path=here::here("output"),
)

###
# rates per 100,000
###
ADToral_Rates$rate <- ADToral_Rates$ADToral / ADToral_Rates$population * 100000
p <- ggplot(data = ADToral_Rates,
                          aes(date, rate)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT oral medications", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")
p <- p +  geom_text(aes(x=as.Date(start, format="%Y-%m-%d")+5, y=min(ADToral_Rates$rate)+(sd(ADToral_Rates$rate)*2)), 
                    color = "red",label="Start of\nrestrictions", angle = 90, size = 3)
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADToral_rates1.png", path=here::here("output"),
)

###
# rates per 100,000 ****by region***
###
Region <- read_csv(here::here("output", "measures", "measure_ADToralbyRegion_rate.csv"))
Region$rate <- Region$ADToral / Region$population * 100000

p <- ggplot(data = Region,
            aes(date, rate, color = region, lty = region)) +
  geom_line()+
  #geom_point(color = "region")+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT oral medications by Region", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))

p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADToralbyRegion1.png", path=here::here("output"),
)

####
# rates per 100,000 ****by IMD***
####
IMD <- read_csv(here::here("output", "measures", "measure_ADToralbyIMD_rate.csv"))
IMD$rate <- IMD$ADToral / IMD$population * 100000

p <- ggplot(data = IMD,
            aes(date, rate, color = imd_cat, lty = imd_cat)) +
  geom_line()+
  #geom_point(color = "imd_cat")+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT oral medications by IMD", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))
p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADToralbyIMD1.png", path=here::here("output"),
)

####
# rates per 100,000 ****by Ethnicity***
####
Ethn <- read_csv(here::here("output", "measures", "measure_ADToralbyEthnicity_rate.csv"))
Ethn$rate <- Ethn$ADToral / Ethn$population * 100000

p <- ggplot(data = Ethn,
            aes(date, rate, color = ethnicity, lty = ethnicity)) +
  geom_line()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT oral medications by ethnicity", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))
p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADToralbyEthnicity1.png", path=here::here("output"),
)

####
# rates per 100,000 ****by Age***
####
Age <- read_csv(here::here("output", "measures", "measure_ADToralbyAge_rate.csv"))
Age$rate <- Age$ADToral / Age$population * 100000

p <- ggplot(data = Age,
            aes(date, rate, color = age_group, lty = age_group)) +
  geom_line()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "ADT oral medications by age", 
       x = "", y = "Rate per 100.000 \nmales with prostate cancer")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")
p <- p + labs(caption="OpenSafely-TPP October 2022")
p <- p + theme(plot.caption = element_text(size=8))
p <- p + theme(plot.title = element_text(size = 10))
p <- p + geom_vline(xintercept=as.Date(start, format="%Y-%m-%d"), size=0.3, colour="red")

ggsave(
  plot= p, dpi=800,width = 20,height = 10, units = "cm",
  filename="ADToralbyAge1.png", path=here::here("output"),
)


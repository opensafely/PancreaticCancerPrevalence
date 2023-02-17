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
  Rates_rounded[,1] <- redactor(Rates_rounded[,1])
  #round to the nearest 5 
  for (j in 1:2){
    Rates_rounded[,j] <- plyr::round_any(Rates_rounded[,j], 5, f = round)}
  # calculate the rates 
  Rates_rounded$value <- round(Rates_rounded[,1]/Rates_rounded$population,1)
  # calc rate per 100,000
  Rates_rounded$value2 <- round((Rates_rounded[,1]/Rates_rounded$population)*100000,1)
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
            "measure_incidencebyIMD_rate.csv",
            "measure_prevalencebyAge_rate.csv","measure_prevalencebyEthnicity_rate.csv",
            "measure_prevalencebyIMD_rate.csv")){
  
  Rates <- read_csv(here::here("output", "measures", i))
  Rates_rounded <- as.data.frame(Rates)
  
  ###
  # Redact and round counts 
  ###
  Rates_rounded[which(is.na(Rates_rounded[,2])),2] <- 1
  Rates_rounded[,2] <- redactor(Rates_rounded[,2])
  #round to the nearest 5 
  for (j in 2:3){
    Rates_rounded[,j] <- plyr::round_any(Rates_rounded[,j], 5, f = round)}
  
  Rates_rounded$value <- round(Rates_rounded[,2]/Rates_rounded$population,1)
  # calc rate per 100,000
  Rates_rounded$value2 <- round((Rates_rounded[,2]/Rates_rounded$population)*100000,1)
  write.table(Rates_rounded, here::here("output", paste0("Rates_rounded_",colnames(Rates_rounded)[2],"_by_",colnames(Rates_rounded)[1],".csv")),
              sep = ",",row.names = FALSE)

  
p <- ggplot(data = Rates_rounded,aes(date, value2, color = Rates_rounded[,1], lty = Rates_rounded[,1])) +
  geom_line()+
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

n <- 1; #rounding level 

#Input <- read_csv(here::here("output", "input.csv"),show_col_types = FALSE)
Input <- read_csv(here::here("output", "input.csv"),col_types = cols(patient_id = col_integer()))

Table1 <- as.data.frame(NA)
xx <- c("preva","ageP","sdP","inci","ageI","sdI",
        "inci15","ageI15","sdI15","inci16","ageI16","sdI16",
        "inci17","ageI17","sdI17","inci18","ageI18","sdI18",
        "inci19","ageI19","sdI19","inci20","ageI20","sdI20",
        "inci21","ageI21","sdI21","inci22","ageI22","sdI22"
        )
Table1[xx] <- NA
Table1[1,"preva"] <- plyr::round_any(length(which(Input$prostate_ca==1)), 5, f = round)
Table1[1,"ageP"] <- round(mean(Input$age_pa_ca),n)
xl <- Input$age_pa_ca; Table1[1,"sdP"] <- paste0(round(sd(xl),n),
                          " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                          round(t.test(xl)$conf.int[2],n),")")

Input2 <- Input[Input$prostate_ca_date>= "2015-01-01",]
Table1[1,"inci"] <- plyr::round_any(length(which(Input2$prostate_ca==1)), 5, f = round)
Table1[1,"ageI"] <- round(mean(Input2$age_pa_ca),n)
xl <- Input2$age_pa_ca; Table1[1,"sdI"] <- paste0(round(sd(xl),n),
                                          " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                          round(t.test(xl)$conf.int[2],n),")"); rm(Input2)

Input$ethnicity[which(is.na(Input$ethnicity))] <- "NAs"; Table1[names(table(Input$ethnicity, exclude=NULL))] <- NA
Table1[1,names(table(Input$ethnicity, exclude=NULL))] <- plyr::round_any(as.numeric(table(Input$ethnicity, exclude=NULL)), 5, f = round)
Input$sex[which(is.na(Input$sex))] <- "NAs"; Table1[names(table(Input$sex, exclude=NULL))] <- NA
Table1[1,names(table(Input$sex, exclude=NULL))] <- plyr::round_any(as.numeric(table(Input$sex, exclude=NULL)), 5, f = round)
Input$imd_cat[which(is.na(Input$imd_cat))] <- "NAs"; Table1[names(table(Input$imd_cat, exclude=NULL))] <- NA
Table1[1,names(table(Input$imd_cat, exclude=NULL))] <- plyr::round_any(as.numeric(table(Input$imd_cat, exclude=NULL)), 5, f = round)

Input2 <- Input[Input$prostate_ca_date>= "2015-01-01" & Input$prostate_ca_date<= "2015-12-31",]
Table1[1,"inci15"] <- plyr::round_any(length(which(Input2$prostate_ca==1)), 5, f = round)
Table1[1,"ageI15"] <- round(mean(Input2$age_pa_ca),n)
xl <- Input2$age_pa_ca; Table1[1,"sdI15"] <- paste0(round(sd(xl),n),
                                                  " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                  round(t.test(xl)$conf.int[2],n),")"); 


Input3 <- Input[Input$prostate_ca_date>= "2016-01-01" & Input$prostate_ca_date<= "2016-12-31",]
Table1[1,"inci16"] <- plyr::round_any(length(which(Input3$prostate_ca==1)), 5, f = round)
Table1[1,"ageI16"] <- paste0(round(mean(Input3$age_pa_ca),n)," (p=",
                                   round(t.test(Input3$age_pa_ca,Input2$age_pa_ca)$p.value,3),")")
xl <- Input3$age_pa_ca; Table1[1,"sdI16"] <- paste0(round(sd(xl),n),
                                                  " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                  round(t.test(xl)$conf.int[2],n),")"); rm(Input2)


Input2 <- Input[Input$prostate_ca_date>= "2017-01-01" & Input$prostate_ca_date<= "2017-12-31",]
Table1[1,"inci17"] <- plyr::round_any(length(which(Input2$prostate_ca==1)), 5, f = round)
Table1[1,"ageI17"] <- paste0(round(mean(Input2$age_pa_ca),n)," (p=",
                             round(t.test(Input3$age_pa_ca,Input2$age_pa_ca)$p.value,3),")")
xl <- Input2$age_pa_ca; Table1[1,"sdI17"] <- paste0(round(sd(xl),n),
                                                  " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                  round(t.test(xl)$conf.int[2],n),")"); rm(Input3)


Input3 <- Input[Input$prostate_ca_date>= "2018-01-01" & Input$prostate_ca_date<= "2018-12-31",]
Table1[1,"inci18"] <- plyr::round_any(length(which(Input3$prostate_ca==1)), 5, f = round)
Table1[1,"ageI18"] <- paste0(round(mean(Input3$age_pa_ca),n)," (p=",
                             round(t.test(Input3$age_pa_ca,Input2$age_pa_ca)$p.value,3),")")
xl <- Input3$age_pa_ca; Table1[1,"sdI18"] <- paste0(round(sd(xl),n),
                                                  " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                  round(t.test(xl)$conf.int[2],n),")"); rm(Input2)


Input2 <- Input[Input$prostate_ca_date>= "2019-01-01" & Input$prostate_ca_date<= "2019-12-31",]
Table1[1,"inci19"] <- plyr::round_any(length(which(Input2$prostate_ca==1)), 5, f = round)
Table1[1,"ageI19"] <- paste0(round(mean(Input2$age_pa_ca),n)," (p=",
                             round(t.test(Input3$age_pa_ca,Input2$age_pa_ca)$p.value,3),")")
xl <- Input2$age_pa_ca; Table1[1,"sdI19"] <- paste0(round(sd(xl),n),
                                                  " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                  round(t.test(xl)$conf.int[2],n),")"); rm(Input3)


Input3 <- Input[Input$prostate_ca_date>= "2020-01-01" & Input$prostate_ca_date<= "2020-12-31",]
Table1[1,"inci20"] <- plyr::round_any(length(which(Input3$prostate_ca==1)), 5, f = round)
Table1[1,"ageI20"] <- paste0(round(mean(Input3$age_pa_ca),n)," (p=",
                             round(t.test(Input3$age_pa_ca,Input2$age_pa_ca)$p.value,3),")")
xl <- Input3$age_pa_ca; Table1[1,"sdI20"] <- paste0(round(sd(xl),n),
                                                  " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                  round(t.test(xl)$conf.int[2],n),")"); rm(Input2)

Input2 <- Input[Input$prostate_ca_date>= "2021-01-01" & Input$prostate_ca_date<= "2021-12-31",]
Table1[1,"inci21"] <- plyr::round_any(length(which(Input2$prostate_ca==1)), 5, f = round)
Table1[1,"ageI21"] <- paste0(round(mean(Input2$age_pa_ca),n)," (p=",
                             round(t.test(Input3$age_pa_ca,Input2$age_pa_ca)$p.value,3),")")
xl <- Input2$age_pa_ca; Table1[1,"sdI21"] <- paste0(round(sd(xl),n),
                                                    " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                    round(t.test(xl)$conf.int[2],n),")"); rm(Input3)


Input3 <- Input[Input$prostate_ca_date>= "2022-01-01" & Input$prostate_ca_date<= "2022-12-31",]
Table1[1,"inci22"] <- plyr::round_any(length(which(Input3$prostate_ca==1)), 5, f = round)
Table1[1,"ageI22"] <- paste0(round(mean(Input3$age_pa_ca),n)," (p=",
                             round(t.test(Input3$age_pa_ca,Input2$age_pa_ca)$p.value,3),")")
xl <- Input3$age_pa_ca; Table1[1,"sdI22"] <- paste0(round(sd(xl),n),
                                                    " (95CIs: ",round(t.test(xl)$conf.int[1],n)," to ",
                                                    round(t.test(xl)$conf.int[2],n),")"); rm(Input2)


Table1 <- t(Table1)
Table1 <- as.data.frame(Table1)
colnames(Table1) <- "summaryStat"
Table1$var <- row.names(Table1)

Table1 <- Table1[,c(2,1)]

# Table1$summaryStat <- round(Table1$summaryStat,1)

write.table(Table1, here::here("output", "Table1.csv"),sep = ",",row.names = FALSE)





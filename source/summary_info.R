### Find summary info for dynamic paragraph
library(tidyverse)
df <- read.csv("../data/taxdata.csv")
# tax_returns.R 
# A source file that takes in a dataset and returns a list of info about it:
tax_returns <- list()
tax_returns$numobservations <- nrow(df)
tax_returns$numfeatures <- ncol(df)
tax_returns$numzipcodes <- unique(df$Zip.Code) %>% 
  length()
tax_returns$numstates <- unique(df$State) %>% 
  length()
tax_returns$totalreturns <- sum(df$Number.of.Single.Returns) + 
  sum(df$Number.of.Head.of.Household.Returns) + 
  sum(df$Number.of.Joint.Returns)
tax_returns$totaltaxescollected <- sum(df$Total.tax.payments.amount)

temp <- filter(df, Zip.Code != 99999)

tax_returns$maxtaxcollected <- max(temp$Total.tax.payments.amount, na.rm = T)

tax_returns$maxtaxcollectedzipcode <- temp %>% 
  filter(Total.tax.payments.amount == max(Total.tax.payments.amount, na.rm = T)) %>%
  pull(Zip.Code)

tax_returns$maxtaxcollectedstate <- temp %>%
  filter(Total.tax.payments.amount == max(Total.tax.payments.amount, na.rm = T)) %>%
  pull(State)

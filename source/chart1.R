# Create first chart
# Scatter plot of log(Total tax payments amount) vs log(AGI) by tax bracket
library(tidyverse)

taxes <- read_csv('../data/taxdata.csv')
 
taxes <- taxes %>% mutate(Adjusted.Size.Gross.Income.Category = 
                          case_when(Adjusted.Size.Gross.Income.Category == "under $25,000" ~ "1. Under $25,000",
                                    Adjusted.Size.Gross.Income.Category == "$25,000 to $50,000" ~ "2. $25,000 to $50,000",
                                    Adjusted.Size.Gross.Income.Category == "$50,000 to $75,000" ~ "3. $50,000 to $75,000",
                                    Adjusted.Size.Gross.Income.Category == "$75,000 to $100,000" ~ "4. $75,000 to $100,000",
                                    Adjusted.Size.Gross.Income.Category == "$100,000 to $200,000" ~ "5. $100,000 to $200,000",
                                    Adjusted.Size.Gross.Income.Category == "$200,000 or more" ~ "6. $200,000 or more"))
taxes <- taxes %>% 
  mutate(normalagi = Adjusted.Gross.Income/(Number.of.Single.Returns + Number.of.Joint.Returns + Number.of.Head.of.Household.Returns),
         normaltaxpayments = Total.tax.payments.amount/(Number.of.Single.Returns + Number.of.Joint.Returns + Number.of.Head.of.Household.Returns))

scatter_plot <- ggplot(taxes, 
                       aes(normalagi, 
                           normaltaxpayments, 
                           color = Adjusted.Size.Gross.Income.Category)) +
  geom_point(position = 'jitter') +
  scale_x_continuous(trans='log10') +
  scale_y_continuous(trans='log10') +
  labs(title = 'Average taxes owed per person vs Average adjusted gross income per person',
       subtitle = 'by tax bracket',
       x = 'Average adjusted gross income per person (thousands of dollars)',
       y = 'Average total taxes owed per person (thousands of dollars)',
       color = 'Tax bracket')
# This scatter plot was included to analyze the relationship between two 
# continuous variable: average total taxes owed per person and average adjusted 
# gross income per person. It shows how the average amount taxes owed per person
# varies with the average adjusted gross income per person across the United
# States, by tax bracket. In general, the average amount of taxes owed person 
# increases as the average adjusted gross income per person increases, which is 
# expected. However, when considering the relationship between these two values 
# between tax brackets, it is interesting to see how higher tax brackets owe a
# disproportionate amount of taxes. This is because we expect the average amount
# of total taxes owed to increase faster with average adjusted gross income for 
# higher brackets, compared to lower brackets, but this is not the case, as 
# shown in the scatter plot.
#Taxable.income.amount
#Total.Income.Amount
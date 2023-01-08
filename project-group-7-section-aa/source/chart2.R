### Create second chart
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
  mutate(normalsalaries = Salaries.and.Wages.Amount / (Number.of.Single.Returns + Number.of.Joint.Returns + Number.of.Head.of.Household.Returns))

boxplots <- ggplot(taxes,
                   aes(normalsalaries, 
                   fill = Adjusted.Size.Gross.Income.Category)) +
  geom_boxplot() +
  scale_x_log10() +
  labs(title = "Boxplots of Average salary per person",
       subtitle = "by tax bracket",
       x = "Average salary per person (thousands of dollars)",
       fill = "Tax bracket")

# These box plots were included to explore the wages of individuals across tax
# brackets. They show the distributions of the average salary per person for each
# tax bracket. It is interesting to observe the number of average salaries that
# lie outside of the upper and lower bounds of each tax bracket. This indicates
# that there are a number of factors outside of a person's salary that eventually
# determine which tax bracket they belong to.
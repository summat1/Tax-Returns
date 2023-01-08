### Create third chart
library(tidyverse)
data <- read.csv("../data/taxdata.csv")
data <- data %>% mutate(Adjusted.Size.Gross.Income.Category = 
                          case_when(Adjusted.Size.Gross.Income.Category == "under $25,000" ~ "1. Under $25",
                                    Adjusted.Size.Gross.Income.Category == "$25,000 to $50,000" ~ "2. $25 - $50",
                                    Adjusted.Size.Gross.Income.Category == "$50,000 to $75,000" ~ "3. $50 - $75",
                                    Adjusted.Size.Gross.Income.Category == "$75,000 to $100,000" ~ "4. $75 - $100",
                                    Adjusted.Size.Gross.Income.Category == "$100,000 to $200,000" ~ "5. $100 - $200",
                                    Adjusted.Size.Gross.Income.Category == "$200,000 or more" ~ "6. $200 or more"))

income_not_from_wages <- data %>% 
  rename("Tax.Bracket.Status" = "Adjusted.Size.Gross.Income.Category") %>% 
  mutate(income_not_from_salary = Total.Income.Amount - Salaries.and.Wages.Amount) %>% 
  group_by(Tax.Bracket.Status) %>% 
  summarise("Total_Income_Not_From_Wages" = 
              1000 * sum(income_not_from_salary), 
            "Total_Number_of_Returns" = 
              sum(Number.of.Single.Returns) +
              sum(Number.of.Head.of.Household.Returns) +
              sum(Number.of.Joint.Returns))
top_bracket_info <- income_not_from_wages %>% 
  filter(Tax.Bracket.Status == "6. $200 or more")
  
top_bracket_capital_gains <- top_bracket_info$Total_Income_Not_From_Wages/
  top_bracket_info$Total_Number_of_Returns
bar_chart_income_not_from_wages <- ggplot(data = income_not_from_wages, 
                    mapping = aes(
                      x = c(Tax.Bracket.Status), 
                      y = c(Total_Income_Not_From_Wages/Total_Number_of_Returns))) +
  geom_bar(stat = "identity") +
  labs(title = "Income not from Salaries/Wages by Tax Bracket",
       subtitle = "Per Capita",
       x = "Tax Bracket (Thousands of Dollars)",
       y = "Income from Assets (Dollars)")

bar_chart_income_not_from_wages

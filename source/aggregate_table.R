data <- read.csv("../data/taxdata.csv")
# Adjusted Gross Income is the number IRS uses to calculate income tax
total_income <- sum(select(data, Adjusted.Gross.Income))
total_taxes <- sum(select(data, Total.tax.payments.amount))
data <- data %>% mutate(Adjusted.Size.Gross.Income.Category = 
         case_when(Adjusted.Size.Gross.Income.Category == "under $25,000" ~ "1. Under $25,000",
                   Adjusted.Size.Gross.Income.Category == "$25,000 to $50,000" ~ "2. $25,000 to $50,000",
                   Adjusted.Size.Gross.Income.Category == "$50,000 to $75,000" ~ "3. $50,000 to $75,000",
                   Adjusted.Size.Gross.Income.Category == "$75,000 to $100,000" ~ "4. $75,000 to $100,000",
                   Adjusted.Size.Gross.Income.Category == "$100,000 to $200,000" ~ "5. $100,000 to $200,000",
                   Adjusted.Size.Gross.Income.Category == "$200,000 or more" ~ "6. $200,000 or more"))

aggregate_table <- data %>% 
  rename("Tax.Bracket.Status" = "Adjusted.Size.Gross.Income.Category") %>% 
  group_by(Tax.Bracket.Status) %>% 
  summarize("Total Number of Returns Filed (in millions)" = 
              round((sum(Number.of.Single.Returns) + 
                       sum(Number.of.Head.of.Household.Returns) +
                       sum(Number.of.Joint.Returns))/1000000, 2),
            "Total Adjusted Gross Income (in billions of dollars)" = 
              round(sum(Adjusted.Gross.Income)/1000000, 2),
            "Percentage of US Total Income" =
              100 * round(sum(Adjusted.Gross.Income)/total_income, 4),
            "Total Tax Payments (in billions of dollars)" =
              round(sum(Total.tax.payments.amount)/1000000, 2),
            "Percentage of US Total Taxes" =
              100 * round(sum(Total.tax.payments.amount)/total_taxes, 4),
            "Effective Tax Rate Percent"=
              100 * round(sum(Total.tax.payments.amount)/sum(Adjusted.Gross.Income), 4))

high_earners_percent_income <- aggregate_table %>% 
  filter(Tax.Bracket.Status == "6. $200,000 or more") %>% 
  pull("Percentage of US Total Income")

high_earners_percent_tax <- aggregate_table %>% 
  filter(Tax.Bracket.Status == "6. $200,000 or more") %>% 
  pull("Percentage of US Total Taxes")

low_earners_percent_income <- aggregate_table %>% 
  filter(Tax.Bracket.Status == "1. Under $25,000") %>% 
  pull("Percentage of US Total Income")

low_earners_percent_tax <- aggregate_table %>% 
  filter(Tax.Bracket.Status == "1. Under $25,000") %>% 
  pull("Percentage of US Total Taxes")

low_earners_tax_rate <- aggregate_table %>% 
  filter(Tax.Bracket.Status == "1. Under $25,000") %>% 
  pull("Effective Tax Rate Percent")

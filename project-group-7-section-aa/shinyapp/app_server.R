# Server
library(tidyverse)
library(plotly)
library(maps)
library(mapproj)
library(scales)

taxes <- read_csv('data/taxdata.csv')

zip_to_county <- read_csv('data/zip_to_county.csv')
st_abbr_to_name <- read_csv('data/state_abbr_to_name.csv')

# format data for map
taxes <- taxes %>% select(-c(...1, X.1, X))
zip_to_county <- zip_to_county %>%
  mutate(COUNTYNAME = str_to_lower(str_replace(COUNTYNAME,"[:space:]County", ""))) %>%
  select(ZIP, COUNTYNAME)
zip_to_county <- zip_to_county %>% mutate(ZIP = as.numeric(ZIP))
st_abbr_to_name <- st_abbr_to_name %>% mutate(State = str_to_lower(State)) %>%
  select(state_name = State, Code)

df <- taxes %>%
  left_join(zip_to_county, by = c("Zip.Code" = "ZIP")) %>%
  left_join(st_abbr_to_name, by = c("State" = "Code"))

totals_map_df <- df %>% 
  mutate(Total.number.of.returns = Number.of.Single.Returns + Number.of.Joint.Returns + Number.of.Head.of.Household.Returns,
         Income.not.from.wages.amount = Total.Income.Amount - Salaries.and.Wages.Amount) %>%
  group_by(COUNTYNAME, state_name) %>%
  summarise(state_name,
            COUNTYNAME,
            total.income.amount = sum(Total.Income.Amount, na.rm = T),
            total.tax.payments.amount = sum(Total.tax.payments.amount, na.rm = T),
            total.itemized.deductions.amount = sum(Total.itemized.deductions.amount, na.rm = T),
            total.number.of.returns = sum(Total.number.of.returns, na.rm = T),
            taxable.income.amount = sum(Taxable.income.amount, na.rm = T),
            income.not.from.wages.amount = sum(Income.not.from.wages.amount, na.rm = T),
            .groups = "keep") %>%
  distinct()

totals_map_df <- totals_map_df %>%
  mutate(proportion.of.income.taxed = total.tax.payments.amount / total.income.amount,
         proportion.of.taxable.income = taxable.income.amount / total.income.amount,
         proportion.of.income.not.from.wages = income.not.from.wages.amount / total.income.amount) %>%
  mutate(COUNTYNAME = str_replace(COUNTYNAME, "\\.", "")) %>%
  mutate(COUNTYNAME = str_replace(COUNTYNAME, "[:space:]parish", ""))

taxes_w_names <- taxes %>%
  left_join(st_abbr_to_name, by = c("State" = "Code")) %>%
  select(state_name, Total.Income.Amount, Total.itemized.deductions.amount)

# format data for scatterplot
temp_df <- taxes %>% left_join(st_abbr_to_name, by = c("State" = "Code"))

scatter_df <- temp_df %>%
  mutate(Total.number.of.returns = Number.of.Single.Returns + Number.of.Joint.Returns + Number.of.Head.of.Household.Returns,
         Income.not.from.wages.amount = Total.Income.Amount - Salaries.and.Wages.Amount,
         Proportion.of.income.taxed = Total.tax.payments.amount / Total.Income.Amount,
         Proportion.of.taxable.income = Taxable.income.amount / Total.Income.Amount,
         Proportion.of.income.not.from.wages = Income.not.from.wages.amount / Total.Income.Amount
         ) %>%
  select(state_name, 
         Zip.Code,
         Adjusted.Size.Gross.Income.Category,
         Total.Income.Amount,
         Total.itemized.deductions.amount,
         Total.number.of.returns, 
         Income.not.from.wages.amount,
         Proportion.of.income.taxed,
         Proportion.of.taxable.income,
         Proportion.of.income.not.from.wages)

scatter_df <- scatter_df %>%
  filter(Proportion.of.income.not.from.wages >= 0)

scatter_df <- scatter_df %>%
  mutate(Adjusted.Size.Gross.Income.Category = 
           case_when(Adjusted.Size.Gross.Income.Category == "under $25,000" ~ "1. Under $25,000",
                     Adjusted.Size.Gross.Income.Category == "$25,000 to $50,000" ~ "2. $25,000 - $50,000",
                     Adjusted.Size.Gross.Income.Category == "$50,000 to $75,000" ~ "3. $50,000 - $75,000",
                     Adjusted.Size.Gross.Income.Category == "$75,000 to $100,000" ~ "4. $75,000 - $100,000",
                     Adjusted.Size.Gross.Income.Category == "$100,000 to $200,000" ~ "5. $100,000 - $200,000",
                     Adjusted.Size.Gross.Income.Category == "$200,000 or more" ~ "6. $200,000 or more"))

total_income <- sum(select(taxes, Adjusted.Gross.Income))
total_taxes <- sum(select(taxes, Total.tax.payments.amount))
taxes_table <- taxes %>% mutate(Adjusted.Size.Gross.Income.Category = 
                          case_when(Adjusted.Size.Gross.Income.Category == "under $25,000" ~ "1. Under $25,000",
                                    Adjusted.Size.Gross.Income.Category == "$25,000 to $50,000" ~ "2. $25,000 to $50,000",
                                    Adjusted.Size.Gross.Income.Category == "$50,000 to $75,000" ~ "3. $50,000 to $75,000",
                                    Adjusted.Size.Gross.Income.Category == "$75,000 to $100,000" ~ "4. $75,000 to $100,000",
                                    Adjusted.Size.Gross.Income.Category == "$100,000 to $200,000" ~ "5. $100,000 to $200,000",
                                    Adjusted.Size.Gross.Income.Category == "$200,000 or more" ~ "6. $200,000 or more"))

aggregate_table <- taxes_table %>% 
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

# Create markdown report to be rendered
report_md = "## Tax Returns
# Understanding the Tax Landscape in the US by Zip Code
#### Authors:
Shivesh Ummat summat@uw.edu, David Li laviddi@uw.edu, Ismail Ibrahim ishy206@uw.edu

#### INFO-201: Technical Foundations of Informatics - The Information School - University of Washington
#### Autumn 2022

### Abstract
We are concerned with the distribution of income and tax payments across the country based on geographical location, because we want to understand wealth inequality and uncover which areas of the US need the most financial subsidies from the government. To address this concern, we plan to analyze tax return data from the IRS in 2019 to understand tax brackets, income, and deductions based on zip code and state. Additionally, we want to know if high earners are abusing tax laws to write off their payments and we aim to quantify the pervasiveness of this problem.

### Keywords
Tax Returns, Income Distribution, Wealth Inequality, Deductions and Write Offs

### Introduction
Our project leverages IRS data from tax returns to examine the fiscal landscape in the US. Wealth and income inequality are becoming increasingly more drastic issues. Why is this? We will examine tax returns to understand how high earners might be taking advantage of tax law for financial gain while the real burden remains on the working class. Where does this happen? Are there hotspots of poverty in the US, and if so, why? We want to answer these questions by comparing income and tax payments across all the zip codes in the US. These might be areas that need government assistance to alleviate the stress of poverty. In addition, we want to begin to understand ways to close the wealth gap by examining which areas of the tax statistics seem to be imbalanced or unfair. This analysis will help inform governmental policy and advise the potential reorganization of tax structure to promote equality.

### Problem Domain
#### Project Framing
Taxes in the U.S. are an issue as old as the country itself. They exist on the notion that everybody pays their fair share: but is this true? The answer is no. The IRS projects that the amount of income tax money owed but not paid will be 540 billion dollars per year for 2017 to 2019, and that those referred to as high earners are responsible for a disproportionate share of these unpaid taxes [[1]](https://abcnews.go.com/Business/wireStory/irs-growing-gap-us-income-taxes-owed-paid-92304350). The latter does not come as a surprise, as prominent figures, such as Donald Trump, often appear in the media for keeping their tax returns private. In fact, recently, the former president filed a case to the Supreme Court requesting that they block the pending disclosure of his personal tax returns from House Democrats [[2]](https://www.cbsnews.com/news/donald-trump-tax-returns-supreme-court-request-to-shield-from-house-committee). With all this in mind, we seek to address issues related to wealth distribution and taxed income by state and nationally.

#### Direct and Indirect Stakeholders
**Policymakers** are direct stakeholders of the data we use and the results and visualizations we produce from it, as they may use this information to guide decisions related to income tax legislation at the federal and state level. Our data may prove useful to policymakers attempting to set state or federal tax brackets and tax rates for future years.

**Working class** people are indirect stakeholders of our data. They may not directly interact with this data but are still subject to its effects through tax laws at the state and federal level. These laws may cause individuals to relocate or seek different employment and may influence their votes and well-beings.

#### Human Values
Values: Equity, Justice
One important value concerning this project is equity. Taxes vary between individuals depending on the tax bracket they belong to, for example, which directly links the issue of taxes to the notion of equity. Below is a figure from Statistica describing the wealth distribution over the years between four different categories of earners [[3]](https://www.statista.com/statistics/299460/distribution-of-wealth-in-the-united-states/).

![This is the data visualization for the distribution of net wealth in the U.S. from 1990-2022](images/netwealth.png)

The figure shows an alarming disparity between earners. In general, the top ten percent of earners in the U.S. hold the majority of the country's net wealth. So, we hope to narrow down areas facing the most financial hardship in order to provide them with equitable solutions. Another important value at stake here is justice, which is closely related to equity. In addition to providing equitable solutions, we hope that this project will help identify systemic causes for inequity in the U.S. and propose ways to fix them in order to provide long-term, equitable access to resources for future generations.

#### Potential Benefits and Harms
The results of this project have the potential to benefit the bottom fifty percent of earners. These are the people who suffer the most from the wealth gap and are most likely to require financial assistance. By narrowing down the locations of this group, we can imagine how and where to allocate additional resources in the pursuit of a more equitable society. On the other hand, this project has the potential to harm the top ten percent of earners: those who benefit from the wealth gap. Ensuring that this group pays their fair share of taxes can be seen as a harm because it shifts a proportional amount of the tax burden onto them.

### Research Questions
**What is the distribution of income over the United States based on Zip Code and State?**
We want to explore if there are certain states that have more concentrated wealth. This can show income inequality in the US. It is important for understanding which areas need the most financial subsidies and government assistance. If these tend to be the most metropolitan areas, how can we change tax law to provide help in large cities?

**Does wealth distribution change based on tax laws in different states?**
It may seem intuitive that states with lower personal income tax should have wealthier individuals. People pay less tax, and high earners may even be attracted to live in these states. Does this assumption hold true? Maybe high earners are equally spread across the country. Are there other forces at work that are worth exploring?

**Are taxes paid fairly or is the tax system abused by high earners?**
There is much discourse in the media about tax write offs and ways to avoid paying taxes. Does this happen as often as it's made out to? Or do high earners pay their taxes fairly and contribute as much as they should? An analysis of tax payments grouped by tax brackets will help us answer this question.

**Are tax breaks and benefits to the working class enough?**
The trend in America shows the ever shrinking middle class. How does this happen? Low earners should be given tax breaks as they are already often working paycheck to paycheck. This might help pull low earners out of poverty and back into the middle class. However, due to the trend, we might hypothesize that tax breaks are not sufficient and should be increased.

### The Dataset
The data we are choosing to use is from the US Government, specifically the Internal Revenue Service (IRS). The data is called \"Individual Income Tax Statistics\" from 2019. This contains information on tax filings, income, returns, loans, deductions, and other monetary observations. It effectively has all the information input on a tax return, for every household in America. This data is grouped by zip code, and there is a separate file for each state in the US. There are 152 columns and 166,000 rows of data in the aggregated dataset. This dataset provides all the information to understand the fiscal landscape of the US based on geographical location. Nuances of tax law such as deductions and liabilities can be explored to understand if there is a trend that could be contributing to income disparities. This dataset will help us uncover the factors and locations of wealth inequalities in the US.

There is a file for each state, but the aggregated dataset already combined each file together. We plan to use the aggregated data:

| File                            | Number of Zip Codes | Number of Rows Per Zip Code  | Number of Observations
| ------------------------------- | ------------------- | ---------------------------- | ---------------
| Alabama  | 641              | 5 (one per tax bracket group)|  152
| Alaska  | 64              | 5 (one per tax bracket group)|  152
| Arizona  | 336              | 5 (one per tax bracket group)|  152
| Arkansas  | 556              | 5 (one per tax bracket group)|  152
| California  | 1689              | 5 (one per tax bracket group)|  152
| ...  | ...              | ... |  ...
| Aggregate Dataset (19zpallagi)  | 33,231              | 5 (one per tax bracket group)|  152

Here is the citation for the data: (Soi Tax Stats - Individual Income Tax Statistics - 2019 ZIP Code Data (SOI).” Internal Revenue Service, US Government, 7 Sept. 2022, https://www.irs.gov/statistics/soi-tax-stats-individual-income-tax-statistics-2019-zip-code-data-soi.)

The data was collected by the IRS in 2019. It was collected from tax return forms, which is an integral part of data that the IRS uses to make sure everyone is paying the right amount in taxes. The data collection was funded using government money. The IRS has $13 billion in funding from the government, some of which was used for this purpose. There is no direct beneficiary, as the government is non-profit and simply helps maintain the law as it is written. However, as the IRS promotes fairness in the law, the people are the beneficiaries of the work they do to uphold the tax code.

The data is validated through governmental quality control. The IRS is very well documented and ensures information is correctly input onto the forms in order to reduce tax fraud. As the IRS performs lots of data validation, the data should be accurate. The data was obtained from the website Data.gov, which is an official government website that houses their open data. There are many datasets on this website that are free to use for anyone.

### Expected Implications
The expected implications for this is that the policy makers and technologists who distribute the taxes based on the individual's income, location and taxation will realize the uneven distribution and taxing of people based on their zone of living. For example, the same person working a construction job in California will be forced to pay more taxes than the same person doing the job in Minneapolis. This is due to the fact that California has state taxes and local taxes which prevents the living person to survive in those situations making the minimum.

Therefore, after the data is collected, analyzed and hard evidence is shown that taxation in America for the living 9-5 tax payers is unfairly distributed, policy makers will make a change to create a better living environment for people to prosper in. On top of that, inflation without pay raise to accommodate inflation kills the living person to still survive as they undergo heavy taxation.

### Limitations
A couple limitations that need to be addressed is the fact that the wealthy people who run the United States of America and the government will take a hard hit once taxation is evenly distributed in all states. This is due to the fact that the wealthy people will take less money home and the government will need to mint more money to accommodate the individuals and organizations building and fixing the parts of the states that need reconstruction.

This is because most government workers use taxpayers money to fix for example concrete streets that have major puddle holes, pay local metro bus workers, police officers, garbage collectors, tax specialists, correctional officers, etc. Cutting down taxes means more money from government pockets to keep up things running and functioning effectively. That's why policy makers need to make a justifiable taxation that would keep both parties at an advantage to live life with ease and have America function without any complications.

### Findings
There were four key research questions we wanted to answer through our analysis of
the IRS tax data set from 2019. The first question was: \"What is 
the distribution of income over the United States based on Zip Code and State?\". 
We were able to successfully look into the income distribution across states and
zip codes. Based on the zip code data, we were able to identify that the location 
from which the highest amount of taxes were collected from Americans in 2019, 
was Manhattan, New York. Through further research, we determined that this was 
due to the state having one of the highest income tax rates in addition to federal
taxes. From here, we analyzed the distribution of wealth between particular states.

Secondly, we wanted to investigate the question: \"Does wealth distribution change based 
on tax laws in different states?\" Our assumption was that higher earners are attracted
to states with low income tax rates. While our data does not allow us identify individual
high earners, we can still say something about the states and counties these earners reside
in. Across all states, there are always one or several counties that have the greatest total
income by far. We found that these are typically urban counties, containing cities such as Los
Angeles, New York, Seattle, etc. In fact, we found that Los Angeles County and New York County
had the highest total income of all counties, yet California and New York had some of the 
highest income tax rates.

The third question was: \"Are taxes paid fairly or is the tax 
system abused by high earners?\" Based on our analysis, we can confidently say no, taxes are not paid fairly.
Both the side-by-side bar plot and scatter plot show that there are many instances where low
earners pay an equal or greater share of their income to taxes compared to high earners. This
pattern is especially prevelant in the Southern region of the U.S.

The fourth question
we endeavored to answer was: \"Are tax breaks and benefits to the working class enough?\"
From our findings, we conclude that they are not enough. The majority of U.S. tax returns were filed with
income under $25,000, the lowest tax bracket, highlighting the number of low earners.
Assitionally, the adjusted gross income of bracket 2 was greater than that of bracket 3 
and bracket 4, suggesting that the middle class is, indeed, shrinking.

### Discussion
Economic inequality in the United States is a pervasive issue that affects 
millions of Americans. This inequality is largely the result of systemic factors 
such as the unequal distribution of wealth and opportunities. For example, our 
analysis shows that this inequality manifests through unequal distribution of income, 
with the top earners in this country taking home a disproportionate share of the 
nation's total income.

The U.S. tax system is a key, contributing factor to economic inequality. The nation's
tax system is progressive in the sense that those 
who earn more are taxed at a higher rate. However, as our findings show, the reality is that the wealthy 
are often able to use loopholes and other strategies to reduce their tax burden 
and pay a lower effective tax rate than those who are less well off. For example, 
they may take advantage of tax-prefered investments or deductions and exemptions that lower 
their taxable income. They are also have greater access to tax attorneys 
and other professionals who can help them reduce their tax liability. These are the
factors that allow the rich to stay rich while shifting the tax burden to low
earners.

Furthermore, it is noteworthy to discuss the effect of regressive taxes as an implication 
of economic inequality. These are taxes that are applied uniformly, 
regardless of income, and have a greater impact on those who are less well off. 
For example, sales taxes and property taxes are often applied regardless of a person's income or wealth.
In general, lower-income individuals spend a larger portion of their income on necessities, 
such as food and housing. In effect, regressive taxes are more detrimental to low earners
than they are for wealthier individuals.

Money is often equated to power. So, given the unequal distribution of wealth in 
this country, the rich have a disproportionate amount of influence over political 
processes. This allows them to shape policies and legislation in their favor, 
including the tax system, further exacerbating inequality.

All our findings support the argument that the current U.S. tax system is flawed
and greatly contributes the ever-growing economic inequality in this country. To
create a more equitable future, we must reform the tax system in a way that
ensures the wealthy pay their fair share of dues, allocates funds towards
equitable programs, such as healthcare and education, and provides financial
support to those in need.


### Conclusion
Overall, it is clear that the tax system in the United States plays a significant 
role in perpetuating economic inequality. Our analysis and findings present information
about the nation's tax system that is otherwise obscured. While the progressive tax system is 
intended to reduce inequality by taxing the wealthy at a higher rate, the reality 
is that the wealthy are able to use their resources to reduce their tax burden 
and keep more of their income. Additionally, regressive taxes disproportionately 
impact those who are less well off, further widening the gap between the rich and 
the poor. In order to address economic inequality in the United States, it will 
be necessary to reform the tax system in order to make it more equitable and 
effective at reducing inequality.

Additionally, the current tax system is not adequately funded to provide essential 
services and support for those in need. This is particularly true for programs 
such as healthcare and education, which are vital for improving social mobility 
and reducing inequality. The tax breaks currently provided to low-income individuals
are not sufficient at remedying inequality either. Taxes should be reinvested into
communities that are in great need of essential institutions that wealthy communities
take for granted. This way we may rid impoverished communities of the systemic factors
that lead to economic inequality and help transform them in a way that affords longevity
and economic prosperity.

The implications of economic inequality in the United States in terms 
of the tax system are significant. The current system fails to adequately 
redistribute wealth, is riddled with loopholes and exemptions, and makes it difficult 
for people who are less well off to even obtain essential services. Additionally, the unequal 
distribution of wealth gives the wealthy disproportionate political power, 
further entrenching inequality. All of these flaws and inequities are largely the
result of systemic factors that purposefully create division in this country.
In order to address these issues, there needs 
to be comprehensive reform of the tax system to ensure that the rich pay their 
fair share and that the necessary funds are available to support those in need. This
requires a shift in our perception of wealth and may entail an entirely new, human-centered
approach on how taxes are collected in the United States.


### Acknowledgements
We acknowledge Lilia for being a great TA and helping us with our questions.

### References
1. IRS: Growing Gap between US Income Taxes Owed and Paid. ABC News, ABC News Network, 28 Oct. 2022, https://abcnews.go.com/Business/wireStory/irs-growing-gap-us-income-taxes-owed-paid-92304350.

2. Legare, Robert. Trump Takes Fight to Shield Tax Returns from House Committee to Supreme Court. CBS News, CBS Interactive, 31 Oct. 2022, https://www.cbsnews.com/news/donald-trump-tax-returns-supreme-court-request-to-shield-from-house-committee.

3. Wealth Distribution in America 1990-2022. Statista, 4 Oct. 2022, https://www.statista.com/statistics/299460/distribution-of-wealth-in-the-united-states/.

4. Soi Tax Stats - Individual Income Tax Statistics - 2019 ZIP Code Data (SOI). Internal Revenue Service, US Government, 7 Sept. 2022, https://www.irs.gov/statistics/soi-tax-stats-individual-income-tax-statistics-2019-zip-code-data-soi."

# Create markdown home page to be rendered
home_md = 
" 
### Taxes in the US: An Overview

> Paying tax is a part of everyone's lives. But is the system fair to everyone?

To understand the nuances of the tax system, we analyzed a dataset from the IRS on 
Tax Returns in 2019. A tax return is a form that contains information on income, expenses,
and taxes liability. This must be annually filed by every income earner or couple or household in the US.
    
In the US in 2019, the total amount of taxes collected was **$1,871,313,069,000 or $1.87 TRILLION.**
    
We want to know:
- What is the distribution of income over the United States based on Zip Code and State?
- Are taxes paid fairly or is the tax system abused by high earners?
- Are tax breaks and benefits to the working class enough?

In order to answer our questions, we will draw on various parameters such as income distribution by zip code,
income that is taxed less or sometimes not at all (deductions, capital gains), and tax burdens on different tax brackets.
We plan to analyze this information by state so that we may compare different areas in the US. This will help us understand
where local legislature is working, and where it isn't.

We find that high earners escape tax via deductions
and capital gains, which are taxed less than ordinary income. Low earners that do not have the means to earn income this way are 
working **paycheck-to-paycheck** and are faced with the **brunt of the tax burden**. From our analysis, we found that Southern states burden 
the lower class more than Northern states. Tax laws in the US do not benefit the working class,
but rather help the **wealthy stay on top**. This may be due to factors such as corporate lobbying and other laws
that help wealthy people influence politics. We hope this analysis may **highlight financial injustice in America** and 
encourage legislative action."
summary_md <- 
  
"### What conclusions can be drawn from this analysis? 
  
We find that high earners earn a significant portion of their income from means other than salary (real estate, stock market, other
assets). This income is often taxed at a lower rate than their wage, **the capital gains tax rate**. High earners are using the capital gains 
tax laws to pay less tax on their income. This law is much more exploitable for high earners
who have the capital to fund portfolio investments. This is one of the most significant ways 
that **wealthy individuals continue to become wealthier**. This is an extremely relevant topic right now, 
as _Joe Biden has proposed to raise the maximum capital gains tax from 20% to 39.6%_. Therefore, for the highest bracket, 
capital gains will be effectively taxed as ordinary income. This will decrease the efficacy of 
this tax evasion strategy and promote equal paying of taxes.

We also conclude that **the tax system in the US does not provide enough benefits to the lower
class**, furthering the cycle of poverty. An interesting results from our analysis is that some states 
provide more benefits to the lower class than others. Southern states typically have a higher burden on the working class
while Northern states do not show this as much. This might be due to economically conservative policies that allow for lower taxes and more tax evasion, but end up shifting 
the burden down to the low earners. Summary statistics help us look at this problem at a larger scale, across the whole US. 

The largest tax bracket by number of returns is income under $25,000 - **49.24 million returns** - 
highlighting the ever-increasing number of low earners in the US. Why are so many people stuck living paycheck-to-paycheck,
just above or falling below the poverty line? This is because, on average, these earners pay *15.79% of their income in taxes*. 
This number is lower for the middle four brackets. This rate is the highest for high earners, which is most fair, 
but should be lowest for the bottom bracket. The fact that it is not shows **injustice in the US tax system**.

Interestingly, the total Adjusted Gross Income from tax bracket 2 is more than 3 and 4, suggesting that the middle class is shrinking. 
Unsurprisingly, high earners in tax bracket 5 make up 37.09% of the total income in the US, while the lowest 
**earners in bracket 1 (which make up almost 6x more returns) only account for 5.19% of income**. 
High earners (bracket 5) are paying upwards of 52.83% of total US taxes, almost 1 trillion US dollars. The following table shows more of these statistics:"

server <- function(input, output) {
### Plot first chart
  output$chart1 <- renderPlotly({
    
    state_shape <- map_data("county") %>% 
      filter(region == input$map_state) %>%
      left_join(totals_map_df, by = c("region" = "state_name", "subregion" = "COUNTYNAME"))
    
    # define a minimalist theme
    blank_theme <- theme_bw() + 
      theme(
        axis.line = element_blank(), 
        axis.text = element_blank(),
        axis.ticks = element_blank(), 
        axis.title = element_blank(), 
        plot.background = element_blank(), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.border = element_blank())
    
    p <- ggplot(state_shape) + geom_polygon(mapping = aes(x = long, 
                                                          y = lat, 
                                                          group = group, 
                                                          fill = !!as.symbol(input$map_val), 
                                                          text = paste0("County: ", str_to_title(subregion))), 
                                            color = "white",
                                            size = .1) +
      coord_map() +
      scale_fill_continuous(low = "#132B43", high = "Red", labels = comma) +
      labs(title = str_to_title(paste0(str_replace_all(input$map_val, "\\.", " "), " in ", input$map_state," by county (2019)")),
           fill = str_to_title(paste0(str_replace_all(input$map_val, "\\.", " ")))) +
      blank_theme
    
    pp <- ggplotly(p)
    return(pp)
  })

### Plot second chart
  taxes <- taxes %>% 
    mutate(Adjusted.Size.Gross.Income.Category = 
                              case_when(Adjusted.Size.Gross.Income.Category == "under $25,000" ~ "1. Under $25K",
                                        Adjusted.Size.Gross.Income.Category == "$25,000 to $50,000" ~ "2. $25K to $50K",
                                        Adjusted.Size.Gross.Income.Category == "$50,000 to $75,000" ~ "3. $50K to $75K",
                                        Adjusted.Size.Gross.Income.Category == "$75,000 to $100,000" ~ "4. $75K to $100K",
                                        Adjusted.Size.Gross.Income.Category == "$100,000 to $200,000" ~ "5. $100K to $200K",
                                        Adjusted.Size.Gross.Income.Category == "$200,000 or more" ~ "6. $200K or more")) %>% 
    rename("Income.Category" = "Adjusted.Size.Gross.Income.Category")
  output$chart2 <- renderPlotly({
    state1 = (state.abb[match(input$first_state_chart_2, state.name)])
    state2 = (state.abb[match(input$second_state_chart_2, state.name)])
    tax_chart2 <- taxes %>% 
      filter(State %in% c(state1, state2)) %>% 
      group_by(State, Income.Category) %>% 
      summarise(Tax_percent_of_income = 100 * sum(Total.tax.payments.amount)/sum(Total.Income.Amount))
    plot <- ggplot(data = tax_chart2, 
                   mapping = 
                     aes(x = Income.Category, 
                         y = Tax_percent_of_income,
                         fill = State)) +
      geom_bar(stat = "identity", position = position_dodge()) +
      labs(
        x = "Income Category",
        y = "% of Total Income Due in Taxes",
        title = "Tax Payments as a Percentage of Income",
      )
    plot
  })
  
### Plot third chart
  output$chart3 <- renderPlotly({
    scatter <- scatter_df %>%
      filter(state_name == input$plot_state, 
             Total.Income.Amount >= input$slider[1], 
             Total.Income.Amount <= input$slider[2])
    
    p <- ggplot(data = scatter, mapping = aes(x = Total.Income.Amount, 
                                              y = !!as.symbol(input$plot_var), 
                                              color = Adjusted.Size.Gross.Income.Category,
                                              text = paste0("Zipcode: ", as.character(Zip.Code)))) +
      geom_point(position="jitter") +
      scale_x_continuous(labels = comma) +
      scale_y_continuous(labels = comma) +
      labs(title = str_to_title(paste0(str_replace_all(input$plot_var, "\\.", " "), " in ", input$plot_state, " by zipcode (2019)")),
           x = "Total Income Amount",
           y = str_to_title(str_replace_all(input$plot_var, "\\.", " ")),
           color = "Tax bracket")
    
    pp <- ggplotly(p)
    return(pp)
  })  
  
  # output report page
  output$report <- renderUI({
    HTML(markdown::markdownToHTML(text = report_md, fragment.only = TRUE))
  })
  
  # output home page
  output$introduction <- renderUI({
    HTML(markdown::markdownToHTML(text = home_md, fragment.only = TRUE))
  })
  
  output$summary <- renderUI({
    HTML(markdown::markdownToHTML(text = summary_md, fragment.only = TRUE))
  })
  output$table <- renderDataTable(aggregate_table)
}

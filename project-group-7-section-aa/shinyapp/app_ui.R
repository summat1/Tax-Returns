# UI
library(shiny)
library(plotly)
library(shinythemes)

### HOME PAGE
home_panel <- tabPanel(
  title = "Home",
  titlePanel("An Analysis of Taxes in the US"),
  fluidPage(
    img("", src = "https://s.yimg.com/ny/api/res/1.2/1AVjgz.Y0ksYNJ0FYvN91w--/YXBwaWQ9aGlnaGxhbmRlcjt3PTY0MDtoPTM2MA--/https://media.zenfs.com/en/gobankingrates_644/ec702bc1147bfe76112ce7f39f871388"),
    p(uiOutput('introduction'))
  )
)

### CHART 1 - map of one state with highlightable counties or entire US with states highlighted 
### (info: Name of county, total # returns, total tax payments issued, total income)
# Chart 1 sidebar content - choose a state
chart1_sidebar_content <- sidebarPanel(selectInput(inputId = "map_state",
                                                   label = "Choose a state",
                                                   choices = list("Alabama" = "alabama",
                                                                 "Arizona" = "arizona",
                                                                 "Arkansas" = "arkansas",
                                                                 "California" = "california",
                                                                 "Colorado" = "colorado",
                                                                 "Connecticut" = "connecticut",
                                                                 "Delaware" = "delaware",
                                                                 "Florida" = "florida",
                                                                 "Georgia" = "georgia",
                                                                 "Idaho" = "idaho",
                                                                 "Illinois" = "illinois",
                                                                 "Indiana" = "indiana",
                                                                 "Iowa" = "iowa",
                                                                 "Kansas" = "kansas",
                                                                 "Kentucky" = "kentucky",
                                                                 "Louisiana" = "louisiana",
                                                                 "Maine" = "maine",
                                                                 "Maryland" = "maryland",
                                                                 "Massachusetts" = "massachusetts",
                                                                 "Michigan" = "michigan",
                                                                 "Minnesota" = "minnesota",
                                                                 "Mississippi" = "mississippi",
                                                                 "Missouri" = "missouri",
                                                                 "Montana" = "montana",
                                                                 "Nebraska" = "nebraska",
                                                                 "Nevada" = "nevada",
                                                                 "New Hampshire" = "new hampshire",
                                                                 "New Jersey" = "new jersey",
                                                                 "New Mexico" = "new mexico",
                                                                 "New York" = "new york",
                                                                 "North Carolina" = "north carolina",
                                                                 "North Dakota" = "north dakota",
                                                                 "Ohio" = "ohio",
                                                                 "Oklahoma" = "oklahoma",
                                                                 "Oregon" = "oregon",
                                                                 "Pennsylvania" = "pennsylvania",
                                                                 "Rhode Island" = "rhode island",
                                                                 "South Carolina" = "south carolina",
                                                                 "South Dakota" = "south dakota",
                                                                 "Tennessee" = "tennessee",
                                                                 "Texas" = "texas",
                                                                 "Utah" = "utah",
                                                                 "Vermont" = "vermont",
                                                                 "Virginia" = "virginia",
                                                                 "Washington" = "washington",
                                                                 "West Virginia" = "west virginia",
                                                                 "Wisconsin" = "wisconsin",
                                                                 "Wyoming" = "wyoming"),
                                                   selected = "washington"),
                                       selectInput(inputId = "map_val",
                                                   label = "Choose a quantity",
                                                   choices = list("Total income" = "total.income.amount",
                                                                  "Total itemized deductions" = "total.itemized.deductions.amount",
                                                                  "Number of returns" = "total.number.of.returns",
                                                                  "Proportion of income taxed" = "proportion.of.income.taxed",
                                                                  "Proportion of taxable income" = "proportion.of.taxable.income",
                                                                  "Proportion of income not from wages" = "proportion.of.income.not.from.wages"),
                                                   selected = "total.income.amount"))
# Chart 1 main content
chart1_main_content <- mainPanel(plotlyOutput("chart1"))

# Chart 1 page
chart1_panel <- tabPanel(
  title = "State Map",
  titlePanel("Choropleth Map of State Tax Information by County"),
  p("The visualization shown below is a choropleth map that illustrates six different 
    pieces of tax information for U.S. states, excluding Alaska and Hawaii, at the 
    county level. We expect counties with greater values for total income to pay more taxes, 
    which is consistent with the values displayed from the map. However, when considering
    whether these tax payments are fair shares, based on the amount of total income, we must
    look at proportions. 
    
    From the map of Washington, we can, for example, compare Jefferson and
    Snohomish County. The total income of Snohomish county is nearly double that of
    Jefferson County, yet the proportions of total income that are paid to taxes are nearly
    the same in both counties. Upon further investigation, we can see that over half of Jefferson
    County's total income is not from wages while that for Snohomish County is around a fourth.
    Stark contrasts in proportions, such as this, indicate potential inequality between the taxes
    paid by high and low earners and require further analysis."),
  sidebarLayout(
    chart1_sidebar_content,
    chart1_main_content
  )
)

### CHART 2 - bar chart to compare taxes paid per bracket 
# Chart 2 sidebar content. select two states to compare or select "USA"
chart2_sidebar_content <- sidebarPanel(
  selectInput(inputId = "first_state_chart_2",
              label = "Choose a State",
              selected = "Louisiana",
              choice = state.name),
  selectInput(inputId = "second_state_chart_2",
              label = "Choose Another State",
              selected = "Washington",
              choice = state.name))
# Chart 2 main content
chart2_main_content <- mainPanel(plotlyOutput("chart2"))

# Chart 2 page
chart2_panel <- tabPanel(
  title = "Taxes by Bracket",
  titlePanel("Assessment of Taxes by Bracket in US States"),
  p("This visualization looks at the amount of tax that 
                                   the IRS charges to different tax brackets in 
                                   different states. We can easily compare any two
                                   states with this graph. 
                                   
                                   As tax bracket increases,
                                   earners should pay more percent of their income
                                   in taxes. This is a fundamental rule of tax 
                                   brackets and is the reason why federal income
                                   tax rates increase as income increases. However,
                                   this is not how taxes in the US seem to be distributed
                                   in practice. The lower tax bracket should be charged 
                                   the least percent of their income, but those earners actually have
                                   almost the same tax burden as the top earners in some states.
                                   
                                   We find that the trend is different in Southern states (typically leaning conservative) 
                                   versus Northwest states (typically leaning liberal). In the South, the tax burden on 
                                   the lowest bracket is almost equal to that for the top bracket. This indicates that 
                                   it may be very difficult to live at or around the poverty line in these states. 
                                   In addition to other hardship, almost 20% of one's paycheck will be taken to tax. In the PNW, 
                                   however, this burden is only around 12-13%. This makes it easier to keep income and start
                                   to move out of the grasps of poverty."),
  sidebarLayout(
    chart2_sidebar_content,
    chart2_main_content
  )
)

### CHART 3 - income on the x axis and deductions on the y axis
# Chart 3 sidebar content - choose income range, choose a state?
chart3_sidebar_content <- sidebarPanel(selectInput(inputId = "plot_state",
                                                   label = "Choose a state",
                                                   choices = list("Alabama" = "alabama",
                                                                  "Alaska" = "alaska",
                                                                  "Arizona" = "arizona",
                                                                  "Arkansas" = "arkansas",
                                                                  "California" = "california",
                                                                  "Colorado" = "colorado",
                                                                  "Connecticut" = "connecticut",
                                                                  "Delaware" = "delaware",
                                                                  "Florida" = "florida",
                                                                  "Georgia" = "georgia",
                                                                  "Hawaii" = "hawaii",
                                                                  "Idaho" = "idaho",
                                                                  "Illinois" = "illinois",
                                                                  "Indiana" = "indiana",
                                                                  "Iowa" = "iowa",
                                                                  "Kansas" = "kansas",
                                                                  "Kentucky" = "kentucky",
                                                                  "Louisiana" = "louisiana",
                                                                  "Maine" = "maine",
                                                                  "Maryland" = "maryland",
                                                                  "Massachusetts" = "massachusetts",
                                                                  "Michigan" = "michigan",
                                                                  "Minnesota" = "minnesota",
                                                                  "Mississippi" = "mississippi",
                                                                  "Missouri" = "missouri",
                                                                  "Montana" = "montana",
                                                                  "Nebraska" = "nebraska",
                                                                  "Nevada" = "nevada",
                                                                  "New Hampshire" = "new hampshire",
                                                                  "New Jersey" = "new jersey",
                                                                  "New Mexico" = "new mexico",
                                                                  "New York" = "new york",
                                                                  "North Carolina" = "north carolina",
                                                                  "North Dakota" = "north dakota",
                                                                  "Ohio" = "ohio",
                                                                  "Oklahoma" = "oklahoma",
                                                                  "Oregon" = "oregon",
                                                                  "Pennsylvania" = "pennsylvania",
                                                                  "Rhode Island" = "rhode island",
                                                                  "South Carolina" = "south carolina",
                                                                  "South Dakota" = "south dakota",
                                                                  "Tennessee" = "tennessee",
                                                                  "Texas" = "texas",
                                                                  "Utah" = "utah",
                                                                  "Vermont" = "vermont",
                                                                  "Virginia" = "virginia",
                                                                  "Washington" = "washington",
                                                                  "West Virginia" = "west virginia",
                                                                  "Wisconsin" = "wisconsin",
                                                                  "Wyoming" = "wyoming"),
                                                   selected = "washington"),
                                       selectInput(inputId = "plot_var",
                                                   label = "Choose a quantity",
                                                   choices = list("Total itemized deductions" = "Total.itemized.deductions.amount",
                                                                  "Number of returns" = "Total.number.of.returns",
                                                                  "Income not from wages" = "Income.not.from.wages.amount",
                                                                  "Proportion of income taxed" = "Proportion.of.income.taxed",
                                                                  "Proportion of taxable income" = "Proportion.of.taxable.income",
                                                                  "Proportion of income not from wages" = "Proportion.of.income.not.from.wages"),
                                                   selected = "Proportion.of.income.taxed"),
                                       sliderInput(inputId = "slider",
                                                   label = "Choose an income range",
                                                   min = 0,
                                                   max = 10000000,
                                                   value = c(0,300000)))
# Chart 3 main content
chart3_main_content <- mainPanel(plotlyOutput("chart3"))

# Chart 3 page
chart3_panel <- tabPanel(
  title = "Scatter Plot",
  titlePanel("Scatter Plot by Total Income"),
  p("The visualization shown below compares six different pieces of tax data 
    collected by zipcode for a chosen state against total income. Each point
    represents a particular zipcode, and the points are colored based on the
    tax bracket for which the data was collected. Iterating on the previous
    visualizations, this scatterplot makes the inequity in tax burden between
    high and low earners visually apparent. Looking at Washington, for example,
    we notice that the proportion of income that is paid to taxes, between tax 
    brackets, is not consistent with what we expect them to be. Higher earners
    are expected to pay a greater share of their income. However, the plot shows
    that there is significant overlap between the different tax brackets. This
    overlap in the proportion of income paid to taxes becomes much more
    apparent when looking at the plots for southern states such as Texas, Alabama,
    or Louisiana. To identify a potential cause for this overlap, we can look at
    the proportion of income not from wages to realize that high earners typically
    have the greatest proportions. This is income that is not necessarily taxable
    and could possibly explain why we see so much overlap in the proportion of 
    income paid to taxes across tax brackets."),
  sidebarLayout(
    chart3_sidebar_content,
    chart3_main_content
  )
)

### SUMMARY PAGE
summary_panel <- tabPanel(
  title = "Summary",
  titlePanel("Our Findings"),
  fluidPage(
    p(
      uiOutput('summary')
    ),
    p(
      dataTableOutput('table')
    )
  )
)

### REPORT PAGE
report_panel <- tabPanel(
  title = "Report",
  titlePanel("Report"),
  fluidPage(p(uiOutput('report')))
)

ui <- navbarPage("Taxes",
                  home_panel,
                  chart1_panel,
                  chart2_panel,
                  chart3_panel,
                  summary_panel,
                  report_panel,
                  theme = shinytheme("yeti")) # temporary theme
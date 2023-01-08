## Overview

The purpose of this deliverable is to provide you with the opportunity to explore your final project dataset(s), and become familiar with collaborative coding techniques. By completing the assignment, you'll demonstrate the following skills:

- Performing an exploratory analysis of a dataset
- Using R Markdown to create a report on the web
- Coding with others.
- All of the work you do this is project deliverable will set the foundations for your final deliverable. That is, for the final deliverable, you will iterate on this work and add to it. 

## Getting started 
You should return to the design brief and carefully re-read the project objectives. 

Please note: Do NOT use the Shiny framework for this assignment. 

## Assignment structure
For this assignment, your team will create a report about the datasets you have selected for your final project.

### A. Data analysis report. Your data analysis report, which will be created in index.Rmd, should contain the following: 

- "Dynamic" paragraph. In will include a well-written paragraph of summary information, citing at least 5 values calculated from the data. Each value should be presented professionally (see INFO-201 Style Guide). Here, the term "dynamic" means that the values are calculated dynamically.
- Table. You will include a table of aggregated data. Your table must group data by one feature.  
- Three charts. You will  that display information from the data (what you visualize is up to you). 
### B. R and Markdown File organization. Unlike other assignments, you'll keep your code organized in multiple different files. This helps keep your project more modular and clear. You'll create six different files for this project:

1. An index.Rmd file that renders your report ("Dynamic" paragraph, table, and three charts). 
2. A .R source file that calculates summary information to be included in your report
3. A .R source file that creates a table of summary information to be included in your report
4. A .R source file that creates your first chart
5. A .R source file that creates your second chart
6. A .R source file that creates your third chart
As we have learned in class, put your R code in the  /source  directory and put your *.Rmd report and *.HTML files in the /docs directory.

### C. The /data directory. Please include your data files in the /data directory. Also, if you are using APIs describe them in the /data/README.md file.

### D. Project report.  You should iterate on your project proposal, improving it, and writing it for your audience. As a reminder, the project proposal elements are listed below. 

## Report Components: More Detail
As described above, you'll be creating six different files. Because the purpose of this assignment is to practice collaboration, each section should be completed by a different person (and each person must work on at least one file on their own). We'll be checking the commit history to ensure that each section was pushed by a different account.

Note on group size: If you are a group of one, two or three we expect that you will do less work - please check with your Teaching Assistant.

Here is additional information on each section:

## index.Rmd File (B.1 above)
In index.Rmd file, you should run the other scripts to generate the necessary content for your report:

"Dynamic" paragraph. Write a summary paragraph that includes information calculated by your summary information function. (See chapter 18 in the book.)

Table. (a) Render your table.  (b) In a short paragraph beneath your table, describe pertinent observations found in it

Three charts. (a) Render each of your charts. (b) In a short paragraph beneath each chart, describe the purpose of the chart and pertinent observations. 

Summary Information Script (B.2 above)
To implement the summary function, you should store summary information in a list. For example:

summary_info.R 
A source file that takes in a dataset and returns a list of info about it:
summary_info <- list()
summary_info$num_observations <- nrow(my_dataframe)
summary_info$some_max_value <- my_dataframe %>%
    filter(some_var == max(some_var, na.rm = T)) %>%
    select(some_label)
The file must compute at least 5 different values from your data.  You should show this information in the "dynamic" paragraph. 

### Aggregate Table Script (B.3 above)
You should write code to produce a table of aggregate information about it. It must perform a groupby() operation to show a dimension of the dataset as grouped by a particular feature (column). We expect the included table to:

Have well formatted (i.e., human readable) column names (so you'll probably have to change them)

Only contain relevant information (i.e., only select some columns of interest)

Be intentionally sorted in a meaningful way

Round any quantitative values so they are displayed in a manner that isn't distracting
When you display the table in your index.Rmd file, you must also include a brief paragraph, describing why you included the table, and what information it reveals.

### Chart Scripts (B.4, B.5, and B.6 above)
In your other .R files you create, you should create a visualization of your data. Create a separate .R file for each chart.

Each chart must return a different type of visualization (e.g., you can only create one Scatter Plot, one map, one bar chart, etc.).  

Beneath each chart,  you must include a brief paragraph, describing why you included the chart and what information it reveals, including notable observations and insights from the chart.

For each chart, we expect a professional appearance, with effective label, titles, scales, and on so.  Some specific points: 

Chart types are intentionally selected to reveal particular patterns in the dataset
Optimal graphical encodings are selected to present the data in the most interpretable way

For two dimensional plots, X, Y axis labels are set with clear human readable titles
When appropriate, the chart has a title

A legend is present for any color encodings

If a legend is present, the legend label has been set to be easily readable

Submission
As with other assignments, we expect your code to pass all linting tests and use the appropriate packages described throughout the course. As with the previous assignments, you should add and commit your changes using git, and push your assignment to GitHub. You will submit the URL of your repository as your assignment. Only one person will need to submit, because this is configured as a group project. 

## All project deliverables should follow the INFO-201 Style Guide. 
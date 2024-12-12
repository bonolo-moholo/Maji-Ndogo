# Maji Ndogo

## Table of contents

- [Project Overview](#project-overview)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Findings](#findings)
- [Action Plan](#action-plan)
- [References](#references)
## Project Overview
The project ia about using Data analysis to address water crisis in a Country called Maji Ndogo. Data was generated using AI for the purpose of this project to mirror real life
challenges .This data was about the state of water sources across Maji Ndogo, how water is collected, gender parity involved in accessing water, the criminal activities involved in 
water collection and how everyone is affected. The data was then analysed using SQL and insights visualized using PowerBI and reported to inform decisions by relevant stakeholders.

## Tools

- Google Sheets (Data Cleaning)
- SQL Server (Data Analysis)
- PowerBI (Data Visualization and Creating a Report)

### Data Cleaning and Preparation

In the initial phase of data cleaning we performed the following tasks:
- We imported/loaded the data, inspected it and split it correctly
- Handled missing values and duplicates
- Data cleaning and formatting

### Exploratory Data Analysis

EDA involved to answer these questions:

- How much is the poulation size
- Investigating ccess to water by population size
- Investigating access to water by area
- Investigated access to water by income group

### Data Analysis
Data Analysis was performed in the following way:

```sql

#Exploring the dataset
SELECT 
	*
FROM 
	md_water_services;

#Checking the type of water sources available
SELECT 
	type_of_water_source
FROM 
	md_water_services.water_sources;

#Assessing the quality of water sources
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10 AND visit_count = 2; -- insight showsdata has errorneous entries as top quality sources should not be visited more than ones but data tells a different story and thus needs cleaning

```
## Findings 

These are the findings uncovered

1. Most water sources are in rural areas in Maji Ndogo.
2. 43% of the people are using shared taps. 2000 people often share one tap.
3. 31% of the population has water infrastructure in their homes, but within that group,
4. 45% face non-functional systems due to issues with pipes, pumps, and reservoirs. Towns like Amina, the rural parts of Amanzi, and a couple
of towns across Akatsi and Hawassa have broken infrastructure.
5. 18% of the people are using wells of which, but within that, only 28% are clean. These are mostly in Hawassa, Kilimani and Akatsi.
6. The citizens often face long wait times for water, averaging more than 120 minutes:
• Queues are very long on Saturdays.
• Queues are longer in the mornings and evenings.
• Wednesdays and Sundays have the shortest queues.

## Action Plan

The plan is to focus on improving the water sources that affect the most people.
1. Shared taps need to be improved first.
2. Wells are a good source of water, but many are contaminated. Contaminated wells will have filters installed and new wells will be drilled 
3. Existing infrastructure will be fixed as this will decrease queue times.
4. Fixing broken taps at home is not a high priority and will therefore not be done now.
5. Most water sources are in rural areas. The teams need to know this as this means they will have to make these repairs/upgrades in
rural areas where road conditions, supplies, and labour are harder challenges to overcome.

## Monitoring the progress of improvement

We created a new table on sql to monitor the progress of improvement as follows:

```sql

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50), -- Street address
Town_name VARCHAR(30),
Province_name VARCHAR(30),
type_of_water_source VARCHAR(50),
Improvement VARCHAR(50), 
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);

```
## Data Visualizations

- Data Visualizations were performend on powerBI and the visual dashboards and DAX calculations are loaded as files.
- The report includes visualizations of people served per location type(rural/urban), number of broken infrastructure per province, the time it took people to queue for water, crimes related to 
  queueing for water, the usage of different water sources per province and per town, the composition of queues, the pollution data analysis, the crimes commited, the national and 
  provincial budget.
- The insights for these visualizations are as follows:
  1. Maji Ndogo population is about 28 million and 18 million people live in the rural areas while 10 million people live in the urban areas
  2. Analysing the queues shows that during the week queues are longer in the mornings and afternoons as we have seen using SQL, and over the weekend queues stays long throughout the day except for Sundays where queues are usually shorter. The other insight is that during the week, women collect water the most while men are mostly found queueing for water on weekends the most. Children are also found in these queues as they probably collect water with their mothers.
  3. While analysing the water collection crime related charts, the insights we get is that women are most likely to be victimized than men when collecting water, and this happens across all different provinces except for Amanzi and the most crimes commited against women include harassment and sexual assault
  4. The map and a pie chart was used to show analysis of the pollution data per province, thus selecting a province on the map shows its pollution percentage on the pie chart. The water sources(wells) in provinces are 41% polluted by chemicals, and 31% biologically contaminated while 28% clean.
  5. The estimated budget to fix water access related issues nationally, including: installing filters for wells, repairing infrustructer, drilling wells and installing new taps is about $147 million and the distribution for each province is shown on the chart below, only 34% of people have access to water.


![pic 4](https://github.com/user-attachments/assets/5526f740-47d5-41cb-a670-1ea1cde5b8af)


## References

 1. Alx Africa Data Analytics programme [Apply at: https://www.alxafrica.com/]
 2. ChatGT [https://chatgpt.com/]

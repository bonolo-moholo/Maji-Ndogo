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
water collection and how everyone is affected. The data was then analysed and insights extracted to inform decisions by relevant stakeholders.

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
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group,
4. 45% face non-functional systems due to issues with pipes, pumps, and reservoirs. Towns like Amina, the rural parts of Amanzi, and a couple
of towns across Akatsi and Hawassa have broken infrastructure.
5. 18% of our people are using wells of which, but within that, only 28% are clean. These are mostly in Hawassa, Kilimani and Akatsi.
6. Our citizens often face long wait times for water, averaging more than 120 minutes:
• Queues are very long on Saturdays.
• Queues are longer in the mornings and evenings.
• Wednesdays and Sundays have the shortest queues.

## Action Plan

We want to focus our efforts on improving the water sources that affect the most people.
1. Most people will benefit if shared taps are improved first.
2. Wells are a good source of water, but many are contaminated. Fixing this will benefit a lot of people.
3. Fixing existing infrastructure will benefit a lot of people. If they have running water again, they won't have to queue, thereby shorting queue times
for others. 
4. Installing taps in homes will stretch  resources too thin, so for now if the queue times are low, no need to improve that source.
5. Most water sources are in rural areas. We need to ensure our teams know this as this means they will have to make these repairs/upgrades in
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
  2. While analysing broken infrastructure per province, Amanzi province showed to have more broken infrastrure than all the other provinces, placing it as top priority in terms of
     fixing broken infrastructure


## References

 1. Alx Africa Data Analytics programme [Apply at: https://www.alxafrica.com/]
 2. ChatGT [https://chatgpt.com/]

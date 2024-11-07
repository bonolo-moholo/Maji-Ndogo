# Maji Ndogo
## Project Overview
The project ia about using Data analysis to address water crisis in a Country called Maji Ndogo. Data was generated using AI for the purpose of this project to mirror real life
challenges .This data was about the state of water sources across Maji Ndogo, how water is collected, gender parity involved in accessing water, the criminal activities involved in 
water collection and how everyone is affected. The data was then analysed and insights extracted to inform decisions by relevant stakeholders.

## Tools

- Google Sheets (Data Cleaning)
- SQL Sever (Data Analysis)
- PowerBI (Data Visualization and Creating a Report)

### Data Cleaning/Preparation

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

SELECT 
	*
FROM 
	md_water_services.visits
WHERE
	time_in_queue>500;

# Figuring out the water source that took the longest time. If we just select the first couple of records of the visits table without a WHERE filter, 
# we can see that some of these rows also have 0 mins  queue time. So lets write down one or two of these too.
SELECT 
	*
FROM 
	md_water_services.visits; -- the sources are KiRu28935224, AkRu05234224, KiRu28520224 with 0 minutes

# Checking records with these sources: HaZa21742224, AkRu05234224
SELECT *
FROM water_source
WHERE source_id = "AkRu05234224" OR source_id = "HaZa21742224";

#Assessing the quality of water sources
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10 AND visit_count = 2; -- Data has errorneous entries as top quality sources should not be visited more than ones but data tells a different story

# Investigating pollution issues
-- Printing rows of pollution data
SELECT *
FROM well_pollution
LIMIT 5;

# CHECKING the intergrity of the well pollution data
SELECT *
FROM well_pollution
WHERE biological > 0.01 AND results = "Clean"; -- 64 rows returned indicating a mistake. biologically contaminated labelled as clean

# identify the records that mistakenly have the word Clean in the description.
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean%_';

# Case 1a: Update descriptions that mistakenly mention `Clean Bacteria: E. coli` to `Bacteria: E. coli`
SET SQL_SAFE_UPDATES = 0;
UPDATE
	well_pollution
SET
	description = 'Bacteria: E. coli' 
WHERE
	description = 'Clean Bacteria: E. coli';
# Case 1b: Update the descriptions that mistakenly mention `Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
UPDATE
	well_pollution
SET
	description = 'Bacteria: Giardia Lamblia' 
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';
# Case 2: Update the `result` to `Contaminated: Biological` where `biological` is greater than 0.01 plus current results is `Clean`
UPDATE
	well_pollution
SET
	results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';
SET SQL_SAFE_UPDATES = 1;
# Checking if updates were successful
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean%_';

# Making a copy of the real data
CREATE TABLE
	md_water_services.well_pollution_copy
AS (
SELECT
	*
FROM
	md_water_services.well_pollution
);
SELECT
*
FROM
well_pollution_copy
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

#Drop the copy table
DROP TABLE
md_water_services.well_pollution_copy;

# updating the employee information
SELECT
	REPLACE(employee_name, ' ','.') # Replace the space with a full stop
FROM
	employee;

SELECT
	LOWER(REPLACE(employee_name, ' ','.')) # Make it all lower case
FROM
	employee;

SELECT
	CONCAT(
	LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email # add it all together
FROM
	employee;

SET SQL_SAFE_UPDATES = 0;
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');
SET SQL_SAFE_UPDATES = 1;

#Checking if the updates happened
SELECT
	email
FROM
	employee;

# Continuing to clean up the data
SELECT
	LENGTH(phone_number) #Checking the length of phone numbers which is supposed to be 12
FROM
	employee;

# Triming the phone numbers
SELECT
	length(trim(phone_number))
FROM 
	employee;

SET SQL_SAFE_UPDATES = 0;
UPDATE 
	employee
SET 
	phone_number = trim(phone_number);
SET SQL_SAFE_UPDATES = 1;

#Checking if updates were successful
SELECT
	LENGTH(phone_number)
FROM 
	employee;

#Honoring employees. 
# 1.Checking where employees reside
SELECT
	town_name,
    COUNT(employee_name) AS num_of_employess
FROM 
	employee
GROUP BY town_name;

# 2.Checking employees with the highest records
SELECT 
	assigned_employee_id,
    sum(visit_count) AS number_of_visits
FROM 
	visits
Group by assigned_employee_id
order by number_of_visits desc
Limit 3;

# 3.Employee contact details
SELECT
	assigned_employee_id,
    employee_name,
    phone_number,
    email
FROM 
	employee
WHERE
	assigned_employee_id = 1 OR  assigned_employee_id = 30 OR assigned_employee_id = 34;
    
# Analyzing locations
# Looking up records per town
SELECT
	town_name,
    COUNT(location_id) AS records_per_town
FROM 
	location
GROUP BY town_name;

# Looking up records per Province
SELECT
	province_name,
    COUNT(location_id) AS records_per_province
FROM 
	location
GROUP BY province_name;

#Presenting the results with town and Province
SELECT
	province_name,
    town_name,
    COUNT(location_id) AS records_per_town
FROM
	location
GROUP BY province_name,
		town_name
order by province_name,
		town_name desc;
        
#Looking up numbers for location types
SELECT
	location_type,
    COUNT(location_id) AS number_per_locationtype
FROM 
	location
GROUP BY location_type;
SELECT 23740 / (15910 + 23740) * 100; #idicates that 60% of water sources are in rural areas

# Diving in to the water sources
SELECT
	sum(number_of_people_served)as people_surveyed
FROM
	water_source;

# Counting water sources
SELECT	
type_of_water_source,
count(type_of_water_source) AS water_sources
FROM water_source
GROUP BY type_of_water_source;

 #Hw many people share particular types of water sources on average?
 SELECT distinct
	type_of_water_source,
    avg(number_of_people_served) AS num_people_per_source_type
FROM 	
	water_source
GROUP BY type_of_water_source;
#6 people live in each household for tap in home meaning the numbers will be calculated as 644/6 = +/-100

#total number of people served by each type of water source in total,
SELECT distinct
	type_of_water_source,
    sum(number_of_people_served) as people_served
FROM 	
	water_source
GROUP BY type_of_water_source
		order by people_served desc;
 
 
 # Calculating the numbers in percentages
SELECT distinct
	type_of_water_source,
ROUND(SUM((number_of_people_served)/27628140*100)) AS people_served
FROM 	
	water_source
GROUP BY type_of_water_source
		order by people_served desc;    
        

SELECT distinct
	type_of_water_source,
    sum(number_of_people_served) as people_served,
    rank() OVER (
    ORDER BY sum(number_of_people_served) DESC
	) AS rank_by_population
FROM 	
	water_source
WHERE type_of_water_source != "tap_in_home"
Group by type_of_water_source
order by people_served desc;

SELECT distinct
	source_id,
	type_of_water_source,
    sum(number_of_people_served) as people_served,
    row_number() OVER (      -- Each source has a unique rank making it easier for engineers to choose which to repiar first
    PARTITION BY type_of_water_source
    ORDER BY sum(number_of_people_served) desc
	) AS priority_rank
FROM 	
	water_source
WHERE type_of_water_source != "tap_in_home" -- Excludes tap in home water source
Group by type_of_water_source,
		source_id
order by people_served desc; -- Orders by the number of people served

# Anlyzing queues
-- How long will the survey take?
SELECT
	DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS survey_length
FROM
	visits;
    
-- how long do people have to queue on average in Maji Ndogo
SELECT 
	avg(NULLIF(time_in_queue,0)) AS time_queued
FROM 
	visits;
    
-- looking at the queue times aggregated across the different days of the week
SELECT
	DAYNAME(time_of_record) AS day_of_the_week,
    AVG(NULLIF(time_in_queue,0)) AS agv_time_queued
FROM
	visits
GROUP BY 
	DAYNAME(time_of_record);
    
# what time during the day do people collect water.
SELECT
	ROUND(AVG(NULLIF(time_in_queue,0))) AS agv_time_queued,
	HOUR(time_of_record) AS time_of_day
FROM 
	visits
GROUP BY 
	time_of_day;

# Changing the format for better reading and understanding
SELECT
	ROUND(AVG(NULLIF(time_in_queue,0))) AS agv_time_queued,
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day -- This formats time for better reading
FROM 
	visits
GROUP BY 
	hour_of_day;
    
#Breaking down queue times for each hour of each day with a pivot table
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day, -- Sunday
ROUND(AVG(
CASE
	WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
	ELSE NULL
	END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
	WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
	ELSE NULL
	END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
		ELSE NULL
		END
),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
	ELSE NULL
	END
),0) AS Wednesday,
-- Thurday
ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
	ELSE NULL
	END
),0) AS Thursday,
-- Friday
ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
		ELSE NULL
		END
),0) AS Friday,
-- Saturday
ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
	ELSE NULL
	END
),0) AS Saturday
FROM
	visits
WHERE
	time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
	hour_of_day
ORDER BY
	hour_of_day;	

# Intergrating the Auditor's report
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

# Checking if there is a difference in the scores by joining the tables
-- Pulling records from different tables
SELECT
	auditor_report.location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS Auditor_score,
    water_quality.subjective_quality_score AS Surveyor_score
FROM
	auditor_report 
JOIN
	visits 
ON
	visits.location_id = auditor_report.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id;

-- Comparing the scores
SELECT
	auditor_report.location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS Auditor_score,
    water_quality.subjective_quality_score AS Surveyor_score
FROM
	auditor_report 
JOIN
	visits 
ON
	visits.location_id = auditor_report.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id
WHERE 
       visits.visit_count = 1 AND
	auditor_report.true_water_source_score = water_quality.subjective_quality_score; -- 1518/1620 = 94% of the records the auditor checked were correct

-- Checking the incorrect records
 SELECT
	auditor_report.location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS Auditor_score,
    water_quality.subjective_quality_score AS Surveyor_score
FROM
	auditor_report 
JOIN
	visits 
ON
	visits.location_id = auditor_report.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id
WHERE 
       visits.visit_count = 1 AND
	auditor_report.true_water_source_score != water_quality.subjective_quality_score; -- 102 incorrect records returned

#Checking if water sources are the same
SELECT
	auditor_report.location_id,
    visits.record_id,
    auditor_report.type_of_water_source AS Auditor_source,
    water_source.type_of_water_source AS Surveyor_source,
    auditor_report.true_water_source_score AS Auditor_score,
    water_quality.subjective_quality_score AS Surveyor_score
FROM
	auditor_report 
JOIN
	visits 
ON
	visits.location_id = auditor_report.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id
JOIN
	water_source
ON
	water_source.source_id = visits.source_id
WHERE 
       visits.visit_count = 1 AND
	auditor_report.true_water_source_score != water_quality.subjective_quality_score; -- No mistake with water sources done
    
# Linking records to employees
SELECT
	auditor_report.location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS Auditor_score,
    water_quality.subjective_quality_score AS Surveyor_score
FROM
	auditor_report 
JOIN
	visits 
ON
	visits.location_id = auditor_report.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id = employee.assigned_employee_id
WHERE 
       visits.visit_count = 1 AND
	auditor_report.true_water_source_score != water_quality.subjective_quality_score;

#Creating a CTE for the query as its a bit complex
WITH 
	Incorrect_records AS(
			SELECT
					auditor_report.location_id,
					visits.record_id,
					employee.employee_name,
					auditor_report.true_water_source_score AS Auditor_score,
					water_quality.subjective_quality_score AS Surveyor_score
			FROM
					auditor_report 
			JOIN
					visits 
			ON
					visits.location_id = auditor_report.location_id
			JOIN 
					water_quality
			ON 
					visits.record_id = water_quality.record_id
			JOIN
					employee
			ON
					visits.assigned_employee_id = employee.assigned_employee_id
			WHERE 
					visits.visit_count = 1 AND
					auditor_report.true_water_source_score != water_quality.subjective_quality_score
)
SELECT *
FROM
	Incorrect_records;

#Checking the number of mistakes the employees made
WITH 
	Incorrect_records AS(
			SELECT
					auditor_report.location_id,
					visits.record_id,
					employee.employee_name,
					auditor_report.true_water_source_score AS Auditor_score,
					water_quality.subjective_quality_score AS Surveyor_score
			FROM
					auditor_report 
			JOIN
					visits 
			ON
					visits.location_id = auditor_report.location_id
			JOIN 
					water_quality
			ON 
					visits.record_id = water_quality.record_id
			JOIN
					employee
			ON
					visits.assigned_employee_id = employee.assigned_employee_id
			WHERE 
					visits.visit_count = 1 AND
					auditor_report.true_water_source_score != water_quality.subjective_quality_score
)
SELECT distinct 
	employee_name,
	count(employee_name) as num_of_mistakes
FROM
	Incorrect_records
GROUP BY 
	employee_name
ORDER BY num_of_mistakes DESC;

# Gathering Evidence
-- Creating a view
CREATE VIEW Incorrect_records AS (
			SELECT
					auditor_report.location_id,
					visits.record_id,
					employee.employee_name,
					auditor_report.true_water_source_score AS Auditor_score,
					water_quality.subjective_quality_score AS Surveyor_score,
                    auditor_report.statements
			FROM
					auditor_report 
			JOIN
					visits 
			ON
					visits.location_id = auditor_report.location_id
			JOIN 
					water_quality
			ON 
					visits.record_id = water_quality.record_id
			JOIN
					employee
			ON
					visits.assigned_employee_id = employee.assigned_employee_id
			WHERE 
					visits.visit_count = 1 AND
					auditor_report.true_water_source_score != water_quality.subjective_quality_score);


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
	SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		Incorrect_records
-- Incorrect_records is a view that joins the audit report to the database for records where the auditor and employees scores are different
	GROUP BY
			employee_name)
SELECT 
	AVG(number_of_mistakes) AS avg_num_mistakes
FROM 
	error_count; -- The number is 6

-- Employees who made above average mistakes.  Suspect list that is
WITH suspect_list AS ( 
	SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		Incorrect_records
	GROUP BY
			employee_name)
SELECT
	employee_name,
	number_of_mistakes 
FROM 
	suspect_list
WHERE 
	number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM suspect_list);

# Statements about the suspects
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
	SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		Incorrect_records
	GROUP BY
		employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
	SELECT
		employee_name,
		number_of_mistakes
	FROM
		error_count
	WHERE
		number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))-- This query filters all of the records where the "corrupt" employees gathered data.
	SELECT
		employee_name,
		location_id,
		statements
	FROM
		Incorrect_records
	WHERE
		employee_name in (SELECT employee_name FROM suspect_list) AND -- Adding "not in" on the query indicates that no any other employee received cash
        statements LIKE '%_cash_%';
	
    # Findin the data we need across tables by joining them together
   CREATE VIEW combined_analysis_table AS 
   SELECT
		loc.province_name,
        loc.town_name,
        ws.type_of_water_source,
        loc.location_type,
        ws.number_of_people_served AS people_served,
        vs.time_in_queue,
        well_pollution.results
	FROM 
		location AS loc
	INNER JOIN 
		visits AS vs
        ON loc.location_id = vs.location_id
	INNER JOIN 
		water_source AS ws
        ON ws.source_id = vs.source_id
	 LEFT JOIN 
		well_pollution
        ON well_pollution.source_id = vs.source_id
	WHERE vs.visit_count = 1;
    
# Finding the final insights from the data
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
	province_name,
	SUM(number_of_people_served) AS total_ppl_serv
FROM
	combined_analysis_table
GROUP BY
	province_name
)
SELECT
	ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
	THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
	THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
	THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
	THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
	THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN
	province_totals pt ON ct.province_name = pt.province_name
GROUP BY
	ct.province_name
ORDER BY
	ct.province_name;

# Calculating populations in totals and not percentages
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
	province_name,
	SUM(number_of_people_served) AS total_ppl_serv
FROM
	combined_analysis_table
GROUP BY
	province_name
)
SELECT
	*
FROM
	province_totals;
    
-- Aggregating the data per town
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
	THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
	THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
	THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
	THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
	THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

SELECT * FROM town_aggregated_water_access; -- analysing the table

-- Checking which towns has the highest ration of people with taps in home but no  running water
SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *

100,0) AS Pct_broken_taps

FROM
town_aggregated_water_access;

```
## Findings from Analysis

These are the findings uncovered

1. Most water sources are rural in Maji Ndogo.
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
• Most people will benefit if shared taps are improved first.
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

-- Project progress query 
-- This is to show water sources to be improved
SELECT
	location.address,
	location.town_name,
	location.province_name,
	water_source.source_id,
	water_source.type_of_water_source,
	well_pollution.results
FROM
	water_source
LEFT JOIN
	well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
	visits ON water_source.source_id = visits.source_id
INNER JOIN 
	location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
well_pollution.results != 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source = 'shared_tap' AND time_in_queue > 30)
);

# Inserting information into the project progress table, Improvement column
INSERT INTO project_progress (source_id, Improvement, type_of_water_source)
SELECT
    wp.source_id,
    CASE 
        WHEN wp.results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN ws.type_of_water_source = 'river' AND wp.results IS NULL THEN 'Drill well'
        ELSE NULL
    END AS Improvement,
    ws.type_of_water_source
FROM 
    well_pollution AS wp
LEFT JOIN 
    water_source AS ws
    ON wp.source_id = ws.source_id
WHERE
    (wp.results IN ('Contaminated: Biological', 'Contaminated: Chemical'))
    OR (ws.type_of_water_source = 'river');
```

## References

 Alx Africa Institution

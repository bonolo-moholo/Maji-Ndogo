#  Understanding the data
SHOW TABLES;

-- Exploring each table. 
SELECT * FROM location; -- Locations table

-- Exploring Visits table
SELECT * FROM visits;

-- Exploring water source table to see the type of sources we have
SELECT type_of_water_source FROM water_source;

-- Unpacking visits to water sources
SELECT 
	*
FROM 
	md_water_services.visits
WHERE
	time_in_queue>500;

-- Checking out the water source that took the longest time. 
SELECT 
	*
FROM 
	visits
WHERE
	time_in_queue > 500; 

-- Using source_ID to check the names of these sources from another table
SELECT
	*
FROM
	water_source
WHERE 
	source_id = 'AkKi00881224' OR  source_id = 'SoRu37635224' OR source_id = 'SoRu36096224'; -- Shared tap is the source
    
# Checking records with these sources: HaZa21742224, AkRu05234224 which have 0 minutes queue time
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

# Checking the intergrity of the well pollution data
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

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same

source more than once in the future.

*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,

and should refer to the source table. This ensures data integrity.

*/
Address VARCHAR(50), -- Street address
Town_name VARCHAR(30),
Province_name VARCHAR(30),
type_of_water_source VARCHAR(50),
Improvement VARCHAR(50), -- What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);

-- Project progress query 
-- water sources to be improved
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

# Improvement table

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



USE try ;
DROP TABLE IF EXISTS Covid_deaths;
CREATE TABLE Covid_deaths 
(
iso_code VARCHAR(255),
continent VARCHAR(255),
location VARCHAR(255),
RecordDate VARCHAR(255),
population BIGINT,
total_cases	BIGINT,
new_cases BIGINT,
new_cases_smoothed BIGINT,
total_deaths BIGINT,
new_deaths BIGINT, 
new_deaths_smoothed	BIGINT,
total_cases_per_million	BIGINT,
new_cases_per_million BIGINT,
new_cases_smoothed_per_million BIGINT,	
total_deaths_per_million BIGINT,
new_deaths_per_million BIGINT,
new_deaths_smoothed_per_million	BIGINT,
reproduction_rate BIGINT,
icu_patients BIGINT,
icu_patients_per_million BIGINT,
hosp_patients BIGINT,
hosp_patients_per_million BIGINT,	
weekly_icu_admissions BIGINT,
weekly_icu_admissions_per_million BIGINT,
weekly_hosp_admissions BIGINT,
weekly_hosp_admissions_per_million BIGINT
);

LOAD DATA INFILE 'Covid_Deaths.csv' INTO TABLE Covid_deaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES ;


-- SELECT location,RecordDate,population,total_cases,new_cases,total_deaths FROM Covid_deaths 
-- ORDER BY 1;

-- Death percentage of India 
SELECT location,RecordDate,
total_cases,population,total_deaths,
(total_deaths/total_cases)*100 AS death_percentage 
FROM Covid_deaths 
WHERE location LIKE '%INDIA%'
ORDER BY total_deaths DESC ;

-- infection percentage of India  
SELECT location,RecordDate,total_cases,
new_cases,population,
(total_cases/population)*100 AS infection_percentage
 FROM Covid_deaths 
WHERE location LIKE '%INDIA%'
ORDER BY infection_percentage DESC;

-- Country with highest infection percentage 
CREATE VIEW highest_infection_percentage AS
SELECT location,MAX(total_cases) AS HighestInfectionCount,population,
MAX((total_cases/population))*100 AS infection_percentage 
FROM Covid_deaths 
WHERE continent NOT LIKE "%0%"
GROUP BY location,population
ORDER BY infection_percentage DESC;

-- Country with the highest number of new cases in a day
CREATE VIEW most_cases_in_a_day AS
SELECT location,max(new_cases) as highest_new_cases 
FROM Covid_deaths 
WHERE continent NOT LIKE "%0%"
GROUP BY location,population 
ORDER BY highest_new_cases DESC;

-- Country with highest death count 
CREATE VIEW highest_death_count AS
SELECT location,MAX(total_deaths) AS Total_deaths FROM Covid_deaths 
WHERE continent NOT LIKE'%0%' 
GROUP BY location,population
ORDER BY Total_deaths DESC;


-- Country with highest death pecentage 
SELECT location,MAX(total_deaths) AS HighestdeathCount,
population,MAX((total_deaths/population))*100 AS death_percentage 
FROM Covid_deaths 
WHERE continent NOT LIKE'%0%' 
GROUP BY location,population
ORDER BY death_percentage DESC;


-- Distribution of deaths according to the continent 
CREATE VIEW distribution_of_deaths AS 
SELECT continent ,MAX(total_deaths) AS deaths FROM Covid_deaths 
WHERE continent NOT LIKE '%0%'
GROUP BY continent 
ORDER BY deaths DESC;


-- Distribution of cases according to the continent 
CREATE VIEW distribution_of_cases AS 
SELECT continent ,MAX(total_cases) AS Cases FROM Covid_deaths 
WHERE continent NOT LIKE '%0%'
GROUP BY continent 
ORDER BY Cases DESC;


-- Global numbers of cases,deaths and death percentage each day 

SELECT RecordDate,SUM(new_cases) as Total_cases,
SUM(new_deaths) as total_deaths ,
(SUM(new_deaths)/SUM(new_cases)) * 100  as death_percentage_per_day 
FROM Covid_deaths 
WHERE continent NOT LIKE '%0%'
GROUP BY RecordDate 
ORDER BY RecordDate ;


-- Country with highest ICU patients  
SELECT location , sum(new_cases) as Total_cases ,
 sum(icu_patients) as Total_ICU_patients, 
 (sum(icu_patients)/sum(new_cases))*100 AS ICU_patients_percentage
 FROM Covid_deaths 
WHERE continent NOT LIKE "%0%"
GROUP BY location,population 
ORDER BY ICU_patients_percentage DESC;


-- Create a rolling average for icu patients to get weekly icu patients and calculate weekly icu admissions percentage
-- use CTE icu_admissions
CREATE TABLE ICU_patients (
SELECT location,RecordDate,total_cases, weekly_icu_admissions,
SUM(icu_patients) OVER (PARTITION BY location ORDER BY RecordDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Weekly_icu_patients
FROM Covid_deaths 
WHERE icu_patients > 0 and weekly_icu_admissions > 0
ORDER BY location,RecordDate);

CREATE TABLE ICU_ADMISSIONS(
SELECT *,(weekly_icu_admissions/Weekly_icu_patients) * 100 AS  weekly_icu_admission_percentage 
FROM ICU_patients)  ;

CREATE VIEW highest_avg_ICU_admission_percentage AS 
SELECT location, AVG(weekly_icu_admission_percentage) as avg_weekly_icu_admission_percentage FROM icu_admissions
GROUP BY location 
ORDER BY avg_weekly_icu_admission_percentage DESC 




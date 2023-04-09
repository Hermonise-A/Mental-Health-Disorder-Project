--- Global Trends in Mental Health Disorders

SELECT *
FROM mental_health..mental_data_full 

--- Upon doing a quick overview in Excel I noticed that "Entity" was reported amongst region/country information
--- This utlimately indicated the start of new table 
--- Identify the rows that indicate a new table has begun based off "Entity"

SELECT Id
FROM mental_health..mental_data_full 
WHERE Entity LIKE 'Entity'
ORDER BY Id

--- DATA CLEANING 

---I would now like to separate this the 4 datasets to accurately be able to analyze information 


--- Creating new table using data from orginal source with only certain range of rows between 0 and 6467
--- This table highlights percent of population suffering from certian mental health disorders   

SELECT *
INTO disorder_data 
FROM mental_health..mental_data_full 
WHERE Id BETWEEN 0 AND 6467
ORDER BY Id

--- Renames Entity column to Country

sp_rename 'disorder_data.Entity','Country','COLUMN'

--- To reveiw that data was updated properly 

SELECT *
FROM disorder_data 
ORDER BY Id

--- Creates new table using data from orginal source with only certain range of rows between 6469 and 54275; 
--- This table breaks down mental health disorder by prevalence in males vs. females

SELECT *
INTO mental_prevalences 
FROM mental_health..mental_data_full 
WHERE Id BETWEEN 6469 AND 54275
ORDER BY Id

--- To reveiw that data was updated properly 

SELECT *
FROM mental_prevalences
ORDER BY Id

---Deletes columns that no longer exist on this table

ALTER TABLE mental_prevalences
DROP COLUMN Anxiety, Drug_Use, Depression, Alcohol_Use

---Rename columns for more accurate description of data

sp_rename 'mental_prevalences.Schizophrenia','Prevalence_Male','COLUMN'
sp_rename 'mental_prevalences.Bipolar','Prevalence_Female','COLUMN'
sp_rename 'mental_prevalences.Eating','Population','COLUMN'
sp_rename 'mental_prevalences.Entity', 'Country', 'COLUMN'


--- Creates new table using data from orginal source with only certain range of rows between 54277 and 102083 
--- This table describes suicide rates and depressive rates per 100,000 individuals 

SELECT *
INTO suicide_depressive_rate  
FROM mental_health..mental_data_full 
WHERE Id BETWEEN 54277 AND 102083
ORDER BY Id

--- Deletes columns that no longer exist on this table

ALTER TABLE suicide_depressive_rate  
DROP COLUMN Anxiety, Drug_Use, Depression, Alcohol_Use

--- Rename columns for more accurate description of data 

sp_rename 'suicide_depressive_rate.Entity','Country','COLUMN'
sp_rename 'suicide_depressive_rate.Sucide_Rate','Suicide_Rate','COLUMN'
sp_rename 'suicide_depressive_rate.Bipolar','Depressive_Rate','COLUMN'
sp_rename 'suicide_depressive_rate.Eating','Population','COLUMN'

---To reveiw that data was updated properly 

SELECT *
FROM suicide_depressive_rate  
ORDER BY Id

--- Creates new table using data from orginal source with only certain range of rows between 102085 and 108552
--- This table describes the number of people suffering from depression between all genders and ages 

SELECT *
INTO total_depressive_rate  
FROM mental_health..mental_data_full 
WHERE Id BETWEEN 102085 AND 108552
ORDER BY Id

--- Deletes columns that no longer exist on this table

ALTER TABLE total_depressive_rate  
DROP COLUMN Bipolar, Eating, Anxiety, Drug_Use, Depression, Alcohol_Use

--- Rename columns for more accurate description of data 


sp_rename 'total_depressive_rate.Entity','Country','COLUMN'
sp_rename 'total_depressive_rate.Schizophrenia','Total_Depressive_Rate','COLUMN'

---To reveiw that data was updated properly 

SELECT *
FROM total_depressive_rate  
ORDER BY Id

---- DATA REVIEW 

--- Taking a look at data between 1990 and 2017 as most regions/countrys have reduced NULL values within these ranges 

SELECT *
FROM mental_data 
WHERE Year BETWEEN 1990 AND 2017
ORDER BY Id

--- Notice that where Code returns Null values the 'Countries' listed are actually relating to information for groups/regions such as Central Europe, High SDI Income, and South Asia 

SELECT Id, Country, Code 
FROM disorder_data 
WHERE Code IS NULL 
ORDER BY Id
 
--- Disorder Prevalence Rate by Gender 

SELECT Country, Year, Prevalence_Male, Prevalence_Female 
FROM mental_prevalences
WHERE Year BETWEEN 1990 AND 2017
	AND Code IS NOT NULL  
	AND Prevalence_Male IS NOT NULL
	AND Prevalence_Female  IS NOT NULL
ORDER BY Id

--- Here we are looking at the breakdown of Socio-Demographic Index (SDI) 

SELECT Country, Year, Drug_Use, Alcohol_Use
FROM disorder_data 
WHERE Country LIKE '%SDI%'
ORDER BY Year, Country

--- SDI is broken down into 5 categories High SDI, High-middle SDI, Low SDI, Low-middle SDI and Middle SDI 

SELECT DISTINCT(Country)
FROM disorder_data 
WHERE Country LIKE '%SDI%'

--- New dataset was located using Institute for Health Metrics and Evaluation (IHME)  Global Burden of Disease (GBD) Results Tool 
--- Joining drug and alcohol use to data for deaths within both catergories to review correlation from GBD data


SELECT ad_deaths.Location, dis.Year, dis.Drug_Use, dis.Alcohol_Use, ad_deaths.Drug_Use_Deaths, ad_deaths.Alcohol_Use_Deaths 
FROM disorder_data AS dis
JOIN  [mental_health].[dbo].[alcohol_drug_deaths] AS ad_deaths 
	ON dis.Country = ad_deaths.Location
	AND dis.Year = ad_deaths.Year
WHERE Country LIKE '%SDI%'
ORDER BY dis.Year, ad_deaths.Location


--- Creating Temp Table to perform analysis Alcohol/Drug Use versus Respective Deaths 

DROP TABLE IF EXISTS disorder_v_deaths 
CREATE TABLE disorder_v_deaths 
(
Location nvarchar(255),
Year float,
Drug_Use float,
Alcohol_Use float,
Drug_Use_Deaths float,
Alcohol_Use_Deaths float
) 

INSERT INTO disorder_v_deaths
SELECT ad_deaths.Location, dis.Year, dis.Drug_Use, dis.Alcohol_Use, ad_deaths.Drug_Use_Deaths, ad_deaths.Alcohol_Use_Deaths 
FROM disorder_data AS dis
JOIN  [mental_health].[dbo].[alcohol_drug_deaths] AS ad_deaths 
	ON dis.Country = ad_deaths.Location
	AND dis.Year = ad_deaths.Year
WHERE Country LIKE '%SDI%'
ORDER BY dis.Year, ad_deaths.Location

--- Reviews table was properly created 

SELECT *
FROM disorder_v_deaths

--- Focuses on Drug Use and Drug Deaths 

SELECT Location, Year, Drug_Use, Drug_Use_Deaths 
FROM disorder_v_deaths

--- Focuses on alcohol use and deaths caused by alcohol use

SELECT Location, Year, Alcohol_Use, Alcohol_Use_Deaths 
FROM disorder_v_deaths


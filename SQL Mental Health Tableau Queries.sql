--- Disorder Rates by Region 

SELECT Country, Code, Year, Schizophrenia, Bipolar, Eating, Anxiety, Drug_Use, Depression, Alcohol_Use
FROM disorder_data  
WHERE Code IS NULL 
ORDER BY Country;

--- Disorder Prevalence Rate by Gender 

SELECT Country, Code, Year, Prevalence_Male, Prevalence_Female 
FROM mental_prevalences
WHERE Year BETWEEN 1990 AND 2017
	AND Code IS NOT NULL  
	AND Prevalence_Male IS NOT NULL
	AND Prevalence_Female  IS NOT NULL
ORDER BY Id


--- Comparison between Depression, Alcohol and Drug Use by regions specifically SDI 

SELECT Country, Year, Drug_Use, Alcohol_Use
FROM disorder_data  
WHERE Country LIKE '%SDI%'
ORDER BY Country;


--- SDI Breakdown between disorder percentage 

SELECT Country, Year, Schizophrenia, Bipolar, Eating, Anxiety, Drug_Use, Depression, Alcohol_Use
FROM disorder_data 
WHERE Country LIKE '%SDI%'
ORDER BY Year, Country


--- Alcohol and Drug Use vs Category Deaths 

--- Focuses on Drug Use and Drug Deaths 

SELECT Location, Year, Drug_Use, Drug_Use_Deaths 
FROM disorder_v_deaths

--- Focuses on alcohol use and deaths caused by alcohol use

SELECT Location, Year, Alcohol_Use, Alcohol_Use_Deaths 
FROM disorder_v_deaths


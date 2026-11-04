-- ## 1. Prescriber Activity & Specialties

-- ### Prescriber Volume

-- What are the name, specialty, and total claim count of the prescriber with the highest claim volume?
SELECT
    nppes_provider_first_name,
    nppes_provider_last_org_name,
    specialty_description,
    SUM(total_claim_count)
FROM prescriber
    INNER JOIN prescription USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY SUM(total_claim_count) DESC;

-- Who were the five highest-volume prescribers in Nashville by total claims?
SELECT
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE nppes_provider_city LIKE 'NASHVILLE'
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- Who were the five highest-volume prescribers in Memphis by total claims?
SELECT
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE nppes_provider_city LIKE 'MEMPHIS'
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- Who were the highest-volume prescribers across Nashville, Memphis, Knoxville, and Chattanooga?
SELECT 
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE nppes_provider_city IN ('NASHVILLE', 'MEMPHIS', 'KNOXVILLE', 'CHATTANOOGA')
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- ### Specialty Comparisons

-- Which specialty had the highest total number of claims across all drugs?
SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
    INNER JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

-- Which specialty had the highest total number of opioid claims
SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

-- What percentage of each specialty's total claims were for opioids, and which specialties had the highest percentages?
SELECT 
    specialty_description,
	ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) / SUM(total_claim_count) * 100, 2) AS opioid_percentage
FROM prescription
	INNER JOIN prescriber USING (npi)
	INNER JOIN drug USING (drug_name)
GROUP BY specialty_description
ORDER BY opioid_percentage DESC;

-- ### Prescriber Coverage and Missing Records

-- Which specialties have no associated prescriptions?
SELECT specialty_description
FROM prescriber
EXCEPT
SELECT specialty_description
FROM prescriber
	INNER JOIN prescription USING (npi);

-- Prescribers (or NPIs) with no available prescription data
SELECT npi
FROM prescriber
EXCEPT
SELECT npi
FROM prescriber
	INNER JOIN prescription USING (npi);

-- ### Opioid Prescribing Concentration

-- What proportion of opioids are prescribed by the top 10 prescribers? top 50? top 100?
WITH top_10 AS (
    SELECT
        SUM(total_claim_count) AS top_sum
    FROM prescription
        INNER JOIN prescriber USING (npi)
        INNER JOIN drug USING (drug_name)
    WHERE opioid_drug_flag = 'Y'
    GROUP BY npi
    ORDER BY SUM(total_claim_count) DESC
    LIMIT 10
), top_50 AS (
    SELECT
        SUM(total_claim_count) AS top_sum
    FROM prescription
        INNER JOIN prescriber USING (npi)
        INNER JOIN drug USING (drug_name)
    WHERE opioid_drug_flag = 'Y'
    GROUP BY npi
    ORDER BY SUM(total_claim_count) DESC
    LIMIT 50
), top_100 AS (
    SELECT
        SUM(total_claim_count) AS top_sum
    FROM prescription
        INNER JOIN prescriber USING (npi)
        INNER JOIN drug USING (drug_name)
    WHERE opioid_drug_flag = 'Y'
    GROUP BY npi
    ORDER BY SUM(total_claim_count) DESC
    LIMIT 100
)
SELECT
    100.0 * (SELECT SUM(top_sum) FROM top_10) / SUM(total_claim_count) AS top_10,
    100.0 * (SELECT SUM(top_sum) FROM top_50) / SUM(total_claim_count) AS top_50,
    100.0 * (SELECT SUM(top_sum) FROM top_100) / SUM(total_claim_count) AS top_100
FROM prescription
    INNER JOIN prescriber USING (npi)
    INNER JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y';

-- ## 2. Drug Utilization & Prescription Patterns

-- ### Drug Classification

-- Which drugs were classified as opioids, antibiotics, or neither?
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiobiotic'
	ELSE 'neither' END AS drugtype
FROM drug;

-- ### High-Volume Prescriptions

-- Which prescription records had at least 3000 total claims?
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

-- Which drugs with at least 3000 total claims were opioids?
SELECT 
    drug_name, total_claim_count
FROM prescription
    INNER JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000
    AND opioid_drug_flag = 'Y';

-- Which prescribers were associated with drugs having at least 3000 total claims?
SELECT DISTINCT 
	nppes_provider_first_name, 
	nppes_provider_last_org_name
FROM prescriber
	INNER JOIN ( 
		SELECT npi 
		FROM prescription 
			INNER JOIN drug USING (drug_name) 
		WHERE total_claim_count >= 3000 AND opioid_drug_flag = 'Y'
	) AS opioid_prescribers USING (npi);

-- ### Drug Utilization by Specialty

-- What were the five most-prescribed generic drugs among Family Practice prescribers?
SELECT generic_name, SUM(total_claim_count)
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE specialty_description LIKE 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- What were the five most-prescribed generic drugs among Cardiology prescribers?
SELECT generic_name, SUM(total_claim_count)
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE specialty_description LIKE 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- Which generic drugs ranked among the most prescribed by Family Practice and Cardiology prescribers?
SELECT generic_name, SUM(total_claim_count)
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE specialty_description LIKE 'Family Practice' OR
	specialty_description LIKE 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- ### Pain-Management Prescribing

-- What were all possible prescriber-drug combinations for Nashville pain-management specialists and opioid drugs?
SELECT npi, drug_name
FROM prescriber
	CROSS JOIN drug
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y';

-- What was the claim count for every Nashville pain-management specialist and opioid combination (with missing claims reported as zero)?
SELECT 
    npi, 
    drug.drug_name, 
    COALESCE(SUM(total_claim_count), 0)
FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y'
GROUP BY npi, drug.drug_name
ORDER BY SUM(total_claim_count) DESC;

-- ## 3. Prescription Spending & Drug Costs

-- ### Drug Cost Comparisons

-- Which generic drug had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost)
FROM drug
	INNER JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC;

-- Which generic drug had the highest total cost per day supplied?
SELECT 
    generic_name, 
    ROUND(SUM(total_drug_cost) / SUM(total_day_supply), 2) AS cost_per_day
FROM drug
	INNER JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;

-- ### Spending by Drug Classification

-- Was more spent on opioids or antibiotics?
SELECT
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiobiotic'
		ELSE 'neither' END AS drugtype,
	SUM(total_drug_cost)::DECIMAL(18,2) AS total_spent
FROM drug
	INNER JOIN prescription USING (drug_name)
GROUP BY drugtype
ORDER BY total_spent DESC;

-- ### Relative Spending

-- What is the ratio for spending on opioid vs non-opioid prescriptions?
SELECT
    opioid_drug_flag,
    SUM(total_drug_cost) /
        (SELECT SUM(total_drug_cost) FROM prescription INNER JOIN drug USING(drug_name)) AS spending_percent
FROM prescription
    INNER JOIN drug USING (drug_name)
GROUP BY GROUPING SETS ((), (opioid_drug_flag));

-- ## 4. Tennessee Geography & Population

-- ### Population Distribution

-- What was the total population of Tennessee?
SELECT SUM(population)
FROM population
	INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';

-- What percentage of Tennessee's population lived in each county?
SELECT county,
	population,
	ROUND(population / (SELECT SUM(population)
	FROM population INNER JOIN fips_county USING (fipscounty)
	WHERE state = 'TN'), 3) AS pop_percentage
FROM population
	INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN'
GROUP BY county, population
ORDER BY pop_percentage DESC;

-- ### Metropolitan and Statistical Areas

-- How many CBSAs are in Tennessee?
SELECT COUNT(DISTINCT cbsa)
FROM cbsa
	INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';

-- Which CBSAs had the largest and smallest combined populations?
SELECT cbsaname, SUM(population) as comb_pop
FROM cbsa
	INNER JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY comb_pop DESC;

-- What was the most populous county not included in a CBSA?
SELECT county, population
FROM fips_county
	INNER JOIN population USING (fipscounty)
	LEFT JOIN cbsa USING (fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC
LIMIT 1;

-- ## 5. Opioid Claims & Regional Patterns

-- ### Opioid Prescriber Geography

-- Where are the top 10 opioid prescribers located?
SELECT
    nppes_provider_last_org_name,
    nppes_provider_city,
    nppes_provider_state
FROM prescriber
    INNER JOIN (
        SELECT
            npi,
            SUM(total_claim_count)
        FROM prescription
            INNER JOIN drug USING (drug_name)
        WHERE opioid_drug_flag = 'Y'
        GROUP BY npi
        ORDER BY SUM(total_claim_count) DESC
        LIMIT 10
    ) AS top_prescribers USING (npi);

-- Which zip codes in Davidson County have the most opioids prescribed?
SELECT
    nppes_provider_zip5,
    SUM(total_claim_count)
FROM prescriber
    INNER JOIN prescription USING (npi)
    INNER JOIN drug USING (drug_name)
    INNER JOIN (
        SELECT zip 
        FROM zip_fips 
        INNER JOIN fips_county USING (fipscounty) 
        WHERE county = 'DAVIDSON'
    ) AS zip_list ON prescriber.nppes_provider_zip5 = zip_list.zip
WHERE opioid_drug_flag = 'Y'
GROUP BY nppes_provider_zip5
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;

-- ### Pain-Management Specialty Comparisons

-- How many total claims were associated with Interventional Pain Management and Pain Management specialists?
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY specialty_description;

-- What were the specialty-level and combined claim totals for Interventional Pain Management and Pain Management specialists? 
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY GROUPING SETS ((),(specialty_description));

-- How did opioid and non-opioid claims compare across the two pain-management specialties (including category and overall totals)?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY GROUPING SETS ((),(opioid_drug_flag),(specialty_description));

-- ### Multidimensional Claim Analysis

-- How did claim totals break down by opioid status and then by pain-management specialty?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY ROLLUP(opioid_drug_flag, specialty_description);

-- How did claim totals break down by pain-management specialty and then by opioid status?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY ROLLUP(specialty_description, opioid_drug_flag);

-- What were the claim totals across every combination of pain-management specialty and opioid status?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY CUBE(specialty_description, opioid_drug_flag);

-- ### Cross-City Drug Comparison

-- How many claims were recorded for six common opioid categories across Nashville, Memphis, Knoxville, and Chattanooga?
CREATE EXTENSION tablefunc;

SELECT *
FROM crosstab(
	'SELECT nppes_provider_city AS city,
		CASE
			WHEN drug_name ILIKE ''%hydrocodone%'' THEN ''hydrocodone''
			WHEN drug_name ILIKE ''%oxycodone%'' THEN ''oxycodone''
			WHEN drug_name ILIKE ''%oxymorphone%'' THEN ''oxymorphone''
			WHEN drug_name ILIKE ''%morphine%'' THEN ''morphine''
			WHEN drug_name ILIKE ''%codeine%'' THEN ''codeine''
			WHEN drug_name ILIKE ''%fentanyl%'' THEN ''fentanyl''
		END AS drug_category,
		SUM(total_claim_count)
	FROM prescription
		INNER JOIN prescriber USING (npi)
	WHERE nppes_provider_city IN (''NASHVILLE'',''MEMPHIS'',''KNOXVILLE'',''CHATTANOOGA'')
	GROUP BY nppes_provider_city, drug_category
	ORDER BY city')
AS ct(city text, codeine numeric, fentanyl numeric, hydrocodone numeric, morphine numeric, oxycodone numeric, oxymorphone numeric);

-- ## 6. Overdose Deaths & Population-Adjusted Outcomes

-- ### County-Level Overdose Deaths

SELECT county, SUM(overdose_deaths)
FROM fips_county
	INNER JOIN overdose_deaths ON overdose_deaths.fipscounty = fips_county.fipscounty::numeric
GROUP BY county
HAVING SUM(overdose_deaths) > (SELECT AVG(overdose_deaths) FROM overdose_deaths)
ORDER BY SUM(overdose_deaths) DESC;

-- ### Population-Adjusted Measures

-- Which county has the highest overdose deaths per capita?
SELECT
    county,
    SUM(overdose_deaths) / MAX(population) AS deaths_capita
FROM overdose_deaths
    INNER JOIN fips_county ON fips_county.fipscounty::INTEGER = overdose_deaths.fipscounty
    INNER JOIN population ON population.fipscounty::INTEGER = overdose_deaths.fipscounty
WHERE state = 'TN'
GROUP BY county
ORDER BY deaths_capita DESC;

-- ### Overdose Deaths over Time

-- How has total overdose deaths changed over time?
SELECT
    year,
    SUM(overdose_deaths)
FROM overdose_deaths
    INNER JOIN fips_county ON fips_county.fipscounty::INTEGER = overdose_deaths.fipscounty
WHERE state = 'TN'
GROUP BY year;

-- Notebook PIVOT query omitted; no PostgreSQL version was added.

-- ### Trend Estimation

-- Are there any counties in which overdose deaths are trending downward?
SELECT
    county,
    REGR_SLOPE(overdose_deaths, year) AS trend_slope
FROM overdose_deaths
    INNER JOIN fips_county ON fips_county.fipscounty::INTEGER = overdose_deaths.fipscounty
WHERE year BETWEEN 2015 AND 2018
GROUP BY county
HAVING REGR_SLOPE(overdose_deaths, year) < 0
ORDER BY trend_slope;

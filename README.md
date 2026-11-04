## Project Overview

This project uses SQL to analyze Medicare Part D prescribing data alongside drug classifications, population data, geographic reference data, and overdose death records. The database contains eight interconnected tables covering prescribers, prescriptions, drugs, populations, counties, metropolitan areas, ZIP-to-county mappings, and overdose deaths.

The analysis examines prescribing volume, opioid utilization, drug costs, provider specialties, geographic patterns, population distribution, and overdose mortality across Tennessee. Prescribing geography reflects provider locations.

[Project Notebook](scripts/project_eda.ipynb)

![Database diagram](ERD.png)

## Project Objective

Use SQL to investigate healthcare and public-health questions, including:

- Which providers, specialties, and medications account for the highest prescription claim volumes?
- Which specialties have the greatest number and proportion of opioid claims?
- What share of recorded opioid claims is attributable to the top 10, 50, and 100 prescribers?
- Which medications have the highest total cost and cost per day supplied?
- How does spending compare across opioids, antibiotics, and other drugs?
- Which providers generate the most claims across Nashville, Memphis, Knoxville, and Chattanooga?
- How do opioid claims differ by drug category across Nashville, Memphis, Knoxville, and Chattanooga?
- How do overdose death counts and population-adjusted measures vary across Tennessee counties?
- Which counties show downward trends in recorded overdose death counts during 2015–2018?
- How can every Nashville pain-management prescriber–opioid combination be reported, including combinations without matching prescription records?

## Technologies Used

- PostgreSQL — original database and SQL analysis ([SQL queries](scripts/postgres_scripts.sql))
- DuckDB and Python — database connection and SQL execution in the notebook version

## Techniques and Methodology Used

- Relational joins across prescribing, drug, demographic, and geographic datasets ([prescriber join](scripts/project_eda.ipynb#L224-L234); [population and geography joins](scripts/project_eda.ipynb#L5103-L5113))
- Subqueries for filtering, aggregate comparisons, and percentage denominators ([opioid-claim concentration](scripts/project_eda.ipynb#L1347-L1387); [population denominator](scripts/project_eda.ipynb#L3163-L3174))
- Set operations, including `EXCEPT`, to identify specialties and prescribers without matching prescription records ([specialties](scripts/project_eda.ipynb#L1142-L1149); [prescribers](scripts/project_eda.ipynb#L1265-L1272))
- Conditional expressions for drug classification and conditional aggregation for opioid-utilization metrics ([drug classification](scripts/project_eda.ipynb#L1544-L1550); [opioid percentages](scripts/project_eda.ipynb#L992-L1001))
- Cross joins and outer joins to construct complete prescriber–drug combinations ([prescriber–drug combinations](scripts/project_eda.ipynb#L2428-L2441))
- Null handling with `COALESCE` to supply default values for missing aggregate results ([claim-count query](scripts/project_eda.ipynb#L2428-L2441))
- Common table expressions (CTEs) and aggregate subqueries to calculate opioid-claim concentration among leading prescribers ([concentration query](scripts/project_eda.ipynb#L1347-L1387))
- Multidimensional aggregation with `GROUPING SETS`, `ROLLUP`, and `CUBE` ([grouping sets](scripts/project_eda.ipynb#L3912-L3920); [rollup](scripts/project_eda.ipynb#L4140-L4148); [cube](scripts/project_eda.ipynb#L4388-L4396))
- Pivot-table generation using PostgreSQL’s `tablefunc.crosstab` and DuckDB’s native `PIVOT` ([PostgreSQL queries](scripts/postgres_scripts.sql); [notebook pivot](scripts/project_eda.ipynb#L4518-L4542))
- Top-N analysis across specialties, drugs, providers, and geographic areas ([city providers](scripts/project_eda.ipynb#L336-L347); [specialty drugs](scripts/project_eda.ipynb#L1926-L1935); [ZIP codes](scripts/project_eda.ipynb#L3732-L3749))
- Aggregate ratios for cost per day supplied, spending shares, population shares, and overdose deaths relative to population ([cost per day](scripts/project_eda.ipynb#L2721-L2729); [spending share](scripts/project_eda.ipynb#L2909-L2918); [population share](scripts/project_eda.ipynb#L3163-L3174); [overdose deaths relative to population](scripts/project_eda.ipynb#L5103-L5113))
- Annual overdose-death summaries and regression-slope calculations with `REGR_SLOPE` to identify downward county-level trends ([annual totals](scripts/project_eda.ipynb#L5204-L5212); [regression slopes](scripts/project_eda.ipynb#L5603-L5613))
- Documentation of temporal and geographic limitations affecting comparisons between prescription spending and overdose deaths ([documented limitations](scripts/project_eda.ipynb#L2926-L2937))

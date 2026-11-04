## Project Overview

This project uses SQL to analyze Medicare Part D prescribing data alongside drug classifications, population data, geographic reference data, and overdose death records. The database contains eight interconnected tables covering prescribers, prescriptions, drugs, populations, counties, metropolitan areas, ZIP-to-county mappings, and overdose deaths.

The analysis examines prescribing volume, opioid utilization, drug costs, provider specialties, geographic patterns, population distribution, and overdose mortality across Tennessee. Prescribing geography reflects provider locations.

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

- PostgreSQL — original database and SQL analysis ([SQL queries](scripts/postgres_scripts.sql#L1))
- DuckDB and Python — database connection and SQL execution in the notebook version ([Project notebook](scripts/project_eda.ipynb))

## Techniques and Methodology Used

- Relational joins across prescribing, drug, demographic, and geographic datasets ([example](scripts/postgres_scripts.sql#L464))
- Subqueries for filtering, aggregate comparisons, and percentage denominators ([example](scripts/postgres_scripts.sql#L272))
- Set operations, including `EXCEPT`, to identify specialties and prescribers without matching prescription records ([specialties](scripts/postgres_scripts.sql#L82), [prescribers](scripts/postgres_scripts.sql#L90))
- Conditional expressions for drug classification and conditional aggregation for opioid-utilization metrics ([classification](scripts/postgres_scripts.sql#L145), [aggregation](scripts/postgres_scripts.sql#L70))
- Cross joins and outer joins to construct complete prescriber–drug combinations ([example](scripts/postgres_scripts.sql#L222))
- Null handling with `COALESCE` to supply default values for missing aggregate results ([example](scripts/postgres_scripts.sql#L223))
- Common table expressions (CTEs) and aggregate subqueries to calculate opioid-claim concentration among leading prescribers ([example](scripts/postgres_scripts.sql#L100))
- Multidimensional aggregation with `GROUPING SETS`, `ROLLUP`, and `CUBE` ([GROUPING SETS](scripts/postgres_scripts.sql#L376), [ROLLUP](scripts/postgres_scripts.sql#L396), [CUBE](scripts/postgres_scripts.sql#L414))
- Pivot-table generation using PostgreSQL’s `tablefunc.crosstab` and DuckDB’s native `PIVOT` ([crosstab](scripts/postgres_scripts.sql#L425), [notebook](scripts/project_eda.ipynb))
- Top-N analysis across specialties, drugs, providers, and geographic areas ([example](scripts/postgres_scripts.sql#L16))
- Aggregate ratios for cost per day supplied, spending shares, population shares, and overdose deaths relative to population ([cost](scripts/postgres_scripts.sql#L247), [spending](scripts/postgres_scripts.sql#L271), [population](scripts/postgres_scripts.sql#L290), [overdose deaths](scripts/postgres_scripts.sql#L460))
- Annual overdose-death summaries and regression-slope calculations with `REGR_SLOPE` to identify downward county-level trends ([annual summaries](scripts/postgres_scripts.sql#L473), [trend calculation](scripts/postgres_scripts.sql#L486))
- Documentation of temporal and geographic limitations affecting comparisons between prescription spending and overdose deaths ([project notebook](scripts/project_eda.ipynb))

import json
import duckdb

from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

with open(ROOT / 'secrets.json', 'r') as f:
    secrets = json.load(f)

pg_conn = (
        f"host={secrets['PG_HOST']} "
        f"port={secrets['PG_PORT']} "
        f"dbname={secrets['PG_DB']} "
        f"user={secrets['PG_USER']} "
        f"password={secrets['PG_PASSWORD']}"
    )

with duckdb.connect(str(ROOT / 'data' / 'analytics.duckdb')) as con:
    con.sql('INSTALL postgres;')
    con.sql('LOAD postgres;')

    con.execute(f"ATTACH '{pg_conn}' AS pg (TYPE postgres, READ_ONLY);")

    try:
        con.execute("CREATE OR REPLACE TABLE cbsa AS SELECT * FROM pg.cbsa;")
        con.execute("CREATE OR REPLACE TABLE drug AS SELECT * FROM pg.drug;")
        con.execute("CREATE OR REPLACE TABLE fips_county AS SELECT * FROM pg.fips_county;")
        con.execute("CREATE OR REPLACE TABLE overdose_deaths AS SELECT * FROM pg.overdose_deaths;")
        con.execute("CREATE OR REPLACE TABLE population AS SELECT * FROM pg.population;")
        con.execute("CREATE OR REPLACE TABLE prescriber AS SELECT * REPLACE(CAST(npi AS BIGINT) AS npi) FROM pg.prescriber")
        con.execute("CREATE OR REPLACE TABLE prescription AS SELECT * REPLACE(CAST(npi AS BIGINT) AS npi) FROM pg.prescription;")
        con.execute("CREATE OR REPLACE TABLE zip_fips AS SELECT * FROM pg.zip_fips;")
    finally:
        con.execute("DETACH pg;")

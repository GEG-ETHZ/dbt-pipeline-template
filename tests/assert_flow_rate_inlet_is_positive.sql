-- Singlular tests in dbt are SQL queries that should return ZERO results
-- if the data is correct.
-- If this query returns rows, the test fails.

select
    recorded_at,
    flow_rate_inlet
from {{ ref('stg_flow') }}
where flow_rate_inlet < 0

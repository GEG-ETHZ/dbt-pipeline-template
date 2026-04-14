{{ config(materialized='ephemeral') }}

with pressure as (
    select * from {{ ref('stg_pressure') }}
),

flow as (
    select * from {{ ref('stg_flow') }}
),

joined as (
    select
        p.recorded_at,
        p.p_inlet,
        p.p_mid_3_hpa,
        p.p_outlet,
        f.flow_rate_inlet,
        (p.p_inlet - p.p_outlet) as delta_p_hpa
    from pressure as p
    inner join flow as f
        on p.recorded_at = f.recorded_at
)

select * from joined

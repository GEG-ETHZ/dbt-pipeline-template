{{ config(materialized='table') }}

with intermediate_data as (
    select * from {{ ref('int_pressure_flow_joined') }}
),

calculated as (
    select
        recorded_at,
        p_inlet,
        p_mid_3_hpa,
        p_outlet,
        flow_rate_inlet,
        delta_p_hpa,
        -- Calculate relative permeability avoiding division by zero
        -- or negative delta_p
        case
            when delta_p_hpa <= 0 then 0.0
            else (flow_rate_inlet / delta_p_hpa)
        end as relative_permeability
    from intermediate_data
)

select * from calculated
where relative_permeability is not null

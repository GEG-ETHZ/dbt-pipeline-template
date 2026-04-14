with source as (
    select *
    from
        {{
            source(
                'example_lab_data',
                'experiment_material_fluid_pressure_01'
            )
        }}
),

renamed_and_cleaned as (
    select
        recorded_at,
        -- Interpolation of the prepared values
        last_value(p_inlet_step_1 ignore nulls) over (
            order by recorded_at
            rows between unbounded preceding and current row
        ) as p_inlet,

        last_value(p_mid_3_hpa_step_1 ignore nulls) over (
            order by recorded_at
            rows between unbounded preceding and current row
        ) as p_mid_3_hpa,

        last_value(p_outlet_step_1 ignore nulls) over (
            order by recorded_at
            rows between unbounded preceding and current row
        ) as p_outlet
    from (
        select
            cast(timestamp as timestamp) as recorded_at,
            -- Outlier handling: Set p_inlet > 2000 to NULL
            cast(p_outlet as float64) as p_outlet_step_1,

            -- Convert PSI to hPa
            case
                when cast(p_inlet as float64) > 2000 then null
                else cast(p_inlet as float64)
            end as p_inlet_step_1,

            -- Outlet pressure (type correction)
            cast(p_mid_3 as float64) / 0.0145 as p_mid_3_hpa_step_1
        from source
        -- Remove duplicates first to ensure a stable time series
        qualify
            row_number()
                over (
                    partition by cast(timestamp as timestamp) order by timestamp
                )
            = 1
    )
)

select * from renamed_and_cleaned

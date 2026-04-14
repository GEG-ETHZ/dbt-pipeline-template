with source as (
    select *
    from
        {{
            source(
                'example_lab_data',
                'experiment_material_fluid_flowrate_01'
            )
        }}
),

renamed_and_cleaned as (
    select
        recorded_at,
        -- Apply the interpolation to the logic directly
        last_value(flow_rate_step_1 ignore nulls) over (
            order by recorded_at
            rows between unbounded preceding and current row
        ) as flow_rate_inlet
    from (
        select
            cast(timestamp as timestamp) as recorded_at,
            -- Handle negatives and cast to float inside the subquery
            case
                when cast(flow_rate_inlet as float64) < 0 then 0.0
                else cast(flow_rate_inlet as float64)
            end as flow_rate_step_1
        from source
        -- Remove duplicates here so the window function sees a clean timeline
        qualify
            row_number()
                over (
                    partition by cast(timestamp as timestamp) order by timestamp
                )
            = 1
    )
)

select * from renamed_and_cleaned

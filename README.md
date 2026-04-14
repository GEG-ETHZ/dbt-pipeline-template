# dbt Pipeline Template - GEG ETH Zurich

A standardized, production-ready dbt pipeline template for the [Geothermal Energy and Geofluids (GEG)](https://geg.ethz.ch/) at ETH Zurich.

## Why use this template?
This template provides a standardized starting point for building Data Build Tool (dbt) projects within the GEG group. By using this template, you ensure that your data transformations follow analytics engineering best practices. It enables you to:
- **Standardize:** Maintain a uniform directory structure and configuration across all GEG data pipelines.
- **Version Control:** Keep your SQL transformations in code and track history via Git.
- **Test & Document:** Automatically generate documentation and write data quality tests for your models.
- **Simplify:** Quickly spin up a connection to our Google BigQuery data warehouse.

## Prerequisites
Before you start, make sure you have the following tools installed:
- [Python](https://www.python.org/)
- [uv](https://docs.astral.sh/uv/) (for fast Python package and environment management)
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (for BigQuery authentication)

## Setup Instructions

### 1. Install dependencies
This project uses `uv` to manage Python packages securely and quickly. To automatically create the virtual environment and install all dependencies (like `dbt-bigquery`), run:
```bash
uv sync
```

### 2. Authenticate with Google Cloud
We use OAuth to authenticate with BigQuery. You need to authenticate your local machine using the Google Cloud CLI before making calls to the database:
```bash
gcloud auth application-default login
```

### 3. Configure your dbt profile
dbt uses a `profiles.yml` file to store database connection details securely on your machine.
Create or update the file located at `~/.dbt/profiles.yml` with the following configuration:

```yaml
dbt-pipeline-template:  # This profile name is referenced in your dbt_project.yml
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: <gcp_project_id>       # e.g., your-gcp-project-123
      dataset: <dataset_name>         # e.g., example_lab_data
      location: europe-west6          # Zurich region
      threads: 4
      job_execution_timeout_seconds: 300
      priority: interactive
  target: dev
```
*Note: Make sure to replace `<gcp_project_id>` and `<dataset_name>` with your actual BigQuery target details.*

### 4. Install dbt packages
If your project utilizes external macros or custom tests, you'll need to install them via `dbt deps`:
```bash
uv run dbt deps
```

### 5. Setup Pre-commit Hooks (QA)
This project uses automated Git hooks to run `SQLFluff` (SQL linter and auto-formatter), `dbt-checkpoint` (dbt validator), and `detect-secrets` (credential scanner) before code is committed. This guarantees the formatting, logic, and security standards are met.

To install the hooks to your local `.git` repository, run:
```bash
uv run pre-commit install
```

To manually trigger formatting and all validation checks, run:
```bash
uv run pre-commit run --all-files
```

---

## Using the project

To verify that your profile is set up correctly and the connection to the database works:
```bash
uv run dbt debug
```

To load raw data files (like the provided experiment CSV files in the `seeds/` directory) into the database as tables:
```bash
uv run dbt seed
```

To run your data tests and ensure things are executing properly:
```bash
uv run dbt test
```
*Note: This will run both generic tests (like `unique` and `not_null` defined in `.yml` files) and singular tests (custom SQL logic defined in the `tests/` directory).*

To run your models and materialize the pipeline in BigQuery:
```bash
uv run dbt run
```

To generate and view the data documentation interactively:
```bash
uv run dbt docs generate
uv run dbt docs serve
```

## Resources:
- Check out [GEG Group](https://geg.ethz.ch/) at ETH Zurich
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support

# deliveryHeroAssignment
Delivery Hero Case Study

Part 1: Dimensional Data Model Design
https://dbdiagram.io/d/DeliveryHero-Case-Study-673b3f63e9daa85acad57945

Bonus Task: Build an end-to-end workflow (Data pipeline) that enables analytics use-cases

1. Data Ingestion and Transformation: Automate the ingestion, transformation, and generation of source tables and data models

  Extract raw data from sources (e.g., API, storage, or database).
  Load raw data from source tables into BigQuery
  Transform by generating fact and dimension tables using the queries from the data model `eg: fact_participants.sql`
  Schedule periodic execution using Airflow (daily) `eg. airflow/dags/dbt_jobs.py`

2. Data Quality Checks: Implement data quality checks and trigger alerts for issues with dbt great expectations

  Use YAML files to define configurations for data quality thresholds and checks. `eg. datamodel/schema.yml, sources/datamodel.yml`
    Check for missing keys, duplicates, or unexpected null values.
    Compare data row counts between source and target tables.
    Ensure partitions are loaded as expected.
    Trigger alerts (e.g., via Slack or email) for anomalies.

3. Storage and Analytics Layer: Maintain tables with date partitions or date sharded logic.

  Maintain immutable snapshots with incremental logic
  Store final data in BigQuery with historical partitions.
  Provide access for analytics and dashboards

Performance Optimization Considerations:
- Materialise data_model queries as tables to be queried repeatedly and update them periodically (e.g., daily, hourly) based on business requirements.
- Use partitioning and clustering for data_model tables to reduce the amount of data scanned for each query.
- Materialise views on top of data_model tables to cache the results of queries that involve repetitive aggregations or transformations such as the conversion_rate and order_value queries.

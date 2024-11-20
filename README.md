# deliveryHeroAssignment
Delivery Hero Case Study

Part 1: Dimensional Data Model Design
https://dbdiagram.io/d/DeliveryHero-Case-Study-673b3f63e9daa85acad57945

Bonus Task: Build an end-to-end workflow (Data pipeline) that enables analytics use-cases

1. Data Ingestion and Transformation: Automate the ingestion, transformation, and generation of source tables and data models
  Extract raw data from sources (e.g., API, storage, or database).
  Load raw data from source tables into BigQuery
  Transform by generating fact and dimension tables using the queries from the data model eg: fact_participants.sql
  Schedule periodic execution using Airflow (daily) eg. airflow/dags/dbt_jobs.py

2. Data Quality Checks: Implement data quality checks and trigger alerts for issues with dbt great expectations
  Use YAML files to define configurations for data quality thresholds and checks. eg. schema.yml, datamodel.yml
    Check for missing keys, duplicates, or unexpected null values.
    Compare data row counts between source and target tables.
    Ensure partitions are loaded as expected.
    Trigger alerts (e.g., via Slack or email) for anomalies.

3. Storage and Analytics Layer: Maintain historical views of tables with date partitions or date sharded logic.
  Maintain immutable snapshots by appending new data rather than overwriting.
  Store final data in BigQuery with historical partitions.
  Provide access for analytics and dashboards

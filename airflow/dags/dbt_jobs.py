from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
import json
import logging
 
DATE_NODASH = "{{ ds_nodash }}"
DATE_DASH = "{{ ds }}"
 
JOBS = [
    {
        "model": "data_model",
        "schedule": "10 0 * * *",
        "tags": "tag:data_model",
        "cmd_vars": f"{{date_nodash: {DATE_NODASH}}}",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
        "cc": ["sarah"]
    }
]
 
def create_dag(dag_id, job_data):
    schedule = job_data.get("schedule")
    model = job_data.get("model")
    tags = job_data.get("tags")
    cmd_vars = job_data.get("cmd_vars")
    start_date = job_data.get("start_date", datetime(2024, 1, 1))
    catchup = job_data.get("dag_catchup", False)
    retries = job_data.get("retries", 0)
    retry_delay = job_data.get("retry_delay")
    cc = job_data.get("cc", "")
 
 
    default_args = {"retries": retries}
    if retry_delay is not None:
        default_args["retry_delay"] = retry_delay  # Assign retry_delay directly
 
    dag = ContextualDAG(
        dag_id,
        schedule_interval=schedule,
        start_date=start_date,
        catchup=catchup,
        default_args=default_args,
    )

    return dag
 
 
for job in JOBS:
    model = job.get("model")
    name = job.get("name", model)
    dag_id = f"dbt_{name}"
    globals()[dag_id] = create_dag(dag_id, job)

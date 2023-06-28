#!python
import awswrangler as wr
import requests
import pandas as pd
import json
import boto3
from datetime import datetime
import pytz
import logging

logging.getLogger("snowflake.connector.network").disabled = True
logging.getLogger().setLevel(logging.INFO)

def read_response_json_data(url: str) -> dict:
    """
    Read the raw data as json in requests
    Args:
        url (str): API url to get data
    """
    response_json = {}
    response_data = requests.get(url)
    response_json = json.loads(response_data.text)
    return response_json


# Main function. Entrypoint for Lambda
def lambda_handler(event, context):
    """
    Entry point for lambda. This will now export multiple files to bucket
    Args:
        event : None
        context: None
    """

    bucket_name = 'ap-southeast-2-886192468297-data-extraction'
    bucket_filename = datetime.now(pytz.timezone("Pacific/Auckland")).strftime('%Y%m%d') + '-nzd-currency.json'
    local_file_name = '/tmp/sample.json'

    s3 = boto3.resource("s3")
    bucket = s3.Bucket(bucket_name)

    nzd_currency_api = "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/nzd.json"
    logging.debug(f"URL: {nzd_currency_api}")
    json_response = read_response_json_data(nzd_currency_api)
    nzd_conversion = json_response['nzd']

    with open(local_file_name, 'w') as f:
        json.dump(nzd_conversion, f)

    bucket.upload_file(local_file_name, f'currency/{bucket_filename}')
    logging.info(f"File uploaded to S3 to {bucket_filename}")
#!python
import awswrangler as wr
import requests
import logging
import json

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

    nzd_currency_api = "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/nzd.json"
    print(f"URL: {nzd_currency_api}")


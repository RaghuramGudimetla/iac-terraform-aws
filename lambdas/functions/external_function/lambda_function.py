import json
import logging
import requests
from datetime import datetime
logging.getLogger().setLevel(logging.DEBUG)

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

def lambda_handler(event, context):

    status_code = 200

    # Value we return must always be an ARRAY - Sick :(
    nzd_exchange_rates = []

    try:
        event_body = event["body"]
        payload = json.loads(event_body)
        rows = payload["data"]
        
        assert len(rows) > 0, "Input error"

        # I know this doesn't make sense for a single array request though :)
        for record in rows:

            row_number = record[0]

            # Reading the params
            date = record[1]
            currency_to_exchange = record[2]

            logging.debug(f"Read the input values {date} - {currency_to_exchange}")

            nzd_currency_api = f"https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/{date}/currencies/nzd.json"
            logging.debug(f"URL: {nzd_currency_api}")
            json_response = read_response_json_data(nzd_currency_api)
            nzd_conversion = json_response['nzd']

            # Validate if the inputs are fine
            date_value = datetime.strptime(date, "%Y-%m-%d")
            present = datetime.now()
            date_value.date() < present.date()
            assert date_value.date() < present.date(), "Date should be in the past"
            assert str(currency_to_exchange) in nzd_conversion, "Currency must be valid"

            nzd_exchange_rate = nzd_conversion[str(currency_to_exchange)]
            nzd_exchange_rate = round(nzd_exchange_rate, 2)

            # Thsi has to have the row number as well
            records_to_return = [row_number, nzd_exchange_rate]

            nzd_exchange_rates.append(records_to_return)

        logging.debug(f"Response Array: {nzd_exchange_rates}")
        json_compatible_string_to_return = json.dumps({"data" : nzd_exchange_rates})

    except AssertionError as assErr:
        status_code = 400
        json_compatible_string_to_return = event_body
        raise

    except Exception as err:
        status_code = 500
        json_compatible_string_to_return = event_body
        raise

    return {
        'statusCode': status_code,
        'body': json_compatible_string_to_return
    }
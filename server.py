"""
This file will define all the routes for the server and necessary api calls to Roger's API
"""

from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# TODO: move this shit to .env file
ACCESS_TOKEN = '819b3d'
BASE_URL = 'https://pplx.azurewebsites.net/api/rapid/v0/'

headers = {
    'Authorization': f'Bearer {ACCESS_TOKEN}',
    'Cache-Control': 'no-cache',
    'accept': 'application/json',
    'Content-Type': 'application/json'
}

# TODO: complete this one
@app.route('/numberVerification', methods=['GET'])
def number_verification():
    # Ensure that parameters are valid
    phone_number = request.args.get('phoneNumber')

    if not phone_number:
        return jsonify({
            "error": "Missing required parameter: phoneNumber"
        }), 400

    # Prepare the payload
    payload = {
        "phoneNumber": phone_number
    }

    # Send the POST request to the external API
    response = requests.post(f"{BASE_URL}numberVerification/verify", headers=headers, json=payload)

    # Get the JSON response
    final_response = response.json()

    # Check the status from the response
    if final_response["status"] != 200:
        return jsonify({
            "error": final_response.get("message", "An error occurred"),
            "code": final_response.get("code", "UNKNOWN_ERROR")
        }), final_response["status"]

    # Extract necessary fields from the response
    device_phone_verified = final_response.get("devicePhoneNumberVerified", False)

    return jsonify({
        "phoneNumberVerified": device_phone_verified
    }), 200


@app.route('/isAuthorizedSwap', methods=['GET'])
def sim_swap():
    # Ensure that parameters are valid
    phone_num = request.args.get('phoneNumber')

    if not phone_num:
        return jsonify({
            "isSwapped": None,
            "within30Days": None,
            "status": 400,
            "message": "phoneNumber parameter is required."
        }), 400

    # Prepare the payload
    payload = {
        "phoneNumber": phone_num
    }

    # Send the POST request to the external API
    response = requests.post(f"{BASE_URL}simswap/check", headers=headers, json=payload)

    # Get the JSON response
    final_response = response.json()

    # Check the status from the response
    if final_response["status"] != 200:
        return jsonify({
            "isSwapped": None,
            "within30Days": None,
            "status": final_response["status"],
            "message": final_response.get("message", "An error occurred.")
        }), final_response["status"]

    # Extract necessary fields from the response
    is_swapped = final_response.get("swapped", False)
    latest_sim_change = final_response.get("latestSimChange")
    if latest_sim_change:
        from datetime import datetime, timedelta

        # Convert latest_sim_change to a datetime object
        latest_sim_change_date = datetime.fromisoformat(latest_sim_change[:-1])
        within_30_days = (datetime.utcnow() - latest_sim_change_date) <= timedelta(days=30)
    else:
        within_30_days = False

    return jsonify({
        "isSwapped": is_swapped,
        "within30Days": within_30_days,
        "status": 200,
        "message": "Request successful."
    }), 200

#TODO: complete this one
@app.route('/locationVerification', methods=['GET'])
def location_verification():
    phone_number = request.args.get('phoneNumber')
    latitude = request.args.get('latitude')
    longitude = request.args.get('longitude')
    accuracy = request.args.get('accuracy')

    payload = {
        "device": {
            "phoneNumber": phone_number
        },
        "area": {
            "type": "Circle",
            "location": {
                "latitude": latitude,
                "longitude": longitude
            },
            "accuracy": accuracy
        }
    }

    response = requests.post(f"{BASE_URL}location-verification/verify", headers=headers, json=payload)

    return jsonify(response.json())


if __name__ == '__main__':
    app.run(debug=True)

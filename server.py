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
    phone_number = request.args.get('phoneNumber')

    payload = {
        "phoneNumber": phone_number
    }

    response = requests.post(f"{BASE_URL}numberVerification/verify", headers=headers, json=payload)

    return jsonify(response.json())


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


@app.route('/locationVerification', methods=['GET'])

"""
returns True if the phone number is within the 30 metres of the specified coordinates
"""
def location_verification():
    phone_number = request.args.get('phoneNumber')
    latitude = request.args.get('latitude')  # these are the coordinates of the card machine
    longitude = request.args.get('longitude')  # these are the coordinates of the card machine

    payload = {
        "device": {
            "phoneNumber": phone_number
        },
        "area": {
            "type": "Circle",
            "location": {
                "latitude": latitude,
                "longitude": longitude,
                "radius": 30 # adjust this, this assumes it is within 30 meters
            },
            "accuracy": 50
        }
    }

    response = requests.post(f"{BASE_URL}location-verification/verify", headers=headers, json=payload)
    response_data = response.json()
    in_radius = False
    if str(response_data.get("verificationResult")) == "true":
        in_radius = True

    result = {
        "status": response.status_code,
        "withinRadius": in_radius
    }
    return jsonify(result), response.status_code

if __name__ == '__main__':
    app.run(debug=True)

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


@app.route('/numberVerification', methods=['GET'])
def number_verification():
    phone_number = request.args.get('phoneNumber')

    payload = {
        "phoneNumber": phone_number
    }

    response = requests.post(f"{BASE_URL}numberVerification/verify", headers=headers, json=payload)

    return jsonify(response.json())


@app.route('/simswap', methods=['GET'])
def sim_swap():
    phone_number = request.args.get('phoneNumber')

    payload = {
        "phoneNumber": phone_number
    }

    response = requests.post(f"{BASE_URL}simswap/check", headers=headers, json=payload)

    return jsonify(response.json())


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

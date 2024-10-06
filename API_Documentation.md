
# Location Verification and API Calls

## Location Verification when the Card Machine is Within 30m of Our Phone

**API Call made as a GET request to our server:**

```python
import requests

url = "http://localhost:5000/locationVerification"
params = {
    "phoneNumber": "14372293302",
    "latitude": "49.269377",
    "longitude": "-123.252473"
}

response = requests.get(url, params=params)
print(response.json())
```

**Response We Got:**

```json
{
  "status": 200,
  "withinRadius": true
}
```

This Python code checks if a card machine is within 30 meters of a phone. It sends a GET request to `http://localhost:5000/locationVerification` with `phoneNumber`, `latitude`, and `longitude` as query parameters. The server's JSON response indicates if the card machine is within the specified radius as expected. In this case, the response shows the request was successful (`status`: 200) and the card machine is within range (`withinRadius`: true).

---

## Location Verification when the Card Machine is Outside 30m of Our Phone

**API Call made as a GET request to our server:**

```python
import requests

url = "http://localhost:5000/locationVerification"
params = {
    "phoneNumber": "14372293302",
    "latitude": "59.334591",  # this is Sweden
    "longitude": "18.063240"
}

response = requests.get(url, params=params)
print(response.json())
```

**Response We Got:**

```json
{
  "status": 200,
  "withinRadius": false
}
```

This Python code checks if a card machine is within 30 meters of a phone. It sends a GET request to `http://localhost:5000/locationVerification` with `phoneNumber`, `latitude`, and `longitude` as query parameters. The server's JSON response indicates if the card machine is outside the specified radius as expected. In this case, the response shows the request was successful (`status`: 200) and the card machine is outside the range (`withinRadius`: false).

---

## SIM Swap API Call

**API call made to our server as a GET request:**

```python
import requests

url = "http://127.0.0.1:5000/isAuthorizedSwap"
params = {
    "phoneNumber": "14372293302",
}

response = requests.get(url, params=params)
print(response.json())
```

**Response We Got:**

```json
{
  "isSwapped": false,
  "message": "Request successful.",
  "status": 200,
  "within30Days": false
}
```

This Python code sends a GET request to the server at `http://127.0.0.1:5000/isAuthorizedSwap` with the query parameter `phoneNumber` set to `14372293302` to check for SIM swap authorization. It prints the server's JSON response, which indicates whether a SIM swap has occurred, if it happened within the last 30 days, and provides a status message.

---

## Number Verification API Call & Logs

**API Call made to us as a GET Request:**

```python
import requests

url = "http://127.0.0.1:5000/locationVerification"
params = {
    "phoneNumber": "14372293302",
}

response = requests.get(url, params=params)
print(response.json())
```

**The Response I Got:**

```json
{
  "message": "Request successful.",
  "phoneNumberVerified": true,
  "status": 200
}
```

This Python code sends a GET request to the server at `http://127.0.0.1:5000/locationVerification` with the query parameter `phoneNumber` set to `14372293302` to verify the phone number's location. It prints the server's JSON response, which indicates whether the phone number has been successfully verified, and includes a status message confirming the request's success.

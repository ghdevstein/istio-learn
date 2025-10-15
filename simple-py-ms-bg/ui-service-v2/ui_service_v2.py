from flask import Flask, render_template_string, request
import requests

app = Flask(__name__)

# Template with a button to trigger action
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head><title>Service A</title></head>
<body style="background-color: {{ color }}; text-align:center;">
    <h1 style="color: #007BFF;">
        <marquee behavior="scroll" direction="left">I am V2</marquee>
    </h1>
    <p>!!! Hello from Data Service !!! <h1>{{ data }}</h1></p>
    <form action="/trigger" method="post">
        <button type="submit">Trigger Action (calls Service C)</button>
    </form>
    {% if result %}
        <p style="color: green;">Response from Service C: {{ result }}</p>
    {% endif %}
</body>
</html>
"""

@app.route("/", methods=["GET"])
def home():
    try:
        end_user = request.headers.get("end-user", None)
        headers = {}
        if end_user:
            headers["end-user"] = end_user

        res = requests.get("http://data.spms-bg.svc.cluster.local:5001/data", headers=headers)
        #res = requests.get("http://data.spms-bg.svc.cluster.local:5001/data")
        json_data = res.json()
        color = json_data.get("color", "white")
        data = json_data.get("message", "No data")
    except Exception as e:
        color = "white"
        data = f"Error contacting Service B: {e}"

    return render_template_string(HTML_TEMPLATE, color=color, data=data, result=None)

@app.route("/trigger", methods=["POST"])
def trigger():
    try:
        res = requests.post("http://trigger.spms-bg.svc.cluster.local:5002/action")
        #res = requests.post("http://spms-gateway.spms.svc.cluster.local/trigger/action")
        #res = requests.post("http://gateway.istio-system.svc.cluster.local/trigger/action")
        result = res.json().get("result", "No response")
    except Exception as e:
        result = f"Error contacting Service C: {e}"

    # Re-fetch data from Service B
    end_user = request.headers.get("end-user", None)
    headers = {}
    if end_user:
        headers["end-user"] = end_user

    res = requests.get("http://data.spms-bg.svc.cluster.local:5001/data", headers=headers)
    #res = requests.get("http://data.spms-bg.svc.cluster.local:5001/data")
    json_data = res.json()
    color = json_data.get("color", "white")
    data = json_data.get("message", "No data")

    return render_template_string(HTML_TEMPLATE, color=color, data=data, result=result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

from flask import Flask, jsonify
import random

app = Flask(__name__)

COLORS = ["blue", "green", "yellow", "red"]

@app.route("/data")
def get_data():
    return jsonify({
        "message": "dark colors from v2",
        "color": random.choice(COLORS)
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)

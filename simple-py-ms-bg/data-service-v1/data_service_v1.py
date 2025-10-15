from flask import Flask, jsonify
import random

app = Flask(__name__)

COLORS = ["lightblue", "lightgreen", "lightyellow", "lightpink"]

@app.route("/data")
def get_data():
    return jsonify({
        "message": "light colors from v1",
        "color": random.choice(COLORS)
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)

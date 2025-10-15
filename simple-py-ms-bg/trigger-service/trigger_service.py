from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route("/action", methods=["POST"])
def do_action():
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return jsonify({
        "result": f"Service C executed an action at {timestamp}!"
    })

# Add a separate health check endpoint for Kubernetes probes
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"})

# Optional: Handle GET requests to /action for debugging
@app.route("/action", methods=["GET"])
def action_get():
    return jsonify({
        "message": "Use POST method to trigger action",
        "available_endpoints": {
            "POST /action": "Execute action",
            "GET /health": "Health check"
        }
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)
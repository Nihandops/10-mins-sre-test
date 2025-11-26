from flask import Flask, jsonify, request
import time

app = Flask(__name__)

@app.route("/")
def home():
    # small, deterministic short delay to simulate work (default 50ms)
    delay_ms = request.args.get("delay", default="50")
    try:
        delay_ms = int(delay_ms)
    except ValueError:
        delay_ms = 50
    # cap to avoid accidental long delays
    delay_ms = max(0, min(delay_ms, 2000))
    if delay_ms:
        time.sleep(delay_ms / 1000.0)
    return "Hello from SRE Test!", 200

@app.route("/healthz")
def health():
    # quick, lightweight health check should return 200 when app is OK
    return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    # only for local debug (gunicorn used in container)
    app.run(host="0.0.0.0", port=8080)


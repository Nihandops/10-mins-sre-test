# TROUBLESHOOTING.md

This document describes the step-by-step process followed to debug, fix, and deploy the SRE Level-1 assessment application.

---

## 1. Application Issues

### Home Endpoint `/`

* **Symptom:** Slow response times (3–8 seconds).
* **Cause:** Original code used `time.sleep(random.randint(3,8))`.
* **Fix:** Removed unnecessary sleep for faster response.

### Health Endpoint `/healthz`

* **Symptom:** Returned HTTP 500, causing readiness probe failures.
* **Cause:** Status code was hardcoded to 500.
* **Fix:** Changed to HTTP 200:

```python
@app.route("/healthz")
def health():
    return jsonify({"status": "ok"}), 200
```

---

## 2. Dockerfile Issues

* **Symptom:** Docker image build failed and exposed wrong port.
* **Cause:** `EXPOSE 80` while app ran on port 8080.
* **Fix:** Corrected Dockerfile:

```dockerfile
FROM python:3.11-slim
WORKDIR /src
COPY app .
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "main.py"]
```

* Image successfully built as `sre-app:latest1`.

---

## 3. Kubernetes Deployment Issues

* **Deployment Problems:**

  * Container image mismatch → fixed to `sre-app:latest1`.
  * Readiness probe failing → fixed by updating `/healthz` endpoint and probe port.
  * Service not reachable → Service type updated to `NodePort` for LAN access.

**Key Commands Used:**

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods -w
kubectl get svc
```

---

## 4. Logs Analysis

```
[ERROR] Timeout waiting for /healthz
[ERROR] Probe failed for container: sre-app
[WARNING] High response latency detected: 7000ms
```

* **Cause:** Slow `/` endpoint and `/healthz` returning 500.
* **Fix:** Adjusted endpoint response and HTTP status.

---

## 5. Minikube LAN Access

* Minikube VM IP (`192.168.49.2`) is not reachable from local network.
* **Solution:** Use `NodePort` service type and access via host IP:

```text
http://192.168.0.248:<NodePort>
```

* Example: `http://192.168.0.248:32231`

---

## 6. Lessons Learned

* Always match Docker EXPOSE with container port.
* `/healthz` must return 200 for probes.
* NodePort is the simplest way to expose services for LAN access in Minikube.
* Proper liveness and readiness probes prevent downtime and signal healthy containers.

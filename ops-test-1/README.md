# SRE Level-1 Assessment

This repository contains the solution for the SRE Level-1 assessment. The project demonstrates fixing a broken Flask application, Dockerizing it, deploying on Kubernetes (Minikube), and making it accessible from a LAN network.

---

## Project Structure

```
sre-l1-assessment/
│
├── app/
│   ├── main.py           # Flask application
│   └── requirements.txt  # Python dependencies
│
├── Dockerfile            # Docker image build
│
├── k8s/
│   ├── deployment.yaml   # Kubernetes Deployment
│   └── service.yaml      # Kubernetes Service
│
├── logs.txt              # Provided logs for debugging
│
├── TROUBLESHOOTING.md    # Step-by-step debugging notes
│
└── incident-report.md    # Incident report
```

---

## 1. Application Fixes

* **Home endpoint (`/`)**:

  * Original code used `time.sleep(random.randint(3,8))` causing high latency.
  * Fixed by reducing or removing unnecessary delays.
* **Health endpoint (`/healthz`)**:

  * Originally returned HTTP 500.
  * Fixed to return HTTP 200 for correct readiness/liveness probes.

---

## 2. Dockerfile Fixes

* Original Dockerfile exposed wrong port and had minor inefficiencies.
* Fixed Dockerfile:

```dockerfile
FROM python:3.11-slim

WORKDIR /src
COPY app .
RUN pip install -r requirements.txt

EXPOSE 8080
CMD ["python", "main.py"]
```

* Exposes correct port (`8080`) matching the Flask app.
* Optimized image for size and build.

---

## 3. Kubernetes Deployment Fixes

**Deployment YAML (`k8s/deployment.yaml`)**:

* Fixed container image name to match the built Docker image: `sre-app:latest1`.
* Added `readinessProbe` and `livenessProbe`:

```yaml
readinessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 2

livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 2
```

* Added resource requests/limits:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"
```

**Service YAML (`k8s/service.yaml`)**:

* For LAN access, use **NodePort**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sre-service
spec:
  type: NodePort
  selector:
    app: sre
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

* NodePort allows access from your host IP (`192.168.0.248`) on a dynamic port (e.g., 32231).

---

## 4. Minikube Deployment

### Build Docker Image inside Minikube:

```bash
eval $(minikube docker-env)
docker build -t sre-app:latest1 .
```

### Apply Kubernetes manifests:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Check Pods and Services:

```bash
kubectl get pods -w
kubectl get svc sre-service
```

### Access the Service from LAN:

```text
http://192.168.0.248:<NodePort>
```

Example: `http://192.168.0.248:32231`

---

## 5. Logs & Debugging

* Original logs indicated high response latency and readiness probe failures.
* Root causes:

  1. `/` endpoint had 3-8s sleep delay.
  2. `/healthz` returned HTTP 500.
* Fixes applied in `main.py` resolved the issues.

---

## 6. Incident Report

See `incident-report.md` for:

* Summary
* Impact
* Root cause
* Fixes
* Preventive measures

---

## 7. Optional Improvements (Bonus)

* Liveness probe added.
* Resource requests and limits added.
* Deployment tested locally in Minikube.
* NodePort exposes service to LAN devices without extra tunneling.

---

## 8. Commands Summary

```bash
# Set Docker environment for Minikube
eval $(minikube docker-env)

# Build Docker image
docker build -t sre-app:latest1 .

# Apply Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Watch Pods
kubectl get pods -w

# Access Service from LAN
kubectl get svc sre-service
# Note NodePort for access: http://192.168.0.248:<NodePort>
```

---

## 9. Notes

* Minikube VM IP (`192.168.49.2`) is **not accessible from LAN**. Use NodePort with host IP (`192.168.0.248`) instead.
* LoadBalancer services in Minikube require `minikube tunnel` for external IP assignment.
* Application now runs smoothly with reduced latency and proper health checks.

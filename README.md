# SRE Level-2 Advanced Assessment

## Candidate Information
**Name:** MD. Saidur Rahman Nihan  
**Email:** md.srnihan@gmail.com
**Time Taken:** 5 hours  
**Environment Used:** Docker, Minikube, Kubernetes, Terraform  
**Assumptions:**  
- Minikube is used for Kubernetes cluster  
- Local Docker images are used (`advanced-candidate:latest` and `advanced-sidecar:latest`)  


---

## Project Structure

sre-l2-advanced-assessment/
│
├── app/
│ ├── server.go
│ ├── go.mod
│ └── go.sum
│
├── sidecar/
│ └── proxy.py
│
├── Dockerfile
├── docker-compose.yaml
│
├── k8s/
│ ├── deployment.yaml
│ ├── service.yaml
│ ├── hpa.yaml
│ └── networkpolicy.yaml
│
├── logs/
│ ├── app.log
│ └── sidecar.log
│
├── iac/
│ ├── main.tf
│ └── modules/
│ └── ec2/
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
│
├── TROUBLESHOOTING.md
└── incident-report.md



---

## Assessment Tasks Completed

### 1. Fixed Go Application
- Fixed **memory leak** by removing the unbounded append to `leak` slice.  
- Fixed **race condition** using `sync.Mutex` for `counter` access.  
- Fixed **health endpoint** to return consistent status.  
- Added proper logging for requests and health checks.

### 2. Fixed Multi-Stage Dockerfile
- Added CA certificates in Alpine stage  
- Fixed binary copy path  
- Corrected exposed port to `8080`  
- Added non-root user  
- Optimized build layers for caching

### 3. Fixed Kubernetes Deployment
- Corrected container ports (`8080` for app, `9000` for sidecar)  
- Fixed `readinessProbe` path and port  
- Increased resource limits (CPU: 500m, Memory: 256Mi)  
- Set `imagePullPolicy: IfNotPresent`  
- Merged sidecar as a proper container for logging

### 4. Fixed HorizontalPodAutoscaler
- Corrected CPU metrics target  
- Validated by running `kubectl top pods` and stressing app

### 5. Fixed Sidecar Proxy Issues
- Reduced random 504 errors by fixing `proxy.py`  
- Adjusted sidecar logging and request handling  
- Verified by sending HTTP requests through sidecar

### 6. Log Analysis
- Analyzed `app.log` and `sidecar.log`  
- Identified memory leaks, race conditions, and dropped requests  
- Recorded timeline and root causes in `TROUBLESHOOTING.md`

### 7. Production-Style Incident Report
- Created `incident-report.md`  
- Included summary, impact, root cause, timeline, fixes, preventive measures

### 8. Fixed Terraform Configuration
- Corrected variable types  
- Added valid AMI and module inputs  
- Secured the security group  
- Updated AWS provider version  
- Corrected module output references

### 9. Bonus Improvements
- Added structured logging in Go application  
- Improved Dockerfile efficiency  
- Verified Kubernetes deployment in Minikube

---

## How to Run

### Docker
```bash
# Build app
docker build -t advanced-candidate:latest ./app

# Build sidecar
docker build -t advanced-sidecar:latest ./sidecar

# Run using docker-compose
docker-compose up
Kubernetes (Minikube)

kubectl apply -f k8s/
minikube service test2-app-service
kubectl get pods -w
kubectl describe hpa advanced-hpa

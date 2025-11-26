# TROUBLESHOOTING — SRE Level-1 Assessment

## Summary
This doc explains the debugging steps, commands run, fixes applied, and what I learned.

## What was wrong (short)
- App: `/` endpoint slept 3–8s randomly; `/healthz` returned 500.
- Dockerfile: exposed wrong port (80) and used dev server; pip install layering could be optimized.
- K8s: containerPort mismatch (80 vs 8080), readiness probe used wrong port; no liveness probe; readiness was failing.

---

## Step-by-step reproduction & fixing (commands)

### 1) Build and test the container locally
```bash
# build image
docker build -t sre-candidate:latest .

# run
docker run --rm -p 8080:8080 sre-candidate:latest

# test endpoints
curl -i http://localhost:8080/healthz
curl -i http://localhost:8080/
curl -i "http://localhost:8080/?delay=1500" # simulate 1.5s request

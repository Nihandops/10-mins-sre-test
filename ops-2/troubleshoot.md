# TROUBLESHOOTING.md

## 1. Go Application Issues

### a. Memory Leak
- **Cause:** The `leak` slice was being appended on every request without bounds.
- **Fix:** Removed or limited the slice usage for logging purposes.
- **Evidence:** Memory usage stabilized after fix during load testing.

### b. Race Condition
- **Cause:** `counter` variable incremented concurrently without synchronization.
- **Fix:** Added `sync.Mutex` lock/unlock around counter increment.
- **Evidence:** No inconsistent counter values observed in concurrent requests.

### c. Latency
- **Cause:** `time.Sleep(2s)` in handler.
- **Fix:** Removed unnecessary sleep or simulated proper processing.
- **Evidence:** Response times reduced; load testing shows normal latency.

### d. Health Endpoint
- **Cause:** Random failures (`time.Now().Unix()%2==0`) caused readinessProbe to fail.
- **Fix:** Updated `/healthz` to return consistent HTTP 200.
- **Evidence:** Pods reach Ready state; HPA works correctly.

---

## 2. Dockerfile Issues

### a. Missing CA Certificates
- **Fix:** Installed `ca-certificates` in Alpine stage.

### b. Wrong Binary Copy Path
- **Fix:** Ensured `COPY --from=builder /app/server /bin/server`.

### c. Wrong Exposed Port
- **Fix:** Exposed port `8080` instead of `80`.

### d. Non-root User
- **Fix:** Added `RUN adduser -D appuser && chown -R appuser /bin/server` and switched user.

### e. Inefficient Build
- **Fix:** Optimized multi-stage layers to leverage Docker cache.

---

## 3. Kubernetes Deployment Issues

### a. Container Ports
- **Fix:** Set app container port to 8080, sidecar to 9000.

### b. Readiness Probe
- **Fix:** Updated `httpGet` path and port to `/healthz:8080`.

### c. Resource Limits
- **Fix:** Increased CPU to 500m and memory to 256Mi.

### d. ImagePullPolicy
- **Fix:** Changed to `IfNotPresent` to use local images in Minikube.

### e. Pod Sidecar Conflicts
- **Fix:** Adjusted sidecar container to log properly without interfering with app.

- **Evidence:** Pods now run `2/2 READY` and HPA metrics available.

---

## 4. HorizontalPodAutoscaler Issues

- **Cause:** CPU metrics misconfigured (`Value` vs `Utilization`).
- **Fix:** Changed to proper `type: Utilization`, target CPU 50%.
- **Validation:**  
  ```bash
  kubectl top pods
  kubectl apply -f load-generator.yaml  # stress CPU
  kubectl get hpa advanced-hpa

# Production-Style Incident Report

**Incident ID:** INC-2025-1126
**Severity:** SEV-2
**Date:** 26 Nov 2025
**Reported By:** Nihan (DevOps Engineer)
**Environment:** Minikube (Local Kubernetes Cluster)

---

## 1. Summary

A service named **test2-app-service** became **unreachable**, and running `minikube service` returned “no running pod for service found”. Although Pods were running, the Service had **no endpoints**, making the application unavailable.

This was caused by a **label mismatch** between the Deployment and the Service selector.

---

## 2. Impact

* Application became completely unreachable via Kubernetes Service.
* HPA, health checks, and dependent components would fail in a real environment.
* Estimated downtime: **25–30 minutes** (development environment).
* No external user impact in this assessment environment, but production equivalent would cause full outage.

---

## 3. Detection

Issue was first identified when the following command failed:

```
minikube service test2-app-service
```

Error:

```
service not available: no running pod for service test2-app-service found
```

Further confirmation using:

```
kubectl get endpoints test2-app-service
```

Output:

```
ENDPOINTS: <none>
```

This confirmed that the Service had **zero active endpoints**.

---

## 4. Root Cause

### **Root Cause: Label Mismatch**

Deployment pods were labeled:

```
app=advanced
```

But the Service selector was:

```
selector:
  app: advanced-app
```

Because these values did not match, the Service could not discover any pods → no endpoints → application was unreachable.

---

## 5. Timeline

| Time  | Event                                                   |
| ----- | ------------------------------------------------------- |
| 14:05 | Deployment rolled out successfully                      |
| 14:07 | Service applied                                         |
| 14:08 | `minikube service` failed                               |
| 14:09 | Endpoints found empty                                   |
| 14:12 | Labels inspected using `kubectl get pods --show-labels` |
| 14:14 | Label mismatch identified                               |
| 14:16 | Service selector corrected                              |
| 14:17 | Service reapplied                                       |
| 14:18 | Endpoints populated; service operational                |
| 14:20 | Incident resolved                                       |

---

## 6. Resolution

Updated the Service selector:

```
selector:
  app: advanced  # fixed; matches deployment
```

Then applied:

```
kubectl apply -f service.yaml
kubectl get endpoints test2-app-service
```

Endpoints were populated successfully and service became reachable through NodePort.

---

## 7. Corrective Actions

### Short-term Fixes

* Corrected the selector label.
* Verified endpoints and connectivity.
* Tested application externally via NodePort.

### Long-term Preventive Measures

* Enforce consistent labeling conventions (documented naming standards).
* Add CI/CD validation to detect mismatched selectors.
* Implement Kubernetes admission controller checks.
* Add monitoring alerts such as: "Service has 0 endpoints for >1 minute".
* Use kube-linter or conftest to validate YAML before deploy.

---

## 8. Lessons Learned

* Label mismatches are one of the most common causes of service outages in Kubernetes.
* Always verify pod labels:

  ```
  kubectl get pods --show-labels
  ```
* Always verify service endpoints:

  ```
  kubectl get endpoints <service>
  ```
* Consistent labeling and pre-deployment validation prevent this issue entirely.

---

## 9. Status

**Resolved — No further issues.**

# Incident Report

**Project:** SRE Level-1 Assessment
**Date:** 26-Nov-2025
**Reporter:** MD. Saidur Rahman Nihan

---

## 1. Summary

The SRE Level-1 application was failing deployment due to:

* Slow home endpoint response
* Health endpoint returning HTTP 500
* Docker image and Kubernetes deployment misconfigurations

---

## 2. Impact

* Application pods were failing readiness checks.
* Kubernetes deployment could not reach stable running state.
* Service was not accessible from Minikube host or LAN network.

---

## 3. Root Cause

1. **Application code**:

   * `/` endpoint delayed response (3–8 seconds)
   * `/healthz` endpoint returned HTTP 500
2. **Dockerfile misconfiguration**:

   * Wrong port exposed
3. **Kubernetes deployment**:

   * Image name mismatch
   * Readiness/liveness probes misconfigured
   * Service type unsuitable for LAN access

---

## 4. Fixes Applied

* **Application**: Reduced home endpoint latency, corrected `/healthz` status code.
* **Docker**: Corrected `EXPOSE` port and built image `sre-app:latest1`.
* **Kubernetes**:

  * Updated deployment with correct image and probe configurations.
  * Updated service to NodePort for LAN access.
  * Added resource requests and limits.

---

## 5. Preventive Actions

* Implement automated tests for `/healthz` endpoint.
* Ensure Dockerfile ports match application.
* Use readiness/liveness probes in all deployments.
* Validate NodePort or LoadBalancer configuration for accessible services.
* Monitor response latency and adjust code if needed.

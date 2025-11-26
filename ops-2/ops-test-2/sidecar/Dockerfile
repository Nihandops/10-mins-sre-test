# sidecar/Dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY proxy.py .

RUN pip install flask

EXPOSE 9000
ENTRYPOINT ["python", "proxy.py"]


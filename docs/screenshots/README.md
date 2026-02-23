# Screenshots Directory

This directory contains screenshots demonstrating the project's capabilities.

## Required Screenshots

1. **jenkins-pipeline.png** - Jenkins 6-stage DevSecOps pipeline
2. **grafana-http-metrics.png** - Grafana dashboard showing HTTP metrics
3. **grafana-runtime.png** - Grafana dashboard showing Python runtime metrics
4. **trivy-scan.png** - Trivy security scan results

## How to Capture

### Jenkins Pipeline
- Navigate to: http://YOUR_EC2_IP:8080
- Click on project → Build History → Latest build
- Capture full pipeline view

### Grafana Dashboards
- Navigate to: http://YOUR_EC2_IP:3000
- Login with admin credentials
- Capture each dashboard

### Trivy Scan
- From Jenkins build logs showing Trivy output
- Or from terminal: `docker run aquasec/trivy image secure-release-platform:latest`

## Placeholder

Until screenshots are added, the README will display placeholder text.

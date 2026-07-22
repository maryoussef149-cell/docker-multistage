# Multistaging with Docker

A Node.js/Express application demonstrating production-grade Docker and networking practices: multi-stage builds, health checks, Nginx reverse proxy with SSL, load balancing, and multi-container orchestration with Docker Compose.

## Application

A minimal Express server with two endpoints:
- `GET /` returns a greeting with the responding container's hostname (useful for verifying load balancing)
- `GET /health` health check endpoint returning `{ "status": "ok" }`

## Architecture
GitHub push → CI/CD Pipeline (test → build → push → deploy)
↓
EC2 Instance (AWS)
↓
Client → Nginx (SSL + Load Balancer) → app1 / app2 → Redis

Two identical instances of the app (`app1`, `app2`) run behind an Nginx reverse proxy, which handles SSL and distributes incoming requests between them (round robin).

## Docker & Networking Practices Demonstrated

### Multi-stage Build & Image Optimization
The Dockerfile uses a two-stage build on `node:18-alpine` instead of the full `node:18` image, reducing the final image size from **1.58GB to 186MB (~88% reduction)**.

### Health Checks
The Dockerfile includes a `HEALTHCHECK` instruction that pings `/health` every 30 seconds, so Docker tracks each container's health automatically (visible via `docker compose ps`).

### Reverse Proxy (Nginx)
Nginx sits in front of the application containers. Clients never talk to the app containers directly — only Nginx is exposed to the host (ports 80/443).

### SSL / HTTPS
A self-signed certificate is used to terminate SSL at the Nginx layer. All HTTP traffic (port 80) is automatically redirected to HTTPS (port 443).

### Load Balancing
Nginx distributes requests across two app instances (`app1`, `app2`) using an `upstream` block, verified by observing different container hostnames responding across repeated requests.

### Docker Compose
Orchestrates four services: `app1`, `app2`, `redis`, and `nginx`, all connected on a custom bridge network (`myapp-network`).

### Networking
All services communicate by service name (e.g. `app1:3000`, `redis:6379`) rather than hardcoded IPs, thanks to Docker's internal DNS resolution.

### Volumes
Redis data is persisted using a named volume (`redis-data`), surviving container restarts and removal.

## Usage

### Run everything
\`\`\`bash
docker compose up -d --build
\`\`\`

### Check service status
\`\`\`bash
docker compose ps
\`\`\`

### Test the endpoints (through Nginx)
\`\`\`bash
curl -k https://localhost
curl -k https://localhost/health
\`\`\`

### Verify load balancing
Run the request multiple times and observe the hostname changing:
\`\`\`bash
curl -k https://localhost
curl -k https://localhost
curl -k https://localhost
\`\`\`

### Stop everything
\`\`\`bash
docker compose down
\`\`\`

## Project Structure
- `index.js`  Express server with `/` and `/health` endpoints
- `Dockerfile`  multi-stage build with health check
- `docker-compose.yml`  app1, app2, redis, and nginx orchestration
- `nginx/nginx.conf`  reverse proxy, SSL termination, and load balancing config
- `nginx/ssl/`  self-signed SSL certificate and key
- `.dockerignore`  excludes `node_modules` and `.git` from the build context
- `.github/workflows/`  CI pipeline (runs tests on push/PR)

## What I Learned
- How Docker layer caching works and how to order Dockerfile instructions to take advantage of it
- How multi-stage builds separate build-time dependencies from the runtime image
- The real impact of base image choice on image size
- How Docker health checks work and how they differ from a simple HTTP endpoint
- How to configure Nginx as a reverse proxy in front of containerized services
- How to terminate SSL at the proxy layer and redirect HTTP to HTTPS
- How Nginx `upstream` blocks enable load balancing across multiple service instances
- How Docker Compose networking enables service-to-service communication by hostname
- How named volumes persist data independently of container lifecycle
- Debugging real-world issues: Docker build cache, YAML indentation errors, MSYS path conversion on Git Bash, and Nginx upstream misconfigurations

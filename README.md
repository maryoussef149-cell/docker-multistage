# Multistaging with Docker

A simple Node.js/Express application containerized with Docker, demonstrating production-grade Docker practices: multi-stage builds, health checks, networking, and multi-container orchestration with Docker Compose.

## Application

A minimal Express server with two endpoints:
- `GET /`  returns a greeting message
- `GET /health`  health check endpoint returning `{ "status": "ok" }`

## Docker Practices Demonstrated

### Multi-stage Build & Image Optimization
The Dockerfile uses a two-stage build (`builder` and production stages) on `node:18-alpine` instead of the full `node:18` image. This reduced the final image size from **1.58GB to 186MB (~88% reduction)**.

### Health Checks
The Dockerfile includes a `HEALTHCHECK` instruction that pings the `/health` endpoint every 30 seconds, allowing Docker to automatically track container health (visible via `docker ps` as `healthy`/`unhealthy`).

### Docker Compose
`docker-compose.yml` orchestrates two services:
- `app`  the Node.js application (built from the local Dockerfile)
- `redis`  a Redis instance for future caching/session needs

### Networking
Both services run on a custom bridge network (`myapp-network`), allowing the `app` container to reach Redis by hostname (`redis`) instead of a hardcoded IP — verified via DNS resolution testing inside the container.

### Volumes
Redis data is persisted using a named volume (`redis-data`), so data survives container restarts and removal.

## Usage

### Build and run with Docker directly
\`\`\`bash
docker build -t myapp:optimized .
docker run -d -p 3000:3000 --name myapp-app myapp:optimized
\`\`\`

### Run with Docker Compose (recommended)
\`\`\`bash
docker compose up -d
\`\`\`

### Check service status
\`\`\`bash
docker compose ps
\`\`\`

### Test the endpoints
\`\`\`bash
curl http://localhost:3000
curl http://localhost:3000/health
\`\`\`

### Stop everything
\`\`\`bash
docker compose down
\`\`\`

## Project Structure
- `index.js`  Express server with `/` and `/health` endpoints
- `hello.js`  simple standalone script
- `test.js`  basic test script
- `Dockerfile`  multi-stage build with health check
- `docker-compose.yml`  app + Redis orchestration
- `.dockerignore`  excludes `node_modules` and `.git` from the build context
- `.github/workflows/`  CI pipeline (runs tests on push/PR)

## What I Learned
- How Docker layer caching works and how to order Dockerfile instructions to take advantage of it
- How multi-stage builds separate build-time dependencies from the runtime image
- The real impact of base image choice (`node:18` vs `node:18-alpine`) on image size
- How Docker health checks work and how they differ from a simple HTTP endpoint
- How Docker Compose networking enables service-to-service communication by hostname
- How named volumes persist data independently of container lifecycle

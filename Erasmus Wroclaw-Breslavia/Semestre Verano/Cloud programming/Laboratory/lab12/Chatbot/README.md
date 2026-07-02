# ChatApp — Docker Assignment

A real-time chat application with a **Spring Boot** backend and a **SvelteKit** frontend, fully containerised with Docker and orchestrated via Docker Compose.

---

## Project Structure

```
project/
├── backend/
│   ├── Dockerfile          ← multistage backend image
│   └── src/ ...
├── frontend/
│   ├── Dockerfile          ← multistage frontend image
│   └── src/ ...
└── compose.yaml            ← orchestrates both containers
```

---

## 1. Backend

### 1.1 How to build the container image

```bash
# From the project root:
docker build -t chatapp-backend ./backend

# Or from inside the backend/ folder:
cd backend
docker build -t chatapp-backend .
```

The image uses a **two-stage build**:

| Stage | Base image | Purpose |
|-------|-----------|---------|
| `builder` | `eclipse-temurin:17-jdk-alpine` | Compile source and produce the JAR |
| `runtime` | `eclipse-temurin:17-jre-alpine` | Run the JAR — no compiler in the final image |

### 1.2 How to run the container

```bash
docker run -d \
  --name chatapp-backend \
  -p 5000:5000 \
  chatapp-backend
```

Test the running container:

```bash
curl http://localhost:5000/chat/all?username=test
# Expected: {"messages":[]}
```

### 1.3 What must be configured for a successful build

| Requirement | Details |
|-------------|---------|
| **Gradle wrapper** | `gradlew` must be present in `backend/`. The Dockerfile runs `chmod +x ./gradlew` automatically. |
| **JAR name** | The Dockerfile copies `build/libs/ChatApp-0.0.1-SNAPSHOT.jar`. If your `build.gradle` uses a different `archivesName` or version, update the `COPY --from=builder` line accordingly. |
| **No manual Java install** | The base image `eclipse-temurin:17-jdk-alpine` already provides Java 17. Do **not** install Java inside the Dockerfile. |

---

## 2. Frontend

### 2.1 How to build the container image

```bash
# From the project root — uses the default backend URL (for Compose):
docker build \
  --build-arg PUBLIC_API_BASE_URL=http://localhost:5000/ \
  -t chatapp-frontend \
  ./frontend
```

The image also uses a **two-stage build**:

| Stage | Base image | Purpose |
|-------|-----------|---------|
| `builder` | `node:20-alpine` | `npm install` + `npm run build` |
| `runtime` | `node:20-alpine` | Serve the compiled SvelteKit Node adapter output |

### 2.2 How to run the container

```bash
docker run -d \
  --name chatapp-frontend \
  -p 3000:3000 \
  chatapp-frontend
```

Open <http://localhost:3000/> in your browser.

### 2.3 What must be configured for a successful build

| Requirement | Details |
|-------------|---------|
| **`PUBLIC_API_BASE_URL`** | A SvelteKit public env variable that must be set **at build time** (the bundler bakes it into the client bundle). Pass it via `--build-arg` when building. |
| **SvelteKit Node adapter** | `@sveltejs/adapter-node` must be configured in `svelte.config.js`. The Dockerfile installs it and patches `svelte.config.js` automatically during the build stage. The runtime stage runs `node build` which relies on this adapter's output. |
| **`package-lock.json`** | Should be committed so `npm install` inside the container is deterministic. |

---

## 3. Running with Docker Compose

### ⚠️ Known limitation — `docker compose up --build`

In environments where Docker Buildx < 0.17.0 is installed, running `docker compose up --build` will fail immediately with:

```
compose build requires buildx 0.17.0 or later
```

**Workaround:** build the images manually first, then start Compose without the `--build` flag. Compose will detect that the images already exist and use them directly.

### Recommended workflow (works in all environments)

```bash
# Step 1 — build both images manually
docker build -t chatapp-backend ./backend
docker build \
  --build-arg PUBLIC_API_BASE_URL=http://localhost:5000/ \
  -t chatapp-frontend ./frontend

# Step 2 — start both containers via Compose (no --build needed)
docker compose up
```

> The image names in `compose.yaml` match the tags used above, so Compose picks them up automatically.

### If your environment has Buildx ≥ 0.17.0

```bash
docker compose up --build
```

- `--build` forces images to be rebuilt from source before starting.
- The frontend waits for the backend health-check to pass before starting.

### Stop and remove containers

```bash
docker compose down
```

### Useful commands

```bash
# View logs from all services
docker compose logs -f

# View logs from one service
docker compose logs -f backend

# Run in detached mode (after images are already built)
docker compose up -d
```

---

## 4. Manual build & run (without Compose)

```bash
# 1. Build images
docker build -t chatapp-backend  ./backend
docker build --build-arg PUBLIC_API_BASE_URL=http://localhost:5000/ \
             -t chatapp-frontend ./frontend

# 2. Create a shared network
docker network create chatapp-network

# 3. Start backend
docker run -d --name chatapp-backend \
  --network chatapp-network \
  -p 5000:5000 \
  chatapp-backend

# 4. Start frontend
docker run -d --name chatapp-frontend \
  --network chatapp-network \
  -p 3000:3000 \
  chatapp-frontend
```

---

## 5. What We Learned

- **Multistage Docker builds** allow us to keep the final image small by separating the build environment (JDK / full Node) from the runtime environment (JRE / minimal Node). The backend runtime image is significantly smaller than an image that also carries the JDK.
- **Build-time vs. runtime environment variables**: SvelteKit's `PUBLIC_*` variables must be available during `npm run build` because they are inlined into the JavaScript bundle. This is different from backend env vars which can be injected at runtime.
- **Docker Compose networking**: Services within the same Compose stack can reach each other using their service name as the hostname (e.g. `http://backend:5000`). However, since the browser runs on the *host machine* (not inside a container), the `PUBLIC_API_BASE_URL` must resolve from the host perspective (`localhost:5000`), not the Docker-internal name.
- **Health checks** in Compose let us express dependencies more precisely than a plain `depends_on` — the frontend only starts once the backend actually accepts connections.
- **Layer caching**: Copying `package.json` / `build.gradle` before the source code means Docker only re-runs the dependency installation step when those manifests change, not on every code edit.
- **Tooling version constraints**: `docker compose up --build` requires Docker Buildx ≥ 0.17.0. When the environment does not meet this requirement, images must be built manually with `docker build` before running `docker compose up`.

---

## 6. Problems Encountered

| # | Problem | Root Cause | Solution |
|---|---------|-----------|----------|
| 1 | `gradlew: Permission denied` | Git does not preserve the executable bit on the Gradle wrapper by default | Added `RUN chmod +x ./gradlew` in the Dockerfile |
| 2 | Frontend could not reach the backend in Compose | `PUBLIC_API_BASE_URL` was set to the Docker-internal hostname (`backend:5000`), which the browser cannot resolve | Set the build arg to `http://localhost:5000/` so the browser uses the host-mapped port |
| 3 | Frontend image failing at runtime with "Cannot find module" | Only `build/` was copied; `node_modules` needed by the Node adapter were missing | Added `COPY --from=builder /app/node_modules ./node_modules` in the runtime stage |
| 4 | `compose build requires buildx 0.17.0 or later` | The lab environment has an older Buildx version that does not support `docker compose up --build` | Build images manually with `docker build`, then run `docker compose up` without `--build` |

---

## 7. Quick Reference

| URL                                            | Description                   |
|------------------------------------------------|-------------------------------|
| <http://localhost:3000/>                       | Frontend (chat UI)            |
| <http://localhost:5000/chat/all?username=test> | Backend health / message list |

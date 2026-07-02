# =============================================================================
# Stage 1 — BUILD
# =============================================================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package manifests first for better layer caching
COPY package.json package-lock.json* ./
RUN npm install

# Install adapter-node (project uses adapter-auto which has no Node server output)
RUN npm install @sveltejs/adapter-node

# Copy the rest of the source
COPY . .

# Patch svelte.config.js to use adapter-node instead of adapter-auto
RUN sed -i "s|@sveltejs/adapter-auto|@sveltejs/adapter-node|g" svelte.config.js

# PUBLIC_API_BASE_URL must be set at build time so SvelteKit bakes it in.
ARG PUBLIC_API_BASE_URL=http://localhost:5000/
ENV PUBLIC_API_BASE_URL=${PUBLIC_API_BASE_URL}

RUN npm run build

# =============================================================================
# Stage 2 — RUNTIME
# =============================================================================
FROM node:20-alpine AS runtime

WORKDIR /app

# adapter-node outputs a self-contained server into build/
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000

CMD ["node", "build"]
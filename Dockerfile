# ---- Stage 1: build ----
FROM node:22-alpine AS build
WORKDIR /app

# Copy dependency files first so Docker can cache the npm install step
COPY package.json package-lock.json .npmrc ./
RUN npm ci

# Now copy the source and build
COPY . .
RUN npm run build && npm prune --omit=dev

# ---- Stage 2: runtime --
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=build --chown=node:node /app/build ./build
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/package.json ./

# Don't run as root (good-practice check)
USER node
EXPOSE 3000
CMD ["node", "build"]
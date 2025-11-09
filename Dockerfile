FROM node:20-alpine

# Create and use /app
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package manifests from the monorepo root
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY shared/package.json ./shared/package.json
COPY server/package.json ./server/package.json
COPY client/package.json ./client/package.json

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the source code from the monorepo root
COPY shared/ ./shared/
COPY server/ ./server/
COPY client/ ./client/
COPY scripts/ ./scripts/
COPY data.json ./

# Set environment
ENV NODE_ENV=production

# Build all packages from root using pnpm filters
RUN node scripts/update-metadata.js && \
    pnpm --filter @meetup/shared build && \
    pnpm --filter ./server build && \
    pnpm --filter ./client build

# Create data directory for SQLite database
RUN mkdir -p /app/server/data && chown -R node:node /app

# Switch to non-root user
USER node

# Expose port
EXPOSE 3000

# Run database migrations and start the server
CMD ["sh", "-c", "pnpm --filter ./server db:push && node server/dist/index.js"]

# build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
RUN npm run build

# production stage - nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy built React app
COPY --from=builder /app/dist .

# Copy custom nginx configuration for SPA routing
# This enables client-side routing by falling back to index.html for non-file requests
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Run nginx in foreground mode (required for Docker)
CMD ["nginx", "-g", "daemon off;"]

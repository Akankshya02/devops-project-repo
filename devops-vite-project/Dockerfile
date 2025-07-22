# Step 1: Build the Vite app
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Step 2: Serve the app with a lightweight web server
FROM nginx:alpine

# Copy built app to nginx default public folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config (optional, you can skip if you don't have one)
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Step 1: Build the Vite app
FROM node:20.19.0-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Step 2: Serve the app with Nginx
FROM nginx:alpine

# Copy built Vite app from builder stage to Nginx public folder
COPY --from=builder /app/dist /usr/share/nginx/html

# (Optional) Copy custom nginx config if you have one
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# Stage 1: Build the React application
FROM node:20-alpine as build

WORKDIR /app

# Copy package.json and install dependencies
COPY app/package.json app/package-lock.json* ./
RUN npm install

# Copy the rest of the application code
COPY app/ ./

# Build the Vite application
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy the built assets from the builder stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx and keep it running in the foreground
CMD ["nginx", "-g", "daemon off;"]

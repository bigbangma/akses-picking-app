# Use the official Node.js image as the base image
FROM node:18-alpine AS builder

# Copyright labels
LABEL maintainer="whybe"
LABEL name="PICKING APP"
LABEL version="1.0.0"

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the Next.js application
RUN npm run build

# Use a smaller base image for the production environment
FROM node:18-alpine AS runner

# Copyright labels
LABEL maintainer="whybe"
LABEL name="PICKING APP"
LABEL version="1.0.0"

# Set the working directory
WORKDIR /app

# Copy the built application from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
COPY --from=builder /app/next.config.ts ./next.config.ts

# Install only production dependencies
RUN npm ci --only=production

# Expose the port the app runs on
EXPOSE 3000

# Start the Next.js application
CMD ["npm", "start"]
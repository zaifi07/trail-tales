FROM node:20-alpine

WORKDIR /app

# Copy the entire project (client, server, and root files)
COPY . .

# Install dependencies and build the React client
RUN cd client && npm install && npm run build
RUN cd server && npm install --omit=dev

# Set production environment
ENV NODE_ENV=production
ENV PORT=5000
EXPOSE 5000

# Start the server
CMD ["node", "server/server.js"]
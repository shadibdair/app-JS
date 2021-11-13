# Build image
FROM node:14-alpine
COPY . /app-javascript
WORKDIR /app-javascript
EXPOSE 8080
# dependencies
RUN npm install
CMD npm run initdb && npm run dev

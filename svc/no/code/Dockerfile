FROM node:10-slim AS compile-image
COPY package.json .
RUN npm install --production

FROM node:10-slim AS build-image
COPY --from=compile-image node_modules /app/node_modules
WORKDIR /app
COPY . .
CMD ["npm", "start"]
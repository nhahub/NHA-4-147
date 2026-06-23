# Stage 1
FROM node:22.17.0-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install --legacy-peer-deps

COPY . .

RUN npm prune --omit=dev


# Stage 2
FROM node:22.17.0-alpine

WORKDIR /app

COPY --from=build /app ./

EXPOSE 8000

CMD ["npm", "start"]
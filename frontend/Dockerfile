# FROM node:22.17.0-alpine AS build

# WORKDIR /app

# COPY package*.json ./

# RUN npm install --legacy-peer-deps
# COPY . .
# RUN npm run build


# FROM nginx:alpine

# COPY nginx.conf /etc/nginx/conf.d/default.conf

# COPY --from=build /app/build /usr/share/nginx/html
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]

FROM node:22.17.0-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --legacy-peer-deps

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
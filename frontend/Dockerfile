# Build Stage
FROM node:14-alpine as build

WORKDIR /app

COPY . .

RUN yarn install

RUN yarn build

# Delivery Stage
FROM nginx:stable-alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]

# Build Stage
FROM node:14-alpine as build

WORKDIR /app

COPY . .

RUN yarn install

EXPOSE 8080

CMD [ "yarn", "start"]

# Build Stage
FROM node:14-alpine as build

WORKDIR /app

COPY . .

RUN yarn install 
RUN yarn build

# Release Stage
FROM node:14-alpine
WORKDIR /app

COPY --from=build /app/build .
COPY package.json .

RUN yarn install --production --no-lockfile

EXPOSE 8090

CMD [ "yarn", "start"]

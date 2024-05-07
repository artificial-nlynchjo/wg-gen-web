ARG COMMIT="N/A"

FROM golang:alpine AS build-back
WORKDIR /app
ARG COMMIT
COPY . .
RUN go build -o wg-gen-web-linux github.com/vx3r/wg-gen-web/cmd/wg-gen-web

FROM node:18.13.0-alpine AS build-front
WORKDIR /app
COPY ui/package*.json ./
COPY ui/yarn.lock ./
RUN npm install
COPY ui/ ./
#RUN yarn build --frozen-lockfile --verbose
RUN npm ci

FROM alpine
WORKDIR /app
COPY --from=build-back /app/wg-gen-web-linux .
COPY --from=build-front /app/dist ./ui/dist
COPY .env .
RUN chmod +x ./wg-gen-web-linux
RUN apk add --no-cache ca-certificates
EXPOSE 8080

CMD ["/app/wg-gen-web-linux"]

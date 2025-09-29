FROM node:23-alpine3.20 as builder

WORKDIR /app
COPY package*.json ./
COPY tsconfig.json ./
RUN npm ci
COPY . .
ARG GH_PAT
ENV GH_PAT=${GH_PAT}
RUN npm run build

FROM node:23-alpine3.20

WORKDIR /app
ARG GH_PAT
ENV GH_PAT=${GH_PAT}
COPY --from=builder /app/build /app/html
COPY nginx.conf /app
RUN mkdir -p /app/run && apk add --no-cache bash && apk add --no-cache curl

EXPOSE 80

CMD ["nginx", "-c", "/app/nginx.conf"]

FROM node:18-alpine AS base

FROM base AS deps
WORKDIR /app
COPY package.json .
RUN npm i

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN NODE_ENV=production npm run build

FROM base AS runner
WORKDIR /app
COPY --from=builder /app/package.json .
COPY --from=builder /app/node_modules ./node_modules
COPY ./tsconfig.json ./tsconfig.json
COPY ./.env ./.env
COPY --from=builder /app/config ./config
COPY --from=builder /app/database ./database
COPY --from=builder /app/dist ./dist
CMD NODE_ENV=production npm run start
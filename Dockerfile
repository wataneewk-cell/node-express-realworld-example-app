FROM node:18-alpine AS builder
WORKDIR /app
RUN apk update && apk add --no-cache openssl
COPY package.json package-lock.json ./
COPY src/prisma ./src/prisma
RUN npm ci
COPY . .
RUN npx prisma generate --schema=./src/prisma/schema.prisma
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
RUN apk update && apk add --no-cache openssl
COPY package.json package-lock.json ./
COPY src/prisma ./src/prisma
RUN npm ci --only=production
RUN npx prisma generate --schema=./src/prisma/schema.prisma
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["sh", "-c", "npx prisma migrate deploy --schema=./src/prisma/schema.prisma && node dist/api/main.js"]
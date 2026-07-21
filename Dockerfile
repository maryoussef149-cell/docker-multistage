#1.build
FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json .

RUN npm install --production

COPY . .

#2.production
FROM node:18-alpine

WORKDIR /app

COPY --from=builder /app .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
	CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "index.js"]

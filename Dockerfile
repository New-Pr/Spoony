# Spoony — Express API + prebuilt Flutter web app, deployed on Railway.
# The web app is built locally (`flutter build web --release`) and committed
# under build/web; server.js serves it alongside /api.
FROM node:22-alpine

WORKDIR /app

COPY backend/package.json backend/package-lock.json backend/
RUN npm --prefix backend ci --omit=dev

COPY backend backend
COPY build/web build/web

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "backend/server.js"]

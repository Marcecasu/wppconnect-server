FROM node:22.21.1-alpine AS base

WORKDIR /usr/src/wpp-server

ENV NODE_ENV=production \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Copia solo package.json para aprovechar cache
COPY package.json ./

# Instala dependencias del sistema necesarias para sharp/libvips
RUN apk update && \
    apk add --no-cache \
      vips-dev \
      fftw-dev \
      gcc \
      g++ \
      make \
      libc6-compat \
    && rm -rf /var/cache/apk/*

# Instala dependencias de Node + sharp
RUN yarn install --production --pure-lockfile && \
    yarn add sharp --ignore-engines && \
    yarn cache clean

# --------- Etapa de build ---------
FROM base AS build

WORKDIR /usr/src/wpp-server
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

COPY package.json ./
RUN yarn install --production=false --pure-lockfile
RUN yarn cache clean

# Copia el código fuente y compila
COPY . .
RUN yarn build

# --------- Imagen final ---------
FROM base

WORKDIR /usr/src/wpp-server/

# Chromium para los recursos que lo usan
RUN apk add --no-cache chromium
RUN yarn cache clean

# Copia el código y el build
COPY . .
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/

EXPOSE 21465

ENTRYPOINT ["node", "dist/server.js"]

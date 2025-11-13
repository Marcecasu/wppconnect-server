# Base estable: Node 20 LTS (Debian)
FROM node:20-bullseye

# Evita prompts y reduce layer size
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependencias del sistema:
# - libvips (requerido por sharp)
# - chromium (para puppeteer)
# - dumb-init (arranque limpio)
RUN apt-get update && apt-get install -y \
    chromium \
    libvips \
    libvips-dev \
    dumb-init \
 && rm -rf /var/lib/apt/lists/*

# Variables recomendadas para puppeteer/chromium
ENV CHROME_PATH=/usr/bin/chromium \
    CHROME_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    NODE_ENV=production

# Directorio de trabajo
WORKDIR /usr/src/wpp-server

# Copia package.json/yarn.lock primero para cache
COPY package.json yarn.lock ./

# Instala dependencias (sin opcionales problemáticos)
RUN yarn install --frozen-lockfile --ignore-optional

# Copia el resto del código
COPY . .

# Build
RUN yarn build

# Puerto del server
ENV SERVER_PORT=21465
EXPOSE 21465

# Inicia con dumb-init para señales limpias
CMD ["dumb-init","node","dist/server.js"]

FROM node:22-bullseye

# Evita prompts
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    chromium \
    libvips \
    libvips-dev \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/wpp-server

# Copiar package.json y yarn.lock (si existe)
COPY package.json ./
COPY yarn.lock ./

# Instalar dependencias
RUN yarn install --ignore-optional

# Copiar el resto del código
COPY . .

# Build
RUN yarn build

# Puerto del servidor
EXPOSE 21465

CMD ["node", "dist/server.js"]

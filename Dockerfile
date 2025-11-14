# Usar Node 22 para respetar el "engine" que pide @wppconnect/server
FROM node:22-bullseye

# Instalar dependencias del sistema (chromium + libvips para sharp)
RUN apt-get update && apt-get install -y \
    chromium \
    libvips \
    libvips-dev \
    dumb-init \
 && rm -rf /var/lib/apt/lists/*

# Carpeta de trabajo dentro del contenedor
WORKDIR /usr/src/wpp-server

# Copiar sólo package.json (NO yarn.lock, porque no existe)
COPY package.json ./

# Instalar dependencias (sin opcionales problemáticos)
RUN yarn install --ignore-optional

# Copiar el resto del código fuente
COPY . .

# Compilar el proyecto (esto genera la carpeta dist/)
RUN yarn build

# Variables básicas
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=21465

EXPOSE 21465

# Comando para iniciar el servidor
CMD ["dumb-init", "yarn", "start"]

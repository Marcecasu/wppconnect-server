FROM node:22-bullseye

# Evitar prompts
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /usr/src/wpp-server

# Dependencias del sistema necesarias para chromium y sharp
RUN apt-get update && apt-get install -y \
    chromium \
    libvips \
    libvips-dev \
    dumb-init \
 && rm -rf /var/lib/apt/lists/*

# Copiar archivos necesarios para instalar dependencias
COPY package.json yarn.lock ./

# Respetar versión de node requerida por engines
RUN yarn install --ignore-optional

# Copiar todo el proyecto
COPY . .

# Build de Typescript
RUN yarn build

# Puerto del servidor
EXPOSE 21465

# Iniciar con dumb-init para evitar zombies
CMD ["dumb-init", "yarn", "start"]

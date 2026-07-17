# ETAPA 1: Construcción
FROM node:12-alpine AS builder

# Instalamos dependencias de compilación si son necesarias
RUN apk add --no-cache openssl

WORKDIR /usr/src/app

# Copiamos solo los archivos de dependencias primero para aprovechar caché
COPY package*.json ./
RUN npm install --production --no-cache

# Copiamos el resto del código
COPY . .

# Aplicamos el parche del puerto ANTES de nada
RUN sed -i 's/4001/4002/g' config/env/all.js

# ETAPA 2: Ejecución (Imagen final)
FROM node:12-alpine

# Instalamos openssl necesario en tiempo de ejecución
RUN apk add --no-cache openssl

WORKDIR /home/node/app

# Copiamos solo lo necesario desde la etapa builder
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app .

# Ajustamos permisos
RUN chown -R node:node /home/node/app

USER node

# Exponemos el puerto que ahora es 4002
EXPOSE 4002

CMD ["node", "server.js"]

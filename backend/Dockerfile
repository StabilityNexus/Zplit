FROM node:20-alpine
WORKDIR /usr/src/app

# copy package manifest first for caching
COPY package.json package-lock.json* ./

# install all deps (including dev for building TS)
RUN npm install

COPY . .

# generate prisma client
RUN npx prisma generate || true

# build TS
RUN npm run build

EXPOSE 4000
CMD ["node", "dist/server.js"]

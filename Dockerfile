FROM node:22-alpine

RUN npm install -g beads-ui

WORKDIR /data

EXPOSE 3000

CMD ["bdui", "start", "--host", "0.0.0.0", "--port", "3000"]

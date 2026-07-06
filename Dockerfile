FROM node:22-alpine

RUN apk add --no-cache git

RUN npm install -g beads-ui

WORKDIR /data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

CMD ["/entrypoint.sh"]

FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y git curl ca-certificates sudo && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash
RUN curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash

RUN npm install -g beads-ui

WORKDIR /data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

CMD ["/entrypoint.sh"]

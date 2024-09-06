FROM oven/bun as base

WORKDIR /app

ENV NODE_ENV="production"


FROM base as build

RUN apt-get update -qq && \
    apt-get install -y build-essential pkg-config python-is-python3

### Copy the lock and package file
COPY --link package.json ./

RUN bun install --ci


# Copy application code
COPY --link . .

FROM base

COPY --from=build /app /app

EXPOSE 3000

# RUN bun run build

CMD ["bun", "run", "build", "&&", "bun", "run", "start"]

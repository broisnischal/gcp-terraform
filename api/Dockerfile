FROM oven/bun as base

WORKDIR /app

ENV NODE_ENV="production"

FROM base as build

RUN apt-get update -qq && \
    apt-get install -y build-essential pkg-config python-is-python3

# Install node modules
COPY --link package.json ./

RUN bun install --ci

# Copy application code
COPY --link . .

FROM base

COPY --from=build /app /app

EXPOSE 3000

CMD [ "bun", "run", "dev" ] # Start the server by default
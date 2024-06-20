FROM elixir:1.17

ENV PHOENIX_VERSION 1.7.14

# Packages
RUN apt-get update && apt-get install -y \
    inotify-tools \
    git \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Phoenix
RUN mix local.hex --force && \
  mix archive.install --force hex phx_new ${PHOENIX_VERSION} && \
  mix local.rebar --force

WORKDIR /srv

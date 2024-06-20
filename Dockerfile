FROM elixir:1.17

ENV PHOENIX_VERSION 1.7.14

# Phoenix
RUN mix local.hex --force && \
  mix archive.install --force hex phx_new ${PHOENIX_VERSION} && \
  mix local.rebar --force

WORKDIR /srv

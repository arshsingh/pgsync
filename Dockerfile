FROM ruby:2.5-alpine3.8
LABEL description="pgsync running under cron for periodic DB synchronisation"

ADD . /app/src/
WORKDIR /app/
RUN \
  set -x && \
  apk add --no-cache postgresql-client postgresql-dev && \
  apk add --no-cache --virtual .build-deps git build-base && \
  cd src/ && \
  gem build pgsync.gemspec && \
  gem install pgsync-*.gem && \
  apk del .build-deps && \
  chmod +x docker/*.sh && \
  mv docker/*.sh ../ && \
  cd .. && \
  rm -r src/ && \
  sentryVersion=1.62.0 && \
  wget -O /usr/local/bin/sentry-cli \
    "https://downloads.sentry-cdn.com/sentry-cli/$sentryVersion/sentry-cli-Linux-x86_64" && \
  chmod a+x /usr/local/bin/sentry-cli

ENTRYPOINT [ "/bin/sh", "/app/entrypoint.sh" ]


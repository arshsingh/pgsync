FROM ruby:2.5-alpine3.8
LABEL author="Tom Saleeba"
LABEL description="pgsync running under cron for periodic DB synchronisation"

ADD . /app/src/
WORKDIR /app/
RUN \
  apk add --no-cache postgresql-client postgresql-dev && \
  apk add --no-cache --virtual .build-deps git build-base && \
  cd src/ && \
  gem build pgsync.gemspec && \
  gem install pgsync-*.gem && \
  apk del .build-deps && \
  chmod +x docker/*.sh && \
  mv docker/*.sh ../ && \
  cd .. && \
  rm -r src/

ENTRYPOINT [ "/bin/sh", "/app/entrypoint.sh" ]


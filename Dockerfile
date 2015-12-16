# FROM alpine:3.2
FROM gliderlabs/alpine
MAINTAINER smizy

RUN adduser -D -g '' -u 1000 docker

ENV FLUENTD_VERSION 0.12.16

RUN apk --update add \
    build-base \
    ca-certificates \
    ruby-dev \
    && \
    rm -rf /var/cache/apk/* && \
    echo 'gem: --no-document' >> /etc/gemrc && \
    gem install fluentd -v $FLUENTD_VERSION && \
    apk del build-base

WORKDIR /fluentd
RUN mkdir log etc plugins

COPY fluent.conf /fluentd/etc/
ONBUILD COPY fluent.conf /fluentd/etc/
ONBUILD COPY plugins/* /fluentd/plugins/

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

RUN chown -R docker:docker /fluentd

USER docker

EXPOSE 24224

VOLUME ["/fluentd/log"]

### docker run -p 24224 -v `pwd`/log: -v /data:/fluentd/log fluentd
CMD fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
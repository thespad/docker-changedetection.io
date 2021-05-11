FROM ghcr.io/linuxserver/baseimage-alpine:3.13
LABEL maintainer="Adam Beardwood"
ENV PYTHONUNBUFFERED=1

RUN \
  apk add --update --no-cache --virtual=build-dependencies \
    openssl-dev \
    libffi-dev \
    gcc \
    libc-dev \
    libxslt-dev \
    zlib-dev \
    g++ \
    python3-dev && \
  apk add --update --no-cache \
    curl \
    libxslt \
    python3 \
    py3-pip && \
  echo "**** install changedetection.io ****" && \
  mkdir -p /app/changedetection && \
  if [ -z ${CHANGEDETECTON_RELEASE+x} ]; then \
    CHANGEDETECTON_RELEASE=$(curl -sX GET "https://api.github.com/repos/dgtlmoon/changedetection.io/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -s -o \
    /tmp/changedetection.tar.gz -L \
    "https://github.com/dgtlmoon/changedetection.io/archive/${CHANGEDETECTON_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/changedetection.tar.gz -C \
    /app/changedetection/ --strip-components=1 && \
  rm /tmp/changedetection.tar.gz && \
  mkdir -p /tmp/wheels && \
  curl -s -o \
    /tmp/wheels.tar.gz -L \
    "https://github.com/TheSpad/docker-changedetection.io/raw/main/wheels/wheels.tar.gz" && \
  tar xf \
    /tmp/wheels.tar.gz -C \
    /tmp/wheels/ && \
  pip install wheel && \
  pip install -U --no-cache-dir --find-links=/tmp/wheels -r /app/changedetection/requirements.txt && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache

COPY root/ /

EXPOSE 5000
VOLUME /config
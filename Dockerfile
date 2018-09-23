FROM lsiobase/ubuntu:bionic

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"
MAINTAINER xyzzyx

ARG DEBIAN_FRONTEND="noninteractive"
ENV FLEXGET_LOG_LEVEL="info"

COPY patches/ /tmp

RUN \
    echo "***** INSTALLING PACKAGES *****" && \
    apt-get update && \
    apt-get install --no-install-recommends -y python-pip deluge-console gosu curl wget unzip patch && \
    wget --quiet -O /tmp/trackers.zip https://github.com/autodl-community/autodl-trackers/archive/master.zip && \
    mkdir -p /defaults/flexget/trackers && \
    cd /defaults/flexget/trackers && \
    unzip -q -o -j /tmp/trackers.zip && \
    apt-get clean && \
    rm /tmp/trackers.zip

ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"
RUN \
    pip install --upgrade setuptools wheel && \
    pip install flexget irc_bot python-telegram-bot && \
    cd /usr/local/lib/python2.7/dist-packages/flexget && \
    patch -Np1 -i /tmp/flexget_irc_password.patch && \
    cd /usr/local/lib/python2.7/dist-packages/irc_bot && \
    patch -Np1 -i /tmp/irc_bot_join-part.patch && \
    mkdir -p /watch/{deluge,rtorrent} && \
    rm -fr /tmp/*

COPY root/ /

VOLUME /config
VOLUME /watch/deluge
VOLUME /watch/rtorrent

EXPOSE 5000


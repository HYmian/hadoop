FROM openjdk:8-jre
MAINTAINER mian <gopher.mian@outlook.com>

# Install required packages
RUN apt-get update && apt-get install -y gnupg && rm -rf /var/lib/apt/lists/*

ENV ZOO_USER zookeeper
ENV ZOO_CONF_DIR /conf
ENV ZOO_DATA_DIR /data
ENV ZOO_DATA_LOG_DIR /datalog

# Add a user and make dirs
RUN set -x \
    && adduser --disabled-password "$ZOO_USER" \
    && mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" \
    && chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"

ARG GPG_KEY=C823E3E5B12AF29C67F81976F5CECB3CB5E9BD2D
ARG DISTRO_NAME=zookeeper-3.4.9

# Download Apache Zookeeper, verify its PGP signature, untar and clean up
RUN set -x \
    && wget -q "http://www.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz" \
    && wget -q "http://www.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" \
    && gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz" \
    && tar -xzf "$DISTRO_NAME.tar.gz" \
    && mv "$DISTRO_NAME/conf/"* "$ZOO_CONF_DIR" \
    && rm -r "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc" 

WORKDIR $DISTRO_NAME
VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR"]

ENV ZOO_PORT 2181
EXPOSE $ZOO_PORT

ENV PATH $PATH:/$DISTRO_NAME/bin
ENV ZOOCFGDIR $ZOO_CONF_DIR

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

FROM bde2020/hadoop-nodemanager:2.0.0-hadoop3.2.1-java8

USER root

# L'image Hadoop repose sur Debian 9, désormais archivée.
# Python 3 est installé pour exécuter les mappers et reducers Hadoop Streaming.
RUN sed -i \
      -e 's|deb.debian.org/debian|archive.debian.org/debian|g' \
      -e 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
      -e 's|httpredir.debian.org/debian|archive.debian.org/debian|g' \
      /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3 \
    && rm -rf /var/lib/apt/lists/*

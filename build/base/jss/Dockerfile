# Base Details
FROM ubuntu:18.04
LABEL maintainer="support@datajar.co.uk"


# Tomcat Version
ARG tomcat_ver


# Package installs
RUN /usr/bin/apt-get update
RUN /usr/bin/apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    java-common \
    mysql-client \
    nano \
    tzdata


# Timezone
# https://serverfault.com/a/826222
ENV TZ=Europe/London


# Amazon Coretto 11
RUN CORRETTO11_LATEST=$(/usr/bin/curl -LS https://corretto.aws/downloads/latest/amazon-corretto-11-x64-linux-jdk.deb -o /tmp/amazon-corretto-11-latest.deb); \
    if [ ! -f /tmp/amazon-corretto-11-latest.deb ]; then \
        /bin/echo; \
        /bin/echo "ERROR: amazon corretto download failed, exiting..."; \
        /bin/echo; \
        exit 1; \
    fi; \
    /usr/bin/curl -LS https://corretto.aws/downloads/latest_checksum/amazon-corretto-11-x64-linux-jdk.deb -o /tmp/amazon-corretto-11-latest-checksum.deb; \
    REMOTE_MD5=$(/bin/cat /tmp/amazon-corretto-11-latest-checksum.deb); \
    if [ ! -f /tmp/amazon-corretto-11-latest-checksum.deb ]; then \
        /bin/echo; \
        /bin/echo "ERROR: amazon corretto checksum download failed, exiting..."; \
        /bin/echo; \
        exit 1; \
    fi; \
    MD5_CHECKSUM=$(/usr/bin/md5sum /tmp/amazon-corretto-11-latest.deb | /usr/bin/awk '{ print $1 }'); \
    if [ "${REMOTE_MD5}" != "${MD5_CHECKSUM}" ]; then \
        /bin/echo; \
        /bin/echo "ERROR: amazon corretto checksum check failed, exiting..."; \
        /bin/echo; \
        exit 1; \
    else \
        /usr/bin/dpkg --install /tmp/amazon-corretto-11-latest.deb; \
    fi


# Tomcat
RUN /usr/bin/curl -SL https://archive.apache.org/dist/tomcat/tomcat-8/v"$tomcat_ver"/bin/apache-tomcat-"$tomcat_ver".tar.gz -o /tmp/apache-tomcat-"$tomcat_ver".tar.gz; \
    DLOAD_SHA512=$(/usr/bin/sha512sum /tmp/apache-tomcat-"$tomcat_ver".tar.gz | /usr/bin/awk '{ print $1 }'); \
    DIST_SHA512=$(/usr/bin/curl -Ls https://archive.apache.org/dist/tomcat/tomcat-8/v"$tomcat_ver"/bin/apache-tomcat-"$tomcat_ver".tar.gz.sha512 | /usr/bin/awk '{ print $1 }'); \
    if [ "${DLOAD_SHA512}" != "${DIST_SHA512}" ]; then \
        /bin/echo; \
        /bin/echo "ERROR: tomcat SHA check failed, exiting..."; \
        /bin/echo; \
        exit 1; \
    fi
RUN /bin/tar -xf /tmp/apache-tomcat-"$tomcat_ver".tar.gz -C /usr/local
RUN /bin/mv /usr/local/apache-tomcat-"$tomcat_ver" /usr/local/tomcat


# Confd (pull latest)
RUN CONFD_LATEST=$(/usr/bin/curl -Ls -o /dev/null -w %{url_effective} https://github.com/kelseyhightower/confd/releases/latest | /usr/bin/awk -F / '{print $NF}' | /usr/bin/cut -c 2-); \
    /usr/bin/curl -SL https://github.com/kelseyhightower/confd/releases/download/v"${CONFD_LATEST}"/confd-"${CONFD_LATEST}"-linux-amd64 -o /usr/local/bin/confd ; \
    DLOAD_SHA256=$(/usr/bin/sha256sum /usr/local/bin/confd | /usr/bin/awk '{ print $1 }'); \
    GHUB_SHA256=$(/usr/bin/curl -Ls https://github.com/kelseyhightower/confd/releases/tag/v"${CONFD_LATEST}" | /usr/bin/awk "/  confd-"${CONFD_LATEST}"-linux-amd64/"'{ print $1 }'); \
    if [ "${DLOAD_SHA256}" != "${GHUB_SHA256}" ]; then \
        /bin/echo; \
        /bin/echo "ERROR: confd SHA check failed, exiting..."; \
        /bin/echo; \
        exit 1; \
    fi
RUN /bin/chmod +x /usr/local/bin/confd


# Web application
RUN /bin/rm -rf /usr/local/tomcat/webapps/*
COPY /war/ROOT* /usr/local/tomcat/webapps/ROOT
RUN /bin/rm -rf /usr/local/tomcat/webapps/ROOT.war


# Housekeeping
RUN /usr/bin/apt-get clean
RUN /bin/rm -rf /tmp/*
RUN /bin/rm -rf /var/lib/apt/lists/*
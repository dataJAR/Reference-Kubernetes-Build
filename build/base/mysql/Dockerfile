# MySQL Version
ARG mysql_ver


# Base Details
FROM mysql:"${mysql_ver}"
LABEL maintainer="support@datajar.co.uk"


# Package installs
RUN /usr/bin/apt-get update && /usr/bin/apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    nano \
    procps \
    tzdata


# Timezone
# https://serverfault.com/a/826222
ENV TZ=Europe/London


# Housekeeping
RUN /usr/bin/apt-get clean; \
    /bin/rm -rf /tmp/*; \
    /bin/rm -rf /var/lib/apt/lists/*
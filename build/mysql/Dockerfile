# Build Args
ARG mysql_base
FROM registry.datajar.mobi:5000/mysql-base:"${mysql_base}"


# Config
COPY ./config/my.cnf /etc/mysql
COPY ./config/run.sh /usr/local/bin/


# Run
RUN /bin/mkdir -p /var/log/mysql/; \
    /bin/chmod -R a+rx /var/log/mysql; \
    /bin/chmod +x /usr/local/bin/run.sh
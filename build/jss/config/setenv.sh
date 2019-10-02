#!/bin/bash
export CATALINA_HOME=/usr/local/tomcat
# TLS 1.3 disabled as per: https://macmule.com/2019/10/01/more-dep-sync-errors/
export CATALINA_OPTS="-Xms1024M -Xmx1024M -Djava.awt.headless=true -server -Djava.security.egd=file:/dev/./urandom -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true -Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2"
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/"
# https://stackoverflow.com/a/39625055
export UMASK='0022'
# Build Args
ARG web_app_ver
FROM registry.datajar.mobi:5000/jss-base:"${web_app_ver}"
ARG instance_name
ARG web_app_dir


# Custom config files
COPY ./config/log4j.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/log4j.properties
COPY ./config/server.xml /usr/local/tomcat/conf/
COPY ./config/setenv.sh /usr/local/tomcat/bin/
COPY ./confd/conf.d /etc/confd/conf.d
COPY ./confd/templates /etc/confd/templates
COPY ./confd/run.sh /usr/local/bin/


# Branding
COPY ./branding/favicon.ico /usr/local/tomcat/webapps/ROOT/
COPY ./branding/favicon.ico /usr/local/tomcat/webapps/ROOT/ui/images/jamf-32-32-favicon.ico
COPY ./branding/jssSetupAssistant.png /usr/local/tomcat/webapps/ROOT/ui/images/assistants/jssSetupAssistant.png
COPY ./branding/jss-logo-plain.png /usr/local/tomcat/webapps/ROOT/ui/images/navigation/jss-logo-plain.png
COPY ./branding/jamf-pro-color.svg /usr/local/tomcat/webapps/ROOT/ui/images/svg/logos/jamf-pro-color.svg
COPY ./branding/jamf-pro-logo-icon.svg /usr/local/tomcat/webapps/ROOT/ui/images/svg/logos/jamf-pro-logo-icon.svg
COPY ./branding/jamf-pro-logo.svg /usr/local/tomcat/webapps/ROOT/ui/images/svg/logos/jamf-pro-logo.svg
COPY ./branding/jamf-pro-mobile-logo.svg /usr/local/tomcat/webapps/ROOT/ui/images/svg/logos/jamf-pro-mobile-logo.svg
COPY ./branding/JSS_pinned.svg /usr/local/tomcat/webapps/ROOT/ui/images/touchicons/JSS_pinned.svg
COPY ./branding/touch-icon-ipad-retina.png /usr/local/tomcat/webapps/ROOT/ui/images/touchicons/touch-icon-ipad-retina.png
COPY ./branding/touch-icon-ipad.png /usr/local/tomcat/webapps/ROOT/ui/images/touchicons/touch-icon-ipad.png
COPY ./branding/touch-icon-iphone-retina.png /usr/local/tomcat/webapps/ROOT/ui/images/touchicons/touch-icon-iphone-retina.png
COPY ./branding/touch-icon-iphone.png /usr/local/tomcat/webapps/ROOT/ui/images/touchicons/touch-icon-iphone.png


# Move .war if from a multi-context host
RUN /bin/bash -c "if [[ "${instance_name}" == "v1-"* ]]; then \
        /bin/mv /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/"${web_app_dir}"; \
fi"


# Environment variables
ENV TERM xterm


# Run
RUN /bin/mkdir -p /usr/local/jss/logs/; \
	/bin/chmod -R a+rx /usr/local/jss/logs; \
	/bin/mkdir -p /usr/local/tomcat/logs/; \
	/bin/chmod -R a+rx /usr/local/tomcat/logs ; \
	/bin/chmod +x /usr/local/bin/run.sh
EXPOSE 8080
CMD ["/usr/local/bin/run.sh"]
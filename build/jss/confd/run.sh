#!/bin/bash

##########################################################################################
################################### Global Variables #####################################
##########################################################################################


# Overall name of the family of software we are installing, with extension removed
swTitle="Docker Run Script"

# Log directory
debugDir="/var/log/managed"

# Log file
debugFile="${debugDir}/dotmobi-run.log"

# Script Version
ver="1.0"

# Environment variables
HOST=$MYSQL_TARQUIN_SERVICE_HOST
USER=$JSS_DB_USERNAME
PASS=$JSS_DB_PASSWORD
DB=$JSS_DB_NAME
ROOT_PASS=$MYSQL_ROOT_PASSWORD

##########################################################################################
#################################### Start functions #####################################
##########################################################################################


setup()
{

    # Make sure we're root & creating logging dirs

    if [ "$(id -u)" != "0" ]
    then
        /bin/echo "ERROR: This script must be run as root" 1>&2
        exit 1
    fi

    if [ ! -d "{debugDir}" ]
    then
        /bin/mkdir -p "${debugDir}"
        /bin/chmod -R 777 "${debugDir}"
    fi

    if [ ! -f "${debugFile}" ]
    then
        /usr/bin/touch "${debugFile}"
    fi

}


start()
{

    # Logging start

    {

        /bin/echo "Started: ${swTitle} ${ver}"

    } | /usr/bin/tee -a "${debugFile}"

}


runConfd()
{

    # Commands to run

    {

        /bin/echo "Running confd..."
        /usr/local/bin/confd -onetime -backend env

    } | /usr/bin/tee -a "${debugFile}"
}


remoteSyslog()
{

    # Commands to run

    {

        /bin/echo "Starting remote_syslog..."
        /usr/local/bin/remote_syslog -V
        /usr/sbin/service remote_syslog start > /dev/null 2>&1

    } | /usr/bin/tee -a "${debugFile}"
}  


mysqlPing()
{

    # Commands to run

    {

        /bin/echo "Checking MySQL connection..."
        
        until  /usr/bin/mysqladmin -h"${HOST}" -u"${USER}" -p"${PASS}" ping > /dev/null 2>&1
        do
            /bin/echo -e "Failed to connect to MySQL Server $HOST using mysqladmin ping, trying again in 10 seconds..."
            sleep 10
        done

    } | /usr/bin/tee -a "${debugFile}"
}


mysqlFlushLogs()
{

    # Commands to run

    {

        /bin/echo "Flushing MySQL logs on ${HOST}..."
 
        if ! /usr/bin/mysqladmin -h"${HOST}" -u"root" -p"${ROOT_PASS}" flush-logs > /dev/null 2>&1; 
        then
            /bin/echo -e "Failed to connect to flush logs..."
            exit 1
        fi

    } | /usr/bin/tee -a "${debugFile}"
}


mysqlCheck()
{

    # Commands to run

    {

        /bin/echo "Running mysqlcheck on database $DB before application startup"
 
        if ! /usr/bin/mysqlcheck -h"${HOST}" -u"${USER}" -p"${PASS}" --auto-repair "${DB}"; 
        then
            /bin/echo "Failed to connect to check $DB before application startup"
            exit 1
        fi

    } | /usr/bin/tee -a "${debugFile}"
}

updateLDAPPoolConfiguration()
{

    # For PI-002208, which is an PI affecting clustered LDAP setups.
    # Pre-10.13 this was an XML file (/usr/local/tomcat/webapps/ROOT/WEB-INF/xml/LDAPPoolConfiguration.xml).
    # Post-10.13 needs values written to the DB.

    {

        # minEvictableIdle value
        mysqlCommand="SELECT * FROM jss_custom_settings WHERE settings_key = 'com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.minEvictableIdle';" 

        if [ -z "$(/bin/echo "${mysqlCommand}" | /usr/bin/mysql -h"${HOST}" -u"${USER}" -p"${PASS}" "${DB}" -ss | /usr/bin/awk '{ print $NF }')" ]
        then
            mysqlCommand="INSERT INTO jss_custom_settings (settings_key, value) VALUES('com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.minEvictableIdle', '40000');" 
            /bin/echo "${mysqlCommand}" | /usr/bin/mysql -h"${HOST}" -u"${USER}" -p"${PASS}" "${DB}" -ss
            /bin/echo "Set com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.minEvictableIdle..."
        else
            /bin/echo "com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.minEvictableIdle, already set. Skipping..."
        fi

        # timeBetweenEviction value
        mysqlCommand="SELECT * FROM jss_custom_settings WHERE settings_key = 'com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.timeBetweenEviction';" 

        if [ -z "$(/bin/echo "${mysqlCommand}" | /usr/bin/mysql -h"${HOST}" -u"${USER}" -p"${PASS}" "${DB}" -ss | /usr/bin/awk '{ print $NF }')" ]
        then
            mysqlCommand="INSERT INTO jss_custom_settings (settings_key, value) VALUES('com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.timeBetweenEviction', '10000');" 
            /bin/echo "${mysqlCommand}" | /usr/bin/mysql -h"${HOST}" -u"${USER}" -p"${PASS}" "${DB}" -ss
            /bin/echo "Set com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.timeBetweenEviction..."
        else
            /bin/echo "com.jamfsoftware.jss.objects.system.ldap.LDAPPoolConfiguration.timeBetweenEviction, already set. Skipping..."
        fi

    } | /usr/bin/tee -a "${debugFile}"
}


startTomcat()
{

    # Commands to run

    {

        /bin/echo "Starting Tomcat..."
        /usr/local/tomcat/bin/catalina.sh run

    } | /usr/bin/tee -a "${debugFile}"
}  

##########################################################################################
#################################### End functions #######################################
##########################################################################################

setup
start
runConfd
remoteSyslog
sleep 10
mysqlPing
mysqlFlushLogs
mysqlCheck
updateLDAPPoolConfiguration
startTomcat
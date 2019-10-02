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
ver="1.2"


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

        /bin/echo "Started: ${swTitle} ${ver} $(/bin/date)"

    } | /usr/bin/tee -a "${debugFile}"

}


startMySQL()
{

    # Commands to run

    {

        if [ -f /usr/local/bin/docker-entrypoint.sh ]
        then
            /bin/echo "Running /usr/local/bin/docker-entrypoint.sh..."
            /usr/local/bin/docker-entrypoint.sh mysqld
        else
            /bin/echo "ERROR: Cannot find /usr/local/bin/docker-entrypoint.sh..."
        fi

    } | /usr/bin/tee -a "${debugFile}"
}


##########################################################################################
#################################### End functions #######################################
##########################################################################################

setup
start
startMySQL

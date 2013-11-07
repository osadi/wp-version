#!/bin/bash
clear

# Columns
FIRST=50
SECOND=20

# Is BADUSER used for the DB?
BADUSER="root"

# Colors
BLACK='\e[30;49m';
RED='\e[31;49m';
GREEN='\e[32;49m';
YELLOW='\e[33;49m';
BLUE='\e[34;49m';
MAGENTA='\e[35;49m';
CYAN='\e[36;49m';
WHITE='\e[37;49m';
RESET="\e[0m";

# Path to folder where we can find WP installs
CHECKDIR=""

DIRS=$(ls -l $CHECKDIR | egrep '^d' | awk '{print $9}')
WPVERSION=$(curl -L -s http://wordpress.org/download/ | grep -E -o 'Version ([0-9]\.[0-9])(\.[0-9])?' | sed 's/Version //')

# Print headers
printf "$BLUE%-${FIRST}s %-${SECOND}s %s$RESET\n" "Folder" "Version ($WPVERSION)" "DB-USER"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# Print customer and version
for DIR in $DIRS
do
    FULLPATH="$CHECKDIR/$DIR"

    # If a WP-folder
    if [ -e "$FULLPATH/wp-includes/version.php" ]; then
        VERSIONFILE="$FULLPATH/wp-includes/version.php"
        CUSTOMERVERSION=$(grep '$wp_version =' ${VERSIONFILE} | awk '{print $3}' | sed 's/'\''\|;//g')

        DBUSER=$(grep  -oP "DB_USER', '\K([a-zA-Z]*)" "${FULLPATH}/wp-config.php")

        # Replace dots and pad right with spaces.
        # Then we replace spaces with 0
        CV=$(printf "%-03s" ${CUSTOMERVERSION//.})
        CV=${CV// /0}
        WV=$(printf "%-03s" ${WPVERSION//.})
        WV=${WV// /0}

        if (( CV < WV )); then
            VERSIONCOLOR=$RED
        else
            VERSIONCOLOR=$GREEN
        fi

        # Check for BADUSER
        shopt -s nocasematch
        case "$DBUSER" in
            $BADUSER ) USERCOLOR=$RED;;
            *) USERCOLOR=$GREEN;;
        esac

        printf "%-${FIRST}s $VERSIONCOLOR%-${SECOND}s$RESET $USERCOLOR%s$RESET\n" ${DIR} ${CUSTOMERVERSION} ${DBUSER}
    fi
done

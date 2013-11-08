#!/bin/bash
clear

# Path to folder where we can find WP installs
CHECK_DIR=""

# Columns
FIRST=50
SECOND=20

# Is BADUSER used for the DB?
BAD_USER="root"

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

VERSION_REGEX="(([0-9]\.[0-9])(\.[0-9])?)"

DIRS=$(ls -l $CHECK_DIR | egrep '^d' | awk '{print $9}')
WP_VERSION=$(curl -L -s http://wordpress.org/download/ | grep -oP "Version \K(${VERSION_REGEX})")

# Print head
printf "$BLUE%-${FIRST}s %-${SECOND}s %s$RESET\n" "Folder" "Version ($WP_VERSION)" "DB-USER"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# Print customer and version
for DIR in $DIRS
do
    FULL_PATH="$CHECK_DIR/$DIR"
    WP_VERSION_FILE="$FULL_PATH/wp-includes/version.php"
    WP_CONFIG_FILE="$FULL_PATH/wp-config.php"

    # WP-folder?
    if [ -e "$WP_VERSION_FILE" ]; then
        CUSTOMER_WP_VERSION=$(grep -oP "wp_version = '\K(${VERSION_REGEX})" "${WP_VERSION_FILE}")
        DB_USER=$(grep -oP "DB_USER', '\K([a-zA-Z]*)" "${WP_CONFIG_FILE}")

        # Replace dots and pad right with spaces.
        # Then replace spaces with 0
        CV=$(printf "%-03s" ${CUSTOMER_WP_VERSION//.})
        CV=${CV// /0}
        WV=$(printf "%-03s" ${WP_VERSION//.})
        WV=${WV// /0}

        # CUSTOMER_VERSION -lt WORDPRESS_VERSION?
        if (( CV < WV )); then
            WP_VERSION_COLOR=$RED
        else
            WP_VERSION_COLOR=$GREEN
        fi

        # Check for BAD_USER
        shopt -s nocasematch
        case "$DB_USER" in
            $BAD_USER ) USER_COLOR=$RED;;
            *) USER_COLOR=$GREEN;;
        esac

        printf "%-${FIRST}s $WP_VERSION_COLOR%-${SECOND}s$RESET $USER_COLOR%s$RESET\n" ${DIR} ${CUSTOMER_WP_VERSION} ${DB_USER}
    fi
done

#!/bin/bash
clear

# Path to folder where we can find WP installs
CHECK_DIR=""

# Columns
FIRST=40  # Folder
SECOND=18 # Version
THIRD=20  # DB-user
FOURTH=20 # Suggested user

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
DIR_COUNT=$(echo "$DIRS" | wc -l)

# Print headers
HEADER[1]="Folders (total:$DIR_COUNT)"
HEADER[2]="Version ($WP_VERSION)"
HEADER[3]="DB-user"
HEADER[4]="Suggested user"
HEADER[5]="Pass"

printf "$BLUE%-${FIRST}s %-${SECOND}s %-${THIRD}s %-${FOURTH}s %s$RESET\n" "${HEADER[@]}"
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
        DB_NAME=$(grep -oP "DB_NAME', '\K([a-zA-Z]*)" "${WP_CONFIG_FILE}")
        DB_PASSWORD=$(grep -oP "DB_PASSWORD', '\K(.*)([^'\);])" "${WP_CONFIG_FILE}")

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
            $BAD_USER )
                USER_COLOR=$RED
                SUGGESTED_USER=${DB_NAME:0:16}
                PASSWORD_COLOR=$YELLOW
                SUGGESTED_PASSWORD=$(openssl rand -base64 32)
                SUGGESTED_PASSWORD=${SUGGESTED_PASSWORD//=/}
            ;;
            *)
                USER_COLOR=$GREEN
                SUGGESTED_USER="-"
                PASSWORD_COLOR=$WHITE
                SUGGESTED_PASSWORD=$DB_PASSWORD
            ;;
        esac

        ROW[1]="${DIR}"
        ROW[2]="${CUSTOMER_WP_VERSION}"
        ROW[3]="${DB_USER}"
        ROW[4]="${SUGGESTED_USER}"
        ROW[5]="${SUGGESTED_PASSWORD}"
        printf "%-${FIRST}s $WP_VERSION_COLOR%-${SECOND}s $USER_COLOR%-${THIRD}s $CYAN%-${FOURTH}s $PASSWORD_COLOR%s$RESET\n" "${ROW[@]}"

        COUNTER=$[$COUNTER +1]
    fi
done
    # Footer
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    printf "$YELLOW%-${FIRST}s$RESET\n" "WP-folders ($COUNTER)"

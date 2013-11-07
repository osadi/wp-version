#!/bin/bash
clear

#===Color Section====#
BLACK='\e[30;49m';
RED='\e[31;49m';
GREEN='\e[32;49m';
YELLOW='\e[33;49m';
BLUE='\e[34;49m';
MAGENTA='\e[35;49m';
CYAN='\e[36;49m';
WHITE='\e[37;49m';
#Reset colors.
RESET="\e[0m";

# Path to folder where we can find WP installs
CHECKDIR=""

DIRS=`ls -l $CHECKDIR | egrep '^d' | awk '{print $9}'`
WPVERSION=`curl -L -s http://wordpress.org/download/ | grep -E -o 'Version ([0-9]\.[0-9])(\.[0-9])?' | sed 's/Version //'`

# Print headers
printf "$BLUE%-40s Version (%s)$RESET\n" "Folder"  $WPVERSION
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# Print customer and version
for DIR in $DIRS
do
    FULLPATH="$CHECKDIR/$DIR"

    if [ -e "$FULLPATH/wp-includes/version.php" ]
    then
        VERSIONFILE="$FULLPATH/wp-includes/version.php"
        CUSTOMERVERSION=`grep '$wp_version =' ${VERSIONFILE} | awk '{print $3}' | sed 's/'\''\|;//g'`

        # Replace dots and pad right with spaces.
        # Then we replace spaces with 0
        CV=$(printf "%-03s" ${CUSTOMERVERSION//.})
        CV=${CV// /0}
        WV=$(printf "%-03s" ${WPVERSION//.})
        WV=${WV// /0}

        if (( CV < WV )); then
            TEXTCOLOR=$RED
        else
            TEXTCOLOR=$GREEN
        fi

        printf "%-40s $TEXTCOLOR%s$RESET\n" ${DIR} ${CUSTOMERVERSION}
    fi
done

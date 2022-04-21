#!/bin/bash

##################################################################
# discovery services to monitoring and run check for each
# see details in readme.md
##################################################################
# Using a terminal command i.e. "clear", in a script called from
# cron (no terminal) will trigger this error message.
# In your particular script, the smbmount command expects
# a terminal in which case the work-arounds above are appropriate.
##################################################################

#clear
echo started ...
echo '---------------------------'
cd $(dirname "$0")

MSMS_SERVICE_LIST=""

for service_ini  in $(ls ./services/*.ini); do
    if [[ "./services/common-reset-settings.ini" != "$service_ini" ]];then
	echo proceed $service_ini ...
        source ./lib/msms.sh "$1" "$service_ini"
	echo '---------------------------'
    fi
done

if [ -n "$MSMS_SERVICE_LIST" ]; then
  echo health-check-all \"$MSMS_SERVICE_LIST\" DAILY
  MESSAGE="$(cat ./templates/daily-4-all.txt)"
  MESSAGE=$(eval echo $MESSAGE)
  send_message_4_all "$MESSAGE"
  echo '---------------------------'
fi

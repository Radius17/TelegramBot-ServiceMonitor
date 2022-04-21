#!/bin/bash

#################################################################
# multi-service monitoring script:
# generic scipt for web service monitoring
# check service with curl, report alerts to telegram
#################################################################

echo $(date '+%Y-%m-%d %H:%M:%S')

# load functions file:
. ./lib/functions.sh
# load empty variables from .ini file:
. ./services/common-reset-settings.ini
# load variables from .ini file:
. $2

#################################################################
# daily alert for confirmation that monitoring itself is working
#################################################################
if test "$1" = "DAILY"; then
  echo health-check \"$MSMS_SERVICE_NAME\" DAILY
  MESSAGE="$(cat ./templates/daily.txt)"
  MESSAGE=$(eval echo $MESSAGE)
  send_message "$MESSAGE"

  if [ -n "$MSMS_SERVICE_NAME" ]; then
    if [ -n "$MSMS_SERVICE_LIST" ]; then
      MSMS_SERVICE_LIST=$MSMS_SERVICE_LIST", "$MSMS_SERVICE_NAME
    else
      MSMS_SERVICE_LIST=$MSMS_SERVICE_NAME
    fi
  fi
fi

#################################################################
# perform service check
#################################################################
if test "$1" != "DAILY"; then
  if [ -n "$MSMS_EXPECTED_FILE" ]; then
    MSMS_EXPECTED="$(cat "./services/$MSMS_EXPECTED_FILE")"
  fi
  # echo expected: "$MSMS_EXPECTED"

  RESPONSE="$(eval curl $MSMS_CURL_PARAMS \"$MSMS_SERVICE_ENDPOINT\")"
  EXIT_CODE=$?
  if [[ $EXIT_CODE != 0 ]]; then
    echo health-check \"$MSMS_SERVICE_NAME\" FAILED: CURL EXIT WITH $EXIT_CODE
    MESSAGE="$(cat ./templates/curl-fail.txt)"
    MESSAGE=$(eval echo $MESSAGE)
    send_message "$MESSAGE"
    send_message_4_all "$MESSAGE"
  elif [[ "$RESPONSE" != "$MSMS_EXPECTED" ]]; then
    if [ -n "$MSMS_EXPECTED_FILE" ]; then
      echo health-check \"$MSMS_SERVICE_NAME\" FAILED.
      MSMS_EXPECTED_FILE_REAL=$(basename "$MSMS_EXPECTED_FILE")
      MSMS_EXPECTED_FILE_REAL="~${MSMS_EXPECTED_FILE_REAL%.*}-real.${MSMS_EXPECTED_FILE_REAL##*.}"
      echo "$RESPONSE" > "$MSMS_EXPECTED_FILE_REAL"
      MESSAGE="$(cat ./templates/service-fail.txt)"
    else
      echo health-check \"$MSMS_SERVICE_NAME\" FAILED WITH RESPONSE: "$RESPONSE"
      MESSAGE="$(cat ./templates/service-fail-with-code.txt)"
    fi
    MESSAGE=$(eval echo $MESSAGE)
    send_message "$MESSAGE"
    send_message_4_all "$MESSAGE"
  else
    echo health-check \"$MSMS_SERVICE_NAME\": OK
  fi
fi

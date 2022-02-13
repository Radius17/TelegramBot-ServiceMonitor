#!/bin/bash

#################################################################
# multi-service monitoring script:
# generic scipt for web service monitoring
# check service with curl, report alerts to telegram
# (!) current directory should be "services"
#################################################################

# telegram endpoint
TG_API_URL="https://api.telegram.org/bot$(cat ../telegram-api-key.txt)/sendMessage"

#################################################################
# send message to telegram
# parameter: message text
# recipients chat id list should be in "recipients.txt" file
#################################################################
function send_message {
  if [ -f "$MSMS_RECIPIENTS" ]; then
    for chat_id in $(cat $MSMS_RECIPIENTS); do
#      echo
      f_letter=${chat_id:0:1}
      if [[ "$f_letter" != "#" ]]; then
        curl -s -X POST --connect-timeout 10 $TG_API_URL -d chat_id=$chat_id -d parse_mode="Markdown" -d text="$1" > /dev/null
      fi
    done
  else 
      echo "Custom recipients file absent: $MSMS_RECIPIENTS"
  fi
  
  for chat_id in $(cat common-recipients.txt); do
#    echo
    f_letter=${chat_id:0:1}
    if [[ "$f_letter" != "#" ]]; then
      curl -s -X POST --connect-timeout 10 $TG_API_URL -d chat_id=$chat_id -d parse_mode="Markdown" -d text="$1" > /dev/null
    fi
  done
}

#################################################################
# perform service check
#################################################################
echo
echo $(date '+%Y-%m-%d %H:%M:%S')

# load variables from .ini file:
. $2

# bash ./$2
# echo service name: "$MSMS_SERVICE_NAME"
# cd $(dirname "$0")
if [ -n "$MSMS_EXPECTED_FILE" ]; then
 MSMS_EXPECTED="$(cat "$MSMS_EXPECTED_FILE")"
fi
# echo expected: "$MSMS_EXPECTED"

RESPONSE="$(eval curl $MSMS_CURL_PARAMS \"$MSMS_SERVICE_ENDPOINT\")"
EXIT_CODE=$?
if [[ $EXIT_CODE != 0 ]]; then
  echo health-check \"$MSMS_SERVICE_NAME\" FAILED: CURL EXIT WITH $EXIT_CODE
  MESSAGE="$(cat ../templates/curl-fail.txt)"
  MESSAGE=$(eval echo $MESSAGE)
  send_message "$MESSAGE"
elif [[ "$RESPONSE" != "$MSMS_EXPECTED" ]]; then
  if [ -n "$MSMS_EXPECTED_FILE" ]; then
    echo health-check \"$MSMS_SERVICE_NAME\" FAILED.
    MSMS_EXPECTED_FILE_REAL=$(basename "$MSMS_EXPECTED_FILE")
    MSMS_EXPECTED_FILE_REAL="~${MSMS_EXPECTED_FILE_REAL%.*}-real.${MSMS_EXPECTED_FILE_REAL##*.}"
    echo "$RESPONSE" > "$MSMS_EXPECTED_FILE_REAL"
    MESSAGE="$(cat ../templates/service-fail.txt)"
  else
    echo health-check \"$MSMS_SERVICE_NAME\" FAILED WITH RESPONSE: "$RESPONSE"
    MESSAGE="$(cat ../templates/service-fail-with-code.txt)"
  fi
  MESSAGE=$(eval echo $MESSAGE)
  send_message "$MESSAGE"
else
  echo health-check \"$MSMS_SERVICE_NAME\": OK
fi

#################################################################
# daily alert for confirmation that monitoring itself is working
#################################################################
if test "$1" = "DAILY"; then
  echo health-check \"$MSMS_SERVICE_NAME\" DAILY
  MESSAGE="$(cat ../templates/daily.txt)"
  MESSAGE=$(eval echo $MESSAGE)
  send_message "$MESSAGE"
fi

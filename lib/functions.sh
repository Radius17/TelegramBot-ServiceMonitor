#!/bin/bash

#################################################################
# multi-service monitoring script:
# functions script for web service monitoring
#################################################################
# telegram endpoint
TG_API_URL="https://api.telegram.org/bot$(cat ./config/telegram-api-key.txt)/sendMessage"
#################################################################
# send message to telegram
# parameter: message text
# recipients chat id list should be in "recipients.txt" file
#################################################################
function send_message {
  if [ -f "./services/$MSMS_RECIPIENTS" ]; then
    for chat_id in $(cat ./services/$MSMS_RECIPIENTS); do
#      echo
      f_letter=${chat_id:0:1}
      if [[ "$f_letter" != "#" ]]; then
        curl -s -X POST --connect-timeout 10 $TG_API_URL -d chat_id=$chat_id -d parse_mode="Markdown" -d text="$1" > /dev/null
      fi
    done
  else
      echo "Custom recipients file absent: $MSMS_RECIPIENTS"
  fi
}
function send_message_4_all {
  for chat_id in $(cat ./services/common-recipients.txt); do
#    echo
    f_letter=${chat_id:0:1}
    if [[ "$f_letter" != "#" ]]; then
      curl -s -X POST --connect-timeout 10 $TG_API_URL -d chat_id=$chat_id -d parse_mode="Markdown" -d text="$1" > /dev/null
    fi
  done
}
#################################################################

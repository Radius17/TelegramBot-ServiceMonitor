# Multi-service monitoring script (MSMS)

## ABOUT
Simple script to monitore web services using native linux tools: bash, curl & cron, plus Telegram to deliver alerts.

## SETUP

### 1. CREATE TELEGRAM BOT
- find @botfather in telegram and follow instructions
- get api key for you bot from @botfather and put it into file: ```config/telegram-api-key.txt```

### 2. ADD RECIPIENTS
- recipient should find your bot in telegram and ```/start``` it
- then you can run ```./recipients-setup.sh``` and follow instructions
- common recipients for all services place into file: ```services/common-recipients.txt```
- you can temporary disable recipient by adding ```#``` as first character

### 3. CONFIGURE SERVICES TO MONITORE
- for each service create in folder "services" .ini file with 5 keys:
 - **MSMS_SERVICE_NAME** - human-readable name for service
 - **MSMS_SERVICE_ENDPOINT** - your service endpoint to check with curl
 - **MSMS_CURL_PARAMS** - parameters for curl, see example below
 - **MSMS_EXPECTED** or **MSMS_EXPECTED_FILE** - expected service response. Use **MSMS_EXPECTED_FILE** for long responses.
 - **MSMS_RECIPIENTS** - file with recipients chat ids
- example:
```
MSMS_SERVICE_NAME='my service'
MSMS_SERVICE_ENDPOINT='http://0.0.0.0'
MSMS_CURL_PARAMS='-s -X POST -H "Content-Type: application/json" --connect-timeout 3 -m 7 -d @request.json'
MSMS_EXPECTED='{"ok","true"}'
# MSMS_EXPECTED_FILE='my-service-response.json'
MSMS_RECIPIENTS='my-service-recipients.txt'
```
### 4. RUN ON SCHEDULE
- run: ```sudo crontab -e```
- to check service every 5 minutes and send alert if service unavailable or response unexpectedly, add line:
```
*/5 * * * * /PATH_TO_BOT/monitoring.sh >> /PATH_TO_BOT_LOG/monitoring.log 2>&1
```
- to enable alert every day at 10:00AM as confirmation that monitoring itself is alive, add line:
```
0 10 * * * /PATH_TO_BOT/monitoring.sh DAILY >> /PATH_TO_BOT_LOG/monitoring.log 2>&1
```
- run: ```sudo service cron reload```

multi-service monitoring script (MSMS)

SETUP

1. CREATE TELEGRAM BOT
- find @botfather in telegram and follow instructions
- get api key for you bot from @botfather and put it into file: telegram-api.key

2. ADD RECIPIENTS
- recipient should find your bot in telegram and /start it
- then run ./recipients-setup.sh and follow instruction

3. CONFIGURE SERVICES TO MONITORING
- for each service in folder "services" create .ini file with 5 keys:
 - MSMS_SERVICE_NAME: human-readable name for service
 - MSMS_SERVICE_ENDPOINT: your service endpoint to check with curl
 - MSMS_CURL_PARAMS: parameters for curl, see example below
 - MSMS_EXPECTED: expected service response
 - MSMS_RECIPIENTS: file with recipients chat ids
- example:
MSMS_SERVICE_NAME='my service'
MSMS_SERVICE_ENDPOINT='http://0.0.0.0'
MSMS_CURL_PARAMS='-s -X POST -H "Content-Type: application/json" --connect-timeout 3 -m 7 -d @request.json'
MSMS_EXPECTED='{"ok","true"}'
MSMS_RECIPIENTS='my-service-recipients.txt'

4. RUN ON SCHEDULE
- run: sudo crontab -e
- to check service every minute and send alert if service unavailable or response unexpectedly, add line:
*/1 * * * * /drclinics/bot/monitoring/monitoring.sh >> /drclinics/bot/monitoring/monitoring.log 2>&1
- to enable alert every day at 11:00AM as confirmation that monitoring itself is alive, add line:
0 11 * * * /drclinics/bot/monitoring.sh DAILY >> /drclinics/telemed/logs/monitoring.log 2>&1
- run: sudo service cron reload
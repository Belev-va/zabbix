#!/bin/bash

# Конфигурация
SLACK_BOT_TOKEN="xoxb-your_token"
CHANNEL_ID="channel_id"

# Получаем параметры от Zabbix
ALERT_SUBJECT="$1"
ALERT_MESSAGE="$2"
ALERT_SEVERITY="$3"

# Определяем эмоджи в зависимости от уровня
case "$ALERT_SEVERITY" in
  "Disaster") EMOJI=":fire:" ;;
  "High") EMOJI=":exclamation:" ;;
  "Warning") EMOJI=":warning:" ;;
  *) EMOJI=":grey_exclamation:" ;;
esac

# Проверяем наличие открытого треда (кешируем ID последнего треда)
THREAD_TS_FILE="/tmp/slack_last_thread_ts"
CURRENT_TIME=$(date +%s)

if [[ -f "$THREAD_TS_FILE" ]]; then
  LAST_THREAD_TS=$(cat "$THREAD_TS_FILE")
  THREAD_AGE=$((CURRENT_TIME - LAST_THREAD_TS))
  if [[ $THREAD_AGE -le 30 ]]; then
    THREAD_ARG="\"thread_ts\": \"$LAST_THREAD_TS\","
  else
    THREAD_ARG=""
    echo "$CURRENT_TIME" > "$THREAD_TS_FILE"
  fi
else
  echo "$CURRENT_TIME" > "$THREAD_TS_FILE"
  THREAD_ARG=""
fi

# Отправляем сообщение через Slack API
JSON_PAYLOAD=$(cat <<EOF
{
  "channel": "$CHANNEL_ID",
  $THREAD_ARG
  "text": "$EMOJI *$ALERT_SUBJECT* \n$ALERT_MESSAGE"
}
EOF
)

curl -X POST -H "Authorization: Bearer $SLACK_BOT_TOKEN" -H "Content-type: application/json" \
     --data "$JSON_PAYLOAD" "https://slack.com/api/chat.postMessage"

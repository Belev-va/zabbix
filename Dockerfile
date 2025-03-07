
FROM zabbix/zabbix-server-pgsql:latest

RUN apk update && apk add curl


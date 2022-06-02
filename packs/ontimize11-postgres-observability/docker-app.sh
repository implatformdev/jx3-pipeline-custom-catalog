#!/bin/bash
if [ -z "$GRAFANA_ADMIN_API_KEY" ]
then
  echo "DOCKER-APP.SH -> GET API KEY"
  key=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"ontimize", "role": "Admin"}' http://admin:admin@grafana:3000/api/auth/keys | grep -oP '"key":"?\K[^"}]+')

  if [ ! -z "$key" ]
  then
    echo "DOCKER-APP.SH -> SAVE API KEY"
    export GRAFANA_ADMIN_API_KEY="$key"
  fi
fi

echo "DOCKER-APP.SH -> CREATE DATASOURCE"
curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $GRAFANA_ADMIN_API_KEY" -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"browser","basicAuth":false}"' http://grafana:3000/api/datasources

echo "DOCKER-APP.SH -> COMPILE APP"
mvn clean install -P compose

echo "DOCKER-APP.SH -> RUN APP"
java -jar REPLACE_ME_APP_NAME-boot/target/REPLACE_ME_APP_NAME-boot.jar --spring.profiles.active=compose
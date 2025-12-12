#!/usr/bin/env sh

DEPLOYER_VERSION="1.0.0"
BONITA_ENVIRONMENT="Qualification"

mvn dependency:copy -Dartifact=com.bonitasoft.deployer:bonita-la-deployer:${DEPLOYER_VERSION}:jar \
 -Dmdep.stripClassifier \
 -DoutputDirectory=./

TARGET_URL="http://localhost:8080/bonita"
USERNAME="install"
PASSWORD="install"

#TARGET_URL="http://ec2-54-155-123-65.eu-west-1.compute.amazonaws.com:8081/bonita"
#USERNAME="tech_user"
#PASSWORD="secret"

java -jar bonita-la-deployer-${DEPLOYER_VERSION}.jar \
--development \
--bonita-configuration "target/bonita_application-Qualification.bconf \
--targetUrl ${TARGET_URL} \
--username ${USERNAME} \
--password ${PASSWORD} \
--file /target/bonita_application.zip

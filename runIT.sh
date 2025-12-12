#!/usr/bin/env sh


TARGET_URL="http://localhost:8080/bonita"
#USERNAME="install"
#PASSWORD="install"

echo "run tests"
cd ./IT
mvn clean verify -Dbonita.url=${TARGET_URL}

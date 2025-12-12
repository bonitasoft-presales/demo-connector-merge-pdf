#!/usr/bin/env sh

#PROJECT_FOLDER="${PWD}/.."
#INFRA_FOLDER="${PWD}"
#SCA_FOLDER="${PWD}/sca"
UIB_APPS_FOLDER="${PWD}/../../uib"
UIB_PROD_FOLDER="${PWD}/workspace"
#BONITA_ENVIRONMENT="presales"
ENV_FILE=${PWD}/.env

#copy uib files
rm -rf ${UIB_PROD_FOLDER}
mkdir -p ${UIB_PROD_FOLDER}
cp ${UIB_APPS_FOLDER}/*.json ${UIB_PROD_FOLDER}

docker login https://bonitasoft.jfrog.io

./stop.sh

docker-compose pull
docker-compose build
docker-compose up -d
#!/usr/bin/env sh

set -ev
# -e: Exit immediately if a command exits with a non-zero status
# -v: display command

PROJECT_FOLDER="${PWD}/.."
INFRA_FOLDER="${PWD}"
SCA_FOLDER="${PWD}/sca"
UIB_FOLDER="${SCA_FOLDER}/ui_builder"
BONITA_ENVIRONMENT="presales"
ENV_FILE=${SCA_FOLDER}/.env-local-laurent

#array=("bonitaSSO" "db" "mail" "UIB-macOs")
array=("bonita" "db" "mail" "UIB-macOs")
prefix=" -f ${SCA_FOLDER}/docker-compose-"
suffix=".yml"
joined_string=$(printf "${prefix}%s${suffix} " "${array[@]}")

# Remove trailing space
COMPOSE_FILES=${joined_string% }

# Print the result
echo "compose files: [${COMPOSE_FILES}]"

source ${ENV_FILE}

docker login bonitasoft.jfrog.io

# cleanup
docker compose ${COMPOSE_FILES} --env-file ${ENV_FILE} down -v --remove-orphans

# build SCA
docker image rm ${BONITA_PROJECT_NAME}:${BONITA_PROJECT_VERSION} || true  # Ignore failure of this command

cd ${PROJECT_FOLDER} || exit
./mvnw bonita-project:install

./mvnw clean package \
-Pdocker \
-Dbonita.environment=${BONITA_ENVIRONMENT} \
-Ddocker.baseImageRepository=bonitasoft.jfrog.io/docker-releases/bonita-subscription \
-Ddocker.imageName=${BONITA_PROJECT_NAME}:${BONITA_PROJECT_VERSION}

# build UIB app
rm -rf ${UIB_FOLDER}/production/ui_builder/workspace
mkdir -p ${UIB_FOLDER}/production/ui_builder/workspace
cp ${PROJECT_FOLDER}/uib/*.json ${UIB_FOLDER}/production/ui_builder/workspace
cd ${UIB_FOLDER}/production/ui_builder || exit
docker image rm ${UIB_PROJECT_NAME}:${UIB_PROJECT_VERSION} || true  # Ignore failure of this command

docker build --build-arg "BASE=${APPSMITH_BASE_IMAGE}" \
--platform linux/arm64 \
--build-arg "VERSION=${APPSMITH_VERSION}" \
--build-arg "WORKSPACE=./workspace/" \
-t ${UIB_PROJECT_NAME}:${UIB_PROJECT_VERSION} \
.

#check
docker compose ${COMPOSE_FILES} --env-file ${ENV_FILE} config

# start
docker compose ${COMPOSE_FILES} --env-file ${ENV_FILE} up -d

# wait server started
${INFRA_FOLDER}/healthz.sh

# add admin access to http
#echo "allow non http access to keycloak admin app"
docker exec keycloak sh /opt/keycloak/bonita_init/script_init.sh || true  # Ignore failure of this command

exit 0;

# run IT with smtp override
echo "run IT"
source ${ENV_FILE}
cd ${PROJECT_FOLDER} || exit
echo "running tests with BONITA_EXPOSED_PORT=${BONITA_EXPOSED_PORT} and EC2_PUBLIC_HOSTNAME=${EC2_PUBLIC_HOSTNAME}"
./mvnw clean verify -f ${PROJECT_FOLDER}/IT/pom.xml \
-Dbonita.url=http://${EC2_PUBLIC_HOSTNAME}:${BONITA_EXPOSED_PORT}/bonita \
-DSMTP_SERVER=localhost \
-DSMTP_PORT=2025
# Set the necessary variables
$PROJECT_FOLDER = (Get-Location).Path + "\.."
$INFRA_FOLDER = (Get-Location).Path
$SCA_FOLDER = (Get-Location).Path + "\sca"
$UIB_FOLDER = "${SCA_FOLDER}\ui_builder"
$IT_FOLDER = "${PROJECT_FOLDER}\IT"
$BONITA_ENVIRONMENT = "presales"
$ENV_FILE="${SCA_FOLDER}\.env-local-ale"

# Array of services
$array = @("bonita", "db", "mail", "UIB")
$prefix = " -f ${SCA_FOLDER}\docker-compose-"
$suffix = ".yml"
$joined_string = $array| ForEach-Object { "$prefix$_$suffix" }

# Remove trailing space
$COMPOSE_FILES = $joined_string -join " "

# Print the result
Write-Host "compose files: [$COMPOSE_FILES]"

# Load environment variables from .env file
Get-Content ${ENV_FILE} | ForEach-Object {
    if ($_ -match '^\s*(\w+)\s*=\s*(.*)\s*$') {
        Set-Variable -Name $matches[1] -Value $matches[2]
    }
}


# Docker login
docker login bonitasoft.jfrog.io

# Cleanup
#docker compose ${COMPOSE_FILES} --env-file ${ENV_FILE} down -v --remove-orphans
docker compose -f "${SCA_FOLDER}\docker-compose-bonita.yml" -f "${SCA_FOLDER}\docker-compose-db.yml" -f "${SCA_FOLDER}\docker-compose-mail.yml" -f "${SCA_FOLDER}\docker-compose-UIB.yml" --env-file "${SCA_FOLDER}\.env-local" down -v --remove-orphans

# Build SCA
docker image rm ${BONITA_PROJECT_NAME}:${BONITA_PROJECT_VERSION}

Set-Location -Path ${PROJECT_FOLDER}
mvn bonita-project:install

mvn clean package -P docker -D bonita.environment=${BONITA_ENVIRONMENT} -D docker.baseImageRepository=bonitasoft.jfrog.io/docker-releases/bonita-subscription -D docker.imageName="${BONITA_PROJECT_NAME}":"${BONITA_PROJECT_VERSION}"

# Build UIB app
Remove-Item -Recurse -Force "${UIB_FOLDER}\production\ui_builder\workspace"
New-Item -ItemType Directory -Force -Path "${UIB_FOLDER}\production\ui_builder\workspace"
Copy-Item -Path "${PROJECT_FOLDER}\uib\*.json" -Destination "${UIB_FOLDER}\production\ui_builder\workspace"

Set-Location -Path "${UIB_FOLDER}\production\ui_builder"
docker image rm "${UIB_PROJECT_NAME}:${UIB_PROJECT_VERSION}"

docker build  -t "${UIB_PROJECT_NAME}:${UIB_PROJECT_VERSION}" . --build-arg BASE=${APPSMITH_BASE_IMAGE} --build-arg VERSION=${APPSMITH_VERSION} --build-arg WORKSPACE=./workspace/

# Check
#docker compose ${COMPOSE_FILES} --env-file ${ENV_FILE} config
docker-compose -f "${SCA_FOLDER}\docker-compose-bonita.yml" -f "${SCA_FOLDER}\docker-compose-db.yml" -f "${SCA_FOLDER}\docker-compose-mail.yml" -f "${SCA_FOLDER}\docker-compose-UIB.yml" --env-file "${SCA_FOLDER}\.env-local" config
# Start
#docker compose ${COMPOSE_FILES} --env-file ${ENV_FILE} up -d
docker-compose -f "${SCA_FOLDER}\docker-compose-bonita.yml" -f "${SCA_FOLDER}\docker-compose-db.yml" -f "${SCA_FOLDER}\docker-compose-mail.yml" -f "${SCA_FOLDER}\docker-compose-UIB.yml" --env-file "${SCA_FOLDER}\.env-local" up -d

# Wait for server to start
& "${INFRA_FOLDER}\healthz.ps1"

## Add admin access to HTTP
##echo "allow non-http access to Keycloak admin app"
#docker exec keycloak sh /opt/keycloak/bonita_init/script_init.sh || $true  # Ignore failure of this command

## Run IT with SMTP override
#Write-Host "run IT"
#Set-Location -Path $PROJECT_FOLDER
#Write-Host "running tests with BONITA_EXPOSED_PORT=$BONITA_EXPOSED_PORT and EC2_PUBLIC_HOSTNAME=$EC2_PUBLIC_HOSTNAME"
#./mvnw clean verify -f "$PROJECT_FOLDER\IT\pom.xml" `
#    -Dbonita.url="http://$EC2_PUBLIC_HOSTNAME:$BONITA_EXPOSED_PORT/bonita" `
#    -DSMTP_SERVER="localhost" `
#    -DSMTP_PORT=2025

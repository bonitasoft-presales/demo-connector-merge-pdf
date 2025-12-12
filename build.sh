#!/usr/bin/env sh

BONITA_ENVIRONMENT="presales"

# get project version
BONITA_VERSION=$(mvn help:evaluate -Dexpression=bonita.runtime.version -q -DforceStdout)
echo "BONITA_VERSION=${BONITA_VERSION}" > ./bonita_version.properties

cat bonita_version.properties

# get bonita_la_builder lib
mvn dependency:copy -Dartifact=com.bonitasoft.tools:bonita-la-builder:${BONITA_VERSION}:jar:exec \
 -Dmdep.stripClassifier \
 -DoutputDirectory=.

# build project
java -jar ./bonita-la-builder-${BONITA_VERSION}.jar build \
-B \
-e ${BONITA_ENVIRONMENT} \
-o bonita_application.zip \
.

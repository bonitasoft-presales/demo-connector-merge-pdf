#!/bin/sh

set -euxo pipefail
BONITA_PATH=/opt/bonita

# original file
TEMPLATE_FOLDER=/opt/custom-config.d/template
# replaced with runtime value
CUSTOM_CONFIG_FOLDER=/opt/custom-config.d/parsed

cd ${BONITA_PATH} 

echo "SCRIPT INIT BONITA"
echo "Bonita host name: [${EC2_PUBLIC_HOSTNAME}]"

find setup/platform_conf/initial -name "*.properties" | xargs -n10 sed -i \
    -e 's/^#.*authentication.service.ref.name=.*/'"authentication.service.ref.name=passphraseOrPasswordAuthenticationService"'/'  \
    -e 's/^#.*authentication.service.ref.passphrase=.*/'"authentication.service.ref.passphrase=Bonita"'/' \
    -e 's/^#.*authentication.passphraseOrPasswordAuthenticationService.createMissingUser.enable=.*/'"authentication.passphraseOrPasswordAuthenticationService.createMissingUser.enable=true"'/' \
    -e 's/^#.*bonita.runtime.authentication.passphrase-or-password.create-missing-user.addDefaultMembership.enabled=.*/'"bonita.runtime.authentication.passphrase-or-password.create-missing-user.addDefaultMembership.enabled=false"'/' \
    -e 's/^#.*bonita.runtime.authentication.passphrase-or-password.create-missing-user.createUserGroupsAndRole.enabled=.*/'"bonita.runtime.authentication.passphrase-or-password.create-missing-user.createUserGroupsAndRole.enabled=true"'/'

#find conf -name "log4j2-loggers.xml" | xargs -n10 sed -i \
#-e '/^.*<\/Loggers>/ i\<Logger name="org.keycloak" level="ALL" \/>'  \
#-e '/^.*<\/Loggers>/ i\<Logger name="class org.keycloak" level="ALL" \/>'  \
#-e '/^.*<\/Loggers>/ i\<Logger name="com.bonitasoft.engine.authentication" level="ALL" \/>'  \
#-e '/^.*<\/Loggers>/ i\<Logger name="org.bonitasoft.console.common.server.auth" level="ALL" \/>'


echo "copy files from template folder"
mkdir -p ${CUSTOM_CONFIG_FOLDER}
cp -f ${TEMPLATE_FOLDER}/authenticationManager-config.properties  ${CUSTOM_CONFIG_FOLDER}/authenticationManager-config.properties
cp -f ${TEMPLATE_FOLDER}/keycloak-oidc.json  ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc.json
cp -f ${TEMPLATE_FOLDER}/keycloak-saml.xml ${CUSTOM_CONFIG_FOLDER}/keycloak-saml.xml
cp -f ${TEMPLATE_FOLDER}/security-config.properties ${CUSTOM_CONFIG_FOLDER}/security-config.properties
cp -f ${TEMPLATE_FOLDER}/user-creation-attribute-mapping-custom.properties ${CUSTOM_CONFIG_FOLDER}/user-creation-attribute-mapping-custom.properties
cp -f ${TEMPLATE_FOLDER}/user-creation-group-mapping.properties ${CUSTOM_CONFIG_FOLDER}/user-creation-group-mapping.properties
cp -f ${TEMPLATE_FOLDER}/user-creation-group-profile-mapping.properties ${CUSTOM_CONFIG_FOLDER}/user-creation-group-profile-mapping.properties

sed -i "s/{EC2_PUBLIC_HOSTNAME}/${EC2_PUBLIC_HOSTNAME}/g" ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc.json
sed -i "s/{BONITA_EXPOSED_PORT}/${BONITA_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc.json
sed -i "s/{KEYCLOAK_EXPOSED_PORT}/${KEYCLOAK_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc.json

# seems not used
#sed -i "s/{EC2_PUBLIC_HOSTNAME}/${EC2_PUBLIC_HOSTNAME}/g" ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc-with-discovery-to-rename.json
#sed -i "s/{BONITA_EXPOSED_PORT}/${BONITA_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc-with-discovery-to-rename.json
#sed -i "s/{KEYCLOAK_EXPOSED_PORT}/${KEYCLOAK_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc-with-discovery-to-rename.json

sed -i "s/{EC2_PUBLIC_HOSTNAME}/${EC2_PUBLIC_HOSTNAME}/g" ${CUSTOM_CONFIG_FOLDER}/authenticationManager-config.properties
sed -i "s/{BONITA_EXPOSED_PORT}/${BONITA_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/authenticationManager-config.properties
sed -i "s/{KEYCLOAK_EXPOSED_PORT}/${KEYCLOAK_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/authenticationManager-config.properties

sed -i "s/{EC2_PUBLIC_HOSTNAME}/${EC2_PUBLIC_HOSTNAME}/g" ${CUSTOM_CONFIG_FOLDER}/security-config.properties
sed -i "s/{BONITA_EXPOSED_PORT}/${BONITA_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/security-config.properties
sed -i "s/{KEYCLOAK_EXPOSED_PORT}/${KEYCLOAK_EXPOSED_PORT}/g" ${CUSTOM_CONFIG_FOLDER}/security-config.properties

cp -f ${CUSTOM_CONFIG_FOLDER}/authenticationManager-config.properties  setup/platform_conf/initial/tenant_template_portal/authenticationManager-config.properties
cp -f ${CUSTOM_CONFIG_FOLDER}/keycloak-oidc.json  setup/platform_conf/initial/tenant_template_portal/keycloak-oidc.json
cp -f ${CUSTOM_CONFIG_FOLDER}/keycloak-saml.xml setup/platform_conf/initial/tenant_template_portal/keycloak-saml.xml
cp -f ${CUSTOM_CONFIG_FOLDER}/security-config.properties setup/platform_conf/initial/platform_portal/security-config.properties
cp -f ${CUSTOM_CONFIG_FOLDER}/user-creation-attribute-mapping-custom.properties setup/platform_conf/initial/tenant_template_portal/user-creation-attribute-mapping-custom.properties
cp -f ${CUSTOM_CONFIG_FOLDER}/user-creation-group-mapping.properties setup/platform_conf/initial/tenant_template_portal/user-creation-group-mapping.properties
cp -f ${CUSTOM_CONFIG_FOLDER}/user-creation-group-profile-mapping.properties setup/platform_conf/initial/tenant_template_portal/user-creation-group-profile-mapping.properties

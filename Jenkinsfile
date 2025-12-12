node("bcd") {
    //toLowerCase() required - see to https://bonitasoft.atlassian.net/browse/RUNTIME-1807
   def bonitaEnvironment = "Qualification".toLowerCase()
  	// used to archive artifacts
  	def jobBaseName = "${env.JOB_NAME}".split('/').last()
  	// used to set build description and bcd_stack_id
  	def gitRepoName = "${env.JOB_NAME}".split('/')[1]
  	def normalizedGitRepoName = gitRepoName.toLowerCase().replaceAll('-','_')
  	// used to set bcd_stack_id
  	def branchName = env.BRANCH_NAME
  	def normalizedBranchName = branchName.toLowerCase().replaceAll('-','_')
    // used in steps, do not change
    def bconfFolder = '/home/bonita/bonita-continuous-delivery/bconf'
    // don't change
    def bonitaVersion
    def bonitaProjectVersion
    def bonitaProjectName
    def bonitaVersionShortened
    def bonitaVersionProperties
    def bonitaUrl
    def stackName
    def yamlStackProps
   	def privateDnsName
    def privateIpAddress
    def publicDnsName
  	def publicIpAddress
    def yamlFile = "${WORKSPACE}/props.yaml"
    def zip_files
    def bconf_file
    def bonitaDeployUrl
    def mergeBonitaArgs
    def inputBConf
    def ouputBConf
    def yamlInput
    // don't need to change until explicit issue
    def bonitaDeployerVersion='1.0.0'
    def bonitaAwsVersion = '1.6'
    def keyFileName = '~/.ssh/presale-ci-eu-west-1.pem'
    def keyName="presale-ci-eu-west-1"
    def securityGroup="bonitasoft_presales"
    ansiColor('xterm') {
    timestamps {
        stage("Checkout project") {
            checkout scm
            echo "jobBaseName: $jobBaseName"
            echo "gitRepoName: $gitRepoName"
            // NOTE: this is version of bonita runtime, not project version
            bonitaVersion = sh returnStdout: true, script: 'mvn help:evaluate -Dexpression=bonita.runtime.version -q -DforceStdout'
            // NOTE: project name comes from app sub project
            bonitaProjectName = sh returnStdout: true, script: 'mvn help:evaluate -f app/pom.xml -Dexpression=project.name -q -DforceStdout'
            //toLowerCase() required - see to https://bonitasoft.atlassian.net/browse/RUNTIME-1807
            bonitaProjectName = bonitaProjectName.toLowerCase()
            // NOTE: version is global in main pom.xml
            bonitaProjectVersion = sh returnStdout: true, script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout'
            bonitaVersionShortened= sh returnStdout: true, script:"echo ${bonitaVersion} | tr -d '.'D"
            bonitaVersionShortened=bonitaVersionShortened.trim()
            echo "bonitaVersion: [${bonitaVersion}]"
            echo "bonitaProjectName: [${bonitaProjectName}]"
            echo "bonitaProjectVersion: [${bonitaProjectVersion}]"
            echo "bonitaVersionShortened: [${bonitaVersionShortened}]"
            stackName = "${normalizedGitRepoName}_${normalizedBranchName}_${bonitaVersionShortened}"
            echo "stackName: [${stackName}]"
        }
        stage("Create Bonita Runtime") {
            sh """
mvn dependency:copy \
-Dartifact=com.bonitasoft.presales.aws:bonita-aws:${bonitaAwsVersion}:jar:jar-with-dependencies \
-DoutputDirectory=.
"""
       	    sh """
java -jar bonita-aws-${bonitaAwsVersion}-jar-with-dependencies.jar \
-c create \
--stack-id ${stackName} \
 --name ${stackName} \
 --key-name ${keyName} \
 --security-group ${securityGroup} \
 ${stackName}.yaml ${WORKSPACE}
"""
            yamlStackProps = readYaml file: "${WORKSPACE}/${stackName}.yaml"
            privateDnsName = yamlStackProps.privateDnsName
            privateIpAddress = yamlStackProps.privateIpAddress
            echo "privateDnsName: [${privateDnsName}]" 
            echo "privateIp: [${privateIpAddress}]"
            // ensure ip is added in known hosts
            // keep bcd build stage with stack create, to ensure SSHd is up & running on created stack
            sh """
# ensure file file exists
touch /home/jenkins/.ssh/known_hosts
# clean previous record
ssh-keygen -R ${privateDnsName}
ssh-keygen -R ${privateIpAddress}
ssh -o StrictHostKeyChecking=no -i ~/.ssh/presale-ci-eu-west-1.pem  ubuntu@${privateDnsName} ls
ssh -o StrictHostKeyChecking=no -i ~/.ssh/presale-ci-eu-west-1.pem  ubuntu@${privateIpAddress} ls
"""
            sh """
cd ~/ansible
ansible-playbook bonita.yaml -i ${WORKSPACE}/private-inventory-${stackName}.yaml -e "bonita_version=${bonitaVersion}"
"""
             bonitaUrl = "http://${yamlStackProps.publicDnsName}:8081/bonita/login.jsp"
             currentBuild.description = "<a href='${bonitaUrl}'>${stackName}</a>"
        }
        stage("Build Bonita project") {
            sh """
mvn clean package -Dbonita.environment=${bonitaEnvironment}
"""
        }
        stage('Configure parameters') {
            sh """
mvn bonita-project:extract-configuration \
-Dbonita.environment=${bonitaEnvironment} \
-Dbonita.parametersFile=${WORKSPACE}/originalParams.yml \
-Dparameters.overwrite=true
cat ${WORKSPACE}/originalParams.yml
"""
            echo "yamlFile set to set server URL: ${yamlFile}"
            if( fileExists(yamlFile)) {
                echo "remove existing file ${yamlFile}"
                sh "rm $yamlFile"
            }
            def yamlProps = [:]
            yamlProps.global_parameters=[ [ name:'serverUrl',type:'String',value:"http://${yamlStackProps.publicDnsName}:8081/bonita"]]
            writeYaml file:yamlFile, data:yamlProps
            sh """
mvn bonita-project:merge-configuration \
-Dbonita.configurationFile="${WORKSPACE}/app/target/${bonitaProjectName}-${bonitaProjectVersion}-${bonitaEnvironment}—.bconf" \
-Dbonita.environment="${bonitaEnvironment}" \
-Dbonita.parametersFile="${yamlFile}"
"""
            zip_files = "${WORKSPACE}/app/target/${bonitaProjectName}-${bonitaProjectVersion}-${bonitaEnvironment}.zip"
            bconf_file = "${WORKSPACE}/app/target/${bonitaProjectName}-${bonitaProjectVersion}-${bonitaEnvironment}.bconf"
            def bConfArg = ""
            if(bconf_file && bconf_file){
               //TODO
            }
        }
        stage('Deploy Bonita applications') {
          sh """
mvn dependency:copy -Dartifact=com.bonitasoft.deployer:bonita-la-deployer:${bonitaDeployerVersion}:jar \
-Dmdep.stripClassifier \
-DoutputDirectory=./
"""
          sh """
java -jar bonita-la-deployer-${bonitaDeployerVersion}.jar \
--development \
--bonita-configuration "${WORKSPACE}/app/target/${bonitaProjectName}-${bonitaProjectVersion}-${bonitaEnvironment}.bconf" \
--targetUrl http://${yamlStackProps.privateDnsName}:8081/bonita \
--username install \
--password install \
--file "${WORKSPACE}/app/target/${bonitaProjectName}-${bonitaProjectVersion}-${bonitaEnvironment}.zip"
"""
        }
        stage('Run tests') {
            sh """
 cd ${WORKSPACE}/IT
 mvn clean verify -Dbonita.url=http://${yamlStackProps.privateDnsName}:8081/bonita
 """
         }
        stage('Archive artifacts') {
            archiveArtifacts artifacts: "app/target/*.zip, *.yaml"
        }
    } // timestamps
    } // ansiColor
} // node

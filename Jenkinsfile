#!/usr/bin/env groovy

// Used Jenkins plugins:
// * Pipeline GitHub Notify Step Plugin
// * Disable GitHub Multibranch Status Plugin - https://github.com/bluesliverx/disable-github-multibranch-status-plugin
//
// $OCP_HOSTNAME -- hostname of running Openshift cluster
// $OCP_USER     -- Openshift user
// $OCP_PASSWORD -- Openshift user's password

def prepareTests() {

	// wipeout workspace
	deleteDir()

	dir('oshinko-s2i') {
		checkout scm
	}

	// check golang version
	sh('go version')

	// download oc client
	dir('client') {
		sh('curl -LO https://github.com/openshift/origin/releases/download/v1.5.1/openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz')
		sh('curl -LO https://github.com/openshift/origin/releases/download/v1.5.1/openshift-origin-server-v1.5.1-7b451fc-linux-64bit.tar.gz')
		sh('tar -xzf openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz')
		sh('tar -xzf openshift-origin-server-v1.5.1-7b451fc-linux-64bit.tar.gz')
		sh('cp openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit/oc .')
		sh('cp openshift-origin-server-v1.5.1-7b451fc-linux-64bit/* .')
	}

	// login to openshift instance
	sh('oc login https://$OCP_HOSTNAME:8443 -u $OCP_USER -p $OCP_PASSWORD --insecure-skip-tls-verify=true')
	// let's start on a specific project, to prevent start on a random project which could be deleted in the meantime
	sh('oc project testsuite')
}

def buildUrl

node {
	stage('init') {
		// generate build url
		buildUrl = sh(script: 'curl https://url.corp.redhat.com/new?$BUILD_URL', returnStdout: true)
		githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'This change is being built', status: 'PENDING', targetUrl: buildUrl)
	}
}


try {
	parallel testEphemeral: {
		node {
			stage('Test ephemeral')
					{
						withEnv(["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client", "S2I_TEST_INTEGRATED_REGISTRY=docker-registry-default.$OCP_HOSTNAME", "TEST_ONLY=1"]) {

							prepareTests()

							// run tests
							dir('oshinko-s2i') {
								sh('make test-ephemeral | tee -a test-ephemeral.log')
							}
						}
					}
		}
	}, testPysparkTemplates: {
		node {
			stage('Test pyspark-templates')
					{
						withEnv(["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client", "S2I_TEST_INTEGRATED_REGISTRY=docker-registry-default.$OCP_HOSTNAME", "TEST_ONLY=1"]) {

							prepareTests()

							// run tests
							dir('oshinko-s2i') {
								sh('make test-pyspark-templates | tee -a test-pyspark-templates.log')
							}
						}
					}
		}
	}, testJavaTemplates: {
		node {
			stage('Test java-templates')
					{
						withEnv(["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client", "S2I_TEST_INTEGRATED_REGISTRY=docker-registry-default.$OCP_HOSTNAME", "TEST_ONLY=1"]) {

							prepareTests()

							// run tests
							dir('oshinko-s2i') {
								sh('make test-java-templates | tee -a test-java-templates.log')
							}
						}
					}
		}
	}, testScalaTemplates: {
		node {
			stage('Test scala-templates')
					{
						withEnv(["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client", "S2I_TEST_INTEGRATED_REGISTRY=docker-registry-default.$OCP_HOSTNAME", "TEST_ONLY=1"]) {

							prepareTests()

							// run tests
							dir('oshinko-s2i') {
								sh('make test-scala-templates | tee -a test-scala-templates.log')
							}
						}
					}
		}
	}
} catch (err) {
	githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'There are test failures', status: 'FAILURE', targetUrl: buildUrl)
	throw err
} finally {
	dir('oshinko-s2i') {
		archiveArtifacts(allowEmptyArchive: true, artifacts: '*.log')
	}
}

githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'This change looks good', status: 'SUCCESS', targetUrl: buildUrl)



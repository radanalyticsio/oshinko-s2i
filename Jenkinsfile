#!/usr/bin/env groovy

// Used Jenkins plugins:
// * Pipeline GitHub Notify Step Plugin
// * Disable GitHub Multibranch Status Plugin - https://github.com/bluesliverx/disable-github-multibranch-status-plugin
//

// This script expect following environment variables to be set:
//
// $OCP_HOSTNAME -- hostname of running Openshift cluster
// $OCP_USER     -- Openshift user
// $OCP_PASSWORD -- Openshift user's password
//
// $EXTERNAL_DOCKER_REGISTRY 			-- address of a docker registry
// $EXTERNAL_DOCKER_REGISTRY_USER		-- username to use to authenticate to specified docker registry
// $EXTERNAL_DOCKER_REGISTRY_PASSWORD   -- password/token to use to authenticate to specified docker registry

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
		sh('curl -LO https://github.com/openshift/origin/releases/download/v3.7.0/openshift-origin-client-tools-v3.7.0-7ed6862-linux-64bit.tar.gz')
		sh('curl -LO https://github.com/openshift/origin/releases/download/v3.7.0/openshift-origin-server-v3.7.0-7ed6862-linux-64bit.tar.gz')
		sh('tar -xzf openshift-origin-client-tools-v3.7.0-7ed6862-linux-64bit.tar.gz')
		sh('tar -xzf openshift-origin-server-v3.7.0-7ed6862-linux-64bit.tar.gz')
		sh('cp openshift-origin-client-tools-v3.7.0-7ed6862-linux-64bit/oc .')
		sh('cp openshift-origin-server-v3.7.0-7ed6862-linux-64bit/* .')
	}

	// login to openshift instance
	sh('oc login https://$OCP_HOSTNAME:8443 -u $OCP_USER -p $OCP_PASSWORD --insecure-skip-tls-verify=true')
	// let's start on a specific project, to prevent start on a random project which could be deleted in the meantime
	sh('oc project testsuite')
}


def buildUrl
def globalEnvVariables = ["S2I_TEST_EXTERNAL_REGISTRY=$EXTERNAL_DOCKER_REGISTRY", "S2I_TEST_EXTERNAL_USER=$EXTERNAL_DOCKER_REGISTRY_USER", "S2I_TEST_EXTERNAL_PASSWORD=$EXTERNAL_DOCKER_REGISTRY_PASSWORD", "TEST_ONLY=1"]


node {
	stage('init') {
		// generate build url
		buildUrl = sh(script: 'curl https://url.corp.redhat.com/new?$BUILD_URL', returnStdout: true)
		try {
			githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'This change is being built', status: 'PENDING', targetUrl: buildUrl)
		} catch (err) {
			echo("Wasn't able to notify Github: ${err}")
		}
	}
}

parallel testEphemeral: {
	node {
		stage('Test ephemeral') {
			withEnv(globalEnvVariables + ["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client"]) {

				try {
					prepareTests()

					// run tests
					dir('oshinko-s2i') {
						sh('make test-ephemeral | tee -a test-ephemeral.log && exit ${PIPESTATUS[0]}')
					}
				} catch (err) {
					try {
						githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'There are test failures', status: 'FAILURE', targetUrl: buildUrl)
					} catch (errNotify) {
						echo("Wasn't able to notify Github: ${errNotify}")
					}
					throw err
				} finally {
					dir('oshinko-s2i') {
						archiveArtifacts(allowEmptyArchive: true, artifacts: 'test-ephemeral.log')
					}
				}
			}
		}
	}
}, testPysparkTemplates: {
	node {
		stage('Test pyspark-templates') {
			withEnv(globalEnvVariables + ["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client"]) {

				try {
					prepareTests()

					// run tests
					dir('oshinko-s2i') {
						sh('make test-pyspark-templates | tee -a test-pyspark-templates.log && exit ${PIPESTATUS[0]}')
					}
				} catch (err) {
					try {
						githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'There are test failures', status: 'FAILURE', targetUrl: buildUrl)
					} catch (errNotify) {
						echo("Wasn't able to notify Github: ${errNotify}")
					}
					throw err
				} finally {
					dir('oshinko-s2i') {
						archiveArtifacts(allowEmptyArchive: true, artifacts: 'test-pyspark-templates.log')
					}
				}
			}
		}
	}
}, testJavaTemplates: {
	node {
		stage('Test java-templates') {
			withEnv(globalEnvVariables + ["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client"]) {

				try {
					prepareTests()

					// run tests
					dir('oshinko-s2i') {
						sh('make test-java-templates | tee -a test-java-templates.log && exit ${PIPESTATUS[0]}')
					}
				} catch (err) {
					try {
						githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'There are test failures', status: 'FAILURE', targetUrl: buildUrl)
					} catch (errNotify) {
						echo("Wasn't able to notify Github: ${errNotify}")
					}
					throw err
				} finally {
					dir('oshinko-s2i') {
						archiveArtifacts(allowEmptyArchive: true, artifacts: 'test-java-templates.log')
					}
				}
			}
		}
	}
}, testScalaTemplates: {
	node {
		stage('Test scala-templates') {
			withEnv(globalEnvVariables + ["GOPATH=$WORKSPACE", "KUBECONFIG=$WORKSPACE/client/kubeconfig", "PATH+OC_PATH=$WORKSPACE/client"]) {
				try {
					prepareTests()

					// run tests
					dir('oshinko-s2i') {
						sh('make test-scala-templates | tee -a test-scala-templates.log && exit ${PIPESTATUS[0]}')
					}
				} catch (err) {
					try {
						githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'There are test failures', status: 'FAILURE', targetUrl: buildUrl)
					} catch (errNotify) {
						echo("Wasn't able to notify Github: ${errNotify}")
					}
					throw err
				} finally {
					dir('oshinko-s2i') {
						archiveArtifacts(allowEmptyArchive: true, artifacts: 'test-scala-templates.log')
					}
				}
			}
		}
	}
}

try {
	githubNotify(context: 'jenkins-ci/oshinko-s2i', description: 'This change looks good', status: 'SUCCESS', targetUrl: buildUrl)
} catch (err) {
	echo("Wasn't able to notify Github: ${err}")
}



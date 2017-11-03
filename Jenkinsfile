node {
    properties([
        [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '15']]
    ])

    stage('Checkout') {
        checkout scm
    }

    stage('Gradle Build') {
        dir('yang-lsp') {
            try {
                sh "./gradlew clean build copyDist createLocalMavenRepo --refresh-dependencies --continue"
            } finally {
                step([$class: 'JUnitResultArchiver', testResults: '**/build/test-results/test/*.xml'])
            }
        }
    }
    if (env.BRANCH_NAME == 'master') {
        build '../yangster/master', wait: false
	build '../yang-eclipse/master', wait: false
    }
    archive 'yang-lsp/build/**, '
}

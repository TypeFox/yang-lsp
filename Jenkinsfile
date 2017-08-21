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

    archive 'yang-lsp/build/**, '
}

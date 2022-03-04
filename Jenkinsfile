/*******************************************************************************
 * Copyright (c) 2012-2017 TypeFox GmbH and itemis AG.
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *   Moritz Eysholdt - Initial contribution and API
 *******************************************************************************/

pipeline {
  agent {
    kubernetes {
      inheritFrom 'centos-7'
    }
  }
  options {
    buildDiscarder(logRotator(numToKeepStr:'15'))
    disableConcurrentBuilds()
    timeout(time: 120, unit: 'MINUTES')
  }
  triggers {
    cron(env.BRANCH_NAME == 'master' ? 'H 2 * * *' : '')
    githubPush()
  }

  tools {
    maven 'apache-maven-3.8.4'
    jdk 'temurin-jdk8-latest'
  }

  environment {
    MAVEN_EXTRA_PARAMS = '--batch-mode --update-snapshots -fae -Dmaven.repo.local=xpect-local-maven-repository -DtestOnly=false'
  }

  stages {
    stage('prepare workspace') {
        steps {
        step([$class: 'WsCleanup'])
        // we need to live with detached head, or we need to adjust settings:
        // https://issues.jenkins-ci.org/browse/JENKINS-42860
        checkout scm
        }
    }
    stage('log configuration') {
        steps {
        echo('===== checking tools versions =====')
        sh '''\
               git config --get remote.origin.url
               git reset --hard
               pwd
               ls -la
               mvn -v
               java -version
           '''
        echo('===================================')
        }
    }
    stage('compile with Eclipse Luna and Xtext 2.9.2') {
        steps {
        sh "mvn -P!tests -Declipsesign=true -Dtarget-platform=eclipse_4_4_2-xtext_2_9_2 ${MAVEN_EXTRA_PARAMS} clean install"
        archiveArtifacts artifacts: 'org.eclipse.xpect.releng/p2-repository/target/repository/**/*.*,org.eclipse.xpect.releng/p2-repository/target/org.eclipse.xpect.repository-*.zip'
        }
    }

    stage('test with Eclipse Luna and Xtext 2.9.2') {
      steps {
        wrap([$class: 'Xvnc', takeScreenshot: false, useXauthority: true]) {
          sh "mvn -P!plugins -P!xtext-examples -Dtarget-platform=eclipse_4_4_2-xtext_2_9_2 ${MAVEN_EXTRA_PARAMS} clean integration-test"
        }
      }
    }

    stage('test with Eclipse Mars and Xtext 2.14') {
      steps {
        wrap([$class: 'Xvnc', takeScreenshot: false, useXauthority: true]) {
          sh "mvn -P!plugins -P!xtext-examples -Dtarget-platform=eclipse_4_5_0-xtext_2_14_0 ${MAVEN_EXTRA_PARAMS} clean integration-test"
        }
      }
    }

    stage('test with Eclipse 2020-06 and Xtext nighly') {
      steps {
        wrap([$class: 'Xvnc', takeScreenshot: false, useXauthority: true]) {
          sh "mvn -P!plugins -P!xtext-examples -Dtarget-platform=eclipse_2020_06-xtext_nightly ${MAVEN_EXTRA_PARAMS} clean integration-test"
        }
      }
    }

    stage('deploy nightly') {
      when {
        expression { env.BRANCH_NAME?.toLowerCase() == 'master' }
      }
      steps {
        withCredentials([file(credentialsId: 'secret-subkeys.asc', variable: 'KEYRING')]) {
          sh '''
                rm -r xpect-local-maven-repository
                gpg --batch --import "${KEYRING}"
                for fpr in $(gpg --list-keys --with-colons  | awk -F: '/fpr:/ {print $10}' | sort -u);
                do
                    echo -e "5\ny\n" | gpg --batch --command-fd 0 --expert --edit-key $fpr trust;
                done
                '''
          sh "mvn -P!tests -P maven-publish -Dtarget-platform=eclipse_4_4_2-xtext_2_9_2 ${MAVEN_EXTRA_PARAMS} clean deploy"
        }
      }
    }

    stage('deploy release') {
      when {
        expression { env.BRANCH_NAME?.toLowerCase()?.startsWith('release_') }
      }
      steps {
        withCredentials([file(credentialsId: 'secret-subkeys.asc', variable: 'KEYRING')]) {
          sh '''
                rm -r xpect-local-maven-repository
                gpg --batch --import "${KEYRING}"
                for fpr in $(gpg --list-keys --with-colons  | awk -F: '/fpr:/ {print $10}' | sort -u);
                do
                    echo -e "5\ny\n" | gpg --batch --command-fd 0 --expert --edit-key $fpr trust;
                done
                '''
          sh "mvn -P!tests -P!xtext-examples -P maven-publish -Dtarget-platform=eclipse_4_4_2-xtext_2_9_2 ${MAVEN_EXTRA_PARAMS} clean deploy"
        }
      }
    }
  }
  post {
    always {
      junit testResults: '**/TEST-*.xml'
    }
  }
}

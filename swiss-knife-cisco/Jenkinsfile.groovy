@Library(['thor-shared-pipelines'])

// Build Artifact name based on the branch it's being built from
def buildArtifactName() {
  def artifactBaseName = env.ARTIFACT_NAME
  def branchName = env.GIT_BRANCH.replaceAll('origin/', '')
  def artifactName

  // Replace any characters not allowed in filenames with underscores
  def safeBranchName = branchName.replaceAll('[^A-Za-z0-9_-]', '_').toLowerCase()
  artifactName = "${artifactBaseName}:${safeBranchName}-${currentBuild.number}"

  return artifactName
}

pipeline {
  agent {
    label 'base'
  }

  options {
    buildDiscarder(
      logRotator(
        numToKeepStr: '10'
      )
    )
    instanceType('t3.xlarge')
    instanceExecutors('1')
    disableConcurrentBuilds()
    timestamps()
  }

  environment {
    // Used for sending Private Webex notification if the SonarQube Quality Gate fails
    BRANCH_NAME = env.GIT_BRANCH.replaceAll('origin/', '')
    GIT_GENERIC_CREDS = 'sift-reporting-gen-github'
    KMS_ARN = 'arn:aws:kms:us-west-2:563853376529:key/f44a726f-5674-4c6a-8f70-8120e0f25643'
    AWS_ACC_PROD = '563853376529'
    AWS_ACC_STAGE = '072824598875'
    AWS_ROLE = 'jenkins-sift-cdaas'
    SL_AWS_CREDS_ID = 'sl-login-creds'
    AWS_REGION = 'us-west-2'
    AWS_ECR_REPO = "dkr.ecr.${env.AWS_REGION}.amazonaws.com"
    ARTIFACT_NAME = 'china/generic'

//    ARTIFACTORY_URL = 'artifactory.stg-umbrellagov.com'
//    ARTIFACTORY_REPO = 'sift-docker-local'
//    CHINA_DEV_ECR = '114040874283.dkr.ecr.cn-northwest-1.amazonaws.com.cn'
//    CHINA_AWS_REGION = 'cn-northwest-1'
  }

  stages {

    stage('Checkout repo code with tags') {
      steps {
        script {
          def scmVars = checkout([
            $class                           : 'GitSCM',
            branches                         : scm.branches,
            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
            extensions                       : scm.extensions + [[$class: 'CloneOption', noTags: false, reference: '', shallow: false]],
            userRemoteConfigs                : scm.userRemoteConfigs
          ])
          env.GIT_COMMIT_HASH = scmVars.GIT_COMMIT.substring(0, 8)
          sh "echo ${GIT_COMMIT_HASH}"
          currentBuild.displayName = "#${currentBuild.number}/${env.BRANCH_NAME}/${GIT_COMMIT_HASH}"
        }
      }
    }

    stage('Build Image') {
      steps {
        withAWS(
          roleAccount: env.AWS_ACC_PROD,
          role: env.AWS_ROLE,
          region: env.AWS_REGION
        ) {
          script { artifactName = buildArtifactName() }
          sh """#!/usr/bin/env bash
                bash -x
//                curl -sS -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
//                mv cosign-linux-amd64 cosign
//                chmod +x cosign
                aws ecr get-login-password --region us-west-2 | docker login -u AWS --password-stdin https://563853376529.dkr.ecr.us-west-2.amazonaws.com/
                echo "Starting docker build!..🚧"
                cd swiss-knife-cisco/swiss-knife
                ls -al
                docker build -f Dockerfile --no-cache -t ${artifactName} .
            """
        }
      }
    }

    stage('Tag and push to Commercial staging ECR') {
      steps {
        script {
          withChecks('Docker upload - Staging ECR') {
            withAWS(
              roleAccount: env.AWS_ACC_STAGE,
              role: env.AWS_ROLE,
              region: env.AWS_REGION
            ) {
              echo "Artifact name: ${artifactName}"
              def exitCode = sh(script: """#!/usr/bin/env bash
                    set -e
                    echo "==========================="
                    echo "Uploading Docker image!..📤"
                    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^"
                    aws ecr get-login-password --region us-west-2 | docker login -u AWS --password-stdin https://${env.AWS_ACC_STAGE}.dkr.ecr.us-west-2.amazonaws.com/
                    docker tag ${artifactName} ${env.AWS_ACC_STAGE}.dkr.ecr.us-west-2.amazonaws.com/${artifactName}
                    docker push ${env.AWS_ACC_STAGE}.dkr.ecr.us-west-2.amazonaws.com/${artifactName}
                  """, returnStatus: true)
              if (exitCode == 0) {
                echo "Docker image!..📤 uploaded to Staging ECR"
              } else {
                error "Docker image!..📤 upload failed to Staging ECR"
              }
            }
          }
        }
      }
    }

    stage('Tag and push to Prod ECR') {
      steps {
        script {
          withChecks('Docker upload - Prod ECR') {
            withAWS(
              roleAccount: env.AWS_ACC_PROD,
              role: env.AWS_ROLE,
              region: env.AWS_REGION
            ) {
              echo "Artifact name: ${artifactName}"
              def exitCode = sh(script: """#!/usr/bin/env bash
                    set -e
                    echo "==========================="
                    echo "Uploading Docker image!..📤"
                    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^"
                    aws ecr get-login-password --region us-west-2 | docker login -u AWS --password-stdin https://${env.AWS_ACC_PROD}.dkr.ecr.us-west-2.amazonaws.com/
                    docker tag ${artifactName} ${env.AWS_ACC_PROD}.dkr.ecr.us-west-2.amazonaws.com/${artifactName}
                    docker push ${env.AWS_ACC_PROD}.dkr.ecr.us-west-2.amazonaws.com/${artifactName}
                  """, returnStatus: true)
              if (exitCode == 0) {
                echo "Docker image!..📤 uploaded to Prod ECR"
              } else {
                error "Docker image!..📤 upload failed to Prod ECR"
              }
            }
          }
        }
      }
    }

  }

  post {
    success {
      script {
        echo "Build finished successfully!"
      }
    }

    failure {
      script {
        echo "Build failed!"
      }
    }

    cleanup {
      script {
        sh 'docker system prune --force --all'
      }
      cleanWs()
    }
  }
}
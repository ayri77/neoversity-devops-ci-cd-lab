pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
      envFrom:
        - configMapRef:
            name: jenkins-pipeline-config

    - name: git
      image: alpine/git:latest
      imagePullPolicy: Always
      command:
        - cat
      tty: true
      envFrom:
        - configMapRef:
            name: jenkins-pipeline-config

    - name: trivy
      image: aquasec/trivy:0.72.0
      imagePullPolicy: IfNotPresent
      command:
        - cat
      tty: true
      envFrom:
        - configMapRef:
            name: jenkins-pipeline-config
'''
    }
  }

  environment {
    AWS_REGION    = 'eu-central-1'
    IMAGE_TAG     = "v1.0.${BUILD_NUMBER}"

    GITOPS_REPO   = 'github.com/ayri77/neoversity-devops-gitops.git'
    GITOPS_BRANCH = 'main'
    GITOPS_VALUES = 'charts/django-app/values.yaml'
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context="${WORKSPACE}/docker/django" \
              --dockerfile="${WORKSPACE}/docker/django/Dockerfile" \
              --destination="${ECR_REPOSITORY_URL}:${IMAGE_TAG}" \
              --cache=true
          '''
        }
      }
    }

    stage('Scan Docker Image') {
      steps {
        container('trivy') {
          sh '''
            trivy image \
              --scanners vuln \
              --severity CRITICAL \
              --ignore-unfixed \
              --exit-code 1 \
              --no-progress \
              --timeout 15m \
              "${ECR_REPOSITORY_URL}:${IMAGE_TAG}"
          '''
        }
      }
    }

    stage('Update GitOps Repository') {
      steps {
        container('git') {
          withCredentials([
            usernamePassword(
              credentialsId: 'github-token',
              usernameVariable: 'GITHUB_USERNAME',
              passwordVariable: 'GITHUB_TOKEN'
            )
          ]) {
            sh '''
              rm -rf gitops-repository

              git clone \
                --branch "${GITOPS_BRANCH}" \
                "https://${GITOPS_REPO}" \
                gitops-repository

              cd gitops-repository

              sed -i \
                "s|^  repository:.*|  repository: ${ECR_REPOSITORY_URL}|" \
                "${GITOPS_VALUES}"

              sed -i \
                "s|^  tag:.*|  tag: \"${IMAGE_TAG}\"|" \
                "${GITOPS_VALUES}"

              grep -E "repository:|tag:" "${GITOPS_VALUES}"

              git config user.name "Jenkins CI"
              git config user.email "jenkins@localhost"

              git add "${GITOPS_VALUES}"

              REPOSITORY_NAME="${ECR_REPOSITORY_URL##*/}"

              if git diff --cached --quiet; then
                echo "GitOps values already contain ${IMAGE_TAG}"
              else
                git commit \
                  -m "Deploy ${REPOSITORY_NAME}:${IMAGE_TAG}"

                set +x
                git push \
                  "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${GITOPS_REPO}" \
                  "HEAD:${GITOPS_BRANCH}"
              fi
            '''
          }
        }
      }
    }
  }
}

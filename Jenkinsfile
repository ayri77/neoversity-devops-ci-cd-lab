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
'''
    }
  }

  environment {
    AWS_REGION  = 'eu-central-1'
    ECR_REGISTRY = '487337210313.dkr.ecr.eu-central-1.amazonaws.com'
    IMAGE_NAME   = 'lesson-8-ecr'
    IMAGE_TAG    = 'latest'
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context="${WORKSPACE}/docker/django" \
              --dockerfile="${WORKSPACE}/docker/django/Dockerfile" \
              --destination="${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" \
              --cache=true
          '''
        }
      }
    }
  }
}
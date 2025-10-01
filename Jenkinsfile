// SWE645 Assignment 2 - Jenkinsfile for CI/CD Pipeline
// Authors: Divyanshi Detroja (G01522554), Yashwanth Katanguri (G01514418), Aditi Srivastava (G01525340)
// This Jenkinsfile defines the CI/CD pipeline for building and deploying the student survey application

pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE_NAME = 'studentsurvey645'
        DOCKER_TAG = "${BUILD_TIMESTAMP}"
        KUBERNETES_NAMESPACE = 'swe645-assignment'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code from Git repository'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image with timestamp tag'
                script {
                    def imageName = "${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    sh "docker build -t ${imageName} ."
                    sh "docker tag ${imageName} ${DOCKER_HUB_CREDENTIALS_USR}/${imageName}"
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                echo 'Pushing Docker image to DockerHub'
                script {
                    def imageName = "${DOCKER_HUB_CREDENTIALS_USR}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${imageName}"
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes cluster'
                script {
                    def imageName = "${DOCKER_HUB_CREDENTIALS_USR}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    
                    // Update deployment with new image
                    sh "kubectl set image deployment/student-survey-app student-survey=${imageName} -n ${KUBERNETES_NAMESPACE}"
                    
                    // Wait for rollout to complete
                    sh "kubectl rollout status deployment/student-survey-app -n ${KUBERNETES_NAMESPACE}"
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment status'
                script {
                    sh "kubectl get pods -n ${KUBERNETES_NAMESPACE}"
                    sh "kubectl get services -n ${KUBERNETES_NAMESPACE}"
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Docker image: ${DOCKER_HUB_CREDENTIALS_USR}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Cleaning up workspace'
            cleanWs()
        }
    }
}

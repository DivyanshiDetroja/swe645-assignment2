pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'divyanshidetroja/studentsurvey645'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/DivyanshiDetroja/swe645-assignment2.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-creds') {
                        def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                        image.push()
                        image.push('0.1')
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
    steps {
        script {
            withCredentials([file(credentialsId: 'kubeconfig-id', variable: 'KUBECONFIG')]) {
                sh 'export KUBECONFIG=$KUBECONFIG'
                sh 'kubectl apply -f k8s/k8s-deployment.yaml'
                sh 'kubectl apply -f k8s/k8s-service.yaml'
                sh 'kubectl rollout status deployment/studentsurvey-app'
            }
        }
    }
}
    }
}
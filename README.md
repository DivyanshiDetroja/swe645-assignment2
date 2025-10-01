# SWE645 Assignment 2 - Containerized Student Survey Application

**Authors:** Divyanshi Detroja (G01522554), Yashwanth Katanguri (G01514418), Aditi Srivastava (G01525340)  
**Course:** SWE645 - Spring 2025  
**Assignment:** Containerization, Kubernetes Deployment, and CI/CD Pipeline

## Overview

This project containerizes the Student Survey Web Application developed in Homework 1 using Docker, deploys it on Kubernetes with Rancher, and establishes a CI/CD pipeline using Jenkins. The application runs with a minimum of 3 pods for scalability and resiliency.

## Application URLs

- **AWS Homepage:** [To be updated after deployment]
- **Kubernetes Application:** [To be updated after deployment]

## Project Structure

```
A2-SWE645/
├── index.html              # Main survey form
├── error.html              # Error page
├── styles.css              # Application styles
├── gmu_cec_logo.png        # GMU logo
├── gmu.jpg                 # GMU image
├── Dockerfile              # Docker container configuration
├── Jenkinsfile             # CI/CD pipeline configuration
├── k8s-deployment.yaml     # Kubernetes deployment manifests
└── README.md               # This documentation
```

## Prerequisites

### Required Software
- Docker Desktop
- Git
- AWS Account
- DockerHub Account
- Jenkins
- kubectl

### AWS Services Used
- EC2 Instances (for Rancher and Jenkins)
- Load Balancer (for Kubernetes service)
- IAM (for EC2 instance management)

## Installation and Setup Instructions

### 1. Git Repository Setup

1. Create a new repository on GitHub or BitBucket
2. Initialize Git in your project directory:
   ```bash
   git init
   git add .
   git commit -m "Initial commit - SWE645 Assignment 2"
   git remote add origin <your-repository-url>
   git push -u origin main
   ```

### 2. Docker Setup and Image Creation

#### 2.1 Install Docker Desktop
- Download and install Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
- Create an account on [DockerHub](https://hub.docker.com/)

#### 2.2 Build Docker Image
```bash
# Build the Docker image
docker build -t studentsurvey645:0.1 .

# Test the image locally
docker run -it -p 8182:8080 studentsurvey645:0.1
```

Access the application at: `http://localhost:8182`

#### 2.3 Push to DockerHub
```bash
# Login to DockerHub
docker login -u <your-dockerhub-username>

# Tag the image
docker tag studentsurvey645:0.1 <your-dockerhub-username>/studentsurvey645:0.1

# Push to DockerHub
docker push <your-dockerhub-username>/studentsurvey645:0.1
```

### 3. AWS Rancher Setup

#### 3.1 Create EC2 Instance for Rancher
1. Log into AWS Console
2. Navigate to EC2 → Launch Instance
3. Choose Ubuntu Server 20.04 LTS AMI
4. Select t2.medium instance type (minimum requirement for Rancher)
5. Configure Security Group:
   - SSH (22): Your IP
   - HTTP (80): 0.0.0.0/0
   - HTTPS (443): 0.0.0.0/0
6. Launch instance and save the key pair

#### 3.2 Install Docker on EC2
```bash
# SSH into your instance
ssh -i <your-key.pem> ubuntu@<public-ip>

# Update system
sudo apt-get update

# Install Docker
sudo apt install docker.io

# Verify installation
docker -v

# Add user to docker group
sudo usermod -aG docker ubuntu
```

#### 3.3 Install Rancher
```bash
# Run Rancher container
sudo docker run --privileged=true -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher

# Wait for Rancher to start (1-2 minutes)
# Access Rancher UI at: http://<public-ip>
```

#### 3.4 Configure Rancher
1. Set admin password
2. Accept terms and conditions
3. Set Rancher server URL

### 4. Kubernetes Cluster Setup

#### 4.1 Create IAM User for Rancher
1. Go to AWS IAM → Users → Add User
2. Enable Programmatic Access
3. Attach policy: AdministratorAccess
4. Save Access Key and Secret Key

#### 4.2 Create Node Template in Rancher
1. In Rancher UI, go to Cluster Management
2. Click "Add Cluster" → Amazon EC2
3. Create Node Template:
   - AWS Access Key: [Your Access Key]
   - AWS Secret Key: [Your Secret Key]
   - Region: us-east-1
   - Instance Type: t2.medium
   - Use Rancher's recommended AMI

#### 4.3 Create Cluster
1. Configure cluster:
   - Name: swe645-cluster
   - etcd: 1 node
   - Control Plane: 1 node
   - Worker: 2 nodes
2. Click "Create"
3. Wait for cluster provisioning (10-15 minutes)

### 5. Deploy Application to Kubernetes

#### 5.1 Update Deployment Configuration
Edit `k8s-deployment.yaml` and replace `your-dockerhub-username` with your actual DockerHub username.

#### 5.2 Deploy to Kubernetes
```bash
# Apply the deployment
kubectl apply -f k8s-deployment.yaml

# Check deployment status
kubectl get pods -n swe645-assignment
kubectl get services -n swe645-assignment
```

#### 5.3 Access Application
1. Get the LoadBalancer URL from Rancher UI
2. Access application at: `http://<loadbalancer-url>`

### 6. Jenkins Setup

#### 6.1 Create EC2 Instance for Jenkins
1. Launch another Ubuntu EC2 instance (t2.medium)
2. Configure Security Group:
   - SSH (22): Your IP
   - HTTP (8080): Your IP
3. Install required software:

```bash
# SSH into Jenkins instance
ssh -i <your-key.pem> ubuntu@<jenkins-public-ip>

# Update system
sudo apt-get update

# Install Docker
sudo apt install docker.io
sudo usermod -aG docker ubuntu

# Install JDK 11
sudo apt install openjdk-11-jdk

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins

# Install kubectl
sudo apt install snapd
sudo snap install kubectl --classic

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

#### 6.2 Configure Jenkins
1. Access Jenkins at: `http://<jenkins-public-ip>:8080`
2. Get initial admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
3. Install suggested plugins
4. Create admin user

#### 6.3 Install Required Jenkins Plugins
- BitBucket Plugin
- Docker Plugin
- Build Timestamp Plugin
- Kubernetes Plugin

#### 6.4 Configure kubectl for Jenkins
```bash
# Switch to Jenkins user
sudo su jenkins

# Create .kube directory
mkdir -p /var/lib/jenkins/.kube

# Copy kubeconfig from Rancher
# (Get kubeconfig from Rancher UI → Cluster → Kubeconfig File)
# Paste content to: /var/lib/jenkins/.kube/config

# Verify kubectl access
kubectl config current-context
```

#### 6.5 Configure Jenkins Credentials
1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Add DockerHub credentials:
   - Kind: Username with password
   - ID: docker-hub-credentials
   - Username: [Your DockerHub username]
   - Password: [Your DockerHub password]

### 7. CI/CD Pipeline Configuration

#### 7.1 Create Jenkins Pipeline
1. Jenkins → New Item → Pipeline
2. Configure pipeline:
   - Name: swe645-student-survey-pipeline
   - Build Triggers: Poll SCM (H/1 * * * *) - checks every minute
   - Pipeline: Pipeline script from SCM
   - SCM: Git
   - Repository URL: [Your Git repository URL]
   - Script Path: Jenkinsfile

#### 7.2 Test Pipeline
1. Make a small change to your code
2. Commit and push to Git repository
3. Jenkins will automatically trigger the pipeline
4. Monitor build progress in Jenkins UI

## Testing and Verification

### 1. Local Testing
```bash
# Test Docker image locally
docker run -p 8182:8080 studentsurvey645:0.1
# Access: http://localhost:8182
```

### 2. Kubernetes Testing
```bash
# Check pod status
kubectl get pods -n swe645-assignment

# Check service status
kubectl get services -n swe645-assignment

# Check application logs
kubectl logs -f deployment/student-survey-app -n swe645-assignment
```

### 3. CI/CD Pipeline Testing
1. Make a code change
2. Commit and push to Git
3. Verify Jenkins pipeline execution
4. Check new image in DockerHub
5. Verify Kubernetes deployment update

## Troubleshooting

### Common Issues

1. **Docker Build Fails**
   - Check Dockerfile syntax
   - Ensure all files are in the correct directory
   - Verify base image availability

2. **Kubernetes Deployment Fails**
   - Check image name and tag
   - Verify namespace exists
   - Check resource limits

3. **Jenkins Pipeline Fails**
   - Verify Git repository access
   - Check DockerHub credentials
   - Ensure kubectl is properly configured

4. **Application Not Accessible**
   - Check LoadBalancer status
   - Verify security group rules
   - Check pod health

### Useful Commands

```bash
# Docker commands
docker images
docker ps
docker logs <container-id>

# Kubernetes commands
kubectl get all -n swe645-assignment
kubectl describe pod <pod-name> -n swe645-assignment
kubectl logs <pod-name> -n swe645-assignment

# Jenkins commands
sudo systemctl status jenkins
sudo systemctl restart jenkins
```

## References

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Rancher Documentation](https://rancher.com/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

## Video Recording

A detailed video recording demonstrating the setup and working of the application will be provided as part of the submission.

## Submission Checklist

- [ ] Source code files
- [ ] Dockerfile
- [ ] Jenkinsfile
- [ ] Kubernetes YAML files
- [ ] README with setup instructions
- [ ] Video recording
- [ ] AWS URLs for homepage and application
- [ ] All files properly commented with author information

---

**Note:** Replace all placeholder values (like `<your-dockerhub-username>`, `<your-repository-url>`, etc.) with your actual values before deployment.

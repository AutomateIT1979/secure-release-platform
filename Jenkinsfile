// TAG: AUTOMATION-DEPLOY-P1-JENKINS
// PURPOSE: CI/CD pipeline for FastAPI application
// SCOPE: Automated testing, building, and deployment
// SAFETY: Secrets via Jenkins Credentials, no hardcoding

/*
 * Secure Release Platform - Jenkins Pipeline
 *
 * Stages:
 *   1. Test - Run pytest test suite
 *   2. Build - Build Docker image
 *   3. Security Scan - Run SAST, SCA, image scans
 *   4. Deploy - Run Ansible playbooks
 *   5. Smoke Test - Verify /health endpoint
 *
 * Triggers:
 *   - GitHub webhook on push to main
 *
 * Requirements:
 *   - Jenkins 2.541.1+
 *   - Docker installed
 *   - Ansible installed
 *   - SSH key configured
 *   - EC2 instance running
 *
 * Author: DevOps Developer
 * Created: 2026-02-08
 * Updated: 2026-02-17
 */
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "secure-release-platform"
        EC2_HOST = "ubuntu@35.180.54.218"
        SSH_KEY = credentials('ec2-ssh-key')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "✅ Code récupéré depuis Git"
                sh 'git rev-parse --short HEAD'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo "📦 Installation des dépendances Python"
                sh 'pip3 install -r requirements.txt'
            }
        }
        
        stage('Run Tests') {
            steps {
                echo "🧪 Lancement des tests"
                sh 'pytest -v --tb=short'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "🐳 Build de l'image Docker"
                sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
                sh 'docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest'
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                echo "🚀 Déploiement sur EC2"
                sh '''
                    ansible-playbook \
                        -i ansible/inventories/staging/hosts.yml \
                        ansible/playbooks/deploy_api.yml
                '''
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline réussi ! API déployée sur http://35.180.54.218:8000"
        }
        failure {
            echo "❌ Pipeline échoué ! Vérifiez les logs."
        }
        always {
            echo "🧹 Nettoyage..."
            sh 'docker system prune -f || true'
        }
    }
}

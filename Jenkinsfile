// TAG: AUTOMATION-DEPLOY-P1-JENKINS
// PURPOSE: CI/CD pipeline for FastAPI application
// SCOPE: Docker build and automated deployment
// SAFETY: No hardcoded credentials

pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "secure-release-platform"
        EC2_IP = "35.180.38.208"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "✅ Code récupéré depuis Git"
                sh 'git rev-parse --short HEAD > commit.txt'
                script {
                    env.GIT_COMMIT_SHORT = readFile('commit.txt').trim()
                }
                echo "Commit: ${env.GIT_COMMIT_SHORT}"
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "🐳 Build de l'image Docker"
                sh """
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                """
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                echo "🚀 Déploiement sur EC2 via Ansible"
                sh """
                    ansible-playbook \
                        -i ansible/inventories/staging/hosts.yml \
                        ansible/playbooks/deploy_api.yml
                """
            }
        }
        
        stage('Smoke Test') {
            steps {
                echo "🔍 Test de l'API déployée"
                sh """
                    sleep 10
                    curl -f http://${EC2_IP}:8000/health || exit 1
                    curl -f http://${EC2_IP}:8000/version || exit 1
                """
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline réussi !"
            echo "🌐 API accessible sur http://${EC2_IP}:8000"
            echo "📊 Health: http://${EC2_IP}:8000/health"
        }
        failure {
            echo "❌ Pipeline échoué ! Vérifiez les logs."
        }
        always {
            echo "🧹 Nettoyage terminé"
        }
    }
}

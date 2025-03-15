pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'kiranitth/sample-app:latest'
        EC2_HOST = 'ubuntu@54.147.223.231'
        SSH_KEY = credentials('deployment-server-key')
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    // Build the application
                    sh 'mvn clean package'

                    // Run tests
                    sh '/opt/maven/bin/mvn test'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Build Docker image
                    sh 'docker build -t ${DOCKER_IMAGE} .'

                    // Login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                        sh 'echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin'
                    }

                    // Push the Docker image to Docker Hub
                    sh 'docker push ${DOCKER_IMAGE}'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: [SSH_KEY]) {
                    script {
                        // SSH into EC2 and run deployment commands
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} << 'EOF'
                            echo "Stopping existing container if running..."
                            docker stop sample-app || true
                            docker rm sample-app || true

                            echo "Pulling latest Docker image..."
                            docker pull ${DOCKER_IMAGE}

                            echo "Checking if port 8080 is free..."
                            netstat -tulnp | grep :8080 && echo "Port 8080 is in use, stopping previous process..." && fuser -k 8080/tcp || echo "Port is free"

                            echo "Starting new container..."
                            docker run -d -p 80:8080 --name sample-app ${DOCKER_IMAGE} && echo "Container started!"
                        EOF
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up or any post steps if needed
            echo 'Pipeline finished.'
        }
    }
}

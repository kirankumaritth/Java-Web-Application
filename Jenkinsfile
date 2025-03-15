pipeline {
    agent any

    environment {
        MAVEN_HOME = "/opt/maven"
        PATH = "$MAVEN_HOME/bin:$PATH"
        
        DOCKER_IMAGE = 'kiranitth/sample-app'
        DOCKER_TAG = 'latest'
        DEPLOY_SERVER = 'ubuntu@54.147.223.231'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    git branch: 'master', 
                        credentialsId: 'GitHub-Creds',
                        url: 'https://github.com/kirankumaritth/simple-java-maven-app.git'
                }
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    sh '$MAVEN_HOME/bin/mvn clean package'
                    sh '$MAVEN_HOME/bin/mvn test'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .'

                    withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_HUB_PASSWORD')]) {
                        sh 'echo $DOCKER_HUB_PASSWORD | docker login -u kiranitth --password-stdin'
                    }

                    sh 'docker push ${DOCKER_IMAGE}:${DOCKER_TAG}'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['deployment-server-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $DEPLOY_SERVER '
                    echo "Stopping existing container if running..."
                    docker stop sample-app || true
                    docker rm sample-app || true
                    
                    echo "Pulling latest Docker image..."
                    docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}

                    echo "Checking if port 8080 is free..."
                    netstat -tulnp | grep :8080 && echo "Port 8080 is in use, stopping previous process..." && fuser -k 8080/tcp || echo "Port is free"

                    echo "Starting new container..."
                    docker run -d -p 8081:8080 --name sample-app ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '
                    """
                }
            }
        }
    }
}

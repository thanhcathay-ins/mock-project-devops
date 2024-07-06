pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'haivt-dockerhub-user-pass'
        DOCKER_IMAGE_NAME = 'haivutuan93/demo-java-app'
        KUBECONFIG_PATH = '/var/jenkins_home/.kube/config' // Đường dẫn tới kubeconfig trong container Jenkins
        CLUSTER_NAME = 'docker-desktop'
    }

    stages {
        stage('Load Env') {
            steps {
                script {
                    loadEnv()
                }
            }
        }

        stage('Build') {
            steps {
                sh 'echo Building...'
                sh 'mvn clean install'
            }
        }

        stage('Set Docker Image Tag') {
            steps {
                script {
                    setDockerImageTag()
                }
            }
        }

        stage('Build Image') {
            steps {
                script {
                    buildDockerImage()
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    pushDockerImage()
                }
            }
        }

        stage('Update Deployment YAML') {
            steps {
                script {
                    updateDeploymentYaml()
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                script {
                    deployToK8s()
                }
            }
        }
    }
}

def loadEnv() {
    // Load file .env
    def envFileContent = readFile '.env'
    def envVars = envFileContent.split('\n')
    for (line in envVars) {
        if (line.trim()) {
            def parts = line.split('=')
            def key = parts[0].trim()
            def value = parts[1].trim()
            env."${key}" = value
        }
    }
}

def setDockerImageTag() {
    env.GIT_COMMIT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    env.DOCKER_IMAGE_TAG = "1.0.${env.BUILD_NUMBER}-${env.GIT_COMMIT}" // Sử dụng số build và Git commit SHA
}

def buildDockerImage() {
    sh 'echo Building Docker Image...'
    sh """
    docker build -t ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG} --build-arg JAR_FILE=target/demo-0.0.1-SNAPSHOT.jar .
    """
}

def pushDockerImage() {
    docker.withRegistry('', env.DOCKER_CREDENTIALS_ID) {
        sh 'echo Pushing Docker Image...'
        sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG}"
    }
}

def updateDeploymentYaml() {
    def yaml = readFile(file: 'k8s/deployment-service.yaml')
    def newYaml = yaml.replaceAll(/\$\{DOCKER_IMAGE_NAME\}/, "${env.DOCKER_IMAGE_NAME}")
            .replaceAll(/\$\{DOCKER_IMAGE_TAG\}/, "${env.DOCKER_IMAGE_TAG}")
    echo "Updated YAML: ${newYaml}"
    writeFile(file: 'k8s/deployment-service.yaml', text: newYaml)
}

def deployToK8s() {
    withEnv(["KUBECONFIG=${env.KUBECONFIG_PATH}"]) {
        sh """
        kubectl config use-context ${env.CLUSTER_NAME}
        kubectl apply -f k8s/deployment-service.yaml
        """
    }
}
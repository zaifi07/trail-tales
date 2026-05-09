pipeline {

    agent any

    environment {

        // Docker image + container
        IMAGE_NAME = "trailtales-second-app"
        CONTAINER_NAME = "trailtales-second-container"

        // App Port Mapping
        HOST_PORT = "5003"
        CONTAINER_PORT = "5003"

        // GitHub Repo
        GIT_REPO = "https://github.com/zaifi07/trail-tales.git"

    }

    triggers {
        githubPush()
    }

    stages {

        // ---------------------------------------------------
        // Checkout Source Code
        // ---------------------------------------------------
        stage('Checkout Code') {
            steps {

                git branch: 'master',
                    url: "${GIT_REPO}"

                script {

                    // Get latest committer email
                    env.COMMITTER_EMAIL = sh(
                        script: "git log -1 --pretty=format:'%ae'",
                        returnStdout: true
                    ).trim()

                    // Get commit author name
                    env.COMMITTER_NAME = sh(
                        script: "git log -1 --pretty=format:'%an'",
                        returnStdout: true
                    ).trim()

                    // Get commit message
                    env.COMMIT_MESSAGE = sh(
                        script: "git log -1 --pretty=format:'%s'",
                        returnStdout: true
                    ).trim()

                    echo "Committer Email: ${env.COMMITTER_EMAIL}"
                }
            }
        }

        // ---------------------------------------------------
        // Build Docker Image
        // ---------------------------------------------------
        stage('Build Docker Image') {

            steps {

                sh """
                    docker build -t ${IMAGE_NAME}:latest .
                """
            }
        }

        // ---------------------------------------------------
        // Stop Existing Container
        // ---------------------------------------------------
        stage('Remove Old Container') {

            steps {

                sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                """
            }
        }

        // ---------------------------------------------------
        // Run New Container
        // ---------------------------------------------------
        stage('Run Container') {

            steps {

                sh """
                    docker run -d \
                    --name ${CONTAINER_NAME} \
                    -p ${HOST_PORT}:${CONTAINER_PORT} \
                    --restart unless-stopped \
                    ${IMAGE_NAME}:latest
                """
            }
        }

        // ---------------------------------------------------
        // Health Check
        // ---------------------------------------------------
        stage('Application Health Check') {

            steps {

                script {

                    sleep 20

                    sh """
                        curl --fail http://15.207.26.84:${HOST_PORT}/api/health
                    """
                }
            }
        }
    }

    // -------------------------------------------------------
    // Notifications
    // -------------------------------------------------------
    post {

        success {

            emailext(
                subject: "✅ Deployment Successful - TrailTales",
                body: """
Hello ${env.COMMITTER_NAME},

Your latest commit has been successfully deployed.

--------------------------------------------------

Commit Message:
${env.COMMIT_MESSAGE}

Application Status:
LIVE ✅

Server:
http://YOUR_EC2_PUBLIC_IP:${HOST_PORT}

--------------------------------------------------

Regards,
Jenkins CI/CD Pipeline
""",
                to: "${env.COMMITTER_EMAIL}"
            )
        }

        failure {

            emailext(
                subject: "❌ Deployment Failed - TrailTales",
                body: """
Hello ${env.COMMITTER_NAME},

Your latest commit failed during build/deployment.

--------------------------------------------------

Commit Message:
${env.COMMIT_MESSAGE}

Application Status:
FAILED ❌

Please check Jenkins console logs.

--------------------------------------------------

Regards,
Jenkins CI/CD Pipeline
""",
                to: "${env.COMMITTER_EMAIL}"
            )
        }
    }
}

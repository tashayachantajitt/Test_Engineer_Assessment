pipeline {
    agent any 

    stages {
        stage('Checkout Code From Git') {
            steps {
                git branch: 'main', url: 'https://github.com/tashayachantajitt/Test_Engineer_Assessment.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing required Python libraries from requirements.txt...'
                bat 'pip install -r requirements.txt'
            }
        }

        stage('Run Web & API Tests') {
            steps {
                echo 'Executing Pytest for Web and API assignments...'
                bat 'pytest -v Assignment_02_Web/ Assignment_03_API/'
            }
        }

        stage('Run Mobile Automate') {
            steps {
                echo 'Executing Robot Framework for Mobile assignment...'
                bat 'robot -d results Assignment_04_Mobile/*.robot'
            }
        }

        stage('Send Result To Jenkins') {
            steps {
                echo 'Publishing Test Reports to Jenkins UI...'
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'results',
                    reportFiles: 'report.html',
                    reportName: 'Robot Framework Report'
                ])
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'results/*.*', fileNamePrepend: 'build_result_'
            echo 'Pipeline execution finished.'
        }
    }
}
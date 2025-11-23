pipeline {
    agent any
    
    environment {
        PROJECT_NAME = 'debian-webserver'
        COMPOSE_FILE = 'podman-compose.yml'
        GIT_REPO = 'https://github.com/lukaszbee/html-pipline.git'
        GIT_BRANCH = 'main'
    }
    
    stages {
        stage('Cleanup Workspace') {
            steps {
                echo '🧹 Czyszczenie workspace...'
                cleanWs()
            }
        }
        
        stage('Checkout') {
            steps {
                echo '📥 Pobieranie kodu z GitHub...'
                echo "Repository: ${GIT_REPO}"
                echo "Branch: ${GIT_BRANCH}"
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}"
            }
        }
        
        stage('Stop Old Containers') {
            steps {
                echo '🛑 Zatrzymywanie starych kontenerów...'
                sh '''
                    podman-compose -f ${COMPOSE_FILE} down || true
                    podman rm -f ${PROJECT_NAME} || true
                '''
            }
        }
        
        stage('Build Image') {
            steps {
                echo '🔨 Budowanie obrazu Debian + Nginx...'
                sh '''
                    podman build -t ${PROJECT_NAME}:latest -f Dockerfile .
                '''
            }
        }
        
        stage('Deploy Container') {
            steps {
                echo '🚀 Uruchamianie kontenera...'
                sh '''
                    podman-compose -f ${COMPOSE_FILE} up -d
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '✅ Weryfikacja wdrożenia...'
                sh '''
                    echo "📋 Sprawdzanie uruchomionych kontenerów:"
                    podman ps | grep ${PROJECT_NAME} || echo "❌ Kontener nie został znaleziony!"
                    
                    echo ""
                    echo "📝 Logi kontenera:"
                    podman logs ${PROJECT_NAME} --tail=20
                    
                    echo ""
                    echo "🌐 Test dostępności strony:"
                    sleep 2
                    curl -s -o /dev/null -w "Status HTTP: %{http_code}\\n" http://localhost:9000 || echo "❌ Nie można połączyć się ze stroną"
                '''
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline zakończony sukcesem!'
            echo '🌐 Strona dostępna na: http://localhost:9000'
        }
        failure {
            echo '❌ Pipeline zakończony błędem!'
            sh '''
                echo "📝 Ostatnie logi kontenera:"
                podman logs ${PROJECT_NAME} --tail=50 || true
            '''
        }
        always {
            echo '🧹 Sprzątanie zakończone'
        }
    }
}

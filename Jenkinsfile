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
                    echo "📋 Sprawdzanie kontenerów:"
                    podman ps | grep ${PROJECT_NAME}
                    
                    echo ""
                    echo "📊 Status kontenera:"
                    CONTAINER_STATUS=$(podman inspect ${PROJECT_NAME} --format '{{.State.Status}}')
                    echo "Status: $CONTAINER_STATUS"
                    
                    echo ""
                    echo "💚 Health check:"
                    HEALTH_STATUS=$(podman inspect ${PROJECT_NAME} --format '{{.State.Health.Status}}' || echo "unknown")
                    echo "Health: $HEALTH_STATUS"
                    
                    echo ""
                    echo "🔌 Mapowanie portów:"
                    podman port ${PROJECT_NAME}
                    
                    echo ""
                    echo "⏳ Czekanie na inicjalizację kontenera..."
                    sleep 5
                    
                    # Sprawdź czy kontener nadal działa
                    if podman ps | grep -q ${PROJECT_NAME}; then
                        echo "✅ Kontener działa poprawnie!"
                        echo "🌐 Strona dostępna pod: http://localhost:9000"
                        echo ""
                        echo "💡 Sprawdź w przeglądarce lub przez curl z hosta:"
                        echo "   curl http://localhost:9000"
                    else
                        echo "❌ Kontener się zatrzymał!"
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        success {
            echo '✅ =========================================='
            echo '✅ Pipeline zakończony sukcesem!'
            echo '✅ =========================================='
            echo ''
            echo '🌐 Strona dostępna na: http://localhost:9000'
            echo '📊 Sprawdź status: podman ps | grep debian-webserver'
            echo '📝 Zobacz logi: podman exec debian-webserver nginx -t'
            echo ''
        }
        failure {
            echo '❌ Pipeline zakończony błędem!'
            sh '''
                echo "📋 Wszystkie kontenery:"
                podman ps -a
                
                echo ""
                echo "🔍 Sprawdzanie portów:"
                podman port ${PROJECT_NAME} || echo "Brak mapowania portów"
            '''
        }
        always {
            echo '🧹 Sprzątanie zakończone'
        }
    }
}

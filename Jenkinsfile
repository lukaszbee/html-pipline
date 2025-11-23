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
                    echo "📊 Szczegóły kontenera:"
                    podman inspect ${PROJECT_NAME} --format '{{.State.Status}}' || true
                    
                    echo ""
                    echo "🌐 Test dostępności strony:"
                    sleep 3
                    
                    # Test HTTP
                    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 || echo "000")
                    echo "Status HTTP: $HTTP_STATUS"
                    
                    if [ "$HTTP_STATUS" = "200" ]; then
                        echo "✅ Strona działa poprawnie!"
                    else
                        echo "❌ Strona nie odpowiada prawidłowo (kod: $HTTP_STATUS)"
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline zakończony sukcesem!'
            echo '🌐 Strona dostępna na: http://localhost:9000'
            echo '📊 Sprawdź status: podman ps | grep debian-webserver'
        }
        failure {
            echo '❌ Pipeline zakończony błędem!'
            sh '''
                echo "📋 Status kontenera:"
                podman ps -a | grep ${PROJECT_NAME} || echo "Kontener nie istnieje"
                
                echo ""
                echo "🔍 Sprawdzanie portu 9000:"
                netstat -tlnp | grep 9000 || ss -tlnp | grep 9000 || echo "Port 9000 nie jest otwarty"
            '''
        }
        always {
            echo '🧹 Sprzątanie zakończone'
        }
    }
}

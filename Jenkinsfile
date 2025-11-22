pipeline {
    agent any
    
    environment {
        // Zmień na URL swojego repo
        GIT_REPO = 'https://github.com/lukaszbee/html-pipline.git'
        GIT_BRANCH = 'main'
    }
    
    stages {
        stage('Pobierz kod z GitHub') {
            steps {
                echo '📥 Pobieram pliki z GitHub...'
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}"
            }
        }
        
        stage('Sprawdź Podman') {
            steps {
                echo '🔍 Sprawdzam czy Podman działa...'
                sh 'podman --version'
                sh 'podman ps'
            }
        }
        
        stage('Zatrzymaj stare kontenery') {
            steps {
                echo '🛑 Zatrzymuję stare kontenery (jeśli istnieją)...'
                sh '''
                    podman stop web-kontener-1 web-kontener-2 web-kontener-3 || true
                    podman rm web-kontener-1 web-kontener-2 web-kontener-3 || true
                '''
            }
        }
        
        stage('Zbuduj obraz') {
            steps {
                echo '🔨 Buduję obraz Docker...'
                sh 'podman build -t moja-strona:v1 .'
            }
        }
        
        stage('Uruchom kontenery') {
            steps {
                echo '🚀 Uruchamiam 3 kontenery...'
                sh '''
                    # Kontener 1
                    podman run -d \
                        --name web-kontener-1 \
                        -p 8081:80 \
                        -v $(pwd)/index1.html:/usr/share/nginx/html/index.html:ro \
                        moja-strona:v1
                    
                    # Kontener 2
                    podman run -d \
                        --name web-kontener-2 \
                        -p 8082:80 \
                        -v $(pwd)/index2.html:/usr/share/nginx/html/index.html:ro \
                        moja-strona:v1
                    
                    # Kontener 3
                    podman run -d \
                        --name web-kontener-3 \
                        -p 8083:80 \
                        -v $(pwd)/index3.html:/usr/share/nginx/html/index.html:ro \
                        moja-strona:v1
                '''
            }
        }
        
        stage('Sprawdź kontenery') {
            steps {
                echo '✅ Sprawdzam uruchomione kontenery...'
                sh 'podman ps | grep web-kontener'
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline zakończony sukcesem!'
            echo 'Strony dostępne na:'
            echo '  - http://localhost:8081 (Strona 1)'
            echo '  - http://localhost:8082 (Strona 2)'
            echo '  - http://localhost:8083 (Strona 3)'
        }
        failure {
            echo '❌ Pipeline zakończony błędem!'
        }
    }
}

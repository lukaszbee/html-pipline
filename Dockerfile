# Bazowy obraz Debian 12 (Bookworm)
FROM debian:12-slim

# Metadata
LABEL maintainer="your-email@example.com"
LABEL description="Debian 12 with Nginx for serving static HTML"

# Aktualizacja systemu i instalacja Nginx
RUN apt-get update && \
    apt-get install -y \
    nginx \
    curl \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Usunięcie domyślnej strony Nginx
RUN rm -f /var/www/html/index.nginx-debian.html

# Utworzenie katalogu dla strony (jeśli nie istnieje)
RUN mkdir -p /var/www/html

# Kopiowanie pliku HTML z głównego katalogu projektu
COPY ./index.html /var/www/html/index.html

# Ustawienie uprawnień
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Konfiguracja Nginx - zmiana domyślnej lokalizacji root
RUN sed -i 's|root /var/www/html;|root /var/www/html;|g' /etc/nginx/sites-available/default

# Ekspozycja portu 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Uruchomienie Nginx w trybie foreground
CMD ["nginx", "-g", "daemon off;"]

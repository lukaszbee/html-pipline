FROM nginx:alpine

# Kopiuj pliki HTML do katalogu nginx
COPY index.html /usr/share/nginx/html/

# Eksponuj port 80
EXPOSE 80

# Nginx startuje automatycznie
CMD ["nginx", "-g", "daemon off;"]

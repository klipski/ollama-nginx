#!/bin/bash

# Set the allowed IPs from the environment variable
ALLOWED_IPS="$ALLOWED_IPS"
DOLLAR="$"

# Create the nginx configuration file
cat <<EOF > /etc/nginx/nginx.conf
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;

        location / {
            allow $ALLOWED_IPS;
            deny all;

            proxy_pass http://ollama:11434;
            proxy_set_header Host ${DOLLAR}host;
            proxy_set_header X-Real-IP ${DOLLAR}remote_addr;
            proxy_set_header X-Forwarded-For ${DOLLAR}proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto ${DOLLAR}scheme;
        }
    }
}
EOF

# Start Nginx
exec nginx -g "daemon off;"


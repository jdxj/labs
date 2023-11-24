server {
    access_log off;
    tcp_nodelay off;

    listen 443 ssl;
    http2 on;
    server_name domain;

    ssl_certificate /etc/nginx/live/domain/fullchain.pem;
    ssl_certificate_key /etc/nginx/live/domain/privkey.pem;
    ssl_early_data off;

    location / {
        proxy_redirect off;
        proxy_pass http://172.18.0.24:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}

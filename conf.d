# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name docker-dev.vliz.be www.docker-dev.vliz.be;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name docker-dev.vliz.be www.docker-dev.vliz.be;

    ssl_certificate /etc/ssl/certs/www.docker-dev.vliz.be.crt;
    ssl_certificate_key /etc/ssl/private/www.docker-dev.vliz.be.key;

    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers on;
    # Uncomment the following line if you have a Diffie-Hellman parameter file
    # ssl_dhparam /etc/nginx/dhparam.pem;
    ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
    ssl_ecdh_curve secp384r1;
    ssl_session_timeout  10m;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    location / {
        set $target_url $arg_url;
        if ($target_url ~* "^https?://") {
            proxy_pass $target_url;
        }
        proxy_ssl_server_name on;  # Enable SSL/TLS for proxy_pass
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Add CORS headers
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Origin, Content-Type, Accept, Authorization';

        # Add logging for debugging
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log debug;
    }
}
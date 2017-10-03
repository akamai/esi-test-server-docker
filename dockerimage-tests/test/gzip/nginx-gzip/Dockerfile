FROM nginx
RUN sed -i'' -e 's/#gzip/gzip/' /etc/nginx/nginx.conf
RUN sed -i'' -e 's/"$http_x_forwarded_for"/"$http_x_forwarded_for" "$http_accept_encoding"/' /etc/nginx/nginx.conf
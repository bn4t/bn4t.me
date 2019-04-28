FROM registry.gitlab.com/pages/hugo:latest as builder

WORKDIR /app/

COPY . /app/
RUN hugo


FROM nginx:alpine
COPY --from=builder /app/public /usr/share/nginx/html


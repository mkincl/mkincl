FROM alpine:3

RUN apk add --no-cache \
    git=2.34.2-r0 \
    make=4.3-r0

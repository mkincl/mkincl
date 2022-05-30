FROM alpine:3.16

RUN apk add --no-cache \
    git=2.36.1-r0 \
    make=4.3-r0

FROM alpine:3.18

RUN apk add --no-cache \
    git=2.40.1-r0 \
    make=4.4.1-r1

FROM alpine:latest

# Your Property
ARG USER=user
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apk update && apk add --no-cache docker-engine \
    && addgroup -g ${GROUP_ID} ${USER} \
    && addgroup docker \
    && adduser -D -u ${USER_ID} -s /bin/sh -G ${USER} ${USER} \
    && adduser ${USER} docker

VOLUME [ "/var/lib/docker" ]
VOLUME [ "/home/${USER}" ]

ENTRYPOINT [ "dockerd" ]
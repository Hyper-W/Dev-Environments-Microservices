FROM alpine:latest AS CERT

ARG CERT_PASS=docker
ARG DOCKER_IP=docker
ARG CERT_NAME=DNS:${DOCKER_IP}

RUN mkdir -p /etc/docker/cert \
    && mkdir -p /etc/docker/cert/server \
    && mkdir -p /etc/docker/cert/client

WORKDIR /etc/docker/cert

RUN apk add openssl \
    && openssl genrsa -aes256 -passout pass:${CERT_PASS} -out private-key.pem 4096 \
    && echo -e "\n\n\n\n\n\n\n\n\n\n" | openssl req -new -x509 -passin pass:${CERT_PASS} -days 36500 -key private-key.pem -sha256 -out ca.pem \
    && openssl genrsa -out server-key.pem 4096 \
    && echo -e "\n\n\n\n\n\n\n\n\n\n" | openssl req -subj "/CN="${DOCKER_IP} -sha256 -new -key server-key.pem -out server.csr \
    && echo subjectAltName = ${CERT_NAME} > extfile.cnf \
    && openssl x509 -req -days 36500 -sha256 -in server.csr -CA ca.pem -CAkey private-key.pem -CAcreateserial -passin pass:${CERT_PASS} -out server-cert.pem -extfile extfile.cnf \
    && openssl genrsa -out key.pem 4096 \
    && echo -e "\n\n\n\n\n\n\n\n\n\n" | openssl req -subj "/CN="${DOCKER_IP} -new -key key.pem -out client.csr \
    && echo extendedKeyUsage = clientAuth > extfile.cnf \
    && openssl x509 -req -days 36500 -sha256 -in client.csr -CA ca.pem -CAkey private-key.pem -CAcreateserial -passin pass:${CERT_PASS} -out cert.pem -extfile extfile.cnf \
    && chmod 0400 private-key.pem server-key.pem key.pem \
    && chmod 0444 ca.pem server-cert.pem cert.pem \
    && cp -p ./ca.pem ./server/ \
    && mv ./server-key.pem ./server/ \
    && mv ./server-cert.pem ./server/ \
    && mv ./ca.pem ./client/ \
    && mv ./key.pem ./client/ \
    && mv ./cert.pem ./client/

FROM alpine:latest AS APP

# Your Property
ARG USER=user
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apk update && apk add --no-cache docker-engine \
    && addgroup -g ${GROUP_ID} ${USER} \
    && addgroup docker \
    && adduser -D -u ${USER_ID} -s /bin/sh -G ${USER} ${USER} \
    && adduser ${USER} docker \
    && mkdir -p /etc/docker/cert/server && mkdir -p /etc/docker/cert/client

COPY --from=CERT /etc/docker/cert/server /etc/docker/cert/server
COPY --from=CERT --chown=${USER_ID}:${GROUP_ID} /etc/docker/cert/client /etc/docker/cert/client

VOLUME [ "/etc/docker/cert/client" ]
VOLUME [ "/etc/docker/cert/server" ]
VOLUME [ "/var/lib/docker" ]
VOLUME [ "/home/${USER}" ]

ENTRYPOINT [ "dockerd" ]
CMD [ "--tlsverify", "--tlscacert=/etc/docker/cert/server/ca.pem", "--tlscert=/etc/docker/cert/server/server-cert.pem", "--tlskey=/etc/docker/cert/server/server-key.pem" ,"-H" ,"tcp://0.0.0.0" ]
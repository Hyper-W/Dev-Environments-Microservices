FROM ubuntu:latest

EXPOSE 8000

# Your Property
ARG USER=user
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DONT_PROMPT_WSL_INSTALL=1

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gnupg lsb-release sudo git bash-completion apt-transport-https nano \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && curl -fsSL https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" > /etc/apt/sources.list.d/helm-stable-debian.list \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin helm code \
    && apt-get remove -y --purge --autoremove gnupg lsb-release apt-transport-https \
    && apt-get clean && rm -rf /var/lib/apt/lists/ \
    && curl -fsSL "https://dl.k8s.io/release/$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
    && chmod a+x /usr/local/bin/kubectl \
    && curl -fsSL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o /usr/local/bin/skaffold \
    && chmod a+x /usr/local/bin/skaffold \
    && mkdir -p /var/run/sshd \
    && groupadd -g ${GROUP_ID} ${USER} \
    && groupadd docker \
    && useradd -u ${USER_ID} -m -s /bin/bash -g ${USER} -G sudo,docker ${USER} \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /var/run/dind && ln -fs /var/run/dind/docker.sock /var/run/docker.sock

ENV PATH=$PATH:/usr/libexec/docker/cli-plugins/

USER ${USER}

VOLUME [ "/home/${USER}" ]

WORKDIR /home/${USER}

RUN mkdir -p ~/.docker/cert \
    && mkdir -p ~/.kube && touch ~/.kube/config && chmod 600 ~/.kube/config && mkdir -p ~/.config/helm \
    && echo "" >> ~/.bashrc && echo "# Kubernetes Settings" >> ~/.bashrc && echo "alias k=kubectl" >> ~/.bashrc \
    && echo "source <(kubectl completion bash)" >> ~/.bashrc && echo "complete -o default -F __start_kubectl k" >> ~/.bashrc \
    && mkdir -p "/home/${USER}/.vscode/extensions" && mkdir -p "/home/${USER}/.vscode-server" \
    && ln -s "/home/${USER}/.vscode/extensions" "/home/${USER}/.vscode-server/extensions"


VOLUME [ "/home/${USER}/.docker" ]
VOLUME [ "/home/${USER}/.docker/cert" ]
VOLUME [ "/home/${USER}/.kube" ]
VOLUME [ "/home/${USER}/.config/helm" ]
VOLUME [ "/home/${USER}/.vscode" ]
VOLUME [ "/home/${USER}/.vscode-server" ]

WORKDIR /home/${USER}

ENTRYPOINT  [ "code" ]
CMD [ "serve-web", "--host", "0.0.0.0", "--without-connection-token" ]

# # After first exec, Do it exec this command.
# docker context create docker --docker "host=tcp://docker:2375,ca=$HOME/.docker/cert/ca.pem,cert=$HOME/.docker/cert/cert.pem,key=$HOME/.docker/cert/key.pem"
# docker context use docker
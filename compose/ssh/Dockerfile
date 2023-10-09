FROM ubuntu:latest

# Your Property
ARG USER=user
ARG USER_ID=1000
ARG GROUP_ID=1000

# K8s Version
ARG KUBE_VERSION=v1.28

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gnupg lsb-release sudo git bash-completion apt-transport-https nano openssh-server \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list \
    && curl -fsSL https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" > /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin kubectl helm \
    && apt-get remove -y --purge --autoremove gnupg lsb-release apt-transport-https \
    && apt-get clean && rm -rf /var/lib/apt/lists/ \
    && mkdir -p /var/run/sshd \
    && groupadd -g ${GROUP_ID} ${USER} \
    && groupadd docker \
    && useradd -u ${USER_ID} -m -s /bin/bash -g ${USER} -G sudo,docker ${USER} \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /var/run/dind && ln -fs /var/run/dind/docker.sock /var/run/docker.sock \
    && sed -i '/PermitRootLogin/c PermitRootLogin no' /etc/ssh/sshd_config \
    && sed -i '/PasswordAuthentication/c PasswordAuthentication no' /etc/ssh/sshd_config

ENV PATH=$PATH:/usr/libexec/docker/cli-plugins/

VOLUME [ "/etc/ssh" ]

USER ${USER}

VOLUME [ "/home/${USER}" ]

WORKDIR /home/${USER}

RUN mkdir -p ~/.kube && touch ~/.kube/config && chmod 600 ~/.kube/config && mkdir -p ~/.config/helm \
    && echo "" >> ~/.bashrc && echo "# Kubernetes Settings" >> ~/.bashrc && echo "alias k=kubectl" >> ~/.bashrc \
    && echo "source <(kubectl completion bash)" >> ~/.bashrc && echo "complete -o default -F __start_kubectl k" >> ~/.bashrc \
    && mkdir -p "/home/${USER}/.vscode/extensions" && mkdir -p "/home/${USER}/.vscode-server" \
    && ln -s "/home/${USER}/.vscode/extensions" "/home/${USER}/.vscode-server/extensions" \
    && mkdir -pm 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys

VOLUME [ "/home/${USER}/.kube" ]
VOLUME [ "/home/${USER}/.config/helm" ]

USER root

CMD [ "/usr/sbin/sshd","-D" ]
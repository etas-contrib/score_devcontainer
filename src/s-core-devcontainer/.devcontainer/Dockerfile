ARG VARIANT="noble"

# User-Setup: Build-Args für User-Infos
ARG USERNAME
ARG USER_ID
ARG USER_GID
ARG DOCKER_GID=999

# Proxy arguments for build-time network access
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG http_proxy
ARG https_proxy
ARG NO_PROXY
ARG no_proxy


FROM buildpack-deps:${VARIANT}-curl

ENV USERNAME=$USERNAME

# User anlegen (wie ehemals in Dockerfile.user)
USER root

RUN if [ -n "$USERNAME" ] && [ -n "$USER_ID" ] && [ -n "$USER_GID" ]; then \
    echo "LASTLOG_UID_MAX    0" >> /etc/login.defs && \
    rm -f /var/log/faillog /var/log/lastlog && \
    groupadd --gid $USER_GID $USERNAME && \
    groupadd -o -g $DOCKER_GID docker && \
    useradd -s /bin/bash --uid $USER_ID --gid $USER_GID -d /home/$USERNAME -m -G docker $USERNAME && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    echo "Defaults  env_keep += \"FORCE_NET_HOST\"" >> /etc/sudoers && \
    echo "Defaults  env_keep += \"http_proxy\"" >> /etc/sudoers && \
    echo "Defaults  env_keep += \"https_proxy\"" >> /etc/sudoers && \
    echo "Defaults  env_keep += \"HTTP_PROXY\"" >> /etc/sudoers && \
    echo "Defaults  env_keep += \"HTTPS_PROXY\"" >> /etc/sudoers && \
    echo "Defaults  env_keep += \"no_proxy\"" >> /etc/sudoers && \
    echo "Defaults  env_keep += \"NO_PROXY\"" >> /etc/sudoers ; \
fi

# User-Umgebung setzen, falls User angelegt
USER ${USERNAME:-root}
WORKDIR /home/${USERNAME:-root}
ENV PATH=/usr/lib/ccache:/home/${USERNAME:-root}/.local/bin:${PATH} \
    CCACHE_DIR=/home/${USERNAME:-root}/.ccache \
    XAUTHORITY=/home/${USERNAME:-root}/.Xauthority
# Set proxy environment variables for the build process
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV NO_PROXY=${NO_PROXY}
ENV no_proxy=${no_proxy}

LABEL dev.containers.features="common"

ARG VARIANT
RUN if [ "$VARIANT" = "noble" ]; then \
        if id "ubuntu" &>/dev/null; then \
            echo "Deleting user 'ubuntu'  for $VARIANT" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user for $VARIANT"; \
        else \
            echo "User 'ubuntu' does not exist for $VARIANT"; \
        fi; \
    fi

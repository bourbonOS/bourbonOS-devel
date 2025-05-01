FROM alpine:edge

RUN apk update && \
    apk add --no-cache \
    sudo \
    shadow \
    openssh-server \
    vim \
    curl \
    wget \
    git \
    openrc \
    bash \
    ncurses \
    procps \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel \
    && rc-update add sshd

RUN mkdir -p /etc/ssh
RUN ssh-keygen -A
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir -p /etc/subsystem-utils
COPY creuserenv.sh /etc/subsystem-utils/
RUN chmod +x /etc/subsystem-utils/creuserenv.sh

ENTRYPOINT ["/etc/subsystem-utils/creuserenv.sh"]
# Use Ubuntu as the base image
FROM --platform=linux/x86_64 containers.cisco.com/sto-ccc-cloud9/hardened_ubuntu:22.04

# Set environment variables for Java and Python versions
ENV JAVA_VERSION 11
ENV PYTHON_VERSION 3.9
ENV GRADLE_VERSION 8.0.2
ENV LEIN_VERSION 2.11.2
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN chsh -s ~/.zshrc

ARG DEBIAN_FRONTEND=noninteractive

# Install Java 11, Python 3, MySQL client, nano, curl, cert tools, SSH tools, kubectl, Docker CLI, and other utilities
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    net-tools \
    htop \
    sysstat \
    dstat \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    unzip \
    wget \
    fd-find \
    && rm -rf /var/lib/apt/lists/*

# Default powerline10k theme, no plugins installed
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)"

COPY .zshrc /root/.zshrc
COPY .p10k.zsh /root/.p10k.zsh
ADD install/ /root/

RUN sh -c "$(git clone https://github.com/asdf-vm/asdf.git ~/.asdf)" && \
    echo ". $HOME/.asdf/asdf.sh" >> /root/.zshrc && \
    echo ". $HOME/.asdf/asdf.sh" >> /root/.bashrc


RUN $HOME/.asdf/bin/asdf plugin-add java
RUN $HOME/.asdf/bin/asdf plugin-add mysql 
RUN $HOME/.asdf/bin/asdf plugin-add python 
RUN $HOME/.asdf/bin/asdf plugin-add jq 
RUN $HOME/.asdf/bin/asdf plugin-add jqp 
RUN $HOME/.asdf/bin/asdf plugin-add awscli 
RUN $HOME/.asdf/bin/asdf plugin-add leiningen 
RUN $HOME/.asdf/bin/asdf plugin-add gradle 
RUN $HOME/.asdf/bin/asdf plugin-add ripgrep

RUN $HOME/.asdf/bin/asdf install awscli latest 
RUN $HOME/.asdf/bin/asdf install gradle 4.7 
RUN $HOME/.asdf/bin/asdf install java adoptopenjdk-11.0.22+7 
RUN $HOME/.asdf/bin/asdf install jq latest 
# RUN $HOME/.asdf/bin/asdf install jqp latest 
# RUN $HOME/.asdf/bin/asdf install mysql 8.0.20
# RUN $HOME/.asdf/bin/asdf install ripgrep 14.1.0
# RUN $HOME/.asdf/bin/asdf install python 3.6.0

RUN apt-get install -y ripgrep \
    mysql-client

# Set the working directory
WORKDIR /workspace


# Default command to run when starting the container
CMD ["sleep", "1000000"]
# Use Ubuntu as the base image
FROM ubuntu:22.04

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
    openjdk-11-jdk \
    mysql-client \
    nano \
    vim \
    python${PYTHON_VERSION} \
    python3-pip \
    curl \
    git \
    net-tools \
    htop \
    sysstat \
    dstat \
    valgrind \
    openssh-client \
    gnupg \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

# Install Ansible
RUN apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip -P /tmp && \
    unzip /tmp/terraform_1.1.7_linux_amd64.zip -d /usr/local/bin && \
    rm /tmp/terraform_1.1.7_linux_amd64.zip

# Install JMX-related tools (assuming VisualVM from previous Dockerfile snippet)

# Install Kafka tools (assuming Confluent Platform tools)
RUN wget -qO - https://packages.confluent.io/deb/7.0/archive.key | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/7.0 stable main" && \
    apt-get update && apt-get install -y confluent-platform

# Install Golang
RUN wget https://golang.org/dl/go1.17.6.linux-amd64.tar.gz -P /tmp && \
    tar -C /usr/local -xzf /tmp/go1.17.6.linux-amd64.tar.gz && \
    rm /tmp/go1.17.6.linux-amd64.tar.gz

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Install Leiningen
RUN wget https://raw.githubusercontent.com/technomancy/leiningen/${LEIN_VERSION}/bin/lein -P /usr/local/bin && \
    chmod a+x /usr/local/bin/lein && \
    lein

# Default powerline10k theme, no plugins installed
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)"

COPY .zshrc /root/.zshrc
COPY .p10k.zsh /root/.p10k.zsh


# Set the working directory
WORKDIR /workspace


# Default command to run when starting the container
ENTRYPOINT ["tail", "-f", "/dev/null"]

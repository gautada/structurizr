ARG UBUNTU_VERSION="24.04"
FROM docker.io/ubuntu:$UBUNTU_VERSION as container

# https://github.com/structurizr/lite
ARG CONTAINER_VERSION="2025.03.28"
# https://jdk.java.net/25/
ARG OPENJDK_VERSION="25-ea+"
ARG OPENJDK_RELEASE="21"

LABEL source="https://github.com/gautada/structureizr-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for structurizr architecture tooling"

RUN /usr/bin/apt-get update \
 && /usr/bin/apt-get install --yes cron git graphviz sudo

WORKDIR /opt
COPY arch.sh arch.sh
RUN . ./arch.sh
ADD "https://download.java.net/java/early_access/jdk25/${OPENJDK_RELEASE}/GPL/openjdk-${OPENJDK_VERSION}${OPENJDK_RELEASE}_linux-aarch64_bin.tar.gz" jdk-25.tgz
ADD "https://github.com/structurizr/lite/releases/download/v$CONTAINER_VERSION/structurizr-lite.war" structurizr.war

RUN /usr/bin/tar zxf jdk-25.tgz \
 && /usr/bin/rm jdk-25.tgz \
 && /usr/bin/mv jdk-25 jdk \
 && /usr/bin/ln -fsv /opt/jdk/bin/java /usr/bin/java

# COPY container-crontab /etc/cron.d/container-crontab
# Give proper permissions
# RUN chmod 0644 /etc/cron.d/container-crontab && crontab /etc/cron.d/container-crontab

# COPY update-libraries /usr/bin/update-libraries

COPY entrypoint /etc/container/entrypoint
# RUN chmod 777 /etc/container/entrypoint

# COPY privileged /etc/sudoers.d/privileged
  
ARG USER=dsl
RUN /usr/sbin/useradd -m ${USER} \
 && groupadd privileged \
 && usermod -aG privileged dsl \
 && /usr/bin/chown -R ${USER}:${USER} /opt
USER $USER
 
WORKDIR /home/$USER
# RUN mkdir -p /home/$USER/workspace/libraries 
# RUN ln -fsv /mnt/volumes/containers /home/$USER/workspace/local
# RUN ln -fsv /home/$USER/workspace/local/index.dsl /home/$USER/workspace/workspace.dsl
RUN ln -fsv /mnt/volumes/container/workspace /home/$USER/workspace

# ENV JAVA_HOME=/opt/jdk
# ENV PATH=$PATH:/opt/jdk/bin

ENTRYPOINT ["/etc/container/entrypoint"]

ARG ALPINE_VERSION=latest

FROM docker.io/gautada/alpine:$ALPINE_VERSION

# ╭―
# │ METADATA           
# ╰――――――――――――――――――――
LABEL source="https://github.com/gautada/structureizr-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for structurizr architecture tooling"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=c4
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
# COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# RUN /bin/rm -f /etc/periodic/hourly/container-backup
# COPY backup /etc/container/backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭―
# │ APPLICATION        
# ╰――――――――――――――――――――
ARG CONTAINER_VERSION="3263"
ARG STRUCTURIZR_VERSION="$CONTAINER_VERSION"
ARG STRUCTURIZR_BRANCH=v"$STRUCTURIZR_VERSION"
ARG STRUCTURIZR_UI_BRANCH=onpremises-v"$STRUCTURIZR_VERSION"

RUN /usr/bin/git config --global advice.detachedHead false
RUN /usr/bin/git clone --branch $STRUCTURIZR_BRANCH --depth 1 https://github.com/structurizr/onpremises.git structurizr-onpremises
RUN /usr/bin/git clone --branch $STRUCTURIZR_UI_BRANCH --depth 1 https://github.com/structurizr/ui.git structurizr-ui

WORKDIR structurizr-onpremises

# RUN /usr/sbin/apk add --no-cache gradle
# RUN /structurizr-onpremises/ui.sh
# RUN /usr/bin/gradle clean build

ADD https://github.com/structurizr/onpremises/releases/download/v2024.03.03/structurizr-onpremises.war structurizr-onpremises.war

# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――

RUN /bin/chown -R $USER:$USER /home/$USER
# USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER



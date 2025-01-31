ARG ALPINE_VERSION=latest

FROM docker.io/gautada/alpine:$ALPINE_VERSION AS build
ARG CONTAINER_VERSION="2024.03.03"
ARG STRUCTURIZR_VERSION="$CONTAINER_VERSION"
ARG STRUCTURIZR_BRANCH=v"$STRUCTURIZR_VERSION"

RUN /sbin/apk add --no-cache openjdk21

WORKDIR /
RUN /usr/bin/git config --global advice.detachedHead false
RUN /usr/bin/git clone --branch $STRUCTURIZR_BRANCH --depth 1 https://github.com/structurizr/lite.git structurizr-lite
RUN /usr/bin/git clone --branch lite-v2024.02.22 --depth 1 https://github.com/structurizr/ui.git structurizr-ui

WORKDIR /structurizr-lite

RUN /structurizr-lite/ui.sh
RUN /usr/bin/wget https://services.gradle.org/distributions/gradle-8.8-rc-1-bin.zip
RUN /usr/bin/unzip gradle-8.8-rc-1-bin.zip
RUN ./gradle-8.8-rc-1/bin/gradle build


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
ARG USER=structurizr
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
RUN /sbin/apk add --no-cache openjdk21 graphviz

COPY --from=build /structurizr-lite/build/libs/structurizr-lite.war /home/$USER/
RUN ln -fsv /mnt/volumes/container/Foodbuy-Common-Architecture/workspace /home/$USER/workspace

# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――

RUN /bin/chown -R $USER:$USER /home/$USER
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER



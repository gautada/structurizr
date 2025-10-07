ARG JAVA_VERSION=25.0.0

FROM docker.io/gautada/java:$JAVA_VERSION as CONTAINER
USER root
# ╭――――――――――――――――――――╮
# │ VARIABLES          │
# ╰――――――――――――――――――――╯
ARG IMAGE_NAME="structurizer"
ARG IMAGE_VERSION="3262"

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A base container for java."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.version="${PACKAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=dsl
RUN /usr/sbin/usermod -l $USER duke \
  && /usr/sbin/usermod -d /home/$USER -m $USER \
  && /usr/sbin/groupmod -n $USER duke \
  && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
# COPY backup.sh /etc/container/backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY entrypoint.sh /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache graphviz  bash 
WORKDIR /opt/structurizr
ADD "https://github.com/structurizr/lite/releases/download/v${IMAGE_VERSION}/structurizr-lite.war" structurizr.war
ADD "https://github.com/structurizr/cli/releases/download/v${IMAGE_VERSION}/structurizr-cli.zip" structurizr-cli.zip
RUN unzip structurizr-cli.zip -d /opt/structurizr/cli \
 && rm -rf /opt/structurizr/structurizr-cli.zip \
 && ln -fsv /opt/structurizr/cli/structurizr.sh /usr/bin/structurizr
WORKDIR /home/$USER/default
COPY workspace.dsl workspace.dsl
RUN chown $USER:$USER -R /home/$USER /opt

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets



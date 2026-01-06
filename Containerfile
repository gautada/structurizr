ARG JAVA_VERSION=25

FROM docker.io/gautada/java:$JAVA_VERSION as BUILD

ARG IMAGE_BRANCH="main"
WORKDIR /opt
RUN apk add --no-cache maven \
 && git clone --branch ${IMAGE_BRANCH} https://github.com/structurizr/structurizr.git structurizr
WORKDIR /opt/structurizr
RUN mvn -DexcludedGroups=IntegrationTest package
# RUN ls structurizr-application/target/*

FROM docker.io/gautada/java:$JAVA_VERSION as CONTAINER
# ╭――――――――――――――――――――╮
# │ VARIABLES          │
# ╰――――――――――――――――――――╯
ARG IMAGE_NAME="structurizr"
ARG IMAGE_VERSION="1.0.0"
# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="C4 as code and display server."
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
  && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd \
  && rm -rf /home/duke

# # ╭――――――――――――――――――――╮
# # │ BACKUP             │
# # ╰――――――――――――――――――――╯
# # COPY backup.sh /etc/container/backup
#
# # ╭――――――――――――――――――――╮
# # │ ENTRYPOINT         │
# # ╰――――――――――――――――――――╯
# COPY entrypoint.sh /etc/container/entrypoint
#
# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache graphviz  bash 
COPY --from=BUILD "/opt/structurizr/structurizr-application/target/structurizr-${IMAGE_VERSION}.war" /opt/structurizr/structurizr.war
COPY structurizr.s6 /etc/services.d/structurizr/run
RUN rm -rf /etc/services.d/java \
 && ln -fsv /mnt/volumes/data/workspace "/home/${USER}/workspace" \
 && chown "${USER}:${USER}" -R "/home/${USER}" /opt
# WORKDIR /opt/structurizr
# ADD "https://github.com/structurizr/lite/releases/download/v${IMAGE_VERSION}/structurizr-lite.war" structurizr.war
# ADD "https://github.com/structurizr/cli/releases/download/v${IMAGE_VERSION}/structurizr-cli.zip" structurizr-cli.zip
# RUN unzip structurizr-cli.zip -d /opt/structurizr/cli \
#  && rm -rf /opt/structurizr/structurizr-cli.zip \
#  && ln -fsv /opt/structurizr/cli/structurizr.sh /usr/bin/structurizr \
#  && ln -fsv /mnt/volumes/data/workspace "/home/${USER}/workspace"
COPY workspace.dsl /mnt/volumes/data/workspace.dsl
WORKDIR /home/$USER
#
# # ╭――――――――――――――――――――╮
# # │ CONTAINER          │
# # ╰――――――――――――――――――――╯
# USER $USER
# VOLUME /mnt/volumes/backup
# VOLUME /mnt/volumes/configmaps
# VOLUME /mnt/volumes/data
# VOLUME /mnt/volumes/secrets
#
#

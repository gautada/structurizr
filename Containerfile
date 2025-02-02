FROM debian:bookworm-slim as build

RUN apt-get update \
 && apt-get install --yes git graphviz \ 
 # zip \
 && apt-get clean
 
ARG STRUCTURIZR_LITE_VERSION="2024.12.07"
# ARG STRUCTURIZR_UI_VERSION="3263"

RUN mkdir -p /mnt/volumes/container /mnt/volumes/backup 

WORKDIR /opt
ADD https://download.java.net/java/early_access/jdk25/7/GPL/openjdk-25-ea+7_linux-aarch64_bin.tar.gz jdk-25.tgz
RUN /usr/bin/tar zxf jdk-25.tgz \
 && /usr/bin/mv jdk-25 jdk \
 && /usr/bin/rm jdk-25.tgz \
 && /usr/bin/ln -fsv /opt/jdk/bin/java /usr/bin/java

# RUN /usr/bin/git config --global advice.detachedHead false
# RUN /usr/bin/git clone --branch v$STRUCTURIZR_LITE_VERSION --depth 1 https://github.com/structurizr/lite.git structurizr-lite
# RUN /usr/bin/git clone --branch v$STRUCTURIZR_UI_VERSION --depth 1 https://github.com/structurizr/ui.git structurizr-ui

# ARG GRADLE_VERSION="8.12.1"
# ADD https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip gradle-$GRADLE_VERSION.zip
# RUN /usr/bin/unzip gradle-$GRADLE_VERSION.zip \
#  && /usr/bin/mv gradle-$GRADLE_VERSION gradle \
#  && /usr/bin/rm gradle-$GRADLE_VERSION.zip \
#  && /usr/bin/ln -fsv /opt/gradle/bin/gradle /usr/bin/gradle

WORKDIR /opt/structurizr-lite
# RUN /opt/structurizr-lite/ui.sh
# RUN /usr/bin/gradle build

ADD https://github.com/structurizr/lite/releases/download/v$STRUCTURIZR_LITE_VERSION/structurizr-lite.war structurizr-lite.war

LABEL source="https://github.com/gautada/structurizr-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for structurizr."

ARG USER=structurizr
RUN /usr/sbin/useradd -m $USER
RUN /usr/bin/chown -R $USER:$USER /opt
USER $USER

RUN /usr/bin/mkdir -p  /home/$USER/workspace

EXPOSE 8080/tcp

WORKDIR /home/$USER

ENTRYPOINT ["/usr/bin/java", "-Djdk.util.jar.enableMultiRelease=false", "-jar", "/opt/structurizr-lite/structurizr-lite.war", "/home/structurizr/workspace"]

#!/bin/sh
echo "--------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------"

VERSION=$1
RELEASE=$2
ARCH=$(uname -m)
echo "${VERSION} ${RELEASE} ${ARCH}"

if [ "$ARCH" = "x86_64" ]; then
  ARCH="x64"
fi

URL="https://download.java.net/java/early_access/jdk${VERSION}/${RELEASE}/GPL/openjdk-${VERSION}-ea+${RELEASE}_linux-${ARCH}_bin.tar.gz"
echo "${URL}"
curl -sLO "${URL}"

/usr/bin/mv  "openjdk-${VERSION}-ea+${RELEASE}_linux-${ARCH}_bin.tar.gz" "jdk-${VERSION}.tar.gz"
/usr/bin/tar zxf "jdk-${VERSION}.tar.gz"
/usr/bin/rm "jdk-${VERSION}.tar.gz"
/usr/bin/mv "jdk-${VERSION}" jdk
/usr/bin/ln -fsv /opt/jdk/bin/java /usr/bin/java
ls -al /opt
ls -al /opt/jdk
ls -al /usr/bin/java
echo "*************************************************************************************"
echo "*************************************************************************************"
echo "*************************************************************************************"
echo "*************************************************************************************"
echo "*************************************************************************************"



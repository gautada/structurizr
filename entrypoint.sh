#!/bin/sh
#
# entrypoint: Located at `/etc/container/entrypoint` this script is the custom
#             entry for a container as called by `/usr/bin/container-entrypoint` set
#             in the upstream [alpine-container](https://github.com/gautada/alpine-container).
#             The default template is kept in
#             [gist](https://gist.github.com/gautada/f185700af585a50b3884ad10c2b02f98)

container_version() {
  echo "0.0.0"
}

container_entrypoint() {
  export JAVA_HOME=/usr/lib/jvm/default-jvm
  export PATH="$PATH:${JAVA_HOME}/bin"
  
  if [ -z "${STRUCTURIZR_WORKSPACE}" ] ; then
    export STRUCTURIZR_WORKSPACE="/home/dsl/workspace" 
  fi
  
  cd /home/dsl || exit
  
  /usr/bin/java -Djdk.util.jar.enableMultiRelease=false \
                -jar /opt/structurizr/structurizr.war \
                "${STRUCTURIZR_WORKSPACE}"
  # tail -f /dev/null

}

# es01_setup image
# creates container with tools needed to parse api-payloads 
# curl over to es01 to configure elasticsearch server 

ARG es_version

FROM docker.elastic.co/elasticsearch/elasticsearch:${es_version}

USER root

RUN apt-get update && apt-get -y install jq gettext-base

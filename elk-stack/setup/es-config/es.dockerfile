ARG es_version

FROM docker.elastic.co/elasticsearch/elasticsearch:${es_version}

ARG gid

RUN groupadd -g ${gid} reactome

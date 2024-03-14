#!/usr/bin/env bash

# exit on attempt to use undeclared variable
set -o nounset
# enable error tracing
set -o errtrace

WORKING_DIR=/usr/share/filebeat
REGISTRY_DIR="$WORKING_DIR"/data/registry/filebeat

find "$WORKING_DIR"/ingest_data -type f | while IFS= read -r DATA_FILE; do
    # get file size, init offset
    BYTES=$(wc -c ${DATA_FILE} | awk '{print $1}')
    OFFSET=0

    # try to find offset from log
    ENTRY="$(grep ${DATA_FILE} ${REGISTRY_DIR}/log.json | tail -1)"
    if [[ $? -eq 0 ]]; then
        OFFSET=$(echo "$ENTRY" | jq '.v.cursor.offset')
    fi

    # if log is missing offset, try to find from snapshot
    if [[ "$OFFSET" -eq 0 && -f "${REGISTRY_DIR}/active.dat" ]]; then
        SNAPSHOT="$(cat ${REGISTRY_DIR}/active.dat)"
        ENTRY=$(grep ${DATA_FILE} ${SNAPSHOT})
        
        if [[ $? -eq 0 ]]; then
            if [[ "${ENTRY: -1}" == "," ]]; then
                ENTRY="${ENTRY::-1}"
            fi
            OFFSET=$(echo ${ENTRY} | jq .cursor.offset)
        fi
    fi

    # remove file if file size equals read offset
    if [[ "$BYTES" -eq "$OFFSET" ]]; then
        rm -f "$DATA_FILE"
    fi
done
#!/bin/bash
# jpegToPNG.sh
DATA_RETENTION_DIR="${1}"
DATA_OUTPUT_DIR="${2}"
OUTPUT_PREFIX=$(date +"%m-%d-%Y-%H-%M-%S")
ls "${DATA_RETENTION_DIR}" | while read JPEG_IMAGE; do
    DATA_OUTPUT_NAME=$(echo "${JPEG_IMAGE}" | cut -d '.' -f1)
    convert "${DATA_RETENTION_DIR}"/"${JPEG_IMAGE}" "${DATA_OUTPUT_DIR}"/"${DATA_OUTPUT_NAME}.""${OUTPUT_PREFIX}.png"
done
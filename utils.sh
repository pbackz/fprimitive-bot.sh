#!/bin/bash

###################################################################
# Script Name	  : utils.sh                                                                                           
# Description	  : A collection of useful shell functions                                                                                          
# Author       	  : Pierre Baconnier                                                
# Email           : pbackz@gmail.com
# Last updated on : 2021/04/12                                         
###################################################################

# Enable Strict mode
# Blockcode from http://redsymbol.net/articles/unofficial-bash-strict-mode/
function enable_strict_mode() {  
  set -e -o pipefail # not '-u' because of is.sh invoking with no args
  IFS=$'\n\t'
  function on_error() { echo "Error on or near line $1; exiting with status $2"; exit "$2"; }
  trap 'on_error ${LINENO} $?' ERR
}

function use_issh() { 
    # shellcheck source=lib/is.sh
    source "${0%/*}"/lib/is.sh
}

# Golang functions
function install_golang_latest() {
  apk update||apt-get update||yum update -y
  apk add go||apt-get install -y golang||yum install -y go
}

function jpeg_to_png() {
  set -- "${@}"
  local OUTPUT_PREFIX
  local DATA_RETENTION_DIR="${1}"
  local DATA_OUTPUT_DIR="${2}"
  find "${DATA_RETENTION_DIR}" -maxdepth 1 -type f | while read -r JPEG_IMAGE; do
      DATA_OUTPUT_NAME=$(echo "${JPEG_IMAGE}" | cut -d '/' -f2 | cut -d '.' -f1)
      # require magick binary
      echo "file found: ./${JPEG_IMAGE}"
      echo "output file destination: ${DATA_OUTPUT_DIR}/${DATA_OUTPUT_NAME}.png"
      ./magick convert ./"${JPEG_IMAGE}" "${DATA_OUTPUT_DIR}"/"${DATA_OUTPUT_NAME}".png
  done
}
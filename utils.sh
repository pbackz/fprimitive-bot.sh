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

# Assertions shell library "is.sh" functions
function dl_issh() { 
    mkdir -p lib
    cd lib
    wget raw.githubusercontent.com/qzb/is.sh/latest/is.sh
    cd -
}

function cleanup_issh() { rm -f "${0%/*}"/lib/is.sh* ; }

function use_issh() { 
    # shellcheck source=lib/is.sh
    source "${0%/*}"/lib/is.sh
}

# Golang functions
function install_golang_latest() {
  local GOTOOLS="${HOME}/go/tools"
  local DL_HOME=https://golang.org
  local DL_PATH_URL
  local LATEST_VERSION_PATTERN
  local LATEST
  cd "${GOTOOLS}";
  DL_PATH_URL="$(wget --no-check-certificate -qO- https://golang.org/dl/ | grep -oP '\/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1)"
  LATEST_VERSION_PATTERN=$(echo "${DL_PATH_URL}" | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )
  echo "Finding latest version of Go for AMD64..."
  LATEST=$(find "${GOTOOLS}" -name "go*" -type f | head -n 1)
  mkdir -p "${GOTOOLS}"
  echo "Downloading latest Go for AMD64: ${LATEST_VERSION_PATTERN}"
  wget --no-check-certificate --continue --show-progress "${DL_HOME}${DL_PATH_URL}" -P "${GOTOOLS}"
  echo "LATEST: ${LATEST}"
  tar -xavf "${GOTOOLS}/${LATEST}"; rm "${GOTOOLS}/${LATEST}.tar.gz"; cd -
  export GOBIN="${GOTOOLS}/go/bin"
  export GOPATH="${GOTOOLS}/go/src"
  export PATH="${PATH}:${GOBIN}"
  unset GOTOOLS, DL_HOME, DL_PATH_URL, LATEST_VERSION_PATTERN, LATEST
}

function jpeg_to_png() {
  set -- "${@}"
  local OUTPUT_PREFIX
  local DATA_RETENTION_DIR="${1}"
  local DATA_OUTPUT_DIR="${2}"
  OUTPUT_PREFIX=$(date +"%m-%d-%Y-%H-%M-%S")
  find "${DATA_RETENTION_DIR}" -maxdepth 1 -type f | while read -r JPEG_IMAGE; do
      DATA_OUTPUT_NAME=$(echo "${JPEG_IMAGE}" | cut -d '.' -f1)
      # require 'imagemagick'
      convert "${JPEG_IMAGE}" "${DATA_OUTPUT_DIR}"/"${DATA_OUTPUT_NAME}"."${OUTPUT_PREFIX}".png
  done
}
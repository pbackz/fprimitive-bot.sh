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
function dl_issh() { wget raw.githubusercontent.com/qzb/is.sh/latest/is.sh; }

function cleanup_issh() { rm ./is.sh*; }

function use_issh() { source ./is.sh; }

# Golang functions
function install_golang_latest() {

  local GOTOOLS="${HOME}/go/tools"
  cd "${GOTOOLS}";
  local DL_HOME=https://golang.org
  local DL_PATH_URL="$(wget --no-check-certificate -qO- https://golang.org/dl/ | grep -oP '\/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1)"
  local LATEST_VERSION_PATTERN="$(echo ${DL_PATH_URL} | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"
  echo "Finding latest version of Go for AMD64..."
  local LATEST="$(find ${GOTOOLS} -name "go*" -type f | head -n 1)"
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


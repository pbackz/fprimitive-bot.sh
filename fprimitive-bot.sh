#!/bin/bash

###################################################################
# Script Name	  : fprimitive-bot.sh                                                                                           
# Description	  : A simple bot which use fogelman/primitive
#                   binary to generate unique random image series                                                                                           
# Author       	  : Pierre Baconnier                                                
# Email           : pbackz@gmail.com
# Last updated on : 2021/13/09                                         
###################################################################

source ./utils.sh
enable_strict_mode

if ! [[ "${#}" -ge 1 ]]; then
  #usage
  exit 1
fi

function main() {
  set -- "${@}"
  use_issh
  install_requirements
  process "${@}"
}

function install_requirements() {
  # Ensure that latest go binary is installed
  if is not available "go"; then
    install_golang_latest
  fi
  # Ensure that fogelman/primitive binary is installed
  if is not available "primitive"; then
    go install github.com/fogleman/primitive@latest
  fi
  if is not available "shuf"; then
    apk add util-linux pciutils usbutils coreutils binutils findutils
  fi
}

function process() {

  set -- "${@}"
  local PRIMITIVE_BINARY
  local DATA_INPUT_DIR="${1}"
  local DATA_OUTPUT_DIR="${2}"
  local SHAPE="${3}"
  local EXTRA_SHAPES="${4}" # flag '-rep'
  local PRIMITIVES_NB="${5}"
  PRIMITIVE_BINARY=${PRIMITIVE_BINARY:-$HOME/go/bin/primitive}
  # "-j" option = Parallel workers. Default value = all cores. Ref. $(primitive --help)
  local ALPHA_VALUE=128 # default value = 128. Ref. $(primitive --help)
  local OUTPUT_IMG_SIZE=2048 # default value = 1024. Ref. $(primitive --help)
  local FILE_PREFIX="output_"
  # TODO : implement function condition to set or not verbose and background_color parameters
  local VERBOSITY=True
  #local STATIC_SHAPE=False
  # BACKGROUND_COLOR="#FF"
  # TODO : impl argument config tracer to reproduce the better result output images
  
  if is empty "${3}"; then
    SHAPE=$(shuf -i 0-9 -n 1 --random-source=/dev/urandom)
  fi
  if is empty "${4}"; then
    EXTRA_SHAPES=$(shuf -i 0-175 -n 1 --random-source=/dev/urandom)
  fi
  if is empty "${5}"; then
    PRIMITIVES_NB=$(shuf -i 1-9 -n 1 --random-source=/dev/urandom)
  fi
          
  #find "${DATA_INPUT_DIR}" -type f # shellcheck recommandation # TODO
  find "${DATA_INPUT_DIR[@]}" -maxdepth 1 -type f | while read -r IMAGE; do
      COUNTER=0
      while [ "${SHAPE}" -le 9 ] && [ "${VERBOSITY}" == "True" ] && [ "${COUNTER}" -ne 50 ]; do
          "${PRIMITIVE_BINARY}" \
          -i "${IMAGE}" \
          -o "${DATA_OUTPUT_DIR}/${FILE_PREFIX}.$(date +"%m-%d-%Y-%H-%M-%S").png" \
          -m "${SHAPE}" \
          -rep "${EXTRA_SHAPES}" \
          -n "${PRIMITIVES_NB}" \
          -s "${OUTPUT_IMG_SIZE}" \
          -a "${ALPHA_VALUE}" -v # WARN : DO NOT SET 'resize (-r)' parameter ! 
                                 # That increases memory/cpu usage and make unrecognizable output image
          
          # Comment following lines (87-95) if you want to keep arguments values
          SHAPE=$(shuf -i 1-9 -n 1 --random-source=/dev/urandom)
          EXTRA_SHAPES=$(shuf -i 0-175 -n 1 --random-source=/dev/urandom) # recognizable result artistic and abstract between 50 to 200 extra shapes
          ALPHA_VALUE=$(shuf -i 64-256 -n 1 --random-source=/dev/urandom)
          PRIMITIVES_NB=$((PRIMITIVES_NB+1))
          if (("${PRIMITIVES_NB}" > 50 )); then
              PRIMITIVES_NB=$(shuf -i 1-9 -n 1 --random-source=/dev/urandom)
          fi

          COUNTER=$((COUNTER+1))
      done
  done
}

main "${@}"
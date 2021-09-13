#!/bin/bash

###################################################################
# Script Name	  : fprimitive-bot.sh                                                                                           
# Description	  : A simple bot which use fogelman/primitive
#                 binary to generate unique random image series                                                                                           
# Author       	  : Pierre Baconnier                                                
# Email           : pbackz@gmail.com
# Last updated on : 2021/13/09                                         
###################################################################

source ./utils.sh
enable_strict_mode

function usage() {
  echo "Automation script to generate random unique image series using fogleman/primitive"
  echo ""
  echo "USAGE: ./fprimitive-bot.sh <DATA_INPUT_DIR> <DATA_OUTPUT_DIR>"
  echo "                           <SHAPE:-{0..9}>"
  echo "                           <EXTRA_SHAPES:-{0..175}>"
  echo "                           <PRIMITIVES_NB:{1..9}>"
  echo "                           [-a=<alpha>|--alpha-value=<alpha:-128>]"
  echo "                           [-o=<output_size:-1024>|--output-size=<output_size:-1024>]"
  echo "                           [-p=<prefix:-output_>|--file-prefix=<prefix:-output_>]"
  echo "                           [-v=<verbose:-true>|--verbosity=<verbose:-true>]"
  echo "  Where:"
  echo "    DATA_INPUT_DIR         Required. The source directory to store images before processing. Must be 1st arg"
  echo "    DATA_OUTPUT_DIR        Required. The destination directory to store images after processing. Must be 2nd arg"
  echo "    SHAPE                  The form of shape. Valid values are {0..9}. Must be 3rd arg"
  echo "    EXTRA_SHAPES           The number of extra shapes. Recommanded values are {0..175}. Must be 4th arg"
  echo "    PRIMITIVES_NB          The number of primitives. Recommanded values are {1..12}. Must be 5th arg"
  echo "    -h or --help           Show help"
  echo "    -a or --alpha-value    Alpha value of image output. Default is 128"
  echo "    -o or --output-size    Image output size. Default is 1024"
  echo "    -p or --file-prefix    File prefix in output directory. Default is 'output_'"
  echo "    -v or --verbosity      Set or not verbosity. Default is true"
  echo " "
  exit
}

function processArgs() {
  if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    usage; else
    for i in $ARGS ; do
      case $i in
      -h|--help)
        usage
        ;;
      -a=*|--alpha-value=*)
        ALPHA_VALUE="${i#*=}"
        ;;
      -o=*|--output-size=*)
        OUTPUT_IMG_SIZE="${i#*=}"
        ;;
      -p=*|--file-prefix=*)
        FILE_PREFIX="${i#*=}"
        ;;
      -v|--verbosity)
        VERBOSITY="${i#*=}"
        ;;
      esac
    done
  fi
  if [ $# -lt 2 ]; then
    echo "Less or equal 2 minimum arguments"
    usage; exit;
  fi
}

function main() {
  set -- "${@}"
  use_issh
  install_requirements
  processArgs "${@}" 
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
}

function process() {

  set -- "${@}"
  local PRIMITIVE_BINARY
  local DATA_INPUT_DIR="${1}"
  local DATA_OUTPUT_DIR="${2}"
  #local SHAPE="${3}"
  #local EXTRA_SHAPES="${4}" # flag '-rep'
  #local PRIMITIVES_NB="${5}"
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
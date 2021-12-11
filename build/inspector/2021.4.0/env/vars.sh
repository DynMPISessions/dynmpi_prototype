#!/bin/bash

show_help()
{
  printf 'ERROR: This script must be sourced\n'
  printf 'Usage:\n'
  printf '\tsource %q\n' "$1"
  printf '\tor\n'
  printf '\t. %q\n' "$1"
  exit 2
}

get_product_dir()
{
  script="$1"
  while [ -L "$script" ]; do
    script_dir="$( dirname "$script" )"
    script_dir="$( cd "$script_dir" && pwd -P )"
    script="$(readlink "$script" )"
    if [ ${script} != '/*' ]; then
        script="$script_dir/$script"
    fi
  done
  script_dir="$( dirname "$script" )"
  script_dir="$( cd "$script_dir" && pwd -P )"
  script_dir="$( dirname "$script_dir" )"
  echo "$script_dir"
}

if [ -n "$ZSH_VERSION" ]; then
  [[ $ZSH_EVAL_CONTEXT == *:file* ]] && SCRIPT="${(%):-%x}" || show_help "${(%):-%x}"
elif [ -n "$KSH_VERSION" ]; then
  if whence -a whence > /dev/null 2>&1; then
    [[ $(cd "$(dirname -- "$0")" && printf '%s' "${PWD%/}/")$(basename -- "$0") != \
    "${.sh.file}" ]] && SCRIPT="${.sh.file}" || show_help "$0"
  else
    case ${KSH_VERSION:-} in (*MIRBSD*KSH*|*LEGACY*KSH*)
        SCRIPT="$( (echo "${.sh.file}") 2>&1 )" || : ;
        SCRIPT="$( expr "${SCRIPT:-}" : '^.*sh: \(.*\)\[[0-9]*\]:')" ;
    esac

  fi
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && SCRIPT="${BASH_SOURCE[0]}" || show_help "${BASH_SOURCE[0]}"
else
  case ${0##*/} in (sh|dash)
      SCRIPT="$( (echo "${.sh.file}") 2>&1 )" || : ;
      SCRIPT="$( expr "${SCRIPT:-}" : '^.*sh: [0-9]*: \(.*\):')" ;
  esac
fi

PRODUCT_DIR=$(get_product_dir "$SCRIPT")

if [ $(uname) = 'Darwin' ]; then
BIN_DIR=
else
  if [ $(uname -m) = 'x86_64' ]; then
BIN_DIR=bin64
    export PKG_CONFIG_PATH="$PRODUCT_DIR/include/pkgconfig/lib64:$PKG_CONFIG_PATH"
  else
BIN_DIR=bin32
    export PKG_CONFIG_PATH="$PRODUCT_DIR/include/pkgconfig/lib32:$PKG_CONFIG_PATH"
  fi
fi

export PATH="$PRODUCT_DIR/$BIN_DIR":"$PATH"

export INSPECTOR_2021_DIR="$PRODUCT_DIR"



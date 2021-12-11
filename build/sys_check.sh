#!/usr/bin/env bash
# shellcheck disable=SC2128

# Copyright 2019 Intel Corporation
# SPDX-License-Identifier: MIT

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# ############################################################################

# Overview

# This is the top-level sys_check.sh script for use with Intel oneAPI
# toolkits. Most "tools" or "components" that are part of an Intel oneAPI
# installation include a `sys_check/sys_check.sh` script that can help uncover
# possible issues, such as missing dependencies, missing or incorrect
# environment variables, OS and hardware requirements, etc.

# NOTE: this script is expected to work with Bash 3.x as well as Bash 4.x, in
# order to be usable on both Linux and macOS systems. This means unique Bash
# 4.x features must be avoided (most notably, Bash array variables).


# ############################################################################

# Globals

sys_chk_args=""
config_file=""
config_array=""
component_array=""
posix_nl='
'


# ############################################################################

# To be called if we encounter bad command-line args or user asks for help.

# Inputs:
#   none
#
# Outputs:
#   message to stdout

script_name=sys_check.sh

usage() {
  echo "  "
  echo "usage: ${script_name}" '[--force] [--config=file] [--help] [...]'
  echo "  -v, --verbose  verbose output"
  echo "  --config=file  customize scan using a ${script_name} configuration file"
  echo "                 search for 'using a config file for setvars.sh' for more info"
  echo "  ...            extra args are passed to individual sys_check/sys_check.sh scripts"
  echo "  "
  echo "  --help         display this help message and exit"
  echo "  "
}


# ############################################################################

# Get absolute pathname to script, when sourced from bash, zsh and ksh shells.
# see https://stackoverflow.com/a/29835459/2914328 for detailed "how it works"
#
# This POSIX-compliant shell function implements an equivalent to the GNU
# `readlink -e` command and is a reasonably robust solution that only fails in
# two rare edge cases:
#   * paths with embedded newlines (very rare)
#   * filenames containing literal string " -> " (also rare)

# Usage:
#   script_path=$(rreadlink "$vars_script_rel_path")
#   script_dir_path=$(dirname -- "$(rreadlink "$vars_script_rel_path")")
#
# Inputs:
#   relative/pathname/script_name
#
# Outputs:
#   /absolute/pathname/script_name

# executing function in a *subshell* to localize vars and effects on `cd`
rreadlink() (
  target=$1 fname="" targetDir="" CDPATH=
  { \unalias command; \unset -f command; } >/dev/null 2>&1
  # shellcheck disable=SC2034
  [ -n "$ZSH_VERSION" ] && options[POSIX_BUILTINS]=on
  while :; do
    [ -L "$target" ] || [ -e "$target" ] || { command printf '%s\n' ":: ERROR: rreadlink(): '$target' does not exist." >&2; return 1; }
    command cd "$(command dirname -- "$target")" >/dev/null 2>&1 || { command printf '%s\n' ":: ERROR: rreadlink() processing failure" >&2; return 1; }
    fname=$(command basename -- "$target")
    [ "$fname" = '/' ] && fname=''
    if [ -L "$fname" ] ; then
      target=$(command ls -l "$fname")
      target=${target#* -> } # delete everything left of first " -> " string
      continue
    fi
    break
  done
  targetDir=$(command pwd -P)
  if   [ "$fname" = '.' ] ;  then
    command printf '%s\n' "${targetDir%/}"
  elif [ "$fname" = '..' ] ; then
    command printf '%s\n' "$(command dirname -- "${targetDir}")"
  else
    command printf '%s\n' "${targetDir%/}/$fname"
  fi
)


# ###########################################################################

# Make sure we are being executed, not sourced.
# Why do we care? Because we want to _only_ run in a Bash shell.

if [ "$0" != "${BASH_SOURCE}" ] ; then
  echo ":: ERROR: Incorrect usage: \"$script_name\" must be executed, not sourced." ;
  usage
  return 255 2>/dev/null || exit 255
fi


# ############################################################################

# Determine path to this file ($BASH_SOURCE) and confirm use of supported OS.
# Expects to be located at the top (root) of the oneAPI install directory.

os=$(uname -s)
case $os in
  (Darwin)
    script_root=$(dirname -- "$(rreadlink "${BASH_SOURCE[0]}")")
    script_name=$(basename -- "${BASH_SOURCE[0]}")
    ;;
  (Linux)
    script_root=$(dirname "$(realpath -e "${BASH_SOURCE[0]}")")
    script_name=$(basename -- "${BASH_SOURCE[0]}")
    ;;
  (*)
    echo ":: ERROR: Unsupported OS: $os"
    exit 255
    ;;
esac


# ############################################################################

# Since bash 3.x does not support array variables, we will use the "for arg
# do" loop (no "in" operator) that implicitly relies on the positional
# arguments array ($@). There is only one $@ array; this function saves that
# array in a format that can be restored to the $@ array at a later time.

# see http://www.etalabs.net/sh_tricks.html ("Working with arrays" section)

# Usage:
#   array_var=$(save_args "$@")
#   eval "set -- $array_var" # restores saved array to the $@ variable
#
# Inputs:
#   The $@ array.
#
# Outputs:
#   Cleverly encoded string that represents the $@ array.

save_args() {
  for arg do
    printf "%s\n" "$arg" | sed -e "s/'/'\\\\''/g" -e "s/^/'/" -e "\$s/\$/' \\\\/"
  done
  # echo needed to pickup final continuation "\" so it's not added as an arg
  echo " "
}


# ############################################################################

# Convert a list of '\n' terminated strings into a format that can be moved
# into the positional arguments array ($@) using the eval "set -- $array_var"
# command. It removes blank lines from the list (awk 'NF') in the process. It
# is not possible to combine the prep and eval steps into a single function
# because you lose the context that contains the resulting "$@" array upon
# return from this function.

# Usage:
#   eval set -- "$(prep_for_eval "$list_of_strings_with_nl")"
#
# Inputs:
#   The passed parameter is expected to be a collection of '\n' terminated
#   strings (e.g., such as from a find or grep command).
#
# Outputs:
#   Cleverly encoded string that represents the $@ array.

prep_for_eval() {
  echo "$1" | awk 'NF' | sed -e "s/^/'/g" -e "s/$/' \\\/g" -e '$s/\\$//'
}


# ############################################################################

# Interpret command-line arguments passed to this script and remove them.
# see https://unix.stackexchange.com/a/258514/103967
# TODO: consider removing support for config file, limited value here

help=0
config=0
config_file=""

# Save a master copy of the arguments array ($@) passed to this script so we
# can restore it, if needed later.

for arg do
  shift
  case "$arg" in
    (--help)
      help=1
      ;;
    (--config=*)
      config=1
      config_file="$(expr "$arg" : '--config=\(.*\)')"
      ;;
    (*)
      set -- "$@" "$arg"
      ;;
  esac
  # echo "\$@ = " "$@"
done

# Save a copy of the arguments array ($@) to be passed to the sys_check
# sub-scripts. This copy excludes any arguments consumed by this script.
sys_chk_args=$(save_args "$@")

if [ "$help" != "0" ] ; then
  usage
  exit 254
fi


# If a config file has been supplied, check that it exists and is readable.
if [ "$config" -eq 1 ] ; then
  # fix problem "~" alias, in case it is part of $config_file pathname
  config_file_fix=$(printf "%s" "$config_file" | sed -e "s:^\~:$HOME:")
  config_file_fix=$(rreadlink "$config_file_fix")
  if [ ! -r "$config_file_fix" ] ; then
    echo ":: ERROR: $script_name config file could not be found or is not readable."
    echo "   Confirm that \"${config_file}\" path and filename are valid and readable."
    exit 4
  fi
fi


# ############################################################################

# Find those components in the installation folder that include a
# `sys_check.sh` script. We need to "uniq" that list to remove duplicates,
# which happens when multiple versions of a component are installed
# side-by-side.

component_array=$(find "$script_root" -mindepth 4 -maxdepth 4 -path "*/sys_check/sys_check.sh" | awk 'NF')

temp_array=""
eval set -- "$(prep_for_eval "$component_array")"
for arg do
  arg=$(basename -- "$(dirname -- "$(dirname -- "$(dirname -- "$arg")")")")
  temp_array=${temp_array}${arg}$posix_nl
done
component_array=$temp_array

# eliminate duplicate component names and
# get final count of $component_array elements
component_array="$(printf "%s\n" "$component_array" | uniq)"
temp_var=$(printf "%s\n" "$component_array" | wc -l)

if [ "$temp_var" -le 0 ] ; then
  echo ":: ERROR: No components found: No \"sys_check/sys_check.sh\" scripts found."
  echo "   The \"${script_name}\" script expects to be located in the installation folder."
  exit 5
fi


# ############################################################################

# At this point, if a config file was provided, it is readable.
# Put contents of $config_file into $config_array, and validate content.
# TODO: condense this section; probably not worth the effort.

version_default="latest"

if [ "$config" = "1" ] ; then

  # get the contents of the $config_file and eliminate blank lines
  config_array=$(awk 'NF' "$config_file_fix")
  temp_array=$(printf "%s\n" "$config_array" | tr "\n" " ")

  # Test $config_file: do the requested component paths exist?
  eval set -- "$(prep_for_eval "$config_array")"
  for arg do
    arg_base=$(expr "$arg" : '\(.*\)=.*')
    arg_verz=$(expr "$arg" : '.*=\(.*\)')
    arg_path=${script_root}/${arg_base}/${arg_verz}/sys_check/sys_check.sh
    # skip test of "default=*" entry here, do it later
    if [ "default" = "$arg_base" ] ; then
      continue
    # skip test of "*=exclude" entry here, do it later
    elif [ "exclude" = "$arg_verz" ] ; then
      continue
    elif [ ! -r "$arg_path" ] || [ "" = "$arg_base" ] ; then
      echo ":: ERROR: Bad config file entry: Unknown component specified."
      echo "   Confirm that \"$arg\" contains a \"sys_check/sys_check.sh\" script."
      exit 6
    fi
  done

  # Test $config_file: do the requested component versions exist?
  eval set -- "$(prep_for_eval "$config_array")"
  for arg do
    arg_base=$(expr "$arg" : '\(.*\)=.*')
    arg_verz=$(expr "$arg" : '.*=\(.*\)')
    arg_path=${script_root}/${arg_base}/${arg_verz}/sys_check/sys_check.sh
    # perform "default=*" test we skipped above
    if [ "default" = "$arg_base" ] && [ "exclude" != "$arg_verz" ]; then
      echo ":: ERROR: Bad config file entry: Invalid \"$arg\" entry."
      echo "   \"default=exclude\" is the only valid \"default=\" statement."
      exit 7
    elif [ "default" = "$arg_base" ] && [ "exclude" = "$arg_verz" ]; then
      version_default=$arg_verz
      continue
    # perform "*=exclude" test we skipped above (except "default=exclude")
    elif [ "exclude" = "$arg_verz" ] ; then
      # no need to validate the component name, since this is an exclude
      # "*=exclude" lines are ignored when we call the sys_check/sys_check.sh scripts
      continue
    elif [ ! -r "$arg_path" ] || [ "" = "$arg_verz" ] ; then
      echo ":: ERROR: Bad config file entry: Unknown version \"$arg_verz\" specified."
      echo "   Confirm that \"$arg\" entry in \"$config_file\" is correct."
      exit 8
    fi
  done

fi


# ############################################################################

# After completing the previous section we have determined the final
# "$version_default" value. It defaults to "latest" but could have been
# changed by the $config_file to "exclude" by a "default=exclude" statement.

# add $version_default to all $component_array elements
eval set -- "$(prep_for_eval "$component_array")"
temp_array=""
for arg do
  arg=${arg}"="${version_default}
  temp_array=${temp_array}${arg}$posix_nl
done
component_array=$temp_array


# ############################################################################

# If a config file was provided, add it to the end of our $component_array,
# but only after first removing from the $component_array those that are in
# the $config_array, so we do not process a component twice.

if [ "$config" = "1" ] ; then

  # remove components from $component_array that are in $config_array
  eval set -- "$(prep_for_eval "$config_array")"
  for arg do
    arg_base=$(expr "$arg" : '\(.*\)=.*')
    component_array=$(printf "%s\n" "$component_array" | sed -e "s/^$arg_base=.*$//")
  done

  # append $config_array to $component_array to address what we removed
  component_array=${component_array}${posix_nl}${config_array}${posix_nl}

fi

# remove any blank lines resulting from all prior operations
component_array=$(printf "%s\n" "$component_array" |  awk 'NF')

# source the list of components in the $component_array
eval set -- "$(prep_for_eval "$component_array")"

RESULT=0

for arg do
  arg_base=$(expr "$arg" : '\(.*\)=.*')
  arg_verz=$(expr "$arg" : '.*=\(.*\)')
  arg_path=${script_root}/${arg_base}/${arg_verz}/sys_check/sys_check.sh
  # echo ":: $arg_path"

  if [ "exclude" = "$arg_verz" ] ; then
    continue
  else
    if [ -r "$arg_path" ] ; then
      echo ":: $arg_base -- $arg_verz"
      # shellcheck disable=SC1090
      (eval set -- "$sys_chk_args" ; source "$arg_path" "$@")
      R=$?
      RESULT=$((R + RESULT))
    else
      continue
    fi
  fi
done


if [ "$RESULT" -eq 0 ] ; then
  echo -e "${GREEN}No Issues Encountered.${NC}"
  exit 0
else
  echo -e "${RED}Issues Encountered.${NC}"
  exit "$RESULT"
fi

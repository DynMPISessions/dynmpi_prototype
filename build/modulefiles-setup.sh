#!/bin/sh
# shellcheck shell=sh

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

# This script collects all the available oneAPI modulefiles and organizes them
# into a folder that can be added to the $MODULEPATH env variable or by way of
# the "module use" command. For each tool/component that is found in the
# oneAPI installation folder, all available versions of modulefiles associated
# with that tool/component are added to the final output folder.

# NOTE: this script is expected to work on Linux and macOS. This means we
# must be sure to avoid GNU options with external commands since macOS tends
# to use older BSD commands.


# ############################################################################

# To be called if we encounter bad command-line args or user asks for help.

# Inputs:
#   none
#
# Outputs:
#   message to stdout

script_name=$(basename -- "$0")

usage() {
  echo "  "
  echo "usage: ${script_name}" '[--output-dir=dir]' '[--help]'
  echo "  "
  echo "Scans the oneAPI installation folder for available modulefiles and organizes"
  echo "them into a single folder that can be added to the \$MODULEPATH environment"
  echo "variable or by using the 'module use' command. For each tool or library that"
  echo "is found in the oneAPI installation folder, all versions available for those"
  echo "tools and libraries are added to the output folder."
  echo "  "
# TODO: change output-dir default to ~/modulefiles ; see also TODO below
  echo "  --output-dir=path/to/folder/name"
  echo "    Specify path/name of folder to contain oneAPI modulefile links."
  echo "    Default location is 'modulefiles' folder inside the oneAPI install dir."
  echo "      e.g., --output-dir=~/intel-oneapi-modulefiles"
  echo "  "
  echo "  --force"
  echo "    Force replacement of modulefiles output directory without warning."
  echo "  "
  echo "  --ignore-latest"
  echo "    Ignore (do not include) the \"latest\" version symlink in the list of"
  echo "    modulefiles created in the modulefiles output directory. Add only the"
  echo "    versioned modulefiles into the modulefiles output directory."
  echo "  "
  echo "  --help"
  echo "    Display this help message and exit."
  echo "  "
}

# TODO: add support for input folder option
#   echo "  --input-dir=path/to/oneapi/install/dir"
#   echo "    Specify oneAPI installation directory to be scanned."
#   echo "    Multiple instances of --input=dir are allowed."
#   echo "    Defaults to folder containing this script."
#   echo "  "


# ############################################################################

# Get absolute path to script. **NOTE:** `readlink` is not a POSIX command!!
# Uses `readlink` to remove links and `pwd -P` to turn into an absolute path.
# see also: https://stackoverflow.com/a/12145443/2914328

# Usage:
#   script_dir=$(get_script_path "$script_rel_path")
#
# Inputs:
#   script/relative/pathname/scriptname
#
# Outputs:
#   /script/absolute/pathname

# executing function in a *subshell* to localize vars and effects on `cd`
get_script_path() (
  script="$1"
  while [ -L "$script" ] ; do
    # combining next two lines fails in zsh shell
    script_dir=$(command dirname -- "$script")
    script_dir=$(cd "$script_dir" && command pwd -P)
    script="$(readlink "$script")"
    case $script in
      (/*) ;;
       (*) script="$script_dir/$script" ;;
    esac
  done
  # combining next two lines fails in zsh shell
  script_dir=$(command dirname -- "$script")
  script_dir=$(cd "$script_dir" && command pwd -P)
  echo "$script_dir"
)


# ###########################################################################

# Make sure we are being executed, not sourced.
# Making this detection for a variety of /bin/sh impersonators is overkill.
# If it becomes necessary to do that, we can add support right here.

# if [ "$0" != "${BASH_SOURCE}" ] ; then
#   echo "  "
#   echo ":: ERROR: Incorrect usage: \"$script_name\" must be executed, not sourced." ;
#   usage
#   return 255 2>/dev/null || exit 255
# fi


# ############################################################################

# Interpret command-line arguments passed to this script.
# Set the default location for the final modulefiles output folder.
# see https://unix.stackexchange.com/a/258514/103967

# TODO: change modulesoutdir default to ~/modulefiles ; see also TODO above

opthelp=0
optforce=0
optignorelatest=0
script_root=$(get_script_path "${0}")
#modulesoutdir=${HOME}/modulefiles
modulesoutdir=${script_root}/modulefiles

for arg do
  shift
  case "$arg" in
    (--help)
      opthelp=1
      ;;
    (--force)
      optforce=1
      ;;
    (--ignore-latest)
      optignorelatest=1
      ;;
    (--output-dir=*)
      modulesoutdir="$(expr "$arg" : '--output-dir=\(.*\)')"
      ;;
    (*)
      set -- "$@" "$arg"
      ;;
  esac
  # echo "\$@ = " "$@"
done

# Fix pesky '~' alias, if $modulesoutdir happens to start with it.
modulesoutdir=$(printf "%s" "$modulesoutdir" | sed -e "s:^\~:$HOME:")

if [ "$opthelp" != "0" ] ; then
  usage
  return 254 2>/dev/null || exit 254
fi


# ############################################################################

# Create the output modulefiles directory.
# Clean it up in case of a pre-existing copy.

echo ":: Initializing oneAPI modulefiles folder ..."
echo ":: Removing any previous oneAPI modulefiles folder content."

# Create the modulefiles output folder.
# Ask user if okay to clean a pre-existing modulefiles output folder.
# Using the "--force" command-line option assumes answer is "yes."

optyn=n
if [ -e "$modulesoutdir" ] && [ "$optforce" = "0" ] ; then
  while true ; do
    echo ":: WARNING: \"$modulesoutdir\" exists and will be deleted."
    command -p read -p "   Okay to proceed with deletion? [yn] " optyn
    case $optyn in
      ([Yy])  optforce=1 ; break ;;
      ([Nn])  optforce=0 ; break ;;
      (*)     echo "   Please answer y or n." ;;
    esac
  done
fi

if ! command -p mkdir -p "$modulesoutdir" ; then
  echo ":: ERROR: Creation of \"$modulesoutdir\" folder failed."
  echo "   Can be caused by read-only target or existing file of same name."
  exit 1
fi
if [ "$optforce" = "1" ] ; then
  if ! command -p rm -rf "$modulesoutdir"/* ; then
    echo ":: ERROR: Deletion of \"$modulesoutdir\" folder failed."
    echo "   Can be caused by read-only target or existing file of same name."
    exit 2
  fi
fi


# ############################################################################

# Process oneAPI components.
# Scan for modulefiles and create symlinks in the modulefiles output folder.
# Usage of `find ... -mindepth ... -maxdepth` may fail on BSD (e.g., macOS).
# TODO: `find` options usage described above is not POSIX compliant.
# TODO: May be worth considering use of `ls` instead of `find`.

echo ":: Generating oneAPI modulefiles folder links."

# each subdirectory is a potential oneAPI "component"
# make sure each "component" variable ends with a trailing '/' character
for component in $(command -p ls -d "$script_root"/*/) ; do
  versiondircount=$(find "$component" -mindepth 1 -maxdepth 1 -type d | wc -l)
  if [ "$versiondircount" -gt 0 ] ; then

    # each subdirectory of a component is a version specifier
    # using 'ls -d' rather than find because it sees symlinked dirs
    for versiondir in $(command -p ls -d "$component"*/) ; do
      version=$(basename "$versiondir")
      modulefilesindir=${versiondir}modulefiles

      # if --ignore-latest option was provided, skip "latest" versiondir
      if [ "$version" = "latest" ] && [ "$optignorelatest" != "0" ] ; then
        continue ;
      fi

      if [ -d "$modulefilesindir" ] ; then
        files="$modulefilesindir/*"
        for modulefile in $files ; do
          modulename=$(basename "$modulefile")

          # resolve modulefiles that were symlinked into expected location
          if [ -h "$modulefile" ] ; then
            modulefile="$(get_script_path "$modulefile")/${modulename}"
          fi

          echo ":: ${modulename}/${version} -> $modulefile"

          # create module directory
          if [ ! -d "$modulesoutdir/$modulename" ] ; then
            if ! command -p mkdir -p "$modulesoutdir/$modulename" ; then
              echo ":: ERROR: Creation of \"$modulesoutdir/$modulename\" folder failed."
              echo "   Can be caused by read-only target or existing file of same name."
              return 3 2>/dev/null || exit 3
            fi
          fi
          # create a symlink to the modulefile located in the install dir
          # TODO: -f option may be dangerous, seek alternate option
          if ! command -p ln -fs "$modulefile" "$modulesoutdir/$modulename/$version" ; then
            echo ":: ERROR: Creation of \"$modulesoutdir/$modulename/$version\" symlink failed."
            echo "   Can be caused by read-only target or existing file of same name."
            return 4 2>/dev/null || exit 4
          fi
        done
      fi

    done

  fi
done

echo ":: oneAPI modulefiles folder initialized."
echo ":: oneAPI modulefiles folder is here: \"$modulesoutdir\""

#!/bin/bash
# shellcheck disable=SC2034

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

# Support for -v (verbose) flag and 'speak' function.
# Use 'speak' if you want to echo only verbose is enabled.
#
# Colors are defined to be used with echo or speak (with the -e flag).
# example:
#   echo -e "the roof, the roof, the roof is ${RED}on fire${NC}!!"

# when using colors, be sure to ALWAYS bookend you usage with ${NC} (No Color)
# or you will affect the output for everyone. The following colors have been
# defined: GREEN, RED, CYAN and NC (No Color).


# capture verbose flag from supplied arguments
VERBOSE=false

for arg do
  shift
  case "$arg" in
    (-v|--verbose)
      VERBOSE=true
      ;;
    (--)
      ;;
    (*)
      set -- "$@" "$arg"
      ;;
  esac
  # echo "\$@ = " "$@"
done


# ############################################################################

# Speak() accepts the same arguments as echo.
# Speak() only echoes if the verbose flag is set.

# Usage:
#   speak "text to echo when verbose enabled")
#   see commented sample code, below
#
# Inputs:
#   one or more strings
#
# Outputs:
#   the text strings if verbose was enabled

speak() {
  if [ "$VERBOSE" = "true" ] ; then
    echo -e "$@"
  fi
}

# constants for color
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color


# ############################################################################

# sample speak() usage

# ping -c1 -W1 -q example.com &>/dev/null
# status=$(echo $?)
# if [[ $status == 0 ]] ; then
#   speak -e "  Internet connection is ${GREEN}working${NC}!"
# else
#   echo -e "  Internet connection is ${RED}not working${NC}!"
#   speak -e "  'ping -c1 -W1 -q example.com' reported ${CYAN}$status${NC} return code."
# fi

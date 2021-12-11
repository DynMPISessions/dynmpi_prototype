#!/bin/csh

set command=($_)
if ( "$command" != "" ) then
    set script_fn = "$command[2-]"
    set script = `eval "readlink -e $command[2-]"`
    set script_dir = `dirname "$script"`
    set product_dir = `cd "$script_dir/.." && pwd -P`
else
    printf 'ERROR: This script should be sourced\n'
    printf 'Usage:\n'
    printf '\tsource %q\n' "$0"
    exit 2
endif

if ( `uname` == "Darwin" ) then
set bin_dir =
else
    set platform = `uname -m`
    if ( $platform == "x86_64" ) then
set bin_dir = bin64
set lib_dir = lib64
    else
set bin_dir = bin32
set lib_dir = lib32
    endif
    if ! $?PKG_CONFIG_PATH then
        setenv PKG_CONFIG_PATH
    endif
    setenv PKG_CONFIG_PATH "$product_dir/include/pkgconfig/$lib_dir"\:"$PKG_CONFIG_PATH"
endif
setenv PATH "$product_dir/$bin_dir"\:"$PATH"
setenv INSPECTOR_2021_DIR "$product_dir"


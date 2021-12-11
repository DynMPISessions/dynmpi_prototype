#!/bin/bash

set -e

# Allow this script to be run from outside of the forge dir
FORGE_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$FORGE_DIR"

source libexec/papi_common.sh

echo "Welcome to the installer for 'PAPI metrics for Arm MAP'"
echo "***********************************************************"
echo

PAPI_CUSTOM_METRIC_SRC_FILE="map/metrics/papi/lib-papi.c"
PAPI_DEFAULT_DIR=""
PAPI_LIB_DIR=""
PAPI_INC_DIR=""
SET_PAPI_DIRS="false"

# try to find PAPI installation directory
PAPI_AVAIL_DIR="$(which papi_avail)"
if [ -n "$PAPI_AVAIL_DIR" ]; then
    PAPI_DEFAULT_DIR="$(dirname $(dirname $PAPI_AVAIL_DIR))";
fi

# if a directory is found, tell the user
if [ -e "$PAPI_DEFAULT_DIR/lib/libpapi.so" ]; then
    echo "The PAPI library was found in $PAPI_DEFAULT_DIR/lib/";
    read -p "Do you want to use this PAPI library installation? [Y/N] " answer
    case $answer in
        [yY]*)
            PAPI_LIB_DIR=$PAPI_DEFAULT_DIR/lib
            PAPI_INC_DIR=$PAPI_DEFAULT_DIR/include
            ;;
        *)
          SET_PAPI_DIRS="true"
          ;;
    esac
else
    echo "PAPI library has not been automatically found on this computer";
    SET_PAPI_DIRS="true"
fi

if [ $SET_PAPI_DIRS == "true" ]; then
    echo "Please enter the directory of the PAPI library to be used by Arm MAP (e.g. /usr/lib): ";
    read -r PAPI_LIB_DIR;
    echo
    echo "Please enter the PAPI include directory (default /usr/include): ";
    read -r PAPI_INC_DIR;
    echo
    PAPI_INC_DIR=${PAPI_INC_DIR:-/usr/include}
fi

# check that the directory is valid (by checking that the libpapi.so file exists), and while it is not, ask the user for a valid directory
while [ ! -e $PAPI_LIB_DIR/libpapi.so ]
do
    echo "The PAPI installation directory you have chosen is invalid, $PAPI_LIB_DIR/libpapi.so doesn't exist"
    echo "Please enter the directory of the PAPI library to be used by Arm MAP (e.g. /usr/lib): ";
    read -r PAPI_LIB_DIR;
done

# find out where to install the metrics
echo "Type of installation? [S]ystem-wide/[P]ersonal"
read installation

while true; do
    case $installation in
        [sS]*)
            # for application-wide installation, the metrics will go in forge/map/metrics
            # and the perf-report xmls will go in forge/performance-reports/templates/partial-reports

            METRICS_DIR=$PWD/map/metrics
            PARTIAL_REPORTS_DIR=$PWD/performance-reports/templates/partial-reports

            # If the partial reports directory is missing, create it if possble
            if [ ! -d $PARTIAL_REPORTS_DIR ] && [ -w $PWD ]; then
              mkdir -p $PARTIAL_REPORTS_DIR
            fi
            # check that the user has write permissions to install directories
            # If the previous creation stage failed, this error will print out.
            if [ ! -w $METRICS_DIR ] || [ ! -w $PARTIAL_REPORTS_DIR ]; then
                echo "You do not have permission to make a system-wide installation.";
                exit
            fi
            break
            ;;

        [pP]*)
            # for personal installation, the metrics will go in .allinea/map/metrics
            # and the perf-report xmls will go in .allinea/perf-report/reports
            if [ -z "$ALLINEA_CONFIG_DIR" ]; then
                METRICS_DIR=$HOME/.allinea
                PARTIAL_REPORTS_DIR=$HOME/.allinea
            else
                METRICS_DIR=$ALLINEA_CONFIG_DIR
                PARTIAL_REPORTS_DIR=$ALLINEA_CONFIG_DIR
            fi

            METRICS_DIR=$METRICS_DIR/map/metrics
            PARTIAL_REPORTS_DIR=$PARTIAL_REPORTS_DIR/perf-report/reports

            break
            ;;
        *)
            echo "Unrecognised input. "
            echo "Type of installation? [S]ystem-wide/[P]ersonal"
            echo "Enter 'S' for a system-wide installation or 'P' for a personal installation: ";
            read installation;
            ;;
    esac
done

function install_metrics {

    mkdir -p $METRICS_DIR
    mkdir -p $PARTIAL_REPORTS_DIR

    echo "Installing PAPI metrics..."
    echo

    # compile the PAPI metrics library
    if gcc -fPIC -Imap/metrics/include -I$PAPI_INC_DIR -o $METRICS_DIR/lib-papi.so $PAPI_CUSTOM_METRIC_SRC_FILE -L$PAPI_LIB_DIR -lpapi -shared -Wl,-rpath=$PAPI_LIB_DIR; then
        # copy the XML file to where it should be
        cp map/metrics/papi/papi.xml $METRICS_DIR
        cp map/metrics/papi/PAPI.config $METRICS_DIR

        # copy partial reports to folder
        cp map/metrics/papi/report-papi-overview.xml $PARTIAL_REPORTS_DIR
        cp map/metrics/papi/report-papi-floatpoint.xml $PARTIAL_REPORTS_DIR
        cp map/metrics/papi/report-papi-branch.xml $PARTIAL_REPORTS_DIR
        cp map/metrics/papi/report-papi-cache-misses.xml $PARTIAL_REPORTS_DIR

        echo "Installation complete"
        echo
        # prompt the user to set the environment variables
        echo "Set the following environment variable before starting Arm MAP: "
        echo "        export ALLINEA_PAPI_CONFIG=$METRICS_DIR/PAPI.config"
        echo
        echo "If you are using a queuing system you should also set and export ALLINEA_PAPI_CONFIG to the compute nodes."
        echo "This can be done by adding the ALLINEA_PAPI_CONFIG export line in the job script before the MAP command line."

    else
        echo "Error: Installation failed"
    fi
}

# determine if PAPI metrics were previously installed
if check_metric_files; then
    # give option to overwrite/remove existing PAPI metrics installation
    echo "Existing PAPI metrics file were detected. [O]verwrite/[U]ninstall"
    read option

    while true; do
        case $option in
            [oO]*)
                install_metrics
                break
                ;;

            [uU]*)
                rm -f $(get_metric_files)
                if check_metric_files; then
                    echo "Error: Uninstallation failed"
                else
                    echo "PAPI metrics were uninstalled successfully."
                    echo
                fi
                break
                ;;
            *)
                echo "Unrecognised input. "
                echo "Existing PAPI metrics file were detected. [O]verwrite/[U]ninstall"
                echo "Enter 'O' to overwrite an existing installation or 'U' to uninstall: ";
                read option;
                ;;
        esac
    done
else
    install_metrics
fi

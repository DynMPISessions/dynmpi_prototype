#!/bin/bash

set -e

ALLINEA_CONFIG_DIR=${ALLINEA_CONFIG_DIR:-$HOME/.allinea}
FORGE_DIR=$(cd "$(dirname "$0")" && pwd)

# Allow this script to be run from outside of the forge dir
cd "$FORGE_DIR"

source libexec/papi_common.sh

echo "Type of installation? [S]ystem-wide/[P]ersonal"
read -r installation
echo

case $installation in
    [sS]*)
        METRICS_DIR=$PWD/map/metrics
        PARTIAL_REPORTS_DIR=$PWD/performance-reports/templates/partial-reports
        ;;
    [pP]*)
        METRICS_DIR="$ALLINEA_CONFIG_DIR/map/metrics"
        PARTIAL_REPORTS_DIR="$ALLINEA_CONFIG_DIR/performance-reports/templates/partial-reports"
        ;;
    *)
        echo "Error: Unrecognised input."
        exit 1
        ;;
esac

if check_metric_files
then
    METRIC_FILES=$(get_metric_files)
    (set -x; rm -f $METRIC_FILES)
    echo
    if check_metric_files
    then
        echo "Error: Uninstallation failed"
    else
        echo "PAPI metrics were uninstalled successfully."
    fi
else
    echo "Error: No installation found. One of the following files is missing"
    echo ""
    echo -e "\t$(get_metric_files | sed 's/ /\n\t/g')"
    echo
    echo "Have you run the installation script?"
fi

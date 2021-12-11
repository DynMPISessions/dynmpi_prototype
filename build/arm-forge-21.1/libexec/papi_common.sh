function get_metric_files {
    echo $METRICS_DIR/lib-papi.so                          \
         $METRICS_DIR/papi.xml                             \
         $METRICS_DIR/PAPI.config                          \
         $PARTIAL_REPORTS_DIR/report-papi-overview.xml     \
         $PARTIAL_REPORTS_DIR/report-papi-floatpoint.xml   \
         $PARTIAL_REPORTS_DIR/report-papi-branch.xml       \
         $PARTIAL_REPORTS_DIR/report-papi-cache-misses.xml
}

function check_metric_files {

    for metric_file in $(get_metric_files)
    do
        if [ -f "$metric_file" ]; then
            return 0
        fi
    done
    return 1
}

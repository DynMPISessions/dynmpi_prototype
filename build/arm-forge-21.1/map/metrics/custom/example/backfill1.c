//! \file
/*! This metric plugin provides an example of a backfilled custom metric.
 */

#include "allinea_metric_plugin_api.h"

//! This function is called when the metric plugin is loaded.
/*!
 *  We do not have to restrict ourselves to async-signal-safe functions because
 *  the initialization function will be called without any locks held.
 * 
 *  \param plugin_id an opaque handle for the plugin.
 *  \param unused unused
 *  \return 0 on success; -1 on failure and set errno
 */
int allinea_plugin_initialize(plugin_id_t plugin_id, void *unused)
{
    return 0;
}

//! This function is called when the metric plugin is unloaded.
/*!
 *  We do not have to restrict ourselves to async-signal-safe functions because
 *  the initialization function will be called without any locks held.
 * 
 *  \param plugin_id an opaque handle for the plugin.
 *  \param unused unused
 *  \return 0 on success; -1 on failure and set errno
 */
int allinea_plugin_cleanup(plugin_id_t plugin_id, void *unused)
{
    return 0;
}

//! This function is registered in backfill1.xml to be called when the sampler is initialised.
/*!
 *  Since this function is called when the sampler is initialised it will occur even if
 *  sampling has been delayed, i.e. close to program start rather than when sampling actually 
 *  starts.
 *
 *  This function does not need to be async-signal-safe as it is called when the MAP
 *  sampler is initialised.
 *
 *  \parameter plugin_id opaque handle for the plugin
 *  \return 0 on success; -1 on failure and set errno
 */
int start_profiling(plugin_id_t plugin_id)
{
    return 0;
}

//! This function is registered in backfill1.xml to be called when sampling has ended.
/*!
 *  This function is called after the sampler terminates its internal timer.
 *
 *  This function needs to be async-signal-safe as it may be called from a signal handler.
 *
 *  \parameter plugin_id opaque handle for the plugin
 *  \return 0 on success; -1 on failure and set errno
 */
int stop_profiling(plugin_id_t plugin_id)
{
    return 0;
}

//! Called once for every sample present at the end of a run.
/*!
 *  This function may be called from a signal handler so it must be async-signal-safe.
 * 
 *  \param metric_id an opaque handle for the metric.
 *  \param in_out_sample_time [in] the time at which this sample is being taken.
 *  \param out_value [out] the value of the metric.
 *
 *  \return 0 on success; -1 on failure and set errno
 */
int backfilled_metric(metric_id_t metric_id, struct timespec *in_out_sample_time, uint64_t *out_value)
{
    // Back fill with value of 5 for all samples. 
    *out_value = 5;
    return 0;
}

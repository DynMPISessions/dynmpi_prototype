/*! \file
 *  \brief Header containing declarations for functions to be implemented by any Arm MAP metric plugin library.
 *
 */

#ifndef ALLINEA_METRIC_PLUGIN_TEMPLATE_H
#define ALLINEA_METRIC_PLUGIN_TEMPLATE_H

#include "allinea_metric_plugin_types.h"

#ifdef __cplusplus
extern "C" {
#endif

//! Initialises a metric plugin.
/*! This function must be implemented by each metric plugin library. It is
 *  called when that plugin library is loaded. Use this function to
 *  setup data structures and do one-off resource checks. Unlike most functions
 *  used in a metric plugin library this is \e not called from a signal handler.
 *  Therefore, it is safe to make general function calls and allocate or
 *  deallocate memory using the normal libc malloc/free new/delete functions.
 *
 *  If it can be determined that this metric plugin cannot function (e.g. the
 *  required information is not available on this machine) then it should
 *  call allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *  to explain the situation then return -1.
 *
 *  \param plugin_id Opaque handle for the metric plugin. Use this when making calls
 *          to allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *  \param data Currently unused, will always be \c NULL
 *  \return 0 on success; -1 on error. A description of the error should be supplied
 *          using allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *          before returning.
 *  \ingroup template
 */
int allinea_plugin_initialize(plugin_id_t plugin_id, void* data);

//! Cleans a metric plugin being unloaded.
/*! This function must be implemented by each metric plugin library. It is
 *  called when that plugin library is unloaded. Use this function to
 *  release any held resources (open files etc). Unlike most functions
 *  used in a metric plugin library, this is \e not called from a signal handler.
 *  Therefore, it is safe to make general function calls and even allocate or
 *  deallocate memory using the normal libc malloc/free new/delete functions.
 *
 *  Note: This will be called after metric data has been extracted and
 *  transferred to the frontend. Therefore, you may not see plugin error messages set by
 *  allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef().
 *
 *  \param plugin_id Opaque handle for the metric plugin. Use this when making calls
 *          to allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *  \param data Currently unused, will always be \c NULL
 *  \return 0 on success; -1 on error. A description of the error should be supplied
 *          using allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *          before returning.
 *  \ingroup template
 */
int allinea_plugin_cleanup(plugin_id_t plugin_id, void* data);

//! Example of an integer metric \e getter function
/*! An example of a \e getter function that returns an integer metric value. Real \e getter
 *  functions must be registered with the profiler using a \ref xml "Metric definition file".
 *  For example, this function (if it existed) would be registered by having a \c \<metric\>
 *  element along the lines of :
 * \code
 *    <metric id="com.allinea.metrics.myplugin.mymetric">
 *        <units>%</units>
 *        <dataType>uint64_t</dataType>
 *        <domain>time</domain>
 *        <source ref="com.allinea.metrics.myplugin_src" functionName="mymetric_getValue"/>
 *        <display>
 *            <description>Human readable description</description>
 *            <displayName>Human readable display name</displayName>
 *            <type>instructions</type>
 *            <colour>green</colour>
 *        </display>
 *    </metric>
 * \endcode
 * The most relevant line being the one containing \c functionName="mymetric_getValue".
 * See \ref xml for more details on the format of this XML file.
 * \param[in] id An id used by the profiler to identify this metric. This can be
 *              used in calls to \ref api functions i.e. allinea_set_metric_error_message().
 * \param[in,out] currentSampleTime The current time.
 *              This time is acquired from a monotonic clock which reports the time elapsed
 *              from some fixed point in the past. It is unaffected by changes in the system
 *              clock.
 *
 *              This is passed in from the profiler to avoid
 *              unnecessary calls to allinea_get_current_time(). If this metric is backfilled then
 *              this time is not the current time, instead it is the time at which the sample was taken and
 *              the time the sampler is now requesting a data point for.
 *
 *              This parameter is additionally an out parameter and may be updated with the result
 *              from a call to allinea_get_current_time() to ensure the currentSampleTime is close
 *              to the point where the metric is read. Updating currentSampleTime from any
 *              other source is undefined. In the case of a backfilled metric, currentSampleTime
 *              does not function as an out parameter and will result in an error if it is used
 *              as such. It is safe to assume that this pointer is not NULL.
 * \param[out] outValue The return value to be provided to the profiler. It is safe to assume
 *             that this pointer is not NULL.
 * \return 0 if a metric was written to \a outValue successfully, a non-zero value if there
 *              was an error. In the case of an error this function should call
 *              allinea_set_metric_error_message() before returning.
 * \warning This function may have been called from inside a signal handler. Implementations
 *          must not make calls that are not async-signal safe. Do not use any function that
 *          implicitly or explicitly allocates or frees memory, or uses non-reentrant
 *          functions, with the exception of the memory allocators provided by the \ref api (for example,
 *          allinea_safe_malloc() or allinea_safe_free()). Failure to observe async-signal
 *          safety can result in deadlocks, segfaults or undefined/unpredictable behaviour.
 * \note Do not implement this function! Instead implement functions with the same signature
 *              but with a more appropriate function name.
 * \ingroup template */
int mymetric_getIntValue(metric_id_t id, struct timespec *currentSampleTime, uint64_t *outValue);

//! Example of a floating-point metric \e getter function
/*! An example of a \e getter function that returns a floating point metric value. Real \e getter
 *  functions must be registered with the profiler using a \ref xml "Metric definition file".
 *  For example, this function (if it existed) would be registered by having a \c \<metric\>
 *  element along the lines of :
 * \code
 *    <metric id="com.allinea.metrics.myplugin.mymetric">
 *        <units>%</units>
 *        <dataType>double</dataType>
 *        <domain>time</domain>
 *        <source ref="com.allinea.metrics.myplugin_src" functionName="mymetric_getValue"/>
 *        <display>
 *            <description>Human readable description</description>
 *            <displayName>Human readable display name</displayName>
 *            <type>instructions</type>
 *            <colour>green</colour>
 *        </display>
 *    </metric>
 * \endcode
 * The most relevant line being the one containing \c functionName="mymetric_getValue".
 * See \ref xml for more details on the format of this XML file.
 * \param[in] id An id used by the profiler to identify this metric. This can be
 *              used in calls to \ref api functions i.e. allinea_set_metric_error_message().
 * \param[in,out] currentSampleTime The current time.
 *              This time is acquired from a monotonic clock which reports the time elapsed
 *              from some fixed point in the past. It is unaffected by changes in the system
 *              clock.
 *
 *              This is passed in from the profiler to avoid
 *              unnecessary calls to allinea_get_current_time(). If this metric is backfilled then
 *              this time is not the current time, instead it is the time at which the sample was taken and
 *              the time the sampler is now requesting a data point for.
 *
 *              This parameter is additionally an out parameter and may be updated with the result
 *              from a call to allinea_get_current_time() to ensure the currentSampleTime is close
 *              to the point where the metric is read. Updating currentSampleTime from any
 *              other source is undefined. In the case of a backfilled metric, currentSampleTime
 *              does not function as an out parameter and will result in an error if it is used
 *              as such. It is safe to assume that this pointer is not NULL.
 * \param[out] outValue The return value to be provided to the profiler. It is safe to assume
 *             that this pointer is not NULL.
 * \return 0 if a metric was written to \a outValue successfully, a non-zero value if there
 *              was an error. In the case of an error this function should call
 *              allinea_set_metric_error_message() before returning.
 * \warning This function may have been called from inside a signal handler. Implementations
 *          must not make calls that are not async-signal safe. Do not use any function that
 *          implicitly or explicitly allocates or frees memory, or uses non-reentrant
 *          functions, with the exception of the memory allocators provided by the \ref api (for example,
 *          allinea_safe_malloc() or allinea_safe_free()). Failure to observe async-signal
 *          safety can result in deadlocks, segfaults or undefined/unpredictable behaviour.
 * \note Do not implement this function! Instead implement functions with the same signature
 *              but with a more appropriate function name.
 * \ingroup template */
int mymetric_getDoubleValue(metric_id_t id, struct timespec *currentSampleTime, double *outValue);

//! Called when the sampler is initialised
/*! An example of a function which is called when the sampler is initialised. This callback is
 *  optional and does not need to be implemented. If this function exists it can be registered
 *  as follows.
 *  \code
 *      <source id="com.allinea.metrics.backfill_src">
 *          <sharedLibrary>libbackfill1.so</sharedLibrary>
 *          <functions>
 *              <start>start_profiling</start>
 *          </functions>
 *      </source>
 *  \endcode
 *
 *  This function does not need to be async-signal-safe as it is not called from a signal.
 *
 *  \param plugin_id Opaque handle for the metric plugin. Use this when making calls
 *          to allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *  \return 0 on success; -1 on error. A description of the error should be supplied
 *          using allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *          before returning.
 *  \ingroup template
 */
int start_profiling(plugin_id_t plugin_id);

//! Called after the sampler stops sampling.
/*! An example of a function which is called when the sampler finishes sampling. This callback is
 *  optional and does not need to be implemented. If this function exists it can be registered
 *  as follows.
 *  \code
 *      <source id="com.allinea.metrics.backfill_src">
 *          <sharedLibrary>libbackfill1.so</sharedLibrary>
 *          <functions>
 *              <start>stop_profiling</start>
 *          </functions>
 *      </source>
 *  \endcode
 *
 *  \warning This function may be called from a signal handler so must be async-signal-safe
 *
 *  \param plugin_id Opaque handle for the metric plugin. Use this when making calls
 *          to allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *  \return 0 on success; -1 on error. A description of the error should be supplied
 *          using allinea_set_plugin_error_message() or allinea_set_plugin_error_messagef()
 *          before returning.
 *  \ingroup template
 */
int stop_profiling(plugin_id_t plugin_id);


#ifdef __cplusplus
}
#endif

#endif // ALLINEA_METRIC_PLUGIN_TEMPLATE_H

/*! \file
 *  \brief Functions for reporting errors encountered by a metric plugin library or specific metric
 */

#ifndef ALLINEA_METRIC_PLUGIN_ERRORS_H
#define ALLINEA_METRIC_PLUGIN_ERRORS_H

#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#include "allinea_metric_plugin_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/*! \name Error Reporting Enums
 * {@ */

//! List of error codes used in combination with ALLINEA_METRIC_ERROR and ALLINEA_METRIC_WARNING
/*! These error codes have pre-defined behaviour in MAP.
 *  \var METRIC_NODATA      When used with ALLINEA_METRIC_WARNING, the metric information across
 *                          ranks will be displayed unless this error code is observed on all ranks.
 */
typedef enum MetricErrorCodes
{
    ERRORCODES_BEGIN = -3000,
    METRIC_NODATA,
    ERRORCODES_END

}MetricErrorCodes;

//! Metric errors types.
/*! These error types can be used in custom metric libraries to control how metric error messages
 *  are displayed in the GUI.
 *
 *  \var METRIC_ERROR       User-defined "hard" metric error. Metric will be disabled on the rank
 *                          that sets this metric error. If this metric error is observed on a
 *                          single rank, the metric error will be displayed.
 *                          If an errorcode is observed with different MetricErrorTypes, this will
 *                          have precedence over METRIC_WARNING.
 *                          Default metric error type when using allinea_set_metric_error_message.
 *
 *  \var METRIC_WARNING     User-defined "soft" metric error. Metric error will be recorded in the
 *                          MAP file but the metric will still be gathered and visible in the GUI.
 *
 *  \var ALLINEA_METRIC_ERROR  System "hard" metric error. Must be used in combination with codes in
 *                          the MetricErrorCodes object. Pre-defined behaviour in MAP based on these
 *                          errortypes and errorcodes. Metric will be disabled on this rank and not
 *                          displayed in the GUI.
 *                          If an errorcode is observed with different MetricErrorTypes, this will
 *                          have precedence over ALLINEA_METRIC_WARNING and user-defined metric
 *                          errorcodes set with METRIC_ERROR and METRIC_WARNING.
 *
 *  \var ALLINEA_METRIC_WARNING  System "soft" metric error. Must be used in combination with codes
 *                          in the MetricErrorCodes object.
 */
typedef enum MetricErrorType
{
    METRIC_ERROR            = 0x0,
    METRIC_WARNING          = 0x10,
    ALLINEA_METRIC_ERROR    = 0x1,
    ALLINEA_METRIC_WARNING  = 0x11
} MetricErrorType;

//!@} // Doxygen grouping comment

/*! \name Error Reporting Functions
 * Functions for reporting errors encountered by either a specific metric or an entire
 * metric plugin library.
 * @{ */

//! Reports an error that occurred in the plugin (group of metrics).
/*! This method takes a plain text string as its \a error_message.
 *  Use allinea_set_plugin_error_messagef() instead to include specific
 *  details in the string using printf-style substitution.
 *
 *  This method must only be called from within allinea_plugin_initialize(),
 *  and only if the plugin library will not be able to provide its data (for example
 *  if the required interfaces are not present or supported by the system).
 *
 *  \param plugin_id The id identifying the plugin that has encountered an error. The appropriate
 *                  value will have been passed in as an argument to the
 *                  allinea_plugin_initialize() call.
 *  \param error_code An error code that can be used to distinguish between the
 *                  possible errors that may have occurred. The exact value is
 *                  up to the plugin author but each error condition should have its
 *                  own and unique error code. In the case of a failing libc function
 *                  the libc \c errno (from \c <errno.h>) may be appropriate, but
 *                  a plugin-author-specified constant could also be used. The meaning
 *                  of the possible error codes should be documented for the benefit
 *                  of users of your plugin.
 *  \param error_message A text string describing the error in a human-readable form.
 *                  In the case of a failing libc function the value
 *                  <code>strerror(errno)</code> may be appropriate, but a
 *                  plugin-author-specified message could also be used.
 *  \ingroup api
 */
void allinea_set_plugin_error_message(plugin_id_t plugin_id, int error_code, const char *error_message);

//! Reports an error occurred in the plugin (group of metrics).
/*! This method does printf-style substitutions to format values inside the error message.
 *
 *  This method must only be called from within allinea_plugin_initialize(),
 *  and only if the plugin library will not be able to provide its data (for example,
 *  if the required interfaces are not present or supported by the system).
 *
 *  \param plugin_id The id identifying the plugin that has encountered an error. The appropriate
 *                  value will have been passed in as an argument to the
 *                  allinea_plugin_initialize() call.
 *  \param error_code An error code that can be used to distinguish between the
 *                  possible errors that may have occurred. The exact value is
 *                  up to the plugin author but each error condition should have its
 *                  own and unique error code. In the case of a failing libc function
 *                  the libc \c errno (from \c <errno.h>) may be appropriate, but
 *                  a plugin-author-specified constant could also be used. The meaning
 *                  of the possible error codes should be documented for the benefit
 *                  of users of your plugin.
 *  \param error_message A text string describing the error in a human-readable form.
 *                  In the case of a failing libc function the value
 *                  <code>strerror(errno)</code> may be appropriate, but a
 *                  plugin-author-specified message could also be used. This may include
 *                  printf-style substitution characters.
 *  \param ... Zero or more values to be substituted into the \a error_message
 *                  string in the same manner as printf.
 *  \ingroup api
 */
void allinea_set_plugin_error_messagef(plugin_id_t plugin_id, int error_code, const char *error_message, ...);

//! Reports an error of type METRIC_ERROR occurred when reading a metric.
/*! \param metric_id The id identifying the metric that has encountered an error. The appropriate
 *                  value will have been passed in as an argument to the
 *                  metric \e getter call.
 *  \param error_code An error code that can be used to distinguish between the
 *                  possible errors that may have occurred. The exact value is
 *                  up to the plugin author but each error condition should have its
 *                  own and unique error code. In the case of a failing libc function
 *                  the libc \c errno (from \c <errno.h>) may be appropriate, but
 *                  a plugin-author-specified constant could also be used. The meaning
 *                  of the possible error codes should be documented for the benefit
 *                  of users of your plugin.
 *  \param error_message A text string describing the error in a human-readable form.
 *                  In the case of a failing libc function the value
 *                  <code>strerror(errno)</code> may be appropriate, but a
 *                  plugin-author-specified message could also be used.
 *  \ingroup api
 */
void allinea_set_metric_error_message(metric_id_t metric_id, int error_code, const char *error_message);

//! Reports an error occurred when reading a metric and sets the error type.
/*! \param metric_id The id identifying the metric that has encountered an error. The appropriate
 *                  value will have been passed in as an argument to the
 *                  metric \e getter call.
 *  \param error_code An error code that can be used to distinguish between the
 *                  possible errors that may have occurred. The exact value is
 *                  up to the plugin author but each error condition should have its
 *                  own and unique error code. In the case of a failing libc function
 *                  the libc \c errno (from \c <errno.h>) may be appropriate, but
 *                  a plugin-author-specified constant could also be used. The meaning
 *                  of the possible error codes should be documented for the benefit
 *                  of users of your plugin.
 *  \param error_message A text string describing the error in a human-readable form.
 *                  In the case of a failing libc function the value
 *                  <code>strerror(errno)</code> may be appropriate, but a
 *                  plugin-author-specified message could also be used.
 *  \param type     Classification of metric error type being applied. If a metric error
 *                  with the "warning" bit set is supplied, this metric will not be disabled.
 *  \ingroup api
 */
void allinea_set_metric_error_message_with_type(metric_id_t metric_id, int error_code, const char *error_message, MetricErrorType type);

//! Reports an error occurred when reading a metric.
/*! This method does printf-style substitutions to format values inside the error message.
 *  \param metric_id The id identifying the metric that has encountered an error. The appropriate
 *                  value will have been passed in as an argument to the
 *                  metric \e getter call.
 *  \param error_code An error code that can be used to distinguish between the
 *                  possible errors that may have occurred. The exact value is
 *                  up to the plugin author but each error condition should have its
 *                  own and unique error code. In the case of a failing libc function
 *                  the libc \c errno (from \c <errno.h>) may be appropriate, but
 *                  a plugin-author-specified constant could also be used. The meaning
 *                  of the possible error codes should be documented for the benefit
 *                  of users of your plugin.
 *
 *  \param error_message A text string describing the error in a human-readable form.
 *                  In the case of a failing libc function the value
 *                  <code>strerror(errno)</code> may be appropriate, but a
 *                  plugin-author-specified message could also be used. This may include
 *                  printf-style substitution characters.
 *  \param ... Zero or more values to be substituted into the \a error_message string.
 *
 *  \ingroup api
 */
void allinea_set_metric_error_messagef(metric_id_t metric_id, int error_code, const char *error_message, ...);

//!@} // Doxygen grouping comment

#ifdef __cplusplus
}
#endif

#endif // ALLINEA_METRIC_PLUGIN_ERRORS_H

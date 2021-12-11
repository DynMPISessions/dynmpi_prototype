/*! \file
 *  \brief Header for the Arm MAP sampler metric plugin API, includes all other API header files.
 */

#ifndef ALLINEA_METRIC_PLUGIN_API_H
#define ALLINEA_METRIC_PLUGIN_API_H

#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#include "allinea_metric_plugin_types.h"
#include "allinea_metric_plugin_errors.h"
#include "allinea_safe_malloc.h"
#include "allinea_safe_syscalls.h"

#ifdef __cplusplus
extern "C" {
#endif

/*! \name System Info Functions
 * Functions that provide information about the system or the enclosing profiler.
 * @{ */

//! Returns the number of logical cores on this system
/*! This count includes \e effective cores reported by hyperthreading.
 *  \return The number of CPU cores known to the kernel (including those added by hyperthreading).
 *          -1 if this information is not available.
 *  \sa allinea_get_physical_core_count
 *  \ingroup api */
int allinea_get_logical_core_count(void);

//! Returns the number of physical cores on this system
/*! This count does \e not include the \e effective cores reported when using
 *  hyperthreading.
 *  \return The number of CPU cores known to the kernel (excluding those added by hyperthreading).
 *          -1 if this information is not available
 *  \sa allinea_get_logical_core_count
 *  \ingroup api */
int allinea_get_physical_core_count(void);

//! Reads the configuration file to find the value of a variable.
/*!
 *  This function returns the value of a configuration variable,
 *  or an error if the file is empty, the variable is not found or the
 *  variable is improperly declared.
 *  This function must only be called from outside of the sampler
 *  (such as in allinea_plugin_initialise and similar functions) as
 *  it is not async signal safe.
 *
 *  \param[in] variable
 *      The name of the configuration variable.
 *  \param[in] metricId
 *      The ID of the metric with the configuration file environment variable
 *  \param[out] value
 *      The value of the configuration variable.
 *  \param[in] length
 *      The length of value
 *  \return
 *       0 if there are no errors.
 *      -1 if the file name is too long.
 *      -2 if the file does not exist.
 *      -3 if the variable is not found or is improperly declared.
 *  \ingroup api
 */
int allinea_read_config_file(const char *variable, const char *metricId, char *value, int length);

/// It returns the "customData" attribute of the "source" element from the metric definition defined in
/// the xml file.
/// \param metricId metric id
/// \return  The custom data for the given metric id.
///          A zero length C string if not available.
const char* allinea_get_custom_data(metric_id_t metricId);

//!@} // Doxygen grouping comment

#ifdef __cplusplus
}
#endif

#endif // ALLINEA_METRIC_PLUGIN_API_H

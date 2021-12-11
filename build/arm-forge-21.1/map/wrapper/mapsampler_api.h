#ifndef MAPSAMPLER_API_H
#define MAPSAMPLER_API_H

// MAP_PROFILER_LIBRARY is defined for the map-golem Qt-based library that will
// perform post-processing transmission of results to the frontend.
#if defined MAP_SAMPLER_LIBRARY || defined MAP_PROFILER_LIBRARY
  #include "sampler_global.h"
#else
  #define MAP_SAMPLER_API
#endif

#define MAP_STOP_REASON_UNSET               0
#define MAP_STOP_REASON_EXIT                1
#define MAP_STOP_REASON_MPI_FINALIZE        2
#define MAP_STOP_REASON_UI                  3
#define MAP_STOP_REASON_FATAL_ERROR         4
#define MAP_STOP_REASON_USER                100
#define MAP_STOP_REASON_USER_TIMED_STOP     101

#ifdef __cplusplus
extern "C"
{
#endif
    MAP_SAMPLER_API void allinea_suspend_traces(void);
    MAP_SAMPLER_API void allinea_resume_traces(void);
    MAP_SAMPLER_API void allinea_start_sampling(void);
    MAP_SAMPLER_API void allinea_stop_sampling(void);
    MAP_SAMPLER_API void allinea_take_sample(void);
    MAP_SAMPLER_API void allinea_set_stop_reason(int reason);
#ifdef __cplusplus
}
#endif

#endif // MAPSAMPLER_API_H

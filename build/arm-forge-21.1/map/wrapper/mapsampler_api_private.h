#ifndef MAPSAMPLER_API_PRIVATE_H
#define MAPSAMPLER_API_PRIVATE_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
#include <vector>
#endif

/* This file defines the private API used by Arm MAP. */
/* This API is subject to change without notice - do not use it in your own code. */

#if defined MAP_SAMPLER_LIBRARY || defined MAP_PROFILER_LIBRARY
  #include "sampler_global.h"
#else
  #define MAP_SAMPLER_API
#endif

#define MAP_STOP_AT_EXIT    1
#define MAP_NO_STOP_AT_EXIT 0

#define MAP_LAST_COMPATIBLE_SAMPLER_VERSION 2110
#define MAP_SAMPLER_VERSION_CURRENT         2110
#define MAP_WRAPPER_VERSION_CURRENT         2110

#define MAP_TEST_MODE_ENABLED  1
#define MAP_TEST_MODE_DISABLED 0

typedef struct allinea_cpu_info
{
    int has_info;
    int hyperthreading_enabled;
    unsigned int num_physical_devices;
    unsigned int num_logical_processors;
    unsigned int num_real_cores;
    unsigned int max_processor_number;
} allinea_cpu_info_t;

typedef enum
{
    ALLINEA_INIT_SUCCESS = 0,
    ALLINEA_INIT_ERROR_ALREADY_INITIALISED,
    ALLINEA_INIT_ERROR_ALREADY_STOPPED,
    ALLINEA_INIT_BAD_BASENAME,
    ALLINEA_INIT_SIGPROF_USED,
    ALLINEA_INIT_PROC_CPUINFO_FAILED,
    ALLINEA_INIT_NOT_IN_PRELOAD_LIBRARY,
    ALLINEA_INIT_SIGPROF_HANDLER_SET_TWICE,
    ALLINEA_INIT_MAINTHREAD_SET_TWICE,
    ALLINEA_INIT_BAD_SLEEPING_THRESHOLD,
    ALLINEA_INIT_BAD_METRIC,
    ALLINEA_INIT_BAD_LIBRARY_LOAD,
    ALLINEA_INIT_UNSUPPORTED_MPI_THREAD_MODE,
    ALLINEA_INIT_BAD_SAMPLER_CONFIG_FILE,
    ALLINEA_INIT_SPE_FAILED,
    ALLINEA_INIT_ERROR_GPU
} allinea_init_err_t;

typedef enum
{
    ALLINEA_MPI_THREAD_SUPPORT_UNSPECIFIED,
    ALLINEA_MPI_THREAD_SUPPORT_SINGLE,
    ALLINEA_MPI_THREAD_SUPPORT_FUNNELED,
    ALLINEA_MPI_THREAD_SUPPORT_SERIALIZED,
    ALLINEA_MPI_THREAD_SUPPORT_MULTIPLE
} allinea_mpi_thread_support_t;

typedef enum
{
    ALLINEA_DESTROY_NOW,
    ALLINEA_WAIT_FOR_FILE_TRANSFER
} allinea_destroy_sampler_mode_t;

#ifdef __cplusplus
extern "C"
{
#endif
    MAP_SAMPLER_API int allinea_init_sampler(int numSamples, int initialIntervalMs, const char *filename, int rank);
    MAP_SAMPLER_API int allinea_init_sampler_now(int numSamples, int initialIntervalMs, const char* filename, int stopAtExit,
                                                 const unsigned int startOffset, const unsigned int stopOffset);
    MAP_SAMPLER_API void allinea_destroy_sampler(allinea_destroy_sampler_mode_t mode);
    MAP_SAMPLER_API void allinea_pre_mpi_init(void);
    MAP_SAMPLER_API void allinea_mid_mpi_init(void);
    MAP_SAMPLER_API void allinea_post_mpi_init(void);
    MAP_SAMPLER_API void allinea_set_is_rank_0(int b);
    MAP_SAMPLER_API int  allinea_is_rank_0(void);
    MAP_SAMPLER_API void allinea_set_mpi_thread_support(allinea_mpi_thread_support_t support);
    MAP_SAMPLER_API void allinea_suspend_traces_for_mpi(const char *functionName);
    MAP_SAMPLER_API void allinea_resume_traces_for_mpi(void);
    MAP_SAMPLER_API void allinea_suspend_traces_for_openmp(void); 
    MAP_SAMPLER_API void allinea_resume_traces_for_openmp(void);
    MAP_SAMPLER_API void allinea_add_mpi_call(const char* funcName,
                                              unsigned long long bytesSent,
                                              unsigned long long bytesRecv,
                                              unsigned int mpiType,
                                              unsigned int mpiTransferType);
    MAP_SAMPLER_API void allinea_in_mpi_call(int inMpi);
    MAP_SAMPLER_API void allinea_write_samples(void);
    MAP_SAMPLER_API void allinea_write_debug_log(int enabled);
    MAP_SAMPLER_API void allinea_set_sampler_test_mode(int testmode);
    MAP_SAMPLER_API void allinea_ui_stop_sampling(void);
    MAP_SAMPLER_API int  allinea_sampler_version(void);
    MAP_SAMPLER_API size_t allinea_get_bytes_read_by_map(void);
    MAP_SAMPLER_API size_t allinea_get_bytes_written_by_map(void);
    MAP_SAMPLER_API size_t allinea_get_num_read_calls_by_map(void);
    MAP_SAMPLER_API size_t allinea_get_num_write_calls_by_map(void);
    MAP_SAMPLER_API int  allinea_read_proc_file_fields(const char* procFile, const char* fields[], uint64_t values[]);
    MAP_SAMPLER_API int  allinea_read_proc_file_fields2(const char* procFile, const char* fields[], int *words[], uint64_t values[]);
    MAP_SAMPLER_API void allinea_start_sampler_io_accounting(void);
    MAP_SAMPLER_API void allinea_stop_sampler_io_accounting(void);
    MAP_SAMPLER_API void allinea_sync_sampler_io_accounting(void);
    MAP_SAMPLER_API void allinea_reset_sampler_io_accounting(void);
    MAP_SAMPLER_API int  allinea_sampler_has_stopped(void);
    MAP_SAMPLER_API size_t allinea_get_metric_configuration_filename(const char * metric_id, char * filename, size_t len);
    MAP_SAMPLER_API void allinea_get_cpu_info(allinea_cpu_info_t *info, const char *cpu_info_file, const char* physical_core_from_file_system_prefix_path);
    MAP_SAMPLER_API void allinea_print_elf_header_cache(void);
#ifdef __cplusplus
    MAP_SAMPLER_API void allinea_main_thread_backtraces(std::vector<std::vector<uint64_t> > &bt);
    MAP_SAMPLER_API void allinea_get_backtrace(const int tid, std::vector<uint64_t> &bt);
#endif
    MAP_SAMPLER_API void allinea_thread_sampler_update_known_threads(const int tid);
    MAP_SAMPLER_API void allinea_unw_set_caching_policy_none(void);
    MAP_SAMPLER_API int  allinea_test_unw_caching_policy(void);
    MAP_SAMPLER_API void allinea_proc_maps_initialise(const int tid);
    MAP_SAMPLER_API int  allinea_proc_maps_maybe_update_elf_cache(const int tid);
    MAP_SAMPLER_API int  allinea_internal_iterate_phdr_called(void);
    MAP_SAMPLER_API void allinea_unset_internal_iterate_phdr_function(void);
    MAP_SAMPLER_API void allinea_set_internal_iterate_phdr_function(void);
    MAP_SAMPLER_API void allinea_check_internal_phdr_cache(void);
    MAP_SAMPLER_API void allinea_proc_maps_destory(void);
    MAP_SAMPLER_API void allinea_perform_reset_ld_preload(void);
    MAP_SAMPLER_API void allinea_append_mpi_wrapper_libraries_to_ld_preload(void);
    MAP_SAMPLER_API int  allinea_should_preserve_ld_preload_based_on_short_name(const char *name);
    MAP_SAMPLER_API int  allinea_num_samples_taken(void);
    MAP_SAMPLER_API int  allinea_num_unexpected_and_ignored_sigprofs(void);
    MAP_SAMPLER_API void allinea_call_init_crc(void);
    MAP_SAMPLER_API void allinea_call_init_main_thread(void);
    MAP_SAMPLER_API void allinea_set_backtrace_main_boundary_frame_ip(const uint64_t addr);
    MAP_SAMPLER_API void allinea_set_backtrace_libdl_range(const uint64_t start, const uint64_t end);
    MAP_SAMPLER_API void allinea_init_thread_backtrace(const int tid);
    MAP_SAMPLER_API void allinea_take_thread_backtrace_sample(const int tid);
    MAP_SAMPLER_API void allinea_check_thread_backtrace_consistency(const int tid);
    MAP_SAMPLER_API int  allinea_seen_sample_with_thread_backtrace(void);
#ifdef __cplusplus
}
#endif

#define MPI_TYPE_OTHER      0
#define MPI_TYPE_P2P        1
#define MPI_TYPE_COLLECTIVE 2
#define MPI_TYPE_METADATA   3 ///< Used for post-processing when structures may
                              ///< store metadata or aggregate information on
                              ///< MPI calls

typedef enum{
    MPI_SEND_CALL=0,
    MPI_RECV_CALL,
    MPI_SENDRECV_CALL,
    MPI_DATALESS_CALL
} mpi_call_t;

#endif // MAPSAMPLER_API_PRIVATE_H

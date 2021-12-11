#include <stdlib.h>

#ifndef __PMEMINSP_H__
#define __PMEMINSP_H__

#define PMEMINSP_PHASE_BEFORE_UNFORTUNATE_EVENT    0x1
#define PMEMINSP_PHASE_AFTER_UNFORTUNATE_EVENT     0x2

#ifdef _MSC_VER
#   ifndef PMEMINSP_API
#       ifdef PMEMINSP_EXPORTS
#           define PMEMINSP_API __declspec(dllexport)
#       else
#           define PMEMINSP_API __declspec(dllimport)
#       endif
#   endif
#else
#   ifndef PMEMINSP_API
#       define PMEMINSP_API __attribute__ ((visibility("default")))
#   endif
#endif //_MSC_VER

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */
    /*
     * ignore memory region (addr, addr + size)
     * by default, the whole persistence memory file of interest mapped in the process address space is analyzed
     * this function specifies a subregion that will be ignored 
     */
    void PMEMINSP_API __pmeminsp_ignore_region(void *addr, size_t size);

    /*
     * analyze memory region (addr, addr + siez)
     * by default, the whole persistence memory file of interest mapped in the process address space is analyzed
     * along with __pmeminsp_ignore_region(), this function can specify a subregion that will be analyzed 
     */
    void PMEMINSP_API __pmeminsp_watch_region(void *addr, size_t size);

    /*
     * analysis starts
     */
    void PMEMINSP_API __pmeminsp_start(unsigned int phase);

    /*
     * analysis stops
     */
    void PMEMINSP_API __pmeminsp_stop(unsigned int phase);

    /*
     * analysis pauses
     */
    void PMEMINSP_API __pmeminsp_pause(unsigned int phase);

    /*
     * analysis resumes
     */
    void PMEMINSP_API __pmeminsp_resume(unsigned int phase);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __PMEMINSP_H__ */

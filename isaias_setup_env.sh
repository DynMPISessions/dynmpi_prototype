#!/bin/bash
module unload intel-mpi
module unload intel
module load zlib
module load libtool
module load hwloc
module load m4
module load autoconf
module load automake
module load flex
module load hdf5
export WORK=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2
export DYNMPI_BASE=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder
export LIBEVENT_INSTALL_PATH=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/install/libevent-2.1.12
export OMPI_ROOT=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/install/ompi
export PMIX_ROOT=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/install/pmix
export PRRTE_ROOT=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/install/prrte
export HWLOC_INSTALL_PATH=/dss/dsshome1/lrz/sys/spack/release/21.1.1/opt/haswell/hwloc/2.2.0-gcc-x4ot2a4
export LD_LIBRARY_PATH=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/install/libevent-2.1.12/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/build/p4est_dynres/p4est/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/build/p4est_dynres/libmpilibmpidynres/build/lib:$LD_LIBRARY_PATH

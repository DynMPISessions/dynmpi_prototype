#!/bin/bash -xe

git submodule update --init --recursive
./autogen.pl
./configure --prefix=/opt/hpc/external/ompi \
            --with-hwloc=${HWLOC_INSTALL_PATH} \
            --with-libevent=${LIBEVENT_INSTALL_PATH} \
            --with-pmix=${PMIX_ROOT} \
            #--with-slurm=yes \
            --enable-debug \
            --enable-mpirun-prefix-by-default \
            2>&1 | tee configure.log.$$ 2>&1
make -j 10 2>&1 | tee make.log.$$ 2>&1
make -j 10 install 2>&1 | tee make.install.log.$$


/configure --prefix=/opt/hpc/external/ompi --with-hwloc=${HWLOC_INSTALL_PATH} --with-libevent=${LIBEVENT_INSTALL_PATH} --with-pmix=${PMIX_ROOT} --enable-debug --enable-mpirun-prefix-by-default \

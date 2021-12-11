#!/bin/bash 
#SBATCH -J bench_job_test_tiny
#SBATCH -o ./%x.%j.%N.out
#SBATCH -D ./
#SBATCH --get-user-env
#SBATCH --clusters=cm2_tiny
#SBATCH --partition=cm2_tiny
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=28
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=domi.huber@tum.de
#SBATCH --export=LD_LIBRARY_PATH,DYNMPI_BASE=/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder
#SBATCH --time=00:05:00
#SBATCH --ear=off


module unload intel-mpi
module unload intel
module load slurm_setup

#Generate host file
cd ${DYNMPI_BASE}
scontrol show hostname ${SLURM_JOB_NODELIST} > ${DYNMPI_BASE}/hostfile-${SLURM_JOB_ID}.txt


echo "running test nr. 1 with parameters: -np 28 -c 120 -l 56 -m i+ -n 28 -f 10 -b 1"
/dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/install/prrte/bin/prterun -np 56 --mca btl_tcp_if_include eth0 --hostfile ${DYNMPI_BASE}/hostfile-${SLURM_JOB_ID}.txt -x LD_LIBRARY_PATH -x DYNMPI_BASE ${DYNMPI_BASE}/build/p4est_dynres/applications/build/SWE_p4est_benchOmpidynresSynthetic_release -c 120 -l 56  -m i+ -n 28 -f 10 -b 1
mkdir ${DYNMPI_BASE}/build/p4est_dynres/applications/output/synth/cluster_test
mv ${DYNMPI_BASE}/build/p4est_dynres/applications/output/synth/*.csv ${DYNMPI_BASE}/build/p4est_dynres/applications/output/synth/cluster_test
mkdir ${DYNMPI_BASE}/build/p4est_dynres/applications/output/prrte/cluster_test
mv ${DYNMPI_BASE}/build/p4est_dynres/applications/output/prrte/*.csv ${DYNMPI_BASE}/build/p4est_dynres/applications/output/prrte/cluster_test



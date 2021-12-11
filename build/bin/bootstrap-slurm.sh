#!/usr/bin/env bash

HOSTUSER=$(head -n 1 /opt/hpc/external/slurm/etc/hostuser)
NODECOUNT=$(wc -l < /opt/hpc/external/slurm/etc/nodes)

HOSTUSER=root
echo "Host user: ${HOSTUSER}"
echo "Node count: ${NODECOUNT}"

for ((h=1; h <= ${NODECOUNT}; h++))
do
        nodenumber=$(printf "%02d" ${h})
        echo "ssh ${HOSTUSER}-node${nodenumber} /opt/hpc/build/bin/start-munge.sh"
        ssh ${HOSTUSER}-slurm-node${nodenumber} /opt/hpc/build/bin/start-munge.sh || true
done

# make sure the munged daemons have started before we begin starting the slurmds
sleep 2

for ((h=1; h <= ${NODECOUNT}; h++))
do
        nodenumber=$(printf "%02d" ${h})
        echo "ssh ${HOSTUSER}-node${nodenumber} /opt/hpc/build/bin/start-slurmd.sh"
        ssh ${HOSTUSER}-slurm-node${nodenumber} /opt/hpc/build/bin/start-slurmd.sh || true
done

# make sure the slurmd daemons have started before we begin starting slurmctld
sleep 2

echo "starting the controller..."
/opt/hpc/external/slurm/sbin/slurmctld
sleep 5

echo "Checking with \"sinfo\""
sinfo

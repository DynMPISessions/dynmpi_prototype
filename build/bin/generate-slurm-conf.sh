#!/usr/bin/env bash

# configuration variables
# can these be pulled from Docker?
CORES_PER_NODE=8

# processing host-file
cat ./tmp/hostfile.txt > host_file
echo "processing the provided hostfile "
echo "getting unique entries..."
awk '!a[$0]++' host_file > ./tmp/unique_hosts

# generating slurm.conf dynamically
echo "copying initial slurm.conf work file"
cp -a ./bin/slurm-input/slurm.conf.in ./tmp/slurm.conf.initial
cp -a ./bin/slurm-input/slurm.conf.in ./tmp/slurm.conf.work
echo "setting up NodeName and PartitionName entries in slurm.conf ..."
rm -f ./tmp/hosts
rm -f ./tmp/nodes
rm -f ./tmp/hostuser
HostNumber=1
while read h; do
	FormattedNumber=`printf %02d $HostNumber`
	echo "NodeName=${USER}-node${FormattedNumber} NodeAddr=$h CPUs=${CORES_PER_NODE} State=UNKNOWN" >> ./tmp/slurm.conf.work
	echo "$h	${USER}-node${FormattedNumber}" >> ./tmp/hosts
	echo "${USER}-node${FormattedNumber}" >> ./tmp/nodes
	((HostNumber++))
done < ./tmp/unique_hosts
Nodes=`cat ./tmp/nodes | paste -sd "," -`
echo "PartitionName=local Nodes=${Nodes} Default=YES MaxTime=INFINITE State=UP" >> ./tmp/slurm.conf.work
echo "${USER}" >> ./tmp/hostuser

FirstNodeName="${USER}-node01"
FirstNode=`head -n 1 ./tmp/unique_hosts`
echo "ControlMachine=${FirstNodeName}" >> ./tmp/slurm.conf.work
echo "ControlAddr=${FirstNode}" >> ./tmp/slurm.conf.work
mkdir -p ./install/slurm/etc/
cp -a ./tmp/slurm.conf.work ./install/slurm/etc/slurm.conf
cp -a ./tmp/unique_hosts ./install/slurm/etc/unique_hosts
cp -a ./tmp/hosts ./install/slurm/etc/hosts
cp -a ./tmp/nodes ./install/slurm/etc/nodes
cp -a ./tmp/hostuser ./install/slurm/etc/hostuser

printf "\nhosts:\n"
cat ./install/slurm/etc/hosts 
printf "\nhost user:\n"
cat ./install/slurm/etc/hostuser
printf "\nslurm.conf partition:\n"
tail -5 ./install/slurm/etc/slurm.conf

exit 0

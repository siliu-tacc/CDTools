#!/bin/bash
# A script to collect files/directories from  /tmp
# Author: Si Liu 
# Last modified: 01/12/2021

version=1.1

myhost=`hostname`
case "$myhost" in
    *frontera* ) machine="Frontera";;
    *stampede2* ) machine="Stampede2";;
    * ) echo "This machine may not be supported"; exit;;
esac

if [ "$1" == "-h" ] || [ "$1" == "-H" ] || [ "$1" == "--help" ] ;
then
    echo "This is the collect-distribiute (CDTools)"
    echo "Version: $version"
    echo "This collect.bash command is used to collect files or directories"
    echo "from the local /tmp space"
    echo ""
    echo "Please run the command as:"
    echo "collect.bash /tmp/output /scratch/12345/joe/alloutput"
    echo "or collect.bash --help for this help information"
    echo ""
    echo "Please note: /tmp space is limited!"
    echo "Contact Si Liu (siliu@tacc.utexas.edu) for any questions or concerns."
    exit
fi



if [ "$#" -ne 2 ]
then
    echo "Please provide the target file/dir as:"
    echo "collect.bash /tmp/output /scratch/12345/joe/alloutput"
    exit 1
fi

nodelist=`scontrol show hostnames $SLURM_NODELIST | sed -z 's/\n/,/g' `
TACC_HOSTLIST="${nodelist::-1}"
#echo ${TACC_HOSTLIST}

case $myhost in
    *frontera* ) CMD="collect_tmp_fr";;
    *stampede2* ) CMD="collect_tmp_s2";;
esac

realname=`basename ${1}`

mkdir -p ${2}
chmod a+rX ${2}

#Not needed in Intel19 any more
unset I_MPI_JOB_FAST_STARTUP
unset I_MPI_OFI_LIBRARY

echo "Running collection functions now..."
mpiexec -np $SLURM_TACC_NODES -hosts ${TACC_HOSTLIST} -ppn 1   ${CMD} ${1} ${2}
echo "Done."
exit

#!/bin/bash
# A script to distribute an input file to /tmp

# Author: Si Liu
# Last modified: 01/12/2021

version=0.99

myhost=`hostname`
case "$myhost" in
    *frontera* ) machine="Frontera";;
    *stampede2* ) machine="Stampede2";;
    * ) echo "This machine may not be supported"; exit;;
esac

if [ "$1" == "-h" ] || [ "$1" == "-H" ] || [ "$1" == "--help" ] ;
then
    echo "This is the collect-distribiute (CD Tool)"
    echo "Version: $version"
    echo "This distributr.bash command is used to distribute files or directories"
    echo "to the local /tmp space"
    echo ""
    echo "Please run the command as:"
    echo "distribute.bash /tmp/output"
    echo "or distribute.bash --help for this help information"
    echo " "
    echo "Please note: /tmp space is limited!"
    echo "Contact Si Liu (siliu@tacc.utexas.edu) for any questions or concerns."
    exit
fi


if [ $# -eq 0 ]
then
    echo "Please provide the target file/dir as:"
    echo "distribute.bash /scratch/12345/joe/myinputfile"
    exit 1
fi

if [ -f $1 ]
then
    echo "Going to distribute file ${1} to /tmp"
elif [ -d $1 ]
then
    echo "Going to distribute directory ${1} to /tmp"
else
    echo "Target file/dir is not found!"
    echo "Please check the file to distribute here: $1"
    exit 1
fi

nodelist=`scontrol show hostnames $SLURM_NODELIST | sed -z 's/\n/,/g' `
TACC_HOSTLIST="${nodelist::-1}"
#echo ${TACC_HOSTLIST}

case $myhost in
    *frontera* ) CMD="distribute_tmp_fr";;
    *stampede2* ) CMD="distribute_tmp_s2";;
esac

realname=`basename ${1}`

#Not needed in Intel19 any more
unset I_MPI_JOB_FAST_STARTUP
unset I_MPI_OFI_LIBRARY

echo "Running distribution functions now..."
mpiexec -np $SLURM_TACC_NODES -hosts ${TACC_HOSTLIST} -ppn 1   ${CMD} $1 /tmp/${realname}
echo "Done."
exit

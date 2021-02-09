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
    echo "This untar_tmp.bash command is used to copy and untar a tar file"
    echo "to the local /tmp space"
    echo ""
    echo "Please run the command as:"
    echo "untar_tmp.bash mytarfile.tar"
    echo "or untar_tmp.bash --help for this help information"
    echo " "
    echo "Please note: /tmp space is limited!"
    echo "Contact Si Liu (siliu@tacc.utexas.edu) for any questions or concerns."
    exit
fi


if [ $# -eq 0 ]
then
    echo "Please provide the tar file as:"
    echo "untar_tmp.bash mytarfile.tar"
    echo "The tar file must have been distributed /tmp (with distribute.bash)"
    exit 1
fi

if [ -f $1 ]
then
    echo "Going to untar file ${1} to /tmp"
else
    echo "Target file is not found!"
    echo "Please check the file to distribute here: $1"
    exit 1
fi

nodelist=`scontrol show hostnames $SLURM_NODELIST | sed -z 's/\n/,/g' `
TACC_HOSTLIST="${nodelist::-1}"

#scontrol show hostnames $SLURM_NODELIST > /tmp/si_tmp_host
#echo ${TACC_HOSTLIST}

realname=`basename ${1}`

#Not needed in Intel19 any more
unset I_MPI_JOB_FAST_STARTUP
unset I_MPI_OFI_LIBRARY


echo "Running distribution functions now..."
[[ ! -z "$realname" ]] &&  distribute.bash ${1}

echo "Untar the tar file now..."
[[ ! -z "$realname" ]] &&  mpiexec -np $SLURM_TACC_NODES -hosts ${TACC_HOSTLIST} -ppn 1   tar -xf /tmp/${realname} --directory /tmp
echo "Done."

echo "remove tar file in /tmp..."
[[ ! -z "$realname" ]] &&  mpiexec -np $SLURM_TACC_NODES -hosts ${TACC_HOSTLIST} -ppn 1   rm /tmp/${realname}   
echo "Done"
exit

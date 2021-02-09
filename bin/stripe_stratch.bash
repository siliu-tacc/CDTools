#!/bin/bash
# A script to stripe files automatically 
# Author: Si Liu 
# Last modified: 01/12/2021

version=0.99

onehundredG=107374127424 

myhost=`hostname`
case "$myhost" in
    *frontera* ) machine="Frontera";;
    *stampede2* ) machine="Stampede2";;
    * ) echo "This machine may not be supported"; exit;;
esac

case "$myhost" in
    *frontera* ) CC_max=16;;
    *stampede2* ) CC_max=30;;
    * ) echo "This machine may not be supported"; exit;;
esac

if [ "$1" == "-h" ] || [ "$1" == "-H" ] || [ "$1" == "--help" ] ;
then
    echo "This is the program to stripe your large files automatically"
    echo "Version: $version"
    echo ""
    echo "Please run the command as:"
    echo "autotripe /scratch/12345/joe/myfile"
    echo "or autostripe  --help for this help information"
    echo ""
    echo "Please note: /tmp space is limited!"
    echo "Contact Si Liu (siliu@tacc.utexas.edu) for any questions or concerns."
    exit
fi

if [ "$#" -ne 1 ]
then
    echo "Please provide the target file/dir as:"
    echo "autostripe /scratch/12345/joe/myfile"
    exit 1
fi

if [ !  -f "$1" ]
then
    echo "$1 does not exist."
    exit
fi

path=`dirname ${1}`
realname=`basename ${1}`

#echo "PATH:" ${path}
#echo "File:" ${realname}

echo "Original file: ${path}/${realname}"
stripe_old=`/bin/lfs getstripe -c ${1}`
echo "Original stripe count: "${stripe_old}

filesize=`stat -c %s ${1}`
stripe_set=$((filesize/onehundredG)) 
stripe_set=`expr ${stripe_set} + 1`

if [ ${stripe_set} -le 1 ]
then
    echo "The file is less than 100GB."
    echo "Nothing is changed."
    exit
fi

if [ "${stripe_set}" -gt "${CC_max}" ]
then
    stripe_set=${CC_max}
fi

echo "New stripe count to set: " ${stripe_set}

mkdir -p $SCRATCH/temp_stripe
lfs setstripe -c ${stripe_set}  ${SCRATCH}/temp_stripe/${realname}_striped
cp ${1} ${SCRATCH}/temp_stripe/${realname}_striped
mv $SCRATCH/temp_stripe/${realname}_striped ${path}
rmdir $SCRATCH/temp_stripe

echo "New file: ${path}/${realname}_striped"
stripe_new=`/bin/lfs getstripe -c ${1}_striped`
echo "New stripe count: "${stripe_new}

echo "Done."
exit

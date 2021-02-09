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
echo "Original stripe count: " ${stripe_old}

filesize=`stat -c %s ${1}`
stripe_new=$((filesize/onehundredG)) 

if [ $stripe_new -lt 1 ]
then
    echo "The file is less than 100GB."
    echo "Nothing is changed."
    exit
fi

if [ "$stripe_new" -gt "$CC_max" ];then
  echo "They're equal";
fi

echo "New Stripe count: " ${stripe_new}

#lfs setstripe -c StripeCount ${SCRATCH}/${realname}_striped
#cp ${1} ${SCRATCH}/${realname}_striped
#mv $SCRATCH/${realname}_striped ${path}

#echo "New file: ${dirname} / ${realname}_striped"
#lfs getstripe ${1}_striped

echo "Done."
exit

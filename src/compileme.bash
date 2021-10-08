#!/bin/bash
# A script to distribute an input file to /tmp

module reset
module load intel/19

myhost=`hostname`
case "$myhost" in
    *frontera* ) machine="Frontera";;
    *stampede2* ) machine="Stampede2";;
    * ) echo "This machine may not be supported"; exit;;
esac


case $myhost in
    *frontera* ) TARGET="fr";;
    *stampede2* ) TARGET="s2";;
esac

case $myhost in 
    *frontera* ) ICCCMD="icpc -I/opt/intel/compilers_and_libraries_2020.4.304/linux/mpi/intel64/include -L/opt/intel/compilers_and_libraries_2020.4.304/linux/mpi/intel64/lib/release -L/opt/intel/compilers_and_libraries_2020.4.304/linux/mpi/intel64/lib -L/opt/intel/compilers_and_libraries_2020.4.304/linux/mpi/intel64/libfabric/lib -Xlinker -rpath -Xlinker /opt/apps/gcc/8.3.0/lib64  -Xlinker -rpath -Xlinker /opt/intel/compilers_and_libraries_2020.4.304/linux/mpi/intel64/lib/release -Xlinker -rpath -Xlinker /opt/intel/compilers_and_libraries_2020.4.304/linux/mpi/intel64/lib -Xlinker -rpath -Xlinker /opt/intel/compilers_and_libraries_2020.4.304/linux/mpi/intel64/libfabric/lib -lmpicxx -lmpifort -lmpi -ldl -lrt -lpthread ";;
    *stampede2* ) ICCCMD="icpc -I/opt/intel/compilers_and_libraries_2020.1.217/linux/mpi/intel64/include -L/opt/intel/compilers_and_libraries_2020.1.217/linux/mpi/intel64/lib/release -L/opt/intel/compilers_and_libraries_2020.1.217/linux/mpi/intel64/lib -Xlinker -rpath -Xlinker  /opt/apps/gcc/9.1.0/lib64 -Xlinker -rpath -Xlinker /opt/intel/compilers_and_libraries_2020.1.217/linux/mpi/intel64/lib/release -Xlinker -rpath -Xlinker /opt/intel/compilers_and_libraries_2020.1.217/linux/mpi/intel64/lib -lmpicxx -lmpifort -lmpi -ldl -lrt -lpthread ";;
esac

echo "compiling..."
${ICCCMD} -O3 distribute_tmp.cpp  -lstdc++fs -o distribute_tmp_${TARGET}
${ICCCMD} -O3 collect_tmp.cpp     -lstdc++fs -o collect_tmp_${TARGET}

echo "copying the binary to the bin directory"
cp *_${TARGET} ../bin


#objdump -x ./distribute_tmp_s2 | grep RPATH

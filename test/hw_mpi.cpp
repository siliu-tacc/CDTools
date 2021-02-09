/*********************************************
*   DESCRIPTION:
*   Hello World - C++ Version
*   This is the parallel mpi hello world example
*   Author: Si Liu
*   Last update: May 9, 2020
***********************************************/

#include <mpi.h>
#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <unistd.h>

using namespace std;

int main(int argc, char *argv[]) {
	
	int myrank, size;

        MPI_Init(&argc, &argv);
        MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
        MPI_Comm_size(MPI_COMM_WORLD, &size);

        if(myrank==0) {
		cout<<"Welcome to TACC!"<<endl;
        	cout<<"This is an MPI hello world C++ example."<<endl;
	}
        MPI_Barrier(MPI_COMM_WORLD);
	sleep(myrank);
	cout<<"Hello world! from process "<< setw(4)<< myrank<<" of "<<size<<endl; 

        MPI_Finalize();
        return 0;
}

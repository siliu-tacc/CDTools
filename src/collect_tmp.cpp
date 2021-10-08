#include <mpi.h>
#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <unistd.h>

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <experimental/filesystem>

namespace fs = std::experimental::filesystem;
using namespace std;

std::string base_name(std::string const & path) {
  return path.substr(path.find_last_of("/\\") + 1);
}

int main(int argc, char *argv[]) {

    int myrank, size;
    const int LENGTH=100;

    if(argc!=3) {
        cerr<<"The paths to the source and target file/directory are required!"<<endl;
        return -1;
    }
     
    string source=string(argv[1]);
    string target=string(argv[2]);

    if (source.size() >= LENGTH || target.size() >= LENGTH) {
        cerr<<"source or target path is too long!"<<endl;
        return -1;
    }

    string base=base_name(source);
    //cout<<"source: "<<source<<"   target: "<<target<<endl; 
    //cout<<"base name: "<<base<<endl;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
 
    string mytarget = target + "/" + base + "_" + to_string(myrank);
    //cout<<"source: "<<source<<endl<<"mytarget: "<<mytarget<<endl;     

    const auto copyOptions = fs::copy_options::update_existing | fs::copy_options::recursive;
    fs::copy(source, mytarget, copyOptions); 
    
    MPI_Barrier(MPI_COMM_WORLD); 
    if(myrank==0)
        cout<<source<<" has been collected into "<<target<<"."<<endl;
    MPI_Finalize();
    return 0;

}

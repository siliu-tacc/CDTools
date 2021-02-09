#!/bin/bash
#SBATCH -J testrun           # Job name
#SBATCH -o CDtest.%j.out     # Name of stdout output file (%j expands to jobId)
#SBATCH -e CDtest.%j.err
#SBATCH -p development       # Queue name
#SBATCH -N 4                 # Total number of nodes requested
#SBATCH -n 64                # Total number of cores requested
#SBATCH -t 00:30:00          # Run time (hh:mm:ss) - 5.0 hours
#SBATCH -A A-ccsc            # <-- Allocation name to charge job against


# 0. Preparation
module reset

CDTOOL=/work/01255/siliu/collect_distribute
export PATH=${PATH}:${CDTOOL}/bin

# 1. Run distribute
distribute.bash ${CDTOOL}/datafiles/inputfile
distribute.bash ${CDTOOL}/datafiles/inputdir
distribute.bash ${CDTOOL}/datafiles/outputfile
distribute.bash ${CDTOOL}/datafiles/outputdir

wait

# 2. Run your application here!
ibrun ./myapp

wait

# 3. Run collect 
collect.bash /tmp/outputdir ${CDTOOL}/datafiles/new_output_collected                                                                                                                           
collect.bash /tmp/outputfile ${CDTOOL}/datafiles/new_output_collected

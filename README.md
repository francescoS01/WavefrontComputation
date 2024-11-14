# Wavefront Calculation
There are three versions for the wavefront calculation:
- Sequential
- Parallel with FastFlow
- Parallel with MPI


## Compilation
To compile the source code files, navigate to the Project directory and run the following commands:
- All versions:       `make all`
- Sequential version: `make wf_sequential`
- FastFlow version:   `make wf_fastflow`
- MPI version:        `make wf_mpi`


## Run
After compiling, to run the programs, navigate to the Project directory and run the following commands:
- Sequential version: `srun ./wf_sequential $dim_matrix`
- FastFlow version:   `srun ./wf_fastflow $dim_matrix $num_thread`
- MPI version:        `srun --mpi=pmix --nodes=$num_nodes --ntasks=$num_processes ./wf_mpi $dim_matrix`

**Note**: `dim_matrix` is a number that indicates the number of columns and rows of the matrix.

## Testing
For each version, you can run tests by navigating to the appropriate directory and executing the corresponding shell script. This will output the results in a CSV file in the following format: `dim_matrix, num_thread/num_process, time`. For sequential version: `dim_matrix, time`

After execution, the program will return the execution time. If you want to see the printed matrix, you can uncomment the part of the code where the matrix is printed in the respective version. This will display the matrix in the terminal when you run the program.


## Clean Up
To remove the compiled data, navigate to the Project directory and run the following command:
- Clean all compiled files: `make clean`
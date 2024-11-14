#include <mpi.h>
#include <iostream>
#include <vector>
#include <cmath>  
#include <cstdlib>
#include "../utils/utils_functions.hpp"


int main(int argc, char* argv[]) {
    
    MPI_Init(&argc, &argv); 

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank); 
    MPI_Comm_size(MPI_COMM_WORLD, &size); 

    if (argc < 2) {
        if (rank == 0) {
            std::cerr << "Usage: " << argv[0] << " <matrix_size>" << std::endl;
        }
        MPI_Finalize();
        return -1;
    }

    int n = std::atoi(argv[1]); // dim matrix
    std::vector<double> matrix(n * n, 0.0);

    initialize_diagonalMPI(matrix, n);

    double start_time = MPI_Wtime(); //... start time ... //
    
    // loop to compute and update the diagonals of the matrix
    for (int k = 1; k < n; ++k) {
        int total_elements = n - k;
        int chunk_size = total_elements / size;
        if (total_elements % size > 0) chunk_size++;

        std::vector<double> local_results;
        int m_start = rank * chunk_size;
        int m_end = std::min(m_start + chunk_size, n - k);
        int local_count = std::max(0, m_end - m_start); // Garantisce che local_count sia >= 0


        // compute the local results
        if (local_count > 0) {
            local_results.resize(local_count, 0.0);
            for (int m = m_start; m < m_end; ++m) {
                double res = 0.0;
                for (int i = 0; i < k; ++i) {
                    res += matrix[m * n + (m + i)] * matrix[(m + 1 + i) * n + (m + k)];
                }
                local_results[m - m_start] = std::cbrt(res);
            }
        }

        std::vector<int> recvcounts(size, 0);
        std::vector<int> displs(size, 0);

        for (int i = 0; i < size; ++i) {
            int m_s = i * chunk_size;
            int m_e = std::min(m_s + chunk_size, n - k);
            recvcounts[i] = std::max(0, m_e - m_s);
            displs[i] = m_s;
        }

        std::vector<double> gathered_results(total_elements);
        MPI_Allgatherv(
            local_results.data(),      // local data buffer to send 
            local_count,               // number of elements to send
            MPI_DOUBLE,                // type of data
            gathered_results.data(),   // Buffer to receive data
            recvcounts.data(),         // Numero di elementi ricevuti da ciascun processo
            displs.data(),             // Displacement di ciascun processo
            MPI_DOUBLE,                // Tipo di dato degli elementi ricevuti
            MPI_COMM_WORLD             // Comunicatore
        );

        // update the matrix with the gathered results
        for (int m = 0; m < total_elements; ++m) {
            matrix[m * n + (m + k)] = gathered_results[m];
        }
    }
    // all diagonal are computed

    double end_time = MPI_Wtime(); //... end time ... //
    
    if (rank == 0) {
        double elapsed_time_ms = (end_time - start_time) * 1000;
        std::cout << "Elapsed time: " << elapsed_time_ms << " milliseconds" << std::endl;
    }

    if (rank == 0) {
        //std::cout << "Final matrix:" << std::endl;
        //print_matrix(matrix.data(), n); // Passa il puntatore ai dati del vettore
    }

    MPI_Finalize();
    return 0;
}
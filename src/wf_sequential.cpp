#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <cmath>  
#include <chrono>
#include <iostream>
#include "../utils/utils_functions.hpp"


void seq_wavefront_computation(double* matrix, int n) {
    for (int k = 1; k < n; k++) {            // scorro diagonali 
        for (int m = 0; m < n - k; m++) {    // scorro righe
            double res = 0.0;
            // Calcolo il prodotto scalare per la diagonale k
            for (int i = 0; i < k; i++) {
                res += matrix[m * n + m + i] * matrix[(m + 1 + i) * n + (m + k)];
            }
            matrix[m * n + (m + k)] = std::cbrt(res);  // Uso std::cbrt per la radice cubica
        }
    }
}


int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <matrix_size> <num_workers>" << std::endl;
        return -1;
    }

    int n = std::atoi(argv[1]); 
    double* matrix = (double*)calloc(n * n, sizeof(double));

    if (!matrix) {
        std::cerr << "Memory allocation failed for matrix" << std::endl;
        return -1;
    }

    initialize_diagonal(matrix, n);  

    auto start = std::chrono::high_resolution_clock::now();
    // -------
    seq_wavefront_computation(matrix, n);
    // -------
    auto end = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double, std::milli> durata = end - start;  // Durata in millisecondi
    std::cout << durata.count() << std::endl;

    //print_matrix(matrix, n); 

    free(matrix);   

    return 0;
}
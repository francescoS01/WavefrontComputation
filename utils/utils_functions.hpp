#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cstdint>
#include <vector>

#ifndef UTILS_FUNCTIONS_HPP
#define UTILS_FUNCTIONS_HPP


void initialize_diagonal(double* matrix, int n) {
    for (int i = 0; i < n; ++i) {
        matrix[i * n + i] = static_cast<double>(i + 1) / n;
    }
}

void initialize_diagonalMPI(std::vector<double>& matrix, int n) {
    for (int i = 0; i < n; ++i) {
        matrix[i * n + i] = (double)(i + 1) / n;
    }
}

void print_matrix(double* matrix, int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            printf("%6.2f ", matrix[i * n + j]);
        }
        printf("\n");
    }
}

#endif 
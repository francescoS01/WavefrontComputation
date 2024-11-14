#include "../fastflow/ff/ff.hpp"
#include "../fastflow/ff/node.hpp"
#include "../fastflow/ff/farm.hpp"
#include "../fastflow/ff/parallel_for.hpp"
#include <atomic>
#include <iostream>
#include <cmath>  
#include <chrono>
#include <vector>
#include <thread>
#include <../utils/utils_functions.hpp>

using namespace ff;

struct Task {
    int k;
    int m_start;
    int m_end;
    bool is_feedback;  // true if task is a feedback
};

struct Emitter : ff_node_t<Task> {
    Emitter(int n, int num_workers) 
        : n(n), num_workers(num_workers),
          current_k(0), feedback_count(0), expected_feedback(0) {}

    Task* svc(Task* task) {
       
        // feedback from worker 
        if (task != nullptr) {  
            feedback_count++; 
            delete task;
        }

        // feedback from main or all workers have finished
        if (task == nullptr || feedback_count == expected_feedback) {
            feedback_count = 0;
            current_k++;
            
            if (current_k >= n) return EOS; // all done

            int total_elements = n - current_k;
            int chunk_size = total_elements / num_workers;
            if (total_elements % num_workers > 0) chunk_size++; 
            
            expected_feedback = 0; 

            for (int i = 0; i < num_workers; ++i) {
            // send a task per worker
                int m_start = i * chunk_size;
                int m_end = std::min(m_start + chunk_size, n - current_k);
                if (m_start < m_end) {
                    // invio del task al worker
                    ff_send_out(new Task{current_k, m_start, m_end, false});
                    expected_feedback++; 
                }
            }
        }
        return GO_ON;
    }
};

struct Worker : ff_node_t<Task> {
    Worker(double* matrix, int n) : matrix(matrix), n(n) {}

    Task* svc(Task* task) {
        if (task->m_start < task->m_end) {
            for (int m = task->m_start; m < task->m_end; ++m) {
                double res = 0.0;
                for (int i = 0; i < task->k; ++i) {
                    res += matrix[m * n + (m + i)] * matrix[(m + 1 + i) * n + (m + task->k)];
                }
                matrix[m * n + (m + task->k)] = std::cbrt(res);
            }
        }
        
        // sende empty feedback to emitter
        ff_send_out(new Task{0, 0, 0, true});
        
        delete task;
        return GO_ON;
    }

    double* matrix;
    int n;
};

int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " <matrix_size> <num_workers>" << std::endl;
        return -1;
    }

    int n = std::atoi(argv[1]);             // Dim matrix
    int num_workers = std::atoi(argv[2]); // number of workers

    double* matrix = (double*)calloc(n * n, sizeof(double)); 
    if (!matrix) {
        std::cerr << "Memory allocation failed for matrix" << std::endl;
        return -1;
    }

    initialize_diagonal(matrix, n);

    // create the farm
    Emitter emitter(n, num_workers);
    std::vector<std::unique_ptr<ff_node>> workers;
    for (int i = 0; i < num_workers; ++i) {
        workers.push_back(make_unique<Worker>(matrix, n));
    }
    ff_Farm<Task> farm(std::move(workers), emitter);
    farm.remove_collector();  // not need a collector
    farm.wrap_around();       // ability feedback 

    auto start = std::chrono::high_resolution_clock::now(); // ... start time ... //
    // run the farm
    if (farm.run_and_wait_end() < 0) {
        error("running farm");
        return -1;
    }
    auto end = std::chrono::high_resolution_clock::now();   // ... end time ... //

    std::chrono::duration<double, std::milli> durata = end - start;  
    std::cout << "Elapsed time: " << durata.count() << " milliseconds" << std::endl;

    //print_matrix(matrix, n); 

    free(matrix);  
    return 0;
}

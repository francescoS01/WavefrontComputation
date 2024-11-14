# Definizione dei percorsi
SRC_DIR = ./src
FASTFLOW_DIR = ./fastflow

# Compilatore e flag di compilazione
CXX = g++
MPICXX = mpicxx
CXXFLAGS = -std=c++17 -O3
MPICXXFLAGS = -std=c++20 -Wall -O3
LDFLAGS = -lpthread -DNO_DEFAULT_MAPPING

# Programmi da compilare
SEQUENTIAL = $(SRC_DIR)/wf_sequential.cpp
FASTFLOW_PROGRAM = $(SRC_DIR)/wf_fastflow.cpp
MPI_PROGRAM = $(SRC_DIR)/wf_mpi.cpp

# Obiettivi del Makefile
all: wf_sequential wf_fastflow wf_mpi

# Compilazione singola per ciascun programma
wf_sequential:
	$(CXX) $(CXXFLAGS) -o wf_sequential $(SEQUENTIAL)

wf_fastflow:
	$(CXX) $(CXXFLAGS) -I$(FASTFLOW_DIR) -o wf_fastflow $(FASTFLOW_PROGRAM) $(LDFLAGS)

wf_mpi:
	$(MPICXX) $(MPICXXFLAGS) -I. -o wf_mpi $(MPI_PROGRAM)

# Pulizia
clean:
	rm -f wf_sequential wf_fastflow wf_mpi

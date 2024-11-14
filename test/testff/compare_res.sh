#!/bin/bash
# ./compare_results.sh

# Configura i parametri
PARALLEL_EXECUTABLE="../../wf_fastflow"  # Percorso all'eseguibile parallelo con FastFlow
SEQUENTIAL_EXECUTABLE="../../wf_sequential"  # Percorso all'eseguibile sequenziale
MATRIX_SIZE=2000  # Dimensione della matrice da utilizzare per il confronto
NUM_THREADS=8  # Numero di thread da utilizzare per la versione parallela

# File di output per i risultati
PARALLEL_OUTPUT="parallel_result.txt"
SEQUENTIAL_OUTPUT="sequential_result.txt"
DIFFERENCE_OUTPUT="difference_result.txt"

# Verifica se gli eseguibili esistono
if [ ! -f "$PARALLEL_EXECUTABLE" ]; then
    echo "Errore: L'eseguibile parallelo $PARALLEL_EXECUTABLE non esiste."
    exit 1
fi

if [ ! -f "$SEQUENTIAL_EXECUTABLE" ]; then
    echo "Errore: L'eseguibile sequenziale $SEQUENTIAL_EXECUTABLE non esiste."
    exit 1
fi

# Esegui la versione parallela e salva il risultato
$PARALLEL_EXECUTABLE $MATRIX_SIZE $NUM_THREADS > $PARALLEL_OUTPUT

# Esegui la versione sequenziale e salva il risultato
$SEQUENTIAL_EXECUTABLE $MATRIX_SIZE > $SEQUENTIAL_OUTPUT

# Confronta i risultati facendo la differenza tra le matrici e somma tutte le differenze
TOTAL_DIFFERENCE=0
awk '{
    getline seq < "'$SEQUENTIAL_OUTPUT'"
    diff = $0 - seq
    print diff > "'$DIFFERENCE_OUTPUT'"
    total_diff += diff
} END {
    print "Total Difference: " total_diff
}' $PARALLEL_OUTPUT

echo "Confronto completato. Differenza totale: $TOTAL_DIFFERENCE"
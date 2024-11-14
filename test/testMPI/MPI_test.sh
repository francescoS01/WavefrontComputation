#!/bin/bash
# ./MPI_test.sh

# Configura i parametri
EXECUTABLE="../../wf_mpi"  # Percorso all'eseguibile MPI
OUTPUT_FILE="res_MPI_time2.csv"  # File di output per i risultati

# Specifica le dimensioni delle matrici e i numeri di processi
MATRIX_SIZES=(200 400 600 800 1000 1200 1400 1800 2200 2600 3000)  
PROCESS_COUNTS=(3 5 7 9 11 13 15 17 19 20 21 22 26 30) 

# Numero massimo di nodi da utilizzare
MAX_NODES=5

# Azzera il file di output o creane uno nuovo
echo "Matrix Size,Number of Processes,Execution Time" > $OUTPUT_FILE

# Verifica se l'eseguibile esiste
if [ ! -f "$EXECUTABLE" ]; then
    echo "Errore: L'eseguibile $EXECUTABLE non esiste."
    exit 1
fi

# Ciclo su ogni dimensione della matrice
for N in "${MATRIX_SIZES[@]}"; do
    # Ciclo su ogni numero di processi
    for P in "${PROCESS_COUNTS[@]}"; do
        SUM=0
        ITERATIONS=5

        # Determina il numero di nodi da utilizzare
        if [ "$P" -lt "$MAX_NODES" ]; then
            NUM_NODES=$P
        else
            NUM_NODES=$MAX_NODES
        fi

        for ((i=0; i<ITERATIONS; i++)); do
            # Esegue il codice MPI e cattura l'output
            OUTPUT=$(srun --mpi=pmix --nodes=$NUM_NODES --ntasks=$P $EXECUTABLE $N | grep "Elapsed time" | awk '{print $3}')
            echo "Output catturato: $OUTPUT"  # Debug: stampa l'output catturato
            # Verifica se l'output è un numero valido
            if ! [[ "$OUTPUT" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
                echo "Errore: Output non valido ($OUTPUT) per N=$N, P=$P"
                exit 1
            fi

            # Somma il tempo di esecuzione come numero in virgola mobile
            SUM=$(echo "$SUM + $OUTPUT" | bc)
        done        

        # Calcola la media come numero in virgola mobile
        AVERAGE=$(echo "scale=6; $SUM / $ITERATIONS" | bc)

        # Scrive i risultati nel file CSV
        echo "$N,$P,$AVERAGE" >> $OUTPUT_FILE
    done
done
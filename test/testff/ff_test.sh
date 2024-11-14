#!/bin/bash

# Configura i parametri
EXECUTABLE="../../wf_fastflow"  # Percorso all'eseguibile C++
OUTPUT_FILE="res_ff_time2.csv"  # File di output per i risultati

# Specifica le dimensioni delle matrici e i numeri di thread
MATRIX_SIZES=(200 400 600 800 1000 1200 1400 1800 2200 2600 3000)  
THREAD_COUNTS=(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 18 20 22 26 30) 

# Azzera il file di output o creane uno nuovo
echo "Matrix Size,Number of Threads,Execution Time" > $OUTPUT_FILE

# Verifica se l'eseguibile esiste
if [ ! -f "$EXECUTABLE" ]; then
    echo "Errore: L'eseguibile $EXECUTABLE non esiste."
    exit 1
fi

# Ciclo su ogni dimensione della matrice
for N in "${MATRIX_SIZES[@]}"; do
    # Ciclo su ogni numero di thread
    for W in "${THREAD_COUNTS[@]}"; do
        SUM=0
        ITERATIONS=5

        for ((i=0; i<ITERATIONS; i++)); do
            # Esegue il codice C++ e cattura l'output usando 1 nodo e W core
            OUTPUT=$("$EXECUTABLE" "$N" "$W" | grep "Elapsed time" | awk '{print $3}')
            echo "Output catturato: $OUTPUT"  # Debug: stampa l'output catturato
            
            # Verifica se l'output è un numero valido
            if ! [[ "$OUTPUT" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
                echo "Errore: Output non valido ($OUTPUT) per N=$N, W=$W"
                exit 1
            fi

            # Somma il tempo di esecuzione come numero in virgola mobile
            SUM=$(echo "$SUM + $OUTPUT" | bc)
        done        

        # Calcola la media come numero in virgola mobile
        AVERAGE=$(echo "scale=6; $SUM / $ITERATIONS" | bc)

        # Scrive i risultati nel file CSV
        echo "$N,$W,$AVERAGE" >> $OUTPUT_FILE
    done
done

#!/bin/bash
# ./run_sequential.sh

# Configura i parametri
EXECUTABLE="../../src/sequential"  # Percorso all'eseguibile C++ (assicurati che sia compilato)
OUTPUT_FILE="res_sequential.csv"  # File di output per i risultati

# Specifica le dimensioni delle matrici
MATRIX_SIZES=(200 400 600 800 1000 1200 1400 1800 2200 2600 3000)  # Aggiungi altre dimensioni se necessario

# Numero di iterazioni per calcolare la media
ITERATIONS=5

# Azzera il file di output o creane uno nuovo
echo "Matrix Size,Execution Time" > $OUTPUT_FILE

# Verifica se l'eseguibile esiste
if [ ! -f "$EXECUTABLE" ]; then
    echo "Errore: L'eseguibile $EXECUTABLE non esiste."
    exit 1
fi

# Ciclo su ogni dimensione della matrice
for N in "${MATRIX_SIZES[@]}"; do
    SUM=0

    for ((i=0; i<ITERATIONS; i++)); do
        # Esegue il codice C++ e cattura l'output
        OUTPUT=$(srun $EXECUTABLE $N 2>&1)
        
        # Verifica se l'output è un numero valido
        if ! [[ "$OUTPUT" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            echo "Errore: Output non valido ($OUTPUT) per N=$N"
            exit 1
        fi

        # Converti l'output in un numero intero (arrotondando)
        OUTPUT=${OUTPUT%.*}

        # Somma l'output corrente alla somma totale
        SUM=$((SUM + OUTPUT))
    done

    # Calcola la media (approssimata)
    AVERAGE=$((SUM / ITERATIONS))

    # Scrive i risultati nel file CSV
    echo "$N,$AVERAGE" >> $OUTPUT_FILE
done
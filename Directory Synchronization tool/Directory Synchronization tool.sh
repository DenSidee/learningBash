#!/bin/bash
#Lo scopo è confrontare 2 directory date come argomenti e vedere se hanno file in comune e aggiornare la directory n.2 con i file presenti unicamente nella directory n.1

dir_partenza="$1"
dir_destinazione="$2"

# Funzione per verificare se le directory sono valide
aretheyok() {

    # Controlla se i file dati come argomenti sono directory
    if [ ! -d "$dir_partenza" ] || [ ! -d "$dir_destinazione" ]; then
        echo "ERRORE: Gli elementi indicati non sono directory." >&2 #reindirizzato in STDERR come errore
        exit 1
    fi

    # Controlla se le directory sono diverse
    if [ "$dir_partenza" = "$dir_destinazione" ]; then
        echo "ERRORE: Le directory di partenza e destinazione devono essere diverse." >&2 #reindirizzato in STDERR come errore
        exit 1
    fi

    # Controlla se i file dati come argomenti sono link simbolici
    if [ -L "$dir_partenza" ] || [ -L "$dir_destinazione" ]; then
        echo "ERRORE: I file indicati sono link simbolici." >&2 #reindirizzato in STDERR come errore
        exit 1
    fi
}

aretheyok #si richiama la funzione "aretheyok" per vedere se le directory date come argomenti vanno bene, se vanno bene procedono, altrimenti lo script si interrompe


# Funzione per chiedere conferma prima di procedere --punto 4
conferma() {
    if [ "$confirm" = true ]; then
        echo "Vuoi procedere? [y/n]: "
        read choice
        case "$choice" in
            [Yy]*) return 0 ;; #la funzione risulta vera 
            *) return 1 ;; #la funzione risulta falsa 
        esac
    fi
}

# Funzione per copiare i file dalla directory di partenza alla directory di destinazione se non presenti
copiafile() {
    for file in "$dir_partenza"/*; do
        nome_file=$(basename "$file") #si converte il nome del file in una stringa per facilitare la comparazione nel ciclo for
        if [ ! -e "$dir_destinazione/$nome_file" ]; then #se il file non esiste nella directory di destinazione, procede col copiare 
            if conferma; then
                cp "$file" "$dir_destinazione/$nome_file"
                echo "Copiando: $file -> $dir_destinazione/$nome_file"
            fi
        fi
    done
}

# Funzione per eliminare i file dalla directory di destinazione se non presenti nella directory di partenza
eliminafile() {
    for file in "$dir_destinazione"/*; do
        nome_file=$(basename "$file")
        if [ ! -e "$dir_partenza/$nome_file" ]; then #confronta i file presenti nella cartella di destinazione e se non esistono nella cartella di partenza, li elimina
            if conferma; then
                rm "$file"
                echo "Rimuovendo: $file"
            fi
        fi
    done
}

# Funzione per copiare i file con data di modifica diversa
copiasedatadiversa() {
    for file in "$dir_partenza"/*; do
        nome_file=$(basename "$file")
        if [ -e "$dir_destinazione/$nome_file" ]; then
            if [ "$(stat -c %Y "$file")" -ne "$(stat -c %Y "$dir_destinazione/$nome_file")" ]; then #confronta l'ultima data di modifica e se non sono uguali li sovvrascrive (%Y format UNIX)
                if conferma; then
                    cp "$file" "$dir_destinazione/$nome_file"
                    echo "Aggiornato: $file -> $dir_destinazione/$nome_file"
                fi
            fi
        fi
    done
}

# Funzione per aggiornare ricorsivamente le subdirectory
aggiorna_subdir() {
    for sub_dir in "$dir_partenza"/*; do
        if [ -d "$sub_dir" ]; then #controlla se è una directory 
            nome_subdir=$(basename "$sub_dir")
            if [ ! -e "$dir_destinazione/$nome_subdir" ]; then # controlla se esiste, se non esiste la copia nella directory di destinazione
                if conferma; then
                    cp -r "$sub_dir" "$dir_destinazione/$nome_subdir" #aggiunta l'opzione -r per la ricorsività -> altrimenti si presenta l'errore "cp: -r not specified; omitting directory"
                    echo "Copiando sub-directory: $sub_dir -> $dir_destinazione/$nome_subdir"
                fi
            fi
        fi
    done
}

# Parsing degli argomenti
confirm=false
recursive=false
#si usa il ciclo getopts per verificare se sono stati passati gli argomenti -i -r
while getopts ":ir" opt; do
    case $opt in
        i) confirm=true ;;
        r) recursive=true ;;
        \?) echo "Opzione non valida" >&2 && exit 1 ;; #in caso venga fornito un argomento non supportato esce dallo script e comunica l'errore reindirizzando in STDERR
    esac
done
shift $((OPTIND -1)) #elimina gli argomenti analizzati dopo la fine del ciclo getopts 



echo "Vuoi procedere con la sincronizzazione? [y/n]: "
read choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
  copiafile
  eliminafile
  copiasedatadiversa
fi


if [ "$recursive" = true ]; then #se l'argomento -r è fornito, recursive assume il valore true e richiama la funzione di aggiornamento per le subdirectory
    if conferma;then
        aggiorna_subdir
    fi
fi

echo "Script terminato"

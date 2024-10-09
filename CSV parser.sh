#!/bin/bash

file="$1"

#Controlliamo se il file dato come argomento è un file csv
if [[ "$file" != *.csv ]]
then
    echo "Il file indicato non è un file csv. Indica un file csv!"
    exit 1 
fi





#PUNTO 1
#Funzione per stampare la rubrica 
first_choice() {
    while IFS=';' read -r  nome cognome telefono indirizzo #legge il file csv dato in input e crea variabili di tutte le colonne 
    do
        echo "Nome e cognome: $nome $cognome, Numero:$telefono, Indirizzo: $indirizzo"
    done < "$file"
}

#PUNTO 2
#Funzione per stampare tutte le righe presenti nel file che contengono il cognome indicato nell'input
second_choice() {
    echo "Inserisci cognome da cercare nel file" 
    read cognome
    if grep -q ";$cognome;" "$file"  #Controlla se il cognome indicato è presente nel file ma silenzia l'output di grep (-p)
    then
        grep "$cognome" "$file"
    else
        echo "Cognome non presente nel file"
    fi


}

#PUNTO 3
#Funzione per modificare tutte le occorrenze di un nome di città
third_choice() {
    echo "Inserisci nome città che vuoi modificare"
    read old
    echo "Inserisci il nuovo nome di città"
    read new
    
    sed -i "s/;$old/;$new/g" "$file"

}

#PUNTO 4
#Funzione per eliminare una riga corrispondente al numero indicato in input
fourth_choice() {
    echo "Inserisci il numero di riga da eliminare"
    read riga #Lettura del numero di riga da eliminare 
    sed -i "${riga}d" "$file"  #Elimina riga corrispondente al numero 

}

#STAMPA MENU SCELTE

while true
do
    echo "1) Stampa rubrica"
    echo "2) Stampa righe contenenti cognome desiderato"
    echo "3) Modifica tutti i casi di un nome di città"
    echo "4) Eliminazione riga desiderata" 
    echo "5) Termina Script."

    echo "Inserisci opzione" 
    read choice 

    case $choice in
        1) first_choice ;;
        2) second_choice ;;
        3) third_choice ;;
        4) fourth_choice ;;
        *) echo "Script terminato" && exit ;;
    esac

done

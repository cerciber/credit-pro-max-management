#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Leer el archivo cli.sh y extraer funciones con sus comentarios
while IFS= read -r line; do
    # Buscar comentarios que describen funciones
    if [[ $line =~ ^#\ (.+) ]]; then
        comment="${BASH_REMATCH[1]}"
        # Leer la siguiente línea para obtener el nombre de la función
        read -r next_line
        if [[ $next_line =~ ^([a-zA-Z0-9_-]+)\(\) ]]; then
            function_name="${BASH_REMATCH[1]}"
            
            # Extraer parámetros del comentario (formato: <param>)
            params=""
            if [[ $comment =~ \<([^>]+)\> ]]; then
                # Extraer todos los parámetros encontrados
                while [[ $comment =~ \<([^>]+)\> ]]; do
                    param="${BASH_REMATCH[1]}"
                    if [[ -z "$params" ]]; then
                        params=" <$param>"
                    else
                        params="$params <$param>"
                    fi
                    # Remover el parámetro encontrado para buscar el siguiente
                    comment="${comment/<$param> /}"
                done
            fi
            
            log "cyan" "$function_name\033[33m$params\033[0m \033[90m$comment\033[0m" 1
        fi
    fi
done < ./cli.sh

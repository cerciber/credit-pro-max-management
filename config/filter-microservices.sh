#!/bin/bash

# Cargar la configuración de microservicios
source ./config/config.sh
source ./config/logs.sh

# Array para almacenar los microservicios filtrados
FILTERED_MICROSERVICES=()

# Si no se pasan parámetros, usar todos los microservicios
if [ $# -eq 0 ]; then
    FILTERED_MICROSERVICES=("${MICROSERVICES[@]}")
else
    # Filtrar microservicios según los parámetros proporcionados
    for param in "$@"; do
        encontrado=false
        for service in "${MICROSERVICES[@]}"; do
            if [[ "$service" == "$param" ]]; then
                # Verificar si ya está en la lista filtrada (evitar duplicados)
                if [[ ! " ${FILTERED_MICROSERVICES[@]} " =~ " ${service} " ]]; then
                    FILTERED_MICROSERVICES+=("$service")
                fi
                encontrado=true
                break
            fi
        done
        if [ "$encontrado" = false ]; then
            log "red" "El microservicio '$param' no existe en la configuración." 1
            exit 1
        fi
    done
fi

# Exportar el array filtrado para que pueda ser usado por otros scripts
export FILTERED_MICROSERVICES

#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Cambiar al directorio del microservicio
cd "$1"

# Leer el contenido del package.client.json desde origin/main (versión del cliente)
client_content=$(git show origin/main:package.client.json)

# Obtener las claves del package.client.json y eliminarlas del package.json
log "blue" "Descartando claves del cliente del package.json" 2

# Usar jq para eliminar los elementos específicos de cada clave
echo "$client_content" | jq -r 'to_entries[] | "\(.key)|\(.value | join(","))"' | while IFS='|' read -r key values; do
    if [ -n "$key" ] && [ -n "$values" ]; then
        # Dividir los valores por comas y eliminar cada uno
        echo "$values" | tr ',' '\n' | while read -r value; do
            if [ -n "$value" ]; then
                log "gray" "Descartando $value de $key" 3
                command "jq \"del(.$key.\\\"$value\\\")\" package.json > package.json.tmp && mv package.json.tmp package.json" 4
            fi
        done
    fi
done

log "green" "Configuraciones del cliente descartadas exitosamente" 1
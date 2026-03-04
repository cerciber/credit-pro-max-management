#!/bin/bash

# Cargar variables de entorno desde archivo .env si existe
if [ -f .env ]; then
    log "gray" "Cargando variables de entorno desde .env..." 1
    set -a  # Automáticamente exportar todas las variables
    source .env
    set +a  # Desactivar exportación automática
else
    log "red" "Archivo .env no encontrado." 1
    exit 1
fi

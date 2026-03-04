#!/bin/bash

# Cargar logs
source ./logs.sh

# Imprimir mensaje de inicio en verde
log "white" "GIT CONFIG: Configurando Git en los microservicios especificados"

# Cargar variables de entorno
source ./load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./config/filter-microservices.sh "$@"

log "blue" "Configurando Git en cerciber-manager..." 1

# Configurar usuario local
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

log "gray" "Usuario configurado: $(git config user.name)" 2
log "gray" "Email configurado: $(git config user.email)" 2

# Iterar sobre cada microservicio filtrado
for repo in "${FILTERED_MICROSERVICES[@]}"; do
    log "blue" "Configurando Git en $repo..." 1
    
    cd "$repo"
        
    # Configurar usuario local
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    log "gray" "Usuario configurado: $(git config user.name)" 2
    log "gray" "Email configurado: $(git config user.email)" 2
    
    # Volver al directorio padre
    cd ..
done

log "green" "Configuración de Git completada." 1

#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Imprimir mensaje de inicio
log "white" "GIT MERGE SEND BASE: Enviando cambios del cliente al repositorio base"

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./config/filter-microservices.sh "$@"

# Ir al repo especificado
cd $1

# Ir a la rama base
log "blue" "Cambiando a la rama feat/new-base-changes" 1
command "git checkout feat/new-base-changes" 2

# Asegurar que tenemos la última referencia de upstream/main
log "blue" "Obteniendo cambios del upstream main" 1
command "git fetch upstream main" 2

# Validar estructura de los cambios
log "blue" "Validando estructura de los cambios" 1
command "npm run check-all" 2

# Ejecutar test:webserver
log "blue" "Validando pruebas de extremo a extremo" 1
if ! condition "npm run test:webserver" 2; then
    log "red" "Error: Las pruebas fallaron. El proceso se detiene." 1
    exit 1
fi
log "green" "Pruebas pasaron exitosamente" 2

# Agregar todos los cambios al staging
log "blue" "Agregando todos los cambios al staging" 1
command "git add ." 2

# Hacer commit de los cambios solo si hay cambios en el staging
log "blue" "Hacer commit de los cambios solo si hay cambios" 1
if ! condition "git diff --cached --quiet" 2; then
    log "blue" "Haciendo commit de los cambios" 2
    command "git commit -m \"feat: merge new base changes to main\"" 3
else
    log "gray" "No hay cambios para commitear" 2
fi

# Enviar los cambios al upstream main
log "blue" "Enviando cambios al repositorio base" 1
command "git push upstream feat/new-base-changes:main" 2

# Ir a la rama main
log "blue" "Cambiando a la rama main" 1
command "git checkout main" 2

# Borrar la rama local feat/new-base-changes
log "blue" "Borrando la rama local feat/new-base-changes" 1
command "git branch -D feat/new-base-changes" 2

# Borrar la rama remota feat/new-base-changes
log "blue" "Borrando la rama remota feat/new-base-changes" 1
command "git push origin --delete feat/new-base-changes" 2

# Imprimir mensaje de finalización
log "green" "Se enviaron correctamente los cambios del cliente al repositorio base" 1

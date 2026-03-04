#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Imprimir mensaje de inicio en verde
log "white" "GIT MERGE BASE: Integrando cambios del base en el repositorio actual"

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./config/filter-microservices.sh "$@"

# Ir al repo especificado
cd $1

# Ir a la rama base
log "blue" "Cambiando a la rama feat/base-changes" 1
command "git checkout feat/base-changes" 2

# Traer los cambios del main
log "blue" "Obteniendo cambios del main" 1
command "git fetch origin main" 2

# Mezclar los cambios del main en la rama base
log "blue" "Mergeando cambios del main en feat/base-changes" 1
command "git merge origin/main --no-edit" 2

# Ejecutar test:webserver
log "blue" "Validando pruebas de extremo a extremo" 1
if ! condition "npm run test:webserver" 2; then
    log "red" "Error: Las pruebas fallaron. El proceso se detiene." 2
    exit 1
fi

# Agregar todos los cambios al staging
log "blue" "Agregando todos los cambios al staging" 1
command "git add ." 2

# Hacer commit de los cambios solo si hay cambios en el staging
log "blue" "Hacer commit de los cambios solo si hay cambios" 1
if ! condition "git diff --cached --quiet" 2; then
    log "blue" "Haciendo commit de los cambios" 2
    command "git commit -m \"feat: merge base changes to main\"" 2
else
    log "gray" "No hay cambios para commitear" 2
fi

# Mergear la rama base en el main
log "blue" "Cambiando a la rama main" 1
command "git checkout main" 2

log "blue" "Mergeando feat/base-changes en main" 1
command "git merge feat/base-changes --no-edit" 2

log "blue" "Subiendo cambios al repositorio remoto" 1
command "git push origin main" 2

# Borrar la rama local feat/base-changes
log "blue" "Borrando la rama local feat/base-changes" 1
command "git branch -D feat/base-changes" 2

# Borrar la rama remota feat/base-changes
log "blue" "Borrando la rama remota feat/base-changes" 1
command "git push origin --delete feat/base-changes" 2

# Imprimir mensaje de finalización
log "green" "Se integraron correctamente los cambios del base en el main del repositorio actual" 1


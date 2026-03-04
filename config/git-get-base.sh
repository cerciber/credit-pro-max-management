#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Imprimir mensaje de inicio en verde
log "white" "GIT GET BASE: Obteniendo cambios del base en una rama local feat/base-changes"

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./config/filter-microservices.sh "$@"

# Ir al repo especificado
cd $1

# Cambiar a rama main
log "blue" "Cambiando a rama main" 1
command "git checkout main" 2

# Borrar la rama local feat/base-changes si existe
log "blue" "Borrando la rama local feat/base-changes si existe" 1
if condition "git branch --list feat/base-changes | grep -q feat/base-changes" 2; then
    log "gray" "La rama local feat/base-changes ya existe" 2
    log "blue" "Borrando rama local feat/base-changes" 2
    command "git branch -D feat/base-changes" 3
else
    log "gray" "La rama local feat/base-changes no existe" 2
fi

# Borrar la rama remota feat/base-changes si existe
log "blue" "Borrando rama remota feat/base-changes si existe" 1
if condition "git ls-remote --heads origin feat/base-changes | grep -q feat/base-changes" 2; then
    log "gray" "La rama remota feat/base-changes ya existe" 2
    log "blue" "Borrando rama remota feat/base-changes" 2
    command "git push origin --delete feat/base-changes" 3
else
    log "gray" "La rama remota feat/base-changes no existe" 2
fi

# Verificar si existe el remoto upstream
log "blue" "Asignando el remoto upstream si no existe" 1
if condition "git remote | grep -q upstream" 2; then
    log "gray" "El remoto upstream ya existe" 2
else
    log "gray" "El remoto upstream no existe" 2
    log "blue" "Agregando remoto upstream" 2
    command "git remote add upstream https://github.com/cerciber/cerciber-base.git" 3
fi

# Obtener cambios del repositorio base
log "blue" "Obteniendo cambios del repositorio base" 1
command "git fetch upstream" 2

# Crear rama feat/base-changes con cambios del base
log "blue" "Creando rama feat/base-changes con la versión exacta del base" 1
command "git checkout -b feat/base-changes upstream/main" 2

# Subir rama feat/base-changes al repositorio
log "blue" "Subiendo rama feat/base-changes al remoto" 1
command "git push -u origin feat/base-changes" 2

# Obtener cambios de main
log "blue" "Actualizando cambios del repo actual" 1
command "git fetch origin main" 2

# Mergear cambios de main a feat/base-changes
log "blue" "Mergeando cambios del repo actual en feat/base-changes" 1
if condition "git merge origin/main --no-edit" 2; then
    # Merge exitoso, verificar si hay conflictos
    if git status --porcelain | grep -q "^UU\|^AA\|^DD"; then
        log "yellow" "Se detectaron conflictos en el merge" 1
        log "gray" "Debes resolver los conflictos manualmente antes de continuar" 2
        log "gray" "Una vez resueltos los conflictos, ejecuta" 2
        log "yellow" "git-merge-base $1" 3
    else
        # No hay conflictos, ejecutar automáticamente git-merge-base
        log "green" "Se creó correctamente la rama feat/base-changes con los cambios del base integrados en el repo actual" 1
        log "blue" "Ejecutando automáticamente git-merge-base $1" 2
        cd .. && ./config/git-merge-base.sh $1
    fi
else
    # Merge falló
    log "yellow" "Se encontraron conflictos en el merge" 1
    log "gray" "Revisa los conflictos y resuélvelos manualmente" 2
    log "gray" "Cuando estes listo para mandar los cambios al base, ejecuta" 2
    log "magenta" "git-merge-base $1" 3
fi

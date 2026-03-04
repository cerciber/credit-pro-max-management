#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Imprimir mensaje de inicio
log "white" "GIT PREPARE SEND BASE: Preparando cambios para enviar al repositorio base"

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./config/filter-microservices.sh "$@"

# Ir al repo especificado
cd $1

# Ir al main
log "blue" "Cambiando a la rama main" 1
command "git checkout main" 2

# Borrar la rama local feat/new-base-changes si existe
log "blue" "Borrando la rama local feat/new-base-changes si existe" 1
if condition "git branch --list feat/new-base-changes | grep -q feat/new-base-changes" 2; then
    log "gray" "La rama local feat/new-base-changes ya existe" 2
    log "blue" "Borrando rama local feat/new-base-changes" 2
    command "git branch -D feat/new-base-changes" 3
else
    log "gray" "La rama local feat/new-base-changes no existe" 2
fi

# Borrar la rama remota feat/new-base-changes si existe
log "blue" "Borrando rama remota feat/new-base-changes si existe" 1
if condition "git ls-remote --heads origin feat/new-base-changes | grep -q feat/new-base-changes" 2; then
    log "gray" "La rama remota feat/new-base-changes ya existe" 2
    log "blue" "Borrando rama remota feat/new-base-changes" 2
    command "git push origin --delete feat/new-base-changes" 3
else
    log "gray" "La rama remota feat/new-base-changes no existe" 2
fi

# En el fork agregar el base como remoto si no está (upstream)
log "blue" "Configurando remoto upstream" 1
if condition "git remote | grep -q upstream" 2; then
    log "gray" "El remoto upstream ya existe" 2
    log "blue" "Actualizando URL del remoto upstream" 2
    command "git remote set-url upstream https://github.com/cerciber/cerciber-base.git" 3
else
    log "gray" "El remoto upstream no existe" 2
    log "blue" "Agregando remoto upstream" 2
    command "git remote add upstream https://github.com/cerciber/cerciber-base.git" 3
fi

# Traer lo último del base
log "blue" "Obteniendo cambios del repositorio base" 1
command "git fetch upstream" 2

# Crear rama limpia con los cambios del repo base
log "blue" "Creando rama feat/new-base-changes con la versión exacta del base" 1
command "git checkout -b feat/new-base-changes upstream/main" 2

# Dejar de apuntar al repo base (evitar mandar cambios al main del base directamente)
log "blue" "Subiendo rama feat/new-base-changes al remoto" 1
command "git push -u origin feat/new-base-changes" 2

# Traer al local todos los cambios que se han hecho en el cliente (ignorando las implementaciones de solo el cliente)
log "blue" "Integrando cambios del cliente que se cruzan con el base" 1
command "git checkout origin/main -- . ':!app/(private)' ':!app/(public)' ':!app/api' ':!src/modules' ':!app/config/client' ':!src/config/statics/client' ':!package-lock.json' ':!package.client.json'" 2
command "git checkout origin/main -- 'app/(private)/components'" 2
command "git checkout origin/main -- 'app/(private)/home'" 2
command "git checkout origin/main -- 'app/(private)/status'" 2
command "git checkout origin/main -- 'app/(private)/users'" 2
command "git checkout origin/main -- 'app/(private)/layout.tsx'" 2
command "git checkout origin/main -- 'app/(public)/login'" 2
command "git checkout origin/main -- 'app/api/auth'" 2
command "git checkout origin/main -- 'app/api/status'" 2
command "git checkout origin/main -- 'app/api/users'" 2
command "git checkout origin/main -- 'src/modules/auth'" 2
command "git checkout origin/main -- 'src/modules/general'" 2
command "git checkout origin/main -- 'src/modules/status'" 2
command "git checkout origin/main -- 'src/modules/users'" 2
command "git reset" 2

# Descargar configuraciones del cliente
log "blue" "Descartando configuraciones del cliente" 1
cd ..
source ./config/git-discard-client-config.sh "$1"

# Imprimir mensaje de finalización
log "green" "Se preparó correctamente la rama feat/new-base-changes con los cambios del cliente integrados en el base" 1
log "gray" "Revisa cuidadosamente los cambios que quieres enviar al base antes de continuar" 2
log "gray" "Cuando estés listo para enviar los cambios al base, ejecuta" 2
log "yellow" "git-merge-send-base $1" 3

#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Imprimir mensaje de inicio
log "white" "GIT PREPARE INCREMENT: Preparando nueva rama para incremento"

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según el primer parámetro solamente
source ./config/filter-microservices.sh "$1"

# Verificar que se proporcionen los parámetros necesarios
if [ -z "$1" ] || [ -z "$2" ]; then
    log "red" "Error: Debes proporcionar el nombre del repositorio y el nombre de la rama"
    log "gray" "Uso: ./git-prepare-increment.sh <nombre-repositorio> <nombre-rama>"
    log "gray" "Ejemplo: ./git-prepare-increment.sh cerciber-landing nueva-funcionalidad"
    exit 1
fi

# Ir al repo especificado
cd $1

# Verificar que estamos en un repositorio git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log "red" "Error: No estás en un repositorio git válido"
    exit 1
fi

# Cambiar a rama main
log "blue" "Cambiando a rama main" 1
command "git checkout main" 2

# Actualizar main con los últimos cambios
log "blue" "Actualizando rama main con los últimos cambios" 1
command "git pull origin main" 2

# Usar el nombre de rama proporcionado como segundo parámetro
BRANCH_NAME="feat/$2"

# Borrar la rama local si existe (por seguridad)
log "blue" "Verificando si la rama $BRANCH_NAME ya existe localmente" 1
if condition "git branch --list $BRANCH_NAME | grep -q $BRANCH_NAME" 2; then
    log "gray" "La rama local $BRANCH_NAME ya existe" 2
    log "blue" "Borrando rama local $BRANCH_NAME" 2
    command "git branch -D $BRANCH_NAME" 3
else
    log "gray" "La rama local $BRANCH_NAME no existe" 2
fi

# Borrar la rama remota si existe (por seguridad)
log "blue" "Verificando si la rama $BRANCH_NAME ya existe remotamente" 1
if condition "git ls-remote --heads origin $BRANCH_NAME | grep -q $BRANCH_NAME" 2; then
    log "gray" "La rama remota $BRANCH_NAME ya existe" 2
    log "blue" "Borrando rama remota $BRANCH_NAME" 2
    command "git push origin --delete $BRANCH_NAME" 3
else
    log "gray" "La rama remota $BRANCH_NAME no existe" 2
fi

# Crear nueva rama desde main
log "blue" "Creando nueva rama $BRANCH_NAME desde main" 1
command "git checkout -b $BRANCH_NAME" 2

# Subir la nueva rama al remoto
log "blue" "Subiendo rama $BRANCH_NAME al remoto" 1
command "git push -u origin $BRANCH_NAME" 2

# Imprimir mensaje de finalización
log "green" "Se creó correctamente la rama $BRANCH_NAME y está lista para el incremento" 1
log "gray" "La rama ha sido pusheada al remoto y está configurada para tracking" 2
log "gray" "Puedes comenzar a trabajar en tus cambios en esta rama" 2
log "gray" "Cuando estés listo para mergear, ejecuta:" 2
log "yellow" "git-merge-increment $1 $2" 3

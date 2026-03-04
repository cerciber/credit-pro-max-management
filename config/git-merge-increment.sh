#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Imprimir mensaje de inicio
log "white" "GIT MERGE INCREMENT: Mergeando incremento a main"

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según el primer parámetro solamente
source ./config/filter-microservices.sh "$1"

# Verificar que se proporcionen los parámetros necesarios
if [ -z "$1" ] || [ -z "$2" ]; then
    log "red" "Error: Debes proporcionar el nombre del repositorio y el nombre de la rama"
    log "gray" "Uso: ./git-merge-increment.sh <nombre-repositorio> <nombre-rama>"
    log "gray" "Ejemplo: ./git-merge-increment.sh cerciber-landing nueva-funcionalidad"
    exit 1
fi

# Ir al repo especificado
cd $1

# Verificar que estamos en un repositorio git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log "red" "Error: No estás en un repositorio git válido"
    exit 1
fi

# Construir nombre de rama
BRANCH_NAME="feat/$2"

# Verificar que la rama existe localmente
log "blue" "Verificando que la rama $BRANCH_NAME existe" 1
if ! condition "git branch --list $BRANCH_NAME | grep -q $BRANCH_NAME" 2; then
    log "red" "Error: La rama $BRANCH_NAME no existe localmente"
    log "gray" "Asegúrate de haber ejecutado git-prepare-increment primero"
    exit 1
fi

# Cambiar a la rama de incremento
log "blue" "Cambiando a la rama $BRANCH_NAME" 1
command "git checkout $BRANCH_NAME" 2

# Actualizar main con los últimos cambios
log "blue" "Actualizando rama main con los últimos cambios" 1
command "git fetch origin main" 2

# Traer los cambios del main a la rama de incremento
log "blue" "Mergeando cambios del main en $BRANCH_NAME" 1
if condition "git merge origin/main --no-edit" 2; then
    log "green" "Merge exitoso, no hay conflictos" 2
else
    log "yellow" "Se detectaron conflictos en el merge" 1
    log "gray" "Debes resolver los conflictos manualmente antes de continuar" 2
    log "gray" "Una vez resueltos los conflictos, ejecuta:" 2
    log "yellow" "git-merge-increment $1 $2" 3
    exit 1
fi

# Ejecutar pruebas
log "blue" "Ejecutando pruebas para validar el incremento" 1
if ! condition "npm run test:webserver" 2; then
    log "red" "Error: Las pruebas fallaron. El proceso se detiene." 1
    log "gray" "Corrige los errores en las pruebas antes de continuar" 2
    exit 1
fi
log "green" "Pruebas pasaron exitosamente" 2

# Agregar todos los cambios al staging
log "blue" "Agregando todos los cambios al staging" 1
command "git add ." 2

# Hacer commit de los cambios solo si hay cambios en el staging
log "blue" "Haciendo commit de los cambios del merge" 1
if ! condition "git diff --cached --quiet" 2; then
    log "blue" "Haciendo commit de los cambios del merge" 2
    command "git commit -m \"feat: merge main changes into $BRANCH_NAME\"" 3
else
    log "gray" "No hay cambios para commitear" 2
fi

# Cambiar a main
log "blue" "Cambiando a la rama main" 1
command "git checkout main" 2

# Mergear la rama de incremento a main
log "blue" "Mergeando $BRANCH_NAME a main" 1
command "git merge $BRANCH_NAME --no-edit" 2

# Subir los cambios a main
log "blue" "Subiendo cambios a main" 1
command "git push origin main" 2

# Borrar la rama local
log "blue" "Borrando la rama local $BRANCH_NAME" 1
command "git branch -D $BRANCH_NAME" 2

# Borrar la rama remota
log "blue" "Borrando la rama remota $BRANCH_NAME" 1
command "git push origin --delete $BRANCH_NAME" 2

# Imprimir mensaje de finalización
log "green" "Se mergeó exitosamente el incremento $2 a main" 1
log "gray" "La rama $BRANCH_NAME ha sido eliminada local y remotamente" 2
log "gray" "Los cambios están disponibles en main" 2

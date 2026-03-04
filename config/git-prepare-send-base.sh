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
    command "git remote set-url upstream https://github.com/cerciber/credit-pro-max-base.git" 3
else
    log "gray" "El remoto upstream no existe" 2
    log "blue" "Agregando remoto upstream" 2
    command "git remote add upstream https://github.com/cerciber/credit-pro-max-base.git" 3
fi

# Traer lo último del base
log "blue" "Obteniendo cambios del repositorio base" 1
command "git fetch upstream" 2

# Crear rama limpia con los cambios del repo base
log "blue" "Creando rama feat/new-base-changes con la versión exacta del base" 1
command "git checkout -b feat/new-base-changes upstream/main" 2

# Obtener cambios de main del repo actual (hijo)
log "blue" "Obteniendo cambios del repositorio hijo (origin/main)" 1
command "git fetch origin main" 2

# Verificar si una ruta coincide con una regla (archivo exacto o contenido dentro de carpeta)
matches_rule_path() {
    local file="$1"
    local rule_path="$2"

    if [ "$rule_path" = "." ]; then
        return 0
    fi

    if [ "$file" = "$rule_path" ] || [[ "$file" == "$rule_path/"* ]]; then
        return 0
    fi

    return 1
}

# Determinar si un archivo debe sincronizarse según BASE_SYNC_RULES
# Reglas:
# - include: "ruta"
# - exclude: "!ruta"
# - última coincidencia gana
should_sync_file() {
    local file="$1"
    local include=false
    local rule action rule_path

    for rule in "${BASE_SYNC_RULES[@]}"; do
        if [[ "$rule" == !* ]]; then
            action="exclude"
            rule_path="${rule:1}"
        else
            action="include"
            rule_path="$rule"
        fi

        if matches_rule_path "$file" "$rule_path"; then
            if [ "$action" = "include" ]; then
                include=true
            else
                include=false
            fi
        fi
    done

    if [ "$include" = true ]; then
        return 0
    fi
    return 1
}

# Aplicar sync de archivos diferentes entre upstream/main y origin/main según reglas (hijo -> base)
log "blue" "Integrando diferencias permitidas del hijo hacia el base" 1
while IFS= read -r SYNC_FILE; do
    if [ -n "$SYNC_FILE" ] && should_sync_file "$SYNC_FILE"; then
        if git cat-file -e "origin/main:$SYNC_FILE" 2>/dev/null; then
            command "git checkout origin/main -- \"$SYNC_FILE\"" 2 false
        else
            command "git rm -f -- \"$SYNC_FILE\"" 2 false
        fi
    fi
done < <(git diff --name-only upstream/main origin/main)

# Agregar todos los cambios al staging
log "blue" "Agregando cambios al staging" 1
command "git add -A" 2

# Commit solo si hay cambios
log "blue" "Creando commit con los cambios del hijo (si aplica)" 1
if ! condition "git diff --cached --quiet" 2; then
    command "git commit -m \"feat: sync child changes to base\"" 2
    log "green" "Se prepararon cambios para enviar al base en feat/new-base-changes" 1
else
    log "gray" "No hay diferencias permitidas entre upstream/main y origin/main" 2
fi

# Subir rama feat/new-base-changes al remoto
log "blue" "Subiendo rama feat/new-base-changes al remoto" 1
command "git push -u origin feat/new-base-changes" 2

# Imprimir mensaje de finalización
log "green" "Se preparó correctamente la rama feat/new-base-changes con los cambios permitidos del hijo hacia el base" 1
log "gray" "Revisa cuidadosamente los cambios que quieres enviar al base antes de continuar" 2
log "gray" "Cuando estés listo para enviar los cambios al base, ejecuta" 2
log "yellow" "git-merge-send-base $1" 3

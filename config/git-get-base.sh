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
    command "git remote add upstream https://github.com/cerciber/credit-pro-max-base.git" 3
fi

# Obtener cambios del repositorio base
log "blue" "Obteniendo cambios del repositorio base" 1
command "git fetch upstream" 2

# Obtener cambios de main del repo actual
log "blue" "Actualizando cambios del repo actual" 1
command "git fetch origin main" 2

# Crear rama feat/base-changes basada en main del repo actual
log "blue" "Creando rama feat/base-changes desde origin/main" 1
command "git checkout -b feat/base-changes origin/main" 2

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

# Aplicar sync de archivos diferentes entre origin/main y upstream/main según reglas
log "blue" "Aplicando diferencias permitidas de upstream/main sobre feat/base-changes" 1
while IFS= read -r SYNC_FILE; do
    if [ -n "$SYNC_FILE" ] && should_sync_file "$SYNC_FILE"; then
        if git cat-file -e "upstream/main:$SYNC_FILE" 2>/dev/null; then
            command "git checkout upstream/main -- \"$SYNC_FILE\"" 2 false
        else
            command "git rm -f -- \"$SYNC_FILE\"" 2 false
        fi
    fi
done < <(git diff --name-only origin/main upstream/main)

# Staging de todos los cambios aplicados desde upstream
log "blue" "Agregando cambios aplicados al staging" 1
command "git add -A" 2

# Commit solo si hay cambios
log "blue" "Creando commit con los cambios del base (si aplica)" 1
if ! condition "git diff --cached --quiet" 2; then
    command "git commit -m \"feat: sync upstream base changes\"" 2
    log "green" "Se creó correctamente feat/base-changes con cambios del upstream" 1
else
    log "gray" "No hay diferencias entre origin/main y upstream/main" 2
fi

# Subir rama feat/base-changes al remoto
log "blue" "Subiendo rama feat/base-changes al remoto" 1
command "git push -u origin feat/base-changes" 2

log "green" "Proceso completado. Revisa feat/base-changes y continúa con git-merge-base cuando estés listo." 1

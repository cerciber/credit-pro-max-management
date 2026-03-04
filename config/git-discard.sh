#!/bin/bash
# Cargar logs
source ./config/logs.sh

# Cargar variables de entorno
source ./config/load-env.sh

# Función para mostrar ayuda
show_help() {
    log "white" "GIT DISCARD - Eliminar todos los cambios locales y stash"
    log "cyan" "Uso: git-discard [microservicios...]"
    log "cyan" "Descripción:"
    log "yellow" "  Este comando elimina todos los cambios locales (working directory y staging area)" 1
    log "yellow" "  y también limpia el stash de git para los microservicios especificados." 1
    log "cyan" "Microservicios disponibles:"
    for service in "${MICROSERVICES[@]}"; do
        log "yellow" "  $service" 1
    done
    log "cyan" "Ejemplos:"
    log "yellow" "  git-discard                    # Aplicar a todos los microservicios" 1
    log "yellow" "  git-discard cerciber-base      # Aplicar solo a cerciber-base" 1
    log "yellow" "  git-discard cerciber-base cerciber-admn  # Aplicar a múltiples microservicios" 1
    log "red" "ADVERTENCIA: Esta operación es irreversible y eliminará todos los cambios locales."
}
# Verificar si se solicita ayuda
if [[ "$1" == "help" || "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi
# Filtrar microservicios según los parámetros proporcionados
source ./filter-microservices.sh "$@"
# Función para descartar cambios en un microservicio
discard_changes() {
    local service=$1
    log "blue" "Procesando $service..." 1
    if [ ! -d "$service" ]; then
        log "red" "Directorio $service no existe" 2
        return 1
    fi
    if [ ! -d "$service/.git" ]; then
        log "red" "No es un repositorio git: $service" 2
        return 1
    fi
    cd "$service" || return 1
    # Verificar si hay cambios
    local has_changes=false
    local has_staged=false
    local has_stash=false
    # Verificar cambios en working directory
    if ! git diff --quiet; then
        has_changes=true
    fi
    # Verificar cambios en staging area
    if ! git diff --cached --quiet; then
        has_staged=true
    fi
    # Verificar si hay stash
    if git stash list | grep -q .; then
        has_stash=true
    fi
    if [ "$has_changes" = false ] && [ "$has_staged" = false ] && [ "$has_stash" = false ]; then
        log "green" "No hay cambios que descartar en $service" 2
        cd ..
        return 0
    fi
    # Mostrar resumen de lo que se va a eliminar
    log "yellow" "Cambios que se eliminarán en $service:" 2
    if [ "$has_changes" = true ]; then
        log "red" "  - Cambios en working directory" 3
    fi
    if [ "$has_staged" = true ]; then
        log "red" "  - Cambios en staging area" 3
    fi
    if [ "$has_stash" = true ]; then
        local stash_count=$(git stash list | wc -l)
        log "red" "  - $stash_count elemento(s) en stash" 3
    fi
    # Confirmar antes de proceder
    log "white" ""
    read -p "¿Estás seguro de que quieres eliminar todos estos cambios? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "yellow" "Operación cancelada para $service" 2
        cd ..
        return 0
    fi
    # Eliminar cambios en staging area
    if [ "$has_staged" = true ]; then
        log "cyan" "Eliminando cambios del staging area..." 3
        command "git reset --hard HEAD" 4
    fi
    # Eliminar cambios en working directory
    if [ "$has_changes" = true ]; then
        log "cyan" "Eliminando cambios del working directory..." 3
        command "git checkout -- ." 4
    fi
    # Limpiar stash
    if [ "$has_stash" = true ]; then
        log "cyan" "Limpiando stash..." 3
        command "git stash clear" 4
    fi
    # Verificar que todo esté limpio
    if git diff --quiet && git diff --cached --quiet && ! git stash list | grep -q .; then
        log "green" "Todos los cambios eliminados exitosamente en $service" 2
    else
        log "red" "Error: Algunos cambios no se pudieron eliminar en $service" 2
        cd ..
        return 1
    fi
    cd ..
    return 0
}
# Función principal
main() {
    log "white" "GIT DISCARD: Eliminando cambios locales y stash"
    local success_count=0
    local total_count=${#FILTERED_MICROSERVICES[@]}
    for service in "${FILTERED_MICROSERVICES[@]}"; do
        if discard_changes "$service"; then
            ((success_count++))
        fi
    done
    log "white" "Resumen:"
    log "green" "  Microservicios procesados exitosamente: $success_count/$total_count"
    if [ $success_count -eq $total_count ]; then
        log "green" "Todos los cambios han sido eliminados exitosamente."
        exit 0
    else
        log "red" "Algunos microservicios tuvieron errores."
        exit 1
    fi
}
# Ejecutar función principal
main "$@"
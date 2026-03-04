#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./config/filter-microservices.sh "$@"

# Patrones de ramas a eliminar
BRANCH_PATTERNS=("feat/increment" "feat/base-changes" "feat/new-base-changes")

log "white" "GIT CLEANUP BRANCHES: Limpiando ramas de desarrollo en microservicios filtrados"

# Función para eliminar ramas locales
cleanup_local_branches() {
    local service=$1
    log "blue" "Limpiando ramas locales en $service" 1
    
    cd "$service" || {
        log "red" "No se pudo acceder al directorio $service" 2
        return 1
    }
    
    # Obtener todas las ramas locales que coincidan con los patrones
    for pattern in "${BRANCH_PATTERNS[@]}"; do
        branches=$(git branch | grep -E "$pattern" | sed 's/^[ *]*//' || true)
        
        if [ -n "$branches" ]; then
            log "yellow" "Encontradas ramas locales con patrón '$pattern':" 2
            echo "$branches" | while read -r branch; do
                log "gray" "  - $branch" 3
            done
            
            # Eliminar cada rama
            echo "$branches" | while read -r branch; do
                if [ -n "$branch" ]; then
                    log "blue" "Eliminando rama local: $branch" 2
                    if git branch -D "$branch" 2>/dev/null; then
                        log "green" "✓ Rama local '$branch' eliminada" 3
                    else
                        log "red" "✗ Error eliminando rama local '$branch'" 3
                    fi
                fi
            done
        else
            log "gray" "No se encontraron ramas locales con patrón '$pattern'" 2
        fi
    done
    
    cd - > /dev/null
}

# Función para eliminar ramas remotas
cleanup_remote_branches() {
    local service=$1
    log "blue" "Limpiando ramas remotas en $service" 1
    
    cd "$service" || {
        log "red" "No se pudo acceder al directorio $service" 2
        return 1
    }
    
    # Obtener todas las ramas remotas que coincidan con los patrones
    for pattern in "${BRANCH_PATTERNS[@]}"; do
        branches=$(git branch -r | grep -E "$pattern" | sed 's/^[ *]*//' | sed 's/origin\///' || true)
        
        if [ -n "$branches" ]; then
            log "yellow" "Encontradas ramas remotas con patrón '$pattern':" 2
            echo "$branches" | while read -r branch; do
                log "gray" "  - origin/$branch" 3
            done
            
            # Eliminar cada rama remota
            echo "$branches" | while read -r branch; do
                if [ -n "$branch" ]; then
                    log "blue" "Eliminando rama remota: origin/$branch" 2
                    if git push origin --delete "$branch" 2>/dev/null; then
                        log "green" "✓ Rama remota 'origin/$branch' eliminada" 3
                    else
                        log "red" "✗ Error eliminando rama remota 'origin/$branch'" 3
                    fi
                fi
            done
        else
            log "gray" "No se encontraron ramas remotas con patrón '$pattern'" 2
        fi
    done
    
    cd - > /dev/null
}

# Procesar cada microservicio filtrado
for service in "${FILTERED_MICROSERVICES[@]}"; do
    log "white" "Procesando microservicio: $service" 1
    
    # Verificar que el directorio existe
    if [ ! -d "$service" ]; then
        log "red" "El directorio $service no existe" 2
        continue
    fi
    
    # Verificar que es un repositorio git
    if [ ! -d "$service/.git" ]; then
        log "red" "$service no es un repositorio git" 2
        continue
    fi
    
    # Limpiar ramas locales
    cleanup_local_branches "$service"
    
    # Limpiar ramas remotas
    cleanup_remote_branches "$service"
    
    log "green" "✓ Limpieza completada para $service" 1
    echo ""
done

log "green" "Limpieza de ramas completada para todos los microservicios filtrados"

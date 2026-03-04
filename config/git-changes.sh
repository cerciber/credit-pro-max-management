#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./filter-microservices.sh "$@"

log "white" "GIT CHANGES: Mostrando cambios con formato mejorado estilo GitHub"

# Función para mostrar resumen de archivos modificados
show_file_summary() {
    local service=$1
    local changes_type=$2
    local git_cmd=$3
    
    cd "$service" || return 1
    
    # Obtener lista de archivos modificados
    local files_changed=$(eval "$git_cmd --name-only" 2>/dev/null)
    local files_stats=$(eval "$git_cmd --stat" 2>/dev/null | tail -1)
    
    if [ -n "$files_changed" ]; then
        log "cyan" "📁 Archivos $changes_type:" 2
        echo "$files_changed" | while IFS= read -r file; do
            if [ -n "$file" ]; then
                # Obtener estadísticas específicas del archivo
                local file_stats=$(eval "$git_cmd --numstat" 2>/dev/null | grep "^[0-9]" | grep "$file" | head -1)
                if [ -n "$file_stats" ]; then
                    local added=$(echo "$file_stats" | awk '{print $1}')
                    local deleted=$(echo "$file_stats" | awk '{print $2}')
                    log "gray" "   📄 $file (+$added -$deleted)" 3
                else
                    log "gray" "   📄 $file" 3
                fi
            fi
        done
        
        if [ -n "$files_stats" ]; then
            log "yellow" "📊 Resumen: $files_stats" 2
        fi
    fi
    
    cd - > /dev/null
}

# Función para mostrar diff con formato mejorado
show_enhanced_diff() {
    local service=$1
    local changes_type=$2
    local git_cmd=$3
    
    cd "$service" || return 1
    
    # Verificar si hay cambios
    if ! eval "$git_cmd --quiet" 2>/dev/null; then
        log "green" "🔍 Diferencias $changes_type:" 2
        
        # Mostrar diff con contexto mejorado y colores
        eval "$git_cmd --color=always --unified=3" 2>/dev/null | while IFS= read -r line; do
            if [[ $line =~ ^diff\ --git ]]; then
                # Nueva diferencia de archivo
                local file1=$(echo "$line" | sed 's/.*a\/\(.*\) b\/.*/\1/')
                local file2=$(echo "$line" | sed 's/.*b\/\(.*\)/\1/')
                log "blue" "📝 Archivo: $file2" 3
            elif [[ $line =~ ^@@.*@@ ]]; then
                # Información de líneas
                log "gray" "📍 $line" 3
            elif [[ $line =~ ^\+ ]]; then
                # Línea añadida
                log "green" "   $line" 3
            elif [[ $line =~ ^\- ]]; then
                # Línea eliminada
                log "red" "   $line" 3
            elif [[ $line =~ ^index ]]; then
                # Información del índice
                log "gray" "🔗 $line" 3
            elif [[ $line =~ ^new\ file\ mode ]]; then
                # Archivo nuevo
                log "cyan" "🆕 $line" 3
            elif [[ $line =~ ^deleted\ file\ mode ]]; then
                # Archivo eliminado
                log "red" "🗑️  $line" 3
            elif [[ $line =~ ^rename ]]; then
                # Archivo renombrado
                log "yellow" "🔄 $line" 3
            else
                # Línea de contexto
                log "gray" "   $line" 3
            fi
        done
    fi
    
    cd - > /dev/null
}

# Función para mostrar información del repositorio
show_repo_info() {
    local service=$1
    
    cd "$service" || return 1
    
    # Información de la rama actual
    local current_branch=$(git branch --show-current 2>/dev/null)
    local remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    local commit_count=$(git rev-list --count HEAD 2>/dev/null)
    local last_commit=$(git log -1 --pretty=format:"%h - %s (%cr)" 2>/dev/null)
    
    log "blue" "🌿 Rama actual: $current_branch" 2
    if [ -n "$remote_branch" ]; then
        log "blue" "🔗 Rama remota: $remote_branch" 2
    fi
    log "blue" "📊 Commits: $commit_count" 2
    log "blue" "🕒 Último commit: $last_commit" 2
    
    cd - > /dev/null
}

# Recorre los microservicios filtrados y muestra el diff con formato mejorado
for service in "${FILTERED_MICROSERVICES[@]}"; do
    log "blue" "📦 Procesando microservicio: $service" 1
    
    # Mostrar información del repositorio
    show_repo_info "$service"
    
    # Verificar si hay cambios locales (unstaged)
    log "blue" "🔍 Revisando cambios locales (unstaged)" 2
    show_file_summary "$service" "modificados localmente" "git diff"
    show_enhanced_diff "$service" "locales (unstaged)" "git diff"
    
    # Verificar si hay cambios en staging
    log "blue" "🔍 Revisando cambios en staging area" 2
    show_file_summary "$service" "en staging" "git diff --cached"
    show_enhanced_diff "$service" "en staging" "git diff --cached"
    
    # Verificar si hay cambios en stash
    log "blue" "🔍 Revisando cambios en stash" 2
    if condition "(cd '$service' && git stash list | grep -q .)" 3; then
        local stash_count=$(cd "$service" && git stash list | wc -l)
        log "yellow" "📦 Encontrados $stash_count elemento(s) en stash" 3
        
        # Mostrar información del último stash
        local last_stash=$(cd "$service" && git stash list --oneline | head -1)
        log "gray" "🕒 Último stash: $last_stash" 3
        
        show_enhanced_diff "$service" "en stash" "git stash show -p"
    else
        log "gray" "📭 No hay elementos en stash" 3
    fi
    
    log "white" "────────────────────────────────────────" 1
done

log "green" "✅ Listado de cambios completado con formato mejorado." 1


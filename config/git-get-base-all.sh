#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Cargar variables de entorno
source ./config/load-env.sh

# Filtrar microservicios según los parámetros proporcionados
source ./config/filter-microservices.sh "$@"

# Arrays para almacenar resultados
declare -a success_services=()
declare -a conflict_services=()
declare -a error_services=()

# Función para ejecutar git-get-base sin hacer exit del script principal
run_git_get_base() {
    local service=$1
    # Ejecutar en un subshell para capturar el exit code sin afectar el script principal
    (
        source ./config/git-get-base.sh "$service"
    )
    return $?
}

# Función para verificar si hay conflictos en un microservicio
check_conflicts() {
    local service=$1
    # Verificar si hay conflictos en la rama feat/base-changes
    if [ -d "$service" ] && [ -d "$service/.git" ]; then
        if condition "cd $service && git status --porcelain | grep -q '^UU\\|^AA\\|^DD'" 2; then
            return 0  # Hay conflictos
        fi
    fi
    return 1  # No hay conflictos
}

# Procesar cada microservicio filtrado
for service in "${FILTERED_MICROSERVICES[@]}"; do
    # Ignorar el microservicio "base"
    if [ "$service" = "cerciber-base" ]; then
        continue
    fi

    log "green" "Procesando sistema $service"
    log "cyan" "git-get-base $service" 1
    
    if run_git_get_base "$service"; then
        # Verificar si hay conflictos después del procesamiento
        if check_conflicts "$service"; then
            conflict_services+=("$service")
        else
            success_services+=("$service")
        fi
    else
        error_services+=("$service")
    fi
done

# Mostrar resumen final
log "green" "RESUMEN FINAL" 0

# Servicios exitosos
log "gray" "Servicios completados exitosamente (${#success_services[@]}):" 1
for service in "${success_services[@]}"; do
    log "green" "$service" 2
done

# Servicios con conflictos
log "gray" "Servicios con conflictos (${#conflict_services[@]}):" 1
for service in "${conflict_services[@]}"; do
    log "yellow" "$service" 2
done

# Servicios con errores
log "gray" "Servicios con errores (${#error_services[@]}):" 1
for service in "${error_services[@]}"; do
    log "red" "$service" 2
done

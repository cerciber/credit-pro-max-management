#!/bin/bash

# Cargar logs
source ./config/logs.sh

# Cargar variables de entorno
source ./config/load-env.sh

# Verificar que se proporcionen ambos parámetros
if [ -z "$1" ]; then
    log "red" "Error: Debes proporcionar un microservicio."
    log "white" "Uso: git-send <microservicio> \"mensaje del commit\""
    log "white" "Usa 'git-send help' para ver más información."
    exit 1
fi

if [ -z "$2" ]; then
    log "red" "Error: Debes proporcionar un mensaje para el commit."
    log "white" "Uso: git-send <microservicio> \"mensaje del commit\""
    log "white" "Usa 'git-send help' para ver más información."
    exit 1
fi

MICROSERVICE="$1"
COMMIT_MESSAGE="$2"

# Verificar que el microservicio existe
source ./config.sh
encontrado=false
for service in "${MICROSERVICES[@]}"; do
    if [[ "$service" == "$MICROSERVICE" ]]; then
        encontrado=true
        break
    fi
done

if [ "$encontrado" = false ]; then
    log "red" "El microservicio '$MICROSERVICE' no existe en la configuración."
    log "cyan" "Microservicios disponibles:"
    for service in "${MICROSERVICES[@]}"; do
        log "yellow" "  $service" 1
    done
    exit 1
fi

# Crear array con el microservicio específico
FILTERED_MICROSERVICES=("$MICROSERVICE")

# Función para enviar cambios en un microservicio
send_changes() {
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
    
    # Ejecutar pruebas de extremo a extremo ANTES de cualquier verificación
    if [ -f "package.json" ]; then
        if grep -q '"test:webserver"' package.json; then
            log "cyan" "Ejecutando pruebas de extremo a extremo..." 2
            if ! condition "npm run test:webserver" 3; then
                log "red" "Error: Las pruebas de extremo a extremo fallaron. El proceso se detiene." 2
                cd ..
                return 1
            fi
            log "green" "Pruebas de extremo a extremo pasaron exitosamente" 3
        else
            log "yellow" "No se encontró el script 'test:webserver' en package.json. Saltando pruebas E2E." 2
        fi
    else
        log "yellow" "No se encontró package.json. Saltando pruebas E2E." 2
    fi
    
    # Verificar si hay cambios
    local has_changes=false
    local has_staged=false
    
    # Verificar cambios en working directory
    if ! git diff --quiet; then
        has_changes=true
    fi
    
    # Verificar cambios en staging area
    if ! git diff --cached --quiet; then
        has_staged=true
    fi
    
    if [ "$has_changes" = false ] && [ "$has_staged" = false ]; then
        log "yellow" "No hay cambios que enviar en $service" 2
        cd ..
        return 0
    fi
    
    # Mostrar resumen de los cambios
    log "cyan" "Cambios encontrados en $service:" 2
    if [ "$has_changes" = true ]; then
        log "green" "  - Cambios en working directory" 3
    fi
    if [ "$has_staged" = true ]; then
        log "green" "  - Cambios en staging area" 3
    fi
    
    # Ejecutar git add
    log "cyan" "Ejecutando git add..." 3
    command "git add ." 4
    
    # Verificar que el add fue exitoso
    if [ $? -ne 0 ]; then
        log "red" "Error al ejecutar git add en $service" 2
        cd ..
        return 1
    fi
    
    # Ejecutar git commit
    log "cyan" "Ejecutando git commit..." 3
    command "git commit -m \"$COMMIT_MESSAGE\"" 4
    
    # Verificar que el commit fue exitoso
    if [ $? -ne 0 ]; then
        log "red" "Error al ejecutar git commit en $service" 2
        cd ..
        return 1
    fi
    
    # Ejecutar git push
    log "cyan" "Ejecutando git push..." 3
    command "git push" 4
    
    # Verificar que el push fue exitoso
    if [ $? -ne 0 ]; then
        log "red" "Error al ejecutar git push en $service" 2
        cd ..
        return 1
    fi
    
    log "green" "Cambios enviados exitosamente en $service" 2
    cd ..
    return 0
}

# Función principal
main() {
    log "white" "GIT SEND: Ejecutando pruebas E2E PRIMERO, luego enviando cambios al repositorio remoto"
    log "cyan" "Microservicio: $MICROSERVICE"
    log "cyan" "Mensaje del commit: \"$COMMIT_MESSAGE\""
    
    if send_changes "$MICROSERVICE"; then
        log "green" "Los cambios han sido enviados exitosamente en $MICROSERVICE."
        exit 0
    else
        log "red" "Error al enviar cambios en $MICROSERVICE."
        exit 1
    fi
}

# Ejecutar función principal
main "$@"
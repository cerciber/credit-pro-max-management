# Autoconfigurar los repositorios
setup() {
    chmod +x ./config/setup.sh
    ./config/setup.sh
}

# <microservices...> Configurar git en los ms específicados
git-config() {
    chmod +x ./config/git-config.sh
    ./config/git-config.sh "$@"
}

# <microservice> Obtener los cambios del base en una rama local feat/base-changes
git-get-base() {
    chmod +x ./config/git-get-base.sh
    ./config/git-get-base.sh "$1"
}

# <microservice> Validar si los cambios en la rama feat/base-changes son consistentes y enviarlos a main
git-merge-base() {
    chmod +x ./config/git-merge-base.sh
    ./config/git-merge-base.sh "$1"
}

# <microservice> Preparar los cambios del base en una rama local feat/new-base-changes
git-prepare-send-base() {
    chmod +x ./config/git-prepare-send-base.sh
    ./config/git-prepare-send-base.sh "$1"
}

# <microservice> Validar si los cambios en la rama feat/new-base-changes son consistentes y enviarlos a main
git-merge-send-base() {
    chmod +x ./config/git-merge-send-base.sh
    ./config/git-merge-send-base.sh "$1"
}

# <microservices...> Mostrar líneas de cambios de los ms especificados en FILTERED_MICROSERVICES
git-changes() {
    chmod +x ./config/git-changes.sh
    ./config/git-changes.sh "$@"
}

# <microservice> Enviar cambios al repositorio remoto (add, commit, push)
git-send() {
    chmod +x ./config/git-send.sh
    ./config/git-send.sh "$@"
}

# Mostrar ayuda
cli-help() {
    chmod +x ./config/cli-help.sh
    ./config/cli-help.sh
}
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

source ./config/config.sh

REPOS=()
for SERVICE in "${MICROSERVICES[@]}"; do
  REPOS+=("https://github.com/cerciber/${SERVICE}.git")
done

echo "==> Raíz del proyecto: $ROOT_DIR"

for REPO_URL in "${REPOS[@]}"; do
  NAME="$(basename "$REPO_URL" .git)"
  if [ -d "$NAME" ]; then
    echo "==> Repo '$NAME' ya existe, se omite clonación."
  else
    echo "==> Clonando '$REPO_URL' en '$NAME'..."
    git clone "$REPO_URL" "$NAME"
  fi

  if [ -f "$NAME/package.json" ]; then
    echo "==> Instalando dependencias en '$NAME' con npm i..."
    (cd "$NAME" && npm i)
    echo "==> Instalando navegadores de Playwright en '$NAME'..."
    (cd "$NAME" && npx playwright install)
  else
    echo "==> No se encontró package.json en '$NAME', se omite instalación de dependencias."
  fi
done

echo "==> Setup de repositorios completado."


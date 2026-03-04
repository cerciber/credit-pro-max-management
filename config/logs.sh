# Función para detectar si --stream-partial-output está presente
has_stream_partial_output() {
  local cmd="$1"
  if [[ "$cmd" == *"--output-format stream-json"* ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Función para extraer el texto de un JSON con estructura de asistente
extract_assistant_text() {
  local json_input="$1"
  
  # Usar jq para extraer el texto del campo message.content[0].text (silenciar errores)
  extracted_text=$(echo "$json_input" | jq -r '.message.content[0].text // empty' 2>/dev/null)
  if [ -z "$extracted_text" ]; then
    echo "${json_input:0:200}..."
  else
    echo "$extracted_text"
  fi
}

log() {
  green="\033[0;32m"
  red="\033[0;31m"
  yellow="\033[0;33m"
  blue="\033[0;34m"
  magenta="\033[0;35m"
  cyan="\033[0;36m"
  white="\033[0;37m"
  gray="\033[0;30m"

  color_name=$1
  message=$2
  spacing=${3:-0}  # Valor por defecto: 0 espacios si no se especifica

  # Obtener el valor de la variable de color según el nombre pasado como argumento
  color_value="${!color_name}"

  # Generar los espacios antes de la flecha
  espacios=""
  for ((i=0; i<spacing; i++)); do
    espacios+="   "
  done

  # Imprimir cada línea del mensaje por separado para respetar la tabulación en multilínea
  while IFS= read -r __log_line || [ -n "$__log_line" ]; do
    # Si tiene formato stream-json de Cursor, extraer solo el texto
    if [ "$(has_stream_partial_output "$cmd")" = "true" ]; then
      extracted_text=$(extract_assistant_text "$__log_line")
      if [ -n "$extracted_text" ]; then
        # Si no inicia con {, cambia el color a azul
        if [[ "${extracted_text:0:1}" != "{" ]]; then
          color_value="$white"
        fi
        echo -e "${color_value}${espacios}➜  ${extracted_text}\033[0m"
      fi
    else
      echo -e "${color_value}${espacios}➜  ${__log_line}\033[0m"
    fi
  done <<< "$message"
}

# Función para ejecutar comandos con logs automáticos
command() {
  local cmd="$1"
  local spacing=${2:-1}  # Tabulación para logs del comando
  local exit_on_error=${3:-true}

  # Imprimir el comando antes de ejecutarlo, con el spacing correspondiente
  log "cyan" "$cmd" $spacing

  # Ejecutar el comando y mostrar salida en tiempo real con formato
  local exit_code
  local temp_file=$(mktemp)
  
  # Ejecutar comando y mostrar salida en tiempo real
  local line_count=0
  eval "$cmd" 2>&1 | while IFS= read -r line; do
    if [ -n "$line" ]; then
      # Mostrar en tiempo real con formato
      log "gray" "$line" $spacing
      # También guardar en archivo temporal para verificación de errores
      echo "$line" >> "$temp_file"
      line_count=$((line_count + 1))
    fi
  done
  
  # Obtener el código de salida del comando original
  exit_code=${PIPESTATUS[0]}
  
  # Si el comando falló, borrar las líneas grises y mostrar en rojo
  if [ $exit_code -ne 0 ] && [ -s "$temp_file" ]; then
    # Contar líneas en el archivo temporal
    local total_lines=$(wc -l < "$temp_file")
    
    # Borrar las líneas que se imprimieron (subir cursor y limpiar)
    for ((i=0; i<total_lines; i++)); do
      printf "\033[1A\033[2K"  # Subir una línea y limpiarla
    done
    
    # Mostrar la salida en rojo
    while IFS= read -r line; do
      if [ -n "$line" ]; then
        log "red" "$line" $spacing
      fi
    done < "$temp_file"
  fi
  
  # Limpiar archivo temporal solo si no hay errores
  if [ $exit_code -eq 0 ]; then
    rm -f "$temp_file"
  else
    # Si hay errores, guardar el archivo temporal para uso posterior
    echo "$temp_file" > /tmp/last_error_temp_file
  fi

  # Si el comando falló, terminar el programa
  if [ $exit_code -ne 0 ] && [ $exit_on_error = "true" ]; then
    exit $exit_code
  fi

  # Retornar el código de salida
  return $exit_code
}

condition() {
  local cmd="$1"
  local spacing=${2:-1}

  command "$cmd" $spacing false
  return ${PIPESTATUS[0]}
}
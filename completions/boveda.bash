_boveda_complete() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  if (( COMP_CWORD == 1 )); then
    COMPREPLY=( $(compgen -W 'abrir cerrar nuevo add listar borrar ubicacion backup exportar estado configurar verificar desinstalar llaves claves' -- "$cur") )
    return
  fi
  case "${COMP_WORDS[1]}" in
    add|ubicacion|backup|exportar) compopt -o filenames; COMPREPLY=( $(compgen -f -- "$cur") );;
    llaves) (( COMP_CWORD == 2 )) && COMPREPLY=( $(compgen -W 'listar anadir quitar' -- "$cur") ) ;;
    claves) (( COMP_CWORD == 2 )) && COMPREPLY=( $(compgen -W 'cambiar' -- "$cur") ) ;;
    borrar)
      local root="$HOME/BovedaFIDO2/Trabajo"
      if [[ -d "$root" ]]; then
        while IFS= read -r f; do COMPREPLY+=("${f#"$root"/}"); done < <(find "$root" -mindepth 1 -maxdepth 1 -name "$cur*" -print 2>/dev/null)
      fi ;;
  esac
}
complete -F _boveda_complete boveda

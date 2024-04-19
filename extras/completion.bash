# Bash completion for boop. Doesn't work very well.
_boop() {
    (( COMP_CWORD > 1 )) && return
    COMPREPLY=()
    args=${COMP_WORDS[@]:1}
    cur=${COMP_WORDS[COMP_CWORD]}
    #add_quote=0
    #if [ ! -z $cur ] && [[ $cur == $arg ]] && [[ $cur != \"* ]]; then
    #    # insert a quote
    #    add_quote=1
    #    cur="\\\"$cur"
    #fi
    if [[ $args == -* ]]; then
        use="--help --list-scripts"
    else
        scripts="$(boop --list-scripts)"
        scripts_lower="$(echo "$scripts" | tr '[:upper:]' '[:lower:]')"
        #if $add_quote; then
        #    use="$(echo $scripts | sed "s/ /\\\\ /g" "s/^/\\\"/g")"
        #else
        #    use="$(echo $scripts | sed "s/ /\\\\ /g")"
        #fi
        use="$(echo "$scripts_lower" | sed "s/ /\\\\ /g")"
    fi
    mapfile -t COMPREPLY < <( compgen -W "$use" -- "$cur" )
}

complete -F _boop -o bashdefault -o default boop

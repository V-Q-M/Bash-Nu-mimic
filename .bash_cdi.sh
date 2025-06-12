cdi() {
    local arg="$1"
    # If the argument is a valid directory name, cd into it directly
    if [[ -d "$arg" ]]; then
        cd "$arg"
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        # Otherwise, treat it as an index
        local index=0
        for item in */; do
            if [[ $index -eq $arg ]]; then
                cd "$item"
                break
            fi
            ((index++))
        done
    else
	cd ~
        lsn
        return 1
    fi

    lsn
}


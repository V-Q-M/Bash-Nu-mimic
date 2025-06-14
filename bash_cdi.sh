#!/bin/sh

cdi() {
    arg="$1"
    # If the argument is a valid directory name, cd into it directly
    if [ -d "$arg" ]; then
        cd "$arg" || exit
    elif case "$arg" in
        [0-9]*) : ;;
         *) false ;;
    esac; then
# Otherwise, treat it as an index
        index=0
        for item in */; do
            if [ $index -eq "$arg" ]; then
                cd "$item" || exit
                break
            fi
	i=$((i + 1))
        done
    else
	cd ~ || exit
        ~/scripts/sh_nu.py .
        return 1
    fi

    ~/scripts/sh_nu.py .
}


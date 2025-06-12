lsn(){ 
    local showHidden=false
    local dir="."

    local COLOR1="\e[32m"  # Symlinks
    local COLOR2a="\e[1;34m"  # Directories
    local COLOR2b="\e[34m"  # Directories
    local COLOR3="\e[1;33m"  # Headers
    local COLOR4="\e[35m"  # Headers
    local COLOR5="\e[1;31m"  # Headers
    local COLOR6="\e[36m"
    local RESET="\e[0m"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a)
                showHidden=true
                shift
                ;;
            *)
                dir="$1"
                shift
                ;;
        esac
    done

    if [[ "$showHidden" == true ]]; then
        shopt -s dotglob
    fi

    shopt -s nullglob
    listedFiles=( "$dir"/* )

    centerText() {
        local text="$1"
        local width="$2"
        local pad=$(( (width - ${#text}) / 2 ))
        local padExtra=$(( width - pad - ${#text} ))
        printf "%*s%s%*s" "$pad" "" "$text" "$padExtra" ""
    }

    getFileName() {
        local item="$1"
        local name
        name=$(basename "$item")

        if [[ -L $item ]]; then
            echo -e "$name|${COLOR1}${name}${RESET}"
        elif [[ -d $item ]]; then
            echo -e "$name|${COLOR2a}${name}${RESET}"
        else
            echo -e "$name|$name"
        fi
    }

    determineType() {
        local item="$1"
        local raw=""
        local color=""

        if [[ -L $item ]]; then
            raw="symlink"
            color="${COLOR1}$raw${RESET}"
        elif [[ -d $item ]]; then
            raw="dir"
            color="${COLOR2b}$raw${RESET}"
        elif [[ -f $item ]]; then
            raw="file"
            color="$raw"
        else
            raw="other"
            color="$raw"
        fi

        echo -e "$raw|$color"
    }

getFileSize() {
    local item="$1"

    if [[ -f "$item" ]]; then
        local size
        size=$(stat -c %s "$item" 2>/dev/null)

        if [[ -z "$size" ]]; then
            echo "no access"
            return
        fi

        if (( size < 1000 )); then
            echo "${size} B"
        elif (( size < 1000000 )); then
            awk "BEGIN {printf \"%.2f kB\n\", $size/1000}"
        elif (( size < 1000000000 )); then
            awk "BEGIN {printf \"%.2f MB\n\", $size/1000000}"
        else
            awk "BEGIN {printf \"%.2f GB\n\", $size/1000000000}"
        fi

    elif [[ -d "$item" ]]; then
        local dir_size
        dir_size=$(du -sb "$item" 2>/dev/null | cut -f1)

        if [[ -z "$dir_size" ]]; then
            echo "no access"
            return
        fi

        if (( dir_size < 1000 )); then
            echo "${dir_size} B"
        elif (( dir_size < 1000000 )); then
            awk "BEGIN {printf \"%.2f kB\n\", $dir_size/1000}"
        elif (( dir_size < 1000000000 )); then
            awk "BEGIN {printf \"%.2f MB\n\", $dir_size/1000000}"
        else
            awk "BEGIN {printf \"%.2f GB\n\", $dir_size/1000000000}"
        fi
    else
        echo "     "
    fi
}

    getModifiedTime() {
        local item="$1"
        local color=""
        local test=""
        local modified=$(stat -c '%Y' "$item" 2>/dev/null)
        local now=$(date +%s)
        local age=$(( now - modified ))

        if (( age < 60 )); then
            text="${age}s ago"
            color="${COLOR1}$text${RESET}"
        elif (( age < 3600 )); then
            text="$((age / 60))m ago"
            color="${COLOR4}$text${RESET}"
        elif (( age < 86400 )); then
            text="$((age / 3600))h ago"
            color="${COLOR4}$text${RESET}"
        elif (( age < 2592000 )); then
            text="$((age / 86400))d ago"
            color="${COLOR4}$text${RESET}"
        elif (( age < 5184000 )); then
            text="$((age / 2592000)) month ago"
            color="${COLOR5}$text${RESET}"
        elif (( age < 31104000 )); then
            text="$((age / 2592000)) months ago"
            color="${COLOR5}$text${RESET}"
        else
            text="$((age / 31104000)) years ago"
            color="${COLOR5}$text${RESET}"
        fi

        echo -e "$text|$color"
    }

    if [ ${#listedFiles[@]} -eq 0 ]; then
        echo " ┌───────────┐"
        echo -e " │ \e[90mempty set\e[0m │"
        echo " └───────────┘"
    else
        local maxName=4
        local maxType=4
        local maxSize=4
        local maxModified=8

        for item in "${listedFiles[@]}"; do
            IFS="|" read -r rawName _ <<< "$(getFileName "$item")"
            IFS="|" read -r rawType _ <<< "$(determineType "$item")"
            rawSize="$(getFileSize "$item")"
            IFS="|" read -r rawModified _ <<< "$(getModifiedTime "$item")"

            (( ${#rawName} > maxName )) && maxName=${#rawName}
            (( ${#rawType} > maxType )) && maxType=${#rawType}
            (( ${#rawSize} > maxSize )) && maxSize=${#rawSize}
            (( ${#rawModified} > maxModified )) && maxModified=${#rawModified}
        done

        local maxIndex=$(( ${#listedFiles[@]} - 1 ))
        local maxDigits=${#maxIndex}

        nameBar=$(printf '─%.0s' $(seq 1 $maxName))
        typeBar=$(printf '─%.0s' $(seq 1 $maxType))
        sizeBar=$(printf '─%.0s' $(seq 1 $maxSize))
        modifiedBar=$(printf '─%.0s' $(seq 1 $maxModified))
        indexBar=$(printf '─%.0s' $(seq 1 $maxDigits))

        echo "╭─$indexBar─┬─$nameBar─┬─$typeBar─┬─$sizeBar─┬─$modifiedBar─╮"
        printf "│ ${COLOR3}%${maxDigits}s${RESET} │ ${COLOR3}%s${RESET} │ ${COLOR3}%s${RESET} │ ${COLOR3}%s${RESET} │ ${COLOR3}%s${RESET} │\n" "#" "$(centerText 'name' $maxName)" "$(centerText 'type' $maxType)" "$(centerText 'size' $maxSize)" "$(centerText 'modified' $maxModified)"
        echo "├─$indexBar─┼─$nameBar─┼─$typeBar─┼─$sizeBar─┼─$modifiedBar─┤"

        local j=0
        for item in "${listedFiles[@]}"; do
            IFS="|" read -r rawName nameColored <<< "$(getFileName "$item")"
            namePadding=$(( maxName - ${#rawName} ))
            paddedName="${nameColored}$(printf '%*s' "$namePadding" "")"

            IFS="|" read -r rawType typeColored <<< "$(determineType "$item")"
            typePadding=$(( maxType - ${#rawType} ))
            paddedType="$typeColored$(printf '%*s' "$typePadding" "")"

            filesize="$(getFileSize "$item")"

            IFS="|" read -r rawModified modifiedColored <<< "$(getModifiedTime "$item")"
            modifiedPadding=$(( maxModified - ${#rawModified} ))
            paddedModified="$modifiedColored$(printf '%*s' "$modifiedPadding" "")"

            printf "│ ${COLOR3}%${maxDigits}d${RESET} │ %s │ %s │ ${COLOR6}%-${maxSize}s${RESET} │ %s │\n" \
                   "$j" "$paddedName" "$paddedType" "$filesize" "$paddedModified"
            ((j++))
        done

        echo "╰─$indexBar─┴─$nameBar─┴─$typeBar─┴─$sizeBar─┴─$modifiedBar─╯"
    fi

    [[ "$showHidden" == true ]] && shopt -u dotglob
}

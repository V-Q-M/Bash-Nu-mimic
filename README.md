# Bash-Nu-mimic

A simple bash script that aims to mimic the visual appearance of the nu-shell, while still being posix compliant.

---

## Features

- NuShell-like `ls` output in Bash
- Lightweight and dependency-free
- POSIX-compliant
- Easy to install and use

---

## Installation

Create a scripts directory if you don't have one
```bash
mkdir -p ~/scripts
cd ~/scripts
```

Clone the repo with
```bash
git clone https://github.com/V-Q-M/Bash-Nu-mimic.git
```

Add the script to your .bashrc
```bash
. "$HOME/scripts/bash_nu.sh"
```

Reload the shell (or restart terminal):
```bash
source ~/.bashrc
```

## Usage
Use the custom `lsn` command for NuShell-inspired directory listings.
```bash
lsn                       # default listing
lsn -a`,                  # Show hidden files.
`lsn <path-to-directory>` # Show files in specified directory.

To use replace `ls` with `lsn`, add the alias to your `.bashrc`
```
alias ls="lsn"
```

Then reload the shell (or restart terminal):
```bash
source ~/.bashrc
```

## License
This project is released under the MIT License

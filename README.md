# Bash-Nu-mimic

A minimalist Bash script that mimics the **visual appearance of [nu-shell](https://github.com/nushell/nushell)** — while staying **POSIX-compliant** and lightweight. 

![Preview of lsn](preview.png)


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
lsn              # default listing
lsn -a           # Show hidden files.
lsn <path>`      # Show files in specified directory.
```

To replace `ls` with `lsn`, add the alias to your `.bashrc`
```bash
alias ls="lsn"
```

Then reload the shell (or restart terminal):
```bash
source ~/.bashrc
```

---

This project also features a experimental `cdi` (cd immediate), which allows cd-ing with a index on top of using directory names. E.g. `cdi 0` cds into the entry with index 0, if it is a directory.

## License
This project is released under the MIT License

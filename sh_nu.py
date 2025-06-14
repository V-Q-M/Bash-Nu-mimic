#!/usr/bin/env python3
import os
import sys
import stat
import time

DIR_COLOR     = "\033[94m"  # BLUE
SYMLINK_COLOR = "\033[92m"  # GREEN
SIZE_COLOR        = "\033[96m"  # CYAN
DATE_COLOR        = "\033[35m"  # CYAN
HEADER_COLOR = "\033[93m"  # YELLOW
READ_COLOR = "\033[90m" # GRAY
WRITE_COLOR = "\033[33m" # GREEN
EXECUTE_COLOR = "\033[92m" # YELLOW
RESET        = "\033[0m"   # RESET

current_longest_permission=0


def get_permissions(item):
        mode = os.lstat(item).st_mode
        perm_bits = [
            (mode & stat.S_IRUSR, f"{READ_COLOR}read{RESET} "), (mode & stat.S_IWUSR, f"{WRITE_COLOR}wrt{RESET} "), (mode & stat.S_IXUSR, f"{EXECUTE_COLOR}exe{RESET}"),
        ]
        perms = "".join(char if bit else "   " for bit, char in perm_bits)
        return perms

def get_size(item):
        size = os.path.getsize(item)
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size < 1024:
                return f"{size:.1f} {unit}"
            size /= 1024
        return f"{size:.1f} PB"


def get_date(item):
        mtime = os.path.getmtime(item)  # modification time (seconds since epoch)
        now = time.time()
        diff = now - mtime  # seconds elapsed

        if diff < 60:
            return f"{int(diff)}s ago"
        elif diff < 3600:
            minutes = int(diff // 60)
            return f"{minutes}m ago"
        elif diff < 86400:
            hours = int(diff // 3600)
            return f"{hours}h ago"
        elif diff < 172800:  
            return "1 day ago"
        elif diff < 2592000:  
            days = int(diff // 86400)
            return f"{days} days ago"
        elif diff < 31536000:  # less than 1 year
            months = int(diff // 2592000)
            return f"{months} months ago"
        else:
            years = int(diff // 31536000)
            return f"{years} years ago"
    
def print_table(path):
    result = list_files_and_dirs(path)

    if isinstance(result, dict):
        all_entries = result.get("directories", []) + result.get("files", []) + result.get("symlinks", [])
        all_entries.sort(key=str.lower)

        dir_set = set(result.get("directories", []))
        symlink_set = set(result.get("symlinks", []))

        max_index_length = len(str(len(all_entries)))  # For index column width
        if all_entries:
           max_entry_length = max(len(entry) for entry in all_entries)
           max_permission_length  = 12
           max_size_length  = max(len(get_size(entry)) for entry in all_entries)
           max_date_length  = max(len(get_date(entry)) for entry in all_entries)
        else:
           max_entry_length = 0
           max_permission_length  = 0
           max_size_length  = 0
           max_date_length  = 0

        index_header = ("#").rjust(max_index_length)
        name_header  = ("name").center(max_entry_length)
        permission_header  = ("permissions").center(max_permission_length)
        size_header  = ("size").center(max_size_length)
        date_header  = ("modified").center(max_date_length)

        header_lines=""


        header_top_line = "╭" + "─" * (max_index_length + 2) + "┬" \
                    + "─" * (max_entry_length + 2) + "┬" \
                    + "─" * (max_permission_length + 2) + "┬" \
                    + "─" * (max_size_length + 2) + "┬" \
                    + "─" * (max_date_length + 2) + "╮"

        header_bottom_line = "├" + "─" * (max_index_length + 2) + "┼" \
                    + "─" * (max_entry_length + 2) + "┼" \
                    + "─" * (max_permission_length + 2) + "┼" \
                    + "─" * (max_size_length + 2) + "┼" \
                    + "─" * (max_date_length + 2) + "┤"


        footer_line = "╰" + "─" * (max_index_length + 2) + "┴" \
                    + "─" * (max_entry_length + 2) + "┴" \
                    + "─" * (max_permission_length + 2) + "┴" \
                    + "─" * (max_size_length + 2) + "┴" \
                    + "─" * (max_date_length + 2) + "╯"

        print(header_top_line)
        print(f"│ {HEADER_COLOR}{index_header}{RESET} │ {HEADER_COLOR}{name_header}{RESET} │ {HEADER_COLOR}{permission_header}{RESET} │ {HEADER_COLOR}{size_header}{RESET} │ {HEADER_COLOR}{date_header}{RESET} │")
        print(header_bottom_line)
        
        index = 0
        for entry in all_entries:
            index_str = str(index).rjust(max_index_length)  # Pad index with spaces for alignment
            size_color = SIZE_COLOR
            date_color = DATE_COLOR
            permission_color = DIR_COLOR
            size = get_size(entry)
            date = get_date(entry)
            permission = get_permissions(entry)

            if entry in dir_set:
               name_color = DIR_COLOR
            elif entry in symlink_set:
                 name_color = SYMLINK_COLOR
            else:
                 name_color = ""

            name_str = entry.ljust(max_entry_length)
            permission_str = permission.ljust(max_permission_length)
            size_str = size.ljust(max_size_length)
            date_str = date.ljust(max_date_length)
            
            print(f"│ {HEADER_COLOR}{index_str}{RESET} │ {name_color}{name_str}{RESET} │ {permission_color}{permission_str}{RESET} │ {size_color}{size_str}{RESET} │ {date_color}{date_str}{RESET} │")
            index += 1
        print(footer_line)
    else:
        print(result)


def list_files_and_dirs(path):
    entries = os.listdir(path)
    files = []
    dirs = []
    symlinks = []

    for entry in entries:
        full_path = os.path.join(path, entry)

        if os.path.islink(full_path):
            symlinks.append(entry)
        elif os.path.isdir(full_path):
            dirs.append(entry)
        elif os.path.isfile(full_path):
            files.append(entry)

    return {"files": files, "directories": dirs, "symlinks": symlinks}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <directory_path>")
        sys.exit(1)

    directory = sys.argv[1]
    print_table(directory)

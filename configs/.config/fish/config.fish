if status is-interactive
    # Commands to run in interactive sessions can go here
end

# --- 1. Environment & Path ---
set -gx BUN_INSTALL "$HOME/.bun"
set -gx NVM_DIR "$HOME/.nvm"
set -gx QT_QPA_PLATFORMTHEME qt6ct
set -gx LIBVA_DRIVER_NAME i965

# Fish handles PATH duplicates automatically
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$BUN_INSTALL/bin"
fish_add_path "$HOME/go/bin"

# --- 2. Interactive Settings ---
if status is-interactive
    # Disable the greeting
    set -g fish_greeting

    # --- Aliases (Most copy-paste fine) ---
    # System
    alias update='sudo pacman -Syu'
    # alias install='sudo pacman -S'  <-- REMOVED (Replaced by function below)
    # alias remove='sudo pacman -Rns' <-- REMOVED (Replaced by function below)
    alias rmorphan='sudo pacman -Rns (pacman -Qdtq)'

    # Power
    alias sleep='sudo systemctl suspend'
    alias hibernate='sudo systemctl hibernate'
    alias savebat='sudo cpupower frequency-set -g powersave'
    alias cpuperf='sudo cpupower frequency-set -g performance'

    # Pacman Query
    alias search='pacman -Ss'
    alias info='pacman -Si'
    alias files='pacman -Ql'
    alias owner='pacman -Qo'

    # Git
    alias gpu='git push'
    alias gcl='git clone'

    # Safety
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'

    # Visuals
    alias ls='ls --color=auto -F'
    alias ll='ls -lh'
    alias la='ls -A'
    alias l='ls -CF'
    alias grep='grep --color=auto'

    # --- Fastfetch ---
    if type -q fastfetch
        fastfetch
    end
end

# --- 3. Translated Functions ---

function mkcd --description "Make directory and enter it"
    mkdir -p $argv[1]; and cd $argv[1]
end

function cfg --description "Quick config edit"
    set target "$HOME/.config/$argv[1]"
    if test -z "$argv[1]"
        echo "Usage: cfg <configDirectory>"
        return 1
    end
    if test -d "$target"
        cd "$target"
        nvim .
    else
        echo "Error: Config folder '$argv[1]' not found in ~/.config"
        return 1
    end
end

function remove --description "Smart remove: Searches Pacman and Flatpak"
    if test (count $argv) -eq 0
        echo "Usage: remove <app_name>"
        return 1
    end

    set -l query $argv[1]
    set -l options
    set -l commands

    # 1. Search Pacman (Includes manually installed -U packages)
    set -l pac_matches (pacman -Qq | string match -i "*$query*")
    for pkg in $pac_matches
        set options $options "$pkg (Pacman)"
        set commands $commands "sudo pacman -Rns $pkg"
    end

    # 2. Search Flatpak
    if type -q flatpak
        set -l flat_matches (flatpak list --app --columns=application | string match -i "*$query*")
        for app in $flat_matches
            set options $options "$app (Flatpak)"
            set commands $commands "flatpak uninstall $app"
        end
    end

    # 3. Handle Results
    set -l count (count $options)

    if test $count -eq 0
        echo "❌ No installed packages found matching '$query'"
        return 1
    else if test $count -eq 1
        echo "Found: $options[1]"
        read -P "Remove this package? [Y/n] " confirm
        if test -z "$confirm"; or test "$confirm" = y; or test "$confirm" = Y
            eval $commands[1]
        end
    else
        echo "🔍 Multiple matches found:"
        for i in (seq $count)
            echo " [$i] $options[$i]"
        end

        read -P "Select a number to remove (0 to cancel): " selection

        if string match -qr '^[0-9]+$' -- "$selection"
            if test $selection -gt 0 -a $selection -le $count
                eval $commands[$selection]
            else
                echo "Cancelled."
            end
        else
            echo "Invalid selection."
        end
    end
end

function install --description "Smart install: Tries Yay/Pacman, then Flatpak search"
    if test (count $argv) -eq 0
        echo "Usage: install <app_name>"
        return 1
    end

    set -l query $argv[1]

    # 1. Try Direct Install via Yay (covers Pacman & AUR)
    # If the package exists exactly as typed, install it immediately.
    if yay -Si $query >/dev/null 2>&1
        echo "📦 Found '$query' in repositories/AUR."
        yay -S $query
        return
    end

    # 2. If not found directly, start a Search Mode
    echo "❌ Package '$query' not found exactly. Searching..."

    set -l options
    set -l commands

    # Search Yay (limit to top 10 for brevity)
    # Output format handling: get 'repo/name' and strip to just 'name'
    set -l yay_results (yay -Ss $query | grep -E '^(aur|core|extra|multilib)' | head -n 10 | awk '{print $1}')

    for pkg in $yay_results
        set -l pkg_clean (string split "/" $pkg)[2]
        set options $options "$pkg_clean (Arch/AUR)"
        set commands $commands "yay -S $pkg_clean"
    end

    # Search Flatpak
    if type -q flatpak
        # We perform the search and read line by line to parse AppID and Description
        flatpak search $query --columns=application,description | head -n 5 | while read -l line
            if test -n "$line"
                # Extract first word as App ID
                set -l app_id (echo $line | awk '{print $1}')
                # The rest is description
                set -l app_desc (echo $line | cut -d' ' -f2-)

                # We have to append to lists inside the loop. 
                # Note: In fish, variables in loops can be tricky if not global/scoped correctly, 
                # but appending to local lists works if defined before loop.
                set -a options "$app_id (Flatpak) - $app_desc"
                set -a commands "flatpak install $app_id"
            end
        end
    end

    # 3. Present Choices
    set -l count (count $options)

    if test $count -eq 0
        echo "🚫 No packages found for '$query' in Yay or Flatpak."
        return 1
    end

    echo "🔍 Found similar packages:"
    for i in (seq $count)
        echo " [$i] $options[$i]"
    end

    read -P "Select a number to install (0 to cancel): " selection

    if string match -qr '^[0-9]+$' -- "$selection"
        if test $selection -gt 0 -a $selection -le $count
            eval $commands[$selection]
        else
            echo "Cancelled."
        end
    else
        echo "Invalid selection."
    end
end

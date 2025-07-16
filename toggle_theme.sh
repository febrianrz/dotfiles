#!/bin/bash

# Toggle theme script
# Set default if not set
TERM_BACKGROUND="${TERM_BACKGROUND:-dark}"

# Apply theme based on TERM_BACKGROUND
if [[ "$TERM_BACKGROUND" == "light" ]]; then
    # Light mode - dark colors for light background
    export EZA_COLORS="da=30:sb=30:sn=30:uu=30:un=30:gu=30:gn=30:ga=30:gm=30:gd=30:gv=30:gt=30:xx=30:fi=30:di=30:ln=31:or=31:ex=32"
    export EZA_ICON_SPACING=1
    export LS_COLORS="di=30:ln=31:so=32:pi=33:ex=32:bd=30:cd=30:su=31:sg=31:tw=30:ow=30:st=32:*.txt=30:*.md=31:*.json=31:*.html=31:*.css=32:*.js=33:*.py=33:*.rs=33"
    [ -n "$VERBOSE_THEME" ] && echo "Applied light theme colors"
else
    # Dark mode - bright colors for dark background
    export EZA_COLORS="da=90:sb=90:sn=90:uu=90:un=90:gu=90:gn=90:ga=90:gm=90:gd=90:gv=90:gt=90:xx=90:fi=97:di=1;34:ln=1;36:or=1;31:ex=1;32:*.txt=97:*.md=96:*.rs=93:*.js=93:*.py=93:*.json=96:*.html=91:*.css=96"
    export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:or=1;31:mi=1;31:bd=1;31:cd=1;31"
    [ -n "$VERBOSE_THEME" ] && echo "Applied dark theme colors"
fi

# Update aliases for current shell
if command -v eza &> /dev/null; then
    alias ls="eza --no-filesize -l --color=always --icons=always --no-user"
fi

# Notify Neovim instances about theme change
pkill -SIGUSR1 nvim 2>/dev/null || true

# Also try to update current shell's environment by writing to temp file
echo "export TERM_BACKGROUND=\"$TERM_BACKGROUND\"" > /tmp/theme_env
echo "export EZA_COLORS=\"$EZA_COLORS\"" >> /tmp/theme_env
echo "export LS_COLORS=\"$LS_COLORS\"" >> /tmp/theme_env

# Update starship config based on theme
if [[ "$TERM_BACKGROUND" == "light" ]]; then
    # Light mode starship config
    cat > ~/.config/starship/starship.toml << 'EOF'
[directory]
style = "bold blue"
truncation_length = 3
truncate_to_repo = true

[character]
success_symbol = "[❯](bold black)"
error_symbol = "[❯](bold red)"

[git_branch]
style = "bold black"

[git_status]
style = "bold black"

[git_state]
style = "bold black"

[nodejs]
format = "[$symbol($version )]($style)"
style = "bold black"
symbol = "⬢ "

[php]
format = "[$symbol($version )]($style)"
style = "bold black"
symbol = "🐘 "

[python]
format = "[$symbol$pyenv_prefix($version )]($style)"
style = "bold black"
symbol = "🐍 "
EOF
else
    # Dark mode starship config
    cat > ~/.config/starship/starship.toml << 'EOF'
[directory]
style = "bold bright-cyan"
truncation_length = 3
truncate_to_repo = true

[character]
success_symbol = "[❯](bold bright-white)"
error_symbol = "[❯](bold red)"

[git_branch]
style = "bold bright-magenta"

[git_status]
style = "bold bright-white"

[git_state]
style = "bold bright-white"

[nodejs]
format = "[$symbol($version )]($style)"
style = "bold bright-green"
symbol = "⬢ "

[php]
format = "[$symbol($version )]($style)"
style = "bold bright-blue"
symbol = "🐘 "

[python]
format = "[$symbol$pyenv_prefix($version )]($style)"
style = "bold bright-yellow"
symbol = "🐍 "
EOF
fi

if [ -n "$VERBOSE_THEME" ]; then
    echo "Theme switched to: $TERM_BACKGROUND"
    echo "EZA colors updated for $TERM_BACKGROUND mode"
    echo "Starship config updated for $TERM_BACKGROUND mode"
    
    # Optional: Test eza colors if in current directory
    if command -v eza &> /dev/null && [[ -t 1 ]]; then
        echo "Testing eza colors:"
        eza --color=always --icons=always -la | head -5
    fi
fi

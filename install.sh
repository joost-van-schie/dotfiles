#!/bin/bash
# Coder workspace dotfiles installer
# Dit script wordt automatisch uitgevoerd bij het aanmaken/starten van een workspace

# Installeer nl_NL.UTF-8 locale (voorkomt warnings bij SSH vanuit MacBook)
if ! locale -a 2>/dev/null | grep -q "nl_NL.utf8"; then
  if command -v locale-gen &>/dev/null; then
    sudo sed -i '/nl_NL.UTF-8/s/^# //' /etc/locale.gen 2>/dev/null
    sudo locale-gen nl_NL.UTF-8 &>/dev/null
    echo "dotfiles: nl_NL.UTF-8 locale geïnstalleerd"
  fi
fi

ALIASES_FILE="$HOME/.bash_aliases"

# Voeg aliases toe als ze er nog niet zijn
if ! grep -q "claudesp" "$ALIASES_FILE" 2>/dev/null; then
  cat >> "$ALIASES_FILE" << 'EOF'

# Custom aliases (via dotfiles)
alias claudesp='claude --dangerously-skip-permissions'
EOF
  echo "dotfiles: aliases toegevoegd aan $ALIASES_FILE"
else
  echo "dotfiles: aliases al aanwezig"
fi

# Stel terminal titel in op Coder workspace naam (voor iTerm2 / ManicTime)
if [ -f "$HOME/.bashrc" ] && ! grep -q "CODER_WORKSPACE_NAME" "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" << 'EOF'

# Terminal titel instellen op git repo naam (fallback: workspace naam)
__set_terminal_title() {
  local title
  title=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
  if [ -z "$title" ]; then
    title="${CODER_WORKSPACE_NAME}"
  fi
  echo -ne "\033]0;${title}\007"
}
PROMPT_COMMAND='__set_terminal_title'
EOF
  echo "dotfiles: terminal titel configuratie toegevoegd aan .bashrc"
fi

# Zorg dat .bash_aliases geladen wordt vanuit .bashrc
if [ -f "$HOME/.bashrc" ] && ! grep -q "bash_aliases" "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" << 'EOF'

# Load custom aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF
  echo "dotfiles: .bash_aliases sourcing toegevoegd aan .bashrc"
fi

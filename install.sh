#!/bin/bash
# Coder workspace dotfiles installer
# Dit script wordt automatisch uitgevoerd bij het aanmaken/starten van een workspace

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

# Terminal titel instellen op Coder workspace naam
if [ -n "$CODER_WORKSPACE_NAME" ]; then
  PROMPT_COMMAND='echo -ne "\033]0;${CODER_WORKSPACE_NAME}\007"'
fi
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

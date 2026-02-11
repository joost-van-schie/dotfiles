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

# Voorkom dat Claude Code de terminal titel overschrijft (iTerm2 / ManicTime)
if [ -f "$HOME/.bashrc" ] && ! grep -q 'CLAUDE_CODE_DISABLE_TERMINAL_TITLE' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1' >> "$HOME/.bashrc"
  echo "dotfiles: Claude Code terminal titel uitgeschakeld in .bashrc"
fi

# Installeer ClickUp CLI als die er nog niet is
if [ ! -f "$HOME/bin/clickup" ]; then
  mkdir -p "$HOME/bin"
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
  elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
  fi
  curl -sL "https://github.com/fantasticrabbit/ClickupCLI/releases/download/v0.1.11/clickup_0.1.11_linux_${ARCH}.tar.gz" | tar xz -C "$HOME/bin"
  chmod +x "$HOME/bin/clickup"
  echo "dotfiles: ClickUp CLI geïnstalleerd in ~/bin"
else
  echo "dotfiles: ClickUp CLI al aanwezig"
fi

# ClickUp CLI config met API token
if [ ! -f "$HOME/.clickup/config.yaml" ]; then
  mkdir -p "$HOME/.clickup"
  cat > "$HOME/.clickup/config.yaml" << 'EOF'
port: "4321"
token: pk_212447676_DW9XU0JANFCIRPMPYNXWHD165FHI03CF
EOF
  echo "dotfiles: ClickUp config aangemaakt"
else
  echo "dotfiles: ClickUp config al aanwezig"
fi

# Installeer GitHub CLI als die er nog niet is
if ! command -v gh &>/dev/null; then
  mkdir -p "$HOME/bin"
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    GH_ARCH="amd64"
  elif [ "$ARCH" = "aarch64" ]; then
    GH_ARCH="arm64"
  fi
  GH_VERSION="2.67.0"
  curl -sL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${GH_ARCH}.tar.gz" | tar xz --strip-components=2 -C "$HOME/bin" "gh_${GH_VERSION}_linux_${GH_ARCH}/bin/gh"
  chmod +x "$HOME/bin/gh"
  echo "dotfiles: GitHub CLI geïnstalleerd in ~/bin"
else
  echo "dotfiles: GitHub CLI al aanwezig"
fi

# GitHub CLI authenticatie via persistent token bestand
if [ -f "$HOME/.bashrc" ] && ! grep -q 'GH_TOKEN' "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" << 'GHEOF'

# GitHub CLI token laden uit persistent bestand
if [ -f "$HOME/.gh_token" ]; then
  export GH_TOKEN=$(cat "$HOME/.gh_token")
fi
GHEOF
  echo "dotfiles: GH_TOKEN laden toegevoegd aan .bashrc"
fi
if [ ! -f "$HOME/.gh_token" ]; then
  echo "dotfiles: ACTIE NODIG - stel gh token in met: echo 'TOKEN' > ~/.gh_token"
fi

# Voeg ~/bin toe aan PATH als dat nog niet zo is
if [ -f "$HOME/.bashrc" ] && ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
  echo "dotfiles: ~/bin toegevoegd aan PATH"
fi

# Claude Code globale instructies
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"
cat > "$CLAUDE_MD" << 'EOF'
# Coder Workspace

## Taal
- Communiceer in het Nederlands

## ClickUp
- **Workspace ID:** 90152177083
- **Folder ID en List ID:** staan in de project-level CLAUDE.md
- **Statussen:** gebruik `complete` (NIET `done`) om een taak af te sluiten

## Git conventies
- Gebruik ALTIJD een ClickUp taaknummer in branch namen: `feature/VSS-<id>-korte-beschrijving`
- Gebruik ALTIJD een ClickUp taaknummer in commit messages: `VSS-<id> Beschrijving van de wijziging`
- Haal het taaknummer op uit de project CLAUDE.md of vraag het aan de gebruiker

## ClickUp CLI
De ClickUp CLI (`clickup`) is geïnstalleerd in `~/bin/clickup` met een geconfigureerde API token in `~/.clickup/config.yaml`.

### Gebruik
```bash
clickup get task TASK_ID          # Haal task data op (JSON)
clickup get list LIST_ID          # Haal list data op
clickup get lists FOLDER_ID       # Haal lists in een folder op
clickup get folderless-lists SPACE_ID  # Lists zonder folder
```

Alle output is JSON. Gebruik `jq` voor filtering en formatting.
EOF
echo "dotfiles: CLAUDE.md aangemaakt/bijgewerkt"

# Auto-cd naar project directory bij SSH login
if [ -f "$HOME/.bashrc" ] && ! grep -q "auto-cd" "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" << 'EOF'

# auto-cd naar project directory (workspace naam)
if [ -n "$CODER_WORKSPACE_NAME" ] && [ -d "$HOME/$CODER_WORKSPACE_NAME" ]; then
  cd "$HOME/$CODER_WORKSPACE_NAME"
fi
EOF
  echo "dotfiles: auto-cd naar project directory toegevoegd aan .bashrc"
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
